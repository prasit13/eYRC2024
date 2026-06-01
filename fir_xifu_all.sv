package fir_xifu_pkg;

  // Width of XIF ID field
  parameter int unsigned X_ID_WIDTH = 4;
  parameter int unsigned X_ID_MAX   = 2**X_ID_WIDTH;

  // inst[4:2]=110 [6:5]=10 [1:0]=11
  parameter logic [6:0] INSTR_OPCODE = 7'b1011011;

  // R type
  parameter logic [2:0] INSTR_XFIRDOTP_FUNCT3 = 3'b010;

  // I type
  parameter logic [2:0] INSTR_XFIRLW_FUNCT3 = 3'b000;

  // S type
  parameter logic [2:0] INSTR_XFIRSW_FUNCT3 = 3'b001;

  // useful only in EFCL SS exercise
  parameter logic [2:0] INSTR_PLACEHOLDER_FUNCT3 = 3'b000;

  function automatic logic [2:0] xifu_get_funct3(logic [31:0] in);
    logic [2:0] out;
    out = in[14:12];
    return out;
  endfunction

  function automatic logic [6:0] xifu_get_opcode(logic [31:0] in);
    logic [6:0] out;
    out = in[6:0];
    return out;
  endfunction

  function automatic logic [11:0] xifu_get_immediate_I(logic [31:0] in);
    logic [11:0] out;
    out = in[31:20];
    return out;
  endfunction

  function automatic logic [11:0] xifu_get_immediate_S(logic [31:0] in);
    logic [11:0] out;
    out = {in[31:25], in[11:7]};
    return out;
  endfunction

  function automatic logic [4:0] xifu_get_rs1(logic [31:0] in);
    logic [4:0] out;
    out = in[19:15];
    return out;
  endfunction

  function automatic logic [4:0] xifu_get_rs2(logic [31:0] in);
    logic [4:0] out;
    out = in[24:20];
    return out;
  endfunction

  function automatic logic [4:0] xifu_get_rd(logic [31:0] in);
    logic [4:0] out;
    out = in[11:7];
    return out;
  endfunction

  typedef enum logic[1:0] {
    INSTR_XFIRLW   = 2'b10,
    INSTR_XFIRSW   = 2'b11,
    INSTR_XFIRDOTP = 2'b01,
    INSTR_INVALID  = 2'b00
  } instr_t;
    
  typedef struct packed {
    instr_t instr;
    logic [31:0] base;
    logic [11:0] offset;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd; // also right_shift
    logic [X_ID_WIDTH-1:0] id;
  } id2ex_t;
    
  typedef struct packed {
    instr_t instr;
    logic [31:0] result;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic [X_ID_WIDTH-1:0] id;
  } ex2wb_t;

  typedef struct packed {
    logic [4:0]  rd;
    logic [31:0] result;
    logic       we;
  } wb_fwd_t;

  typedef struct packed {
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
  } ex2regfile_t;

  typedef struct packed {
    logic [31:0] op_a;
    logic [31:0] op_b;
    logic [31:0] op_c;
  } regfile2ex_t;

  typedef struct packed {
    logic [31:0] result;
    logic [4:0]  rd;
    logic        write;
  } wb2regfile_t;

  typedef struct packed {
    logic                  issue;
    logic [X_ID_WIDTH-1:0] id;
  } id2ctrl_t;

  typedef struct packed {
    logic [X_ID_MAX-1:0] commit;
  } ctrl2ex_t;

  typedef struct packed {
    logic [X_ID_MAX-1:0] clear;
  } wb2ctrl_t;

  typedef struct packed {
    logic [X_ID_MAX-1:0] issue;
    logic [X_ID_MAX-1:0] commit;
    logic [X_ID_MAX-1:0] kill;
  } ctrl2wb_t;

endpackage /* fir_xifu_pkg */











module fir_xifu_id
  import cv32e40x_pkg::*;
  import fir_xifu_pkg::*;
(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic clear_i,

  cv32e40x_if_xif.coproc_issue xif_issue_i,
  
  output id2ex_t   id2ex_o,

  output id2ctrl_t id2ctrl_o,

  input  wb_fwd_t wb_fwd_i,

  input  logic ready_i
);

  // Forwarding logic (TODO: move in controller?)
  logic forwarding;
  assign forwarding = wb_fwd_i.we & (wb_fwd_i.rd == xifu_get_rs1(xif_issue_i.issue_req.instr));

  // Back-prop ready: if the EX stage is ready to accept a new instruction,
  // then the XIFU can accept a new instruction to be issued/decoded.
  assign xif_issue_i.issue_ready = ready_i;

  // Decode XIFU-supported instructions: in this example, we support three
  // different instructions:
  //  - `xfirlw xrd, Imm(rs1)` is an I-format instruction moving a word from
  //    the address given by a base stored in the `rs1` register (in the 
  //    core reg. file) into the XIFU register `xrd`; this instruction also
  //    auto-increments `rs1` by the offset `Imm`.
  //  - `xfirsw Imm(rs1), xrs2` is an S-format instruction right-shifting
  //    a word from the XIFU register `xrs2` by `Imm[4:0]` (5 LSB of the
  //    immediate) and moving it into the address given by a base stored in
  //    the `rs1` register (in the core reg. file); this instruction also
  //    auto-increments `rs1` by the offset `Imm[11:5]` (7 MSB of the
  //    immediate).
  //  - `xfirdotp xrd, xrs1, xrs2` is an R-format instruction taking two words
  //    from the `xrs1`, `xrs2` XIFU registers and performing the dot-product
  //    between them considering them as int16 data vectors, and adding this
  //    to the value stored in `xrd`. The result is stored in `xrd` in int32
  //    format.
  // The following procedural block responds to the XIF issue request by
  //  1) decoding the instruction and ascertaining if it is supported or not;
  //     in that case, it is not accepted and the core raises an illegal
  //     instruction exception;
  //  2) reporting back whether the instruction is a load/store, whether it
  //     writes back to a core register, and other info (e.g., whether it
  //     can raise an exception), which here are omitted for simplicity.
  logic valid_instr;
  instr_t instr;
  always_comb
  begin
    xif_issue_i.issue_resp = '0;
    valid_instr = 1'b0;
    instr = INSTR_INVALID;
    if(xif_issue_i.issue_valid & (xifu_get_opcode(xif_issue_i.issue_req.instr) == INSTR_OPCODE)) begin
      unique case(xifu_get_funct3(xif_issue_i.issue_req.instr))
        INSTR_XFIRLW_FUNCT3 : begin
          xif_issue_i.issue_resp.accept = 1'b1;
          xif_issue_i.issue_resp.writeback = 1'b1;
          xif_issue_i.issue_resp.loadstore = 1'b1;
          valid_instr = 1'b1;
          instr = INSTR_XFIRLW;
        end
        INSTR_XFIRSW_FUNCT3 : begin
          xif_issue_i.issue_resp.accept = 1'b1;
          xif_issue_i.issue_resp.writeback = 1'b1;
          xif_issue_i.issue_resp.loadstore = 1'b1;
          valid_instr = 1'b1;
          instr = INSTR_XFIRSW;
        end
        INSTR_XFIRDOTP_FUNCT3 : begin
          xif_issue_i.issue_resp.accept = 1'b1;
          xif_issue_i.issue_resp.writeback = 1'b0;
          xif_issue_i.issue_resp.loadstore = 1'b0;
          valid_instr = 1'b1;
          instr = INSTR_XFIRDOTP;
        end
        default : begin
          xif_issue_i.issue_resp = '0;
          valid_instr = 1'b0;
          instr = INSTR_INVALID;
        end
      endcase
    end
  end

  // Save issue state in controller scoreboard: the XIFU needs to
  // keep track of instructions issued and retired as the core needs
  // to commit them via the XIF commit interface before they change the
  // architectural state. The controller contains a small scoreboard
  // designed for this purpose.
  assign id2ctrl_o.issue = valid_instr;
  assign id2ctrl_o.id    = xif_issue_i.issue_req.id;

  // ID/EX pipe stage: all the instruction information is saved and
  // passed along the pipeline. Contrarily to the CV32E40X pipeline, which
  // uses a valid/ready handshake, in this case we use only a ready signal.
  id2ex_t id2ex_d;
  logic [11:0] s_immediate;
  always_comb
  begin
    s_immediate = xifu_get_immediate_S(xif_issue_i.issue_req.instr);
  end

  always_comb
  begin
    id2ex_d = '0;
    if(instr != INSTR_INVALID) begin
      id2ex_d.base = ~forwarding ? xif_issue_i.issue_req.rs[0] : wb_fwd_i.result;
      if(instr == INSTR_XFIRSW) begin
        id2ex_d.offset = s_immediate[11:5] * 32'sh1; // * 32'sh1 == sign-extend
      end
      else begin
        id2ex_d.offset = xifu_get_immediate_I(xif_issue_i.issue_req.instr);
      end
      id2ex_d.instr = instr;
      id2ex_d.rs1 = xifu_get_rs1(xif_issue_i.issue_req.instr);
      id2ex_d.rs2 = xifu_get_rs2(xif_issue_i.issue_req.instr);
      id2ex_d.rd  = xifu_get_rd(xif_issue_i.issue_req.instr);
      id2ex_d.id  = xif_issue_i.issue_req.id;
    end
  end
  
  always_ff @(posedge clk_i, negedge rst_ni)
  begin
    if(~rst_ni) begin
      id2ex_o <= '0;
    end
    else if(clear_i) begin
      id2ex_o <= '0;
    end
    else if (ready_i) begin
      id2ex_o <= id2ex_d;
    end
  end

endmodule /* fir_xifu_id */




module fir_xifu_ex
  import cv32e40x_pkg::*;
  import fir_xifu_pkg::*; 
(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic clear_i,

  cv32e40x_if_xif.coproc_mem    xif_mem_o,
  
  input  id2ex_t   id2ex_i,
  output ex2wb_t   ex2wb_o,

  output ex2regfile_t ex2regfile_o,
  input  regfile2ex_t regfile2ex_i,

  input  ctrl2ex_t ctrl2ex_i,

  input  wb_fwd_t wb_fwd_i,

  input  logic ready_i,
  output logic ready_o
);

  // Forwarding logic (TODO: move in controller?)
  logic forwarding;
  assign forwarding = wb_fwd_i.we & (wb_fwd_i.rd == id2ex_i.rs1);

  // Compute addresses: this is used for load/store operations, which
  // need to compute the base+offset (with sign extension for the latter)
  // and also the updated address using postincrement.
  logic [31:0] next_addr, curr_addr; 
  assign curr_addr = ~forwarding ? id2ex_i.base : wb_fwd_i.result;
  assign next_addr = curr_addr + signed'(id2ex_i.offset + 32'sh0);
  
  // Issue memory transaction (load or store): currently this is issued
  // immediately for loads and only if a commit signal has arrived for
  // stores (typically in the same EX cycle, at least for CV32E40X).
  // The load/store operation is carried out by the core's LSU.
  always_comb
  begin
    xif_mem_o.mem_req   = '0;
    xif_mem_o.mem_valid = '0;
    if(id2ex_i.instr == INSTR_XFIRSW || id2ex_i.instr == INSTR_XFIRLW) begin
      if(id2ex_i.instr == INSTR_XFIRSW)
        xif_mem_o.mem_valid = ctrl2ex_i.commit[id2ex_i.id]; // do not issue memory requests for non-committed store
      else
        xif_mem_o.mem_valid = 1'b1;
      xif_mem_o.mem_req.id    = id2ex_i.id;
      xif_mem_o.mem_req.addr  = curr_addr;
      xif_mem_o.mem_req.we    = id2ex_i.instr == INSTR_XFIRSW;
      xif_mem_o.mem_req.size  = 3'b100;
      xif_mem_o.mem_req.be    = 4'b1111;
      xif_mem_o.mem_req.wdata = (regfile2ex_i.op_b >>> id2ex_i.rd) * 32'sh1; // the right-shift bits are encoded in Imm[4:0] in S-type, same as RD in R-type
      xif_mem_o.mem_req.last  = 1'b1;
    end
  end

  // Dot product calculation: here we split the operands, extracted from the register
  // file, into 16-bit signed operands and perform the dot-product operation.
  // We use operand gating to (potentially) save a bit of power at the cost of an
  // extra logic layer. Notice the usage of a signed neutral constant (32'sh1) to
  // make sure that the sign-extensions are performed properly.
  logic signed [1:0][15:0] dotp_op_a, dotp_op_b;
  logic signed [1:0][31:0] dotp_prod;
  logic signed [31:0] dotp_op_c, dotp_result;
  assign dotp_op_a = id2ex_i.instr == INSTR_XFIRDOTP ? signed'(regfile2ex_i.op_a) : '0;
  assign dotp_op_b = id2ex_i.instr == INSTR_XFIRDOTP ? signed'(regfile2ex_i.op_b) : '0;
  assign dotp_op_c = id2ex_i.instr == INSTR_XFIRDOTP ? signed'(regfile2ex_i.op_c) : '0;
  assign dotp_prod[0] = (signed'(dotp_op_a[0]) * 32'sh1) * (signed'(dotp_op_b[0]) * 32'sh1);
  assign dotp_prod[1] = (signed'(dotp_op_a[1]) * 32'sh1) * (signed'(dotp_op_b[1]) * 32'sh1);
  assign dotp_result = signed'(dotp_prod[0]) + signed'(dotp_prod[1]) + dotp_op_c;

  // EX/WB pipe stage
  ex2wb_t ex2wb_d;

  always_comb
  begin
    ex2wb_d = '0;
    ex2wb_d.result = id2ex_i.instr == INSTR_XFIRDOTP ? dotp_result : next_addr;
    ex2wb_d.rs1    = id2ex_i.rs1;
    ex2wb_d.rs2    = id2ex_i.rs2;
    ex2wb_d.rd     = id2ex_i.rd;
    ex2wb_d.instr  = id2ex_i.instr;
    ex2wb_d.id     = id2ex_i.id;
  end

  always_ff @(posedge clk_i, negedge rst_ni)
  begin
    if(~rst_ni) begin
      ex2wb_o <= '0;
    end
    else if(clear_i) begin
      ex2wb_o <= '0;
    end
    else if(ready_i) begin
      ex2wb_o <= ex2wb_d;
    end
  end

  // to regfile / XIFU reg file
  always_comb
  begin
    ex2regfile_o = '0;
    ex2regfile_o.rs1 = id2ex_i.rs1;
    ex2regfile_o.rs2 = id2ex_i.rs2;
    ex2regfile_o.rd  = id2ex_i.rd;
  end

  // backprop ready
  assign ready_o = ready_i;

endmodule /* fir_xifu_ex */


module fir_xifu_wb
  import cv32e40x_pkg::*;
  import fir_xifu_pkg::*; 
(
  input  logic clk_i,
  input  logic rst_ni,

  cv32e40x_if_xif.coproc_mem_result xif_mem_result_i,
  cv32e40x_if_xif.coproc_result     xif_result_o,
  
  input  ex2wb_t   ex2wb_i,

  output wb2regfile_t wb2regfile_o,

  output wb2ctrl_t wb2ctrl_o,
  input  ctrl2wb_t ctrl2wb_i,

  output wb_fwd_t wb_fwd_o,

  output logic kill_o,
  output logic ready_o
);

  // Extract all information on the current instruction status from
  // the scoreboard.
  // If an instruction is killed in WB, all the pipeline needs to be
  // cleared.
  logic commit, issue;
  assign issue  = ctrl2wb_i.issue [ex2wb_i.id];
  assign commit = ctrl2wb_i.commit[ex2wb_i.id];
  assign kill_o = ctrl2wb_i.kill  [ex2wb_i.id];
  
  // Set write-back data info for register-file.
  assign wb2regfile_o.result = ex2wb_i.instr == INSTR_XFIRLW   ? xif_mem_result_i.mem_result.rdata : ex2wb_i.result;
  assign wb2regfile_o.write  = ex2wb_i.instr == INSTR_XFIRLW || ex2wb_i.instr == INSTR_XFIRDOTP ? commit : 1'b0;
  assign wb2regfile_o.rd     = ex2wb_i.rd;

  // Save mem_result rdata
  logic [31:0] mem_result_rdata_q;
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      mem_result_rdata_q <= '0;
    end
    else if(xif_mem_result_i.mem_result_valid) begin
      mem_result_rdata_q <= xif_mem_result_i.mem_result.rdata;
    end
  end

  // Set flag when there is a valid result, clear if there is no valid result and there is a commit
  logic mem_result_valid_flag, mem_result_valid_q;
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      mem_result_valid_q <= '0;
    end
    else if(xif_mem_result_i.mem_result_valid) begin
      mem_result_valid_q <= 1'b1;
    end
    else if(commit) begin
      mem_result_valid_q <= 1'b0;
    end
  end
  assign mem_result_valid_flag = xif_mem_result_i.mem_result_valid | mem_result_valid_q;

  // update base address and signal instruction completion
  always_comb
  begin
    xif_result_o.result = '0;
    xif_result_o.result_valid = '0;
    wb2ctrl_o = '0;
    if(ex2wb_i.instr == INSTR_XFIRSW || ex2wb_i.instr == INSTR_XFIRLW) begin
      xif_result_o.result_valid   = mem_result_valid_flag;
      wb2ctrl_o.clear[ex2wb_i.id] = commit & mem_result_valid_flag;
    end
    else if(ex2wb_i.instr == INSTR_XFIRDOTP) begin
      xif_result_o.result_valid   = 1'b1;
      wb2ctrl_o.clear[ex2wb_i.id] = commit;
    end
    xif_result_o.result.id    = ex2wb_i.id;
    xif_result_o.result.data  = ex2wb_i.result; // post-increment
    xif_result_o.result.rd    = ex2wb_i.rs1;
    xif_result_o.result.we    = (ex2wb_i.instr == INSTR_XFIRSW || ex2wb_i.instr == INSTR_XFIRLW);
  end

  // Forward rd and result to EX stage
  assign wb_fwd_o.rd     = xif_result_o.result.rd;
  assign wb_fwd_o.result = xif_result_o.result.data;
  assign wb_fwd_o.we     = xif_result_o.result.we;

  // Back-prop ready: the only condition in which we are not ready is when the current id is issued but not committed yet
  assign ready_o = (issue & ~commit) && ex2wb_i.instr != INSTR_INVALID ? 1'b0 : 1'b1;

endmodule /* fir_xifu_wb */


module fir_xifu_ctrl
  import cv32e40x_pkg::*;
  import fir_xifu_pkg::*; 
(
  input  logic clk_i,
  input  logic rst_ni,

  cv32e40x_if_xif.coproc_commit     xif_commit_i,

  input  id2ctrl_t id2ctrl_i,
  output ctrl2ex_t ctrl2ex_o,
  input  wb2ctrl_t wb2ctrl_i,
  output ctrl2wb_t ctrl2wb_o
);

  // Mask commits that are repeated multiple times for the same ID.
  // The CV-XIF specs actually state that the commit arrives only once,
  // but CV32E40X sometimes generates multiple commits for the same ID.
  logic actual_commit;
  logic                  xif_commit_q;
  logic [X_ID_WIDTH-1:0] xif_id_q;
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      xif_commit_q <= '0;
      xif_id_q     <= '0;
    end
    else begin
      xif_commit_q <= xif_commit_i.commit_valid;
      xif_id_q     <= xif_commit_i.commit.id;
    end
  end
  assign actual_commit = (xif_id_q != xif_commit_i.commit.id) ? xif_commit_i.commit_valid : xif_commit_i.commit_valid & ~xif_commit_q;

  // Save issue/commit/kill status in a small scoreboard. Only actually issued instructions can be committed/killed!
  logic [X_ID_MAX-1:0] issue_d, issue_q;
  logic [X_ID_MAX-1:0] valid_d, valid_q;
  logic [X_ID_MAX-1:0] kill_d,  kill_q;
  for(genvar ii=0; ii<X_ID_MAX; ii++) begin
    assign issue_d[ii] = wb2ctrl_i.clear[ii]                             ? 1'b0 :
                         id2ctrl_i.issue && (id2ctrl_i.id == ii)         ? 1'b1 :
                         issue_q[ii];
    assign valid_d[ii] = wb2ctrl_i.clear[ii]                             ? 1'b0 :
                         actual_commit && (xif_commit_i.commit.id == ii) ? issue_q[ii] :
                         valid_q[ii];
    assign kill_d [ii] = wb2ctrl_i.clear[ii]                                                               ? 1'b0 :
                         actual_commit & xif_commit_i.commit.commit_kill && (xif_commit_i.commit.id == ii) ? issue_q[ii] :
                         valid_q[ii];
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      issue_q <= '0;
      valid_q <= '0;
      kill_q  <= '0;
    end
    else begin
      issue_q <= issue_d;
      valid_q <= valid_d;
      kill_q  <= kill_d;
    end
  end

  // commit *must* be registered, as it is used to generate a clear in WB
  assign ctrl2wb_o.issue  = issue_q;
  assign ctrl2wb_o.commit = valid_q;
  assign ctrl2wb_o.kill   = kill_q;

  // commit can be combinational in EX
  // TODO: check whether this is true; according to the architectural diagram
  //       in the XIF specs, commit arrives late in the ID stage, not early in the
  //       EX stage. This might impose a structural hazard in all store ops to
  //       avoid timing issues, which is quite annoying.
  assign ctrl2ex_o.commit = valid_d | valid_q & ~kill_q & ~kill_d;

endmodule /* fir_xifu_ctrl */



module fir_xifu_regfile 
  import fir_xifu_pkg::*; 
#(
  parameter int unsigned NB_REGS = 4
)
(
  input  logic clk_i,
  input  logic rst_ni,

  input  ex2regfile_t ex2regfile_i,
  output regfile2ex_t regfile2ex_o,
  input  wb2regfile_t wb2regfile_i
);
  
  logic [NB_REGS-1:0][31:0] regs_q;
  
  // 3 RF read ports in EX stage (three MUX networks) + bypassing logic
  logic [31:0] rf_op_a, rf_op_b, rf_op_c;
  assign rf_op_a = regs_q[ex2regfile_i.rs1[$clog2(NB_REGS)-1:0]];
  assign rf_op_b = regs_q[ex2regfile_i.rs2[$clog2(NB_REGS)-1:0]];
  assign rf_op_c = regs_q[ex2regfile_i.rd [$clog2(NB_REGS)-1:0]];
  assign regfile2ex_o.op_a = (wb2regfile_i.rd == ex2regfile_i.rs1) & wb2regfile_i.write ? wb2regfile_i.result : rf_op_a;
  assign regfile2ex_o.op_b = (wb2regfile_i.rd == ex2regfile_i.rs2) & wb2regfile_i.write ? wb2regfile_i.result : rf_op_b;
  assign regfile2ex_o.op_c = (wb2regfile_i.rd == ex2regfile_i.rd)  & wb2regfile_i.write ? wb2regfile_i.result : rf_op_c;

  // 1 RF write port in WB stage
  for(genvar ii=0; ii<NB_REGS; ii++) begin

    // the separate write_en allow for separate automatic clock-gating of the RF
    logic write_en;
    assign write_en = wb2regfile_i.write & (wb2regfile_i.rd == ii);

    always_ff @(posedge clk_i or negedge rst_ni)
    begin
      if(~rst_ni) begin
        regs_q[ii] <= '0;
      end 
      else if(write_en) begin
        regs_q[ii] <= wb2regfile_i.result;
      end
    end

  end

endmodule /* fir_xifu_regfile */



module fir_xifu_top
  import cv32e40x_pkg::*;
  import fir_xifu_pkg::*;
#(
  parameter int unsigned NB_REGS = 4
)
(
  input logic                       clk_i,
  input logic                       rst_ni,
  input logic                       clear_i,
  cv32e40x_if_xif.coproc_issue      xif_issue_i,
  cv32e40x_if_xif.coproc_compressed xif_compressed_i,
  cv32e40x_if_xif.coproc_commit     xif_commit_i,
  cv32e40x_if_xif.coproc_mem        xif_mem_o,
  cv32e40x_if_xif.coproc_mem_result xif_mem_result_i,
  cv32e40x_if_xif.coproc_result     xif_result_o
);

  logic clear;

  ex2regfile_t ex2regfile;
  regfile2ex_t regfile2ex;
  wb2regfile_t wb2regfile;

  id2ex_t id2ex;
  ex2wb_t ex2wb;

  id2ctrl_t id2ctrl;
  ctrl2ex_t ctrl2ex;
  wb2ctrl_t wb2ctrl;
  ctrl2wb_t ctrl2wb;

  wb_fwd_t wb_fwd;

  logic wb_ready, ex_ready;

  // CV32E40X does not currently support compressed XIF instructions
  assign xif_compressed_i.compressed_ready = 1'b1;
  assign xif_compressed_i.compressed_resp  = '0;

  fir_xifu_id i_id (
    .clk_i            ( clk_i       ),
    .rst_ni           ( rst_ni      ),
    .clear_i          ( clear       ),
    .xif_issue_i      ( xif_issue_i ),
    .id2ex_o          ( id2ex       ),
    .wb_fwd_i         ( wb_fwd      ),
    .id2ctrl_o        ( id2ctrl     ),
    .ready_i          ( ex_ready    )
  );

  fir_xifu_ex i_ex (
    .clk_i            ( clk_i      ),
    .rst_ni           ( rst_ni     ),
    .clear_i          ( clear      ),
    .xif_mem_o        ( xif_mem_o  ),
    .id2ex_i          ( id2ex      ),
    .ex2wb_o          ( ex2wb      ),
    .ex2regfile_o     ( ex2regfile ),
    .regfile2ex_i     ( regfile2ex ),
    .ctrl2ex_i        ( ctrl2ex    ),
    .wb_fwd_i         ( wb_fwd     ),
    .ready_o          ( ex_ready   ),
    .ready_i          ( wb_ready   )
  );

  fir_xifu_wb i_wb (
    .clk_i            ( clk_i            ),
    .rst_ni           ( rst_ni           ),
    .xif_mem_result_i ( xif_mem_result_i ),
    .xif_result_o     ( xif_result_o     ),
    .ex2wb_i          ( ex2wb            ),
    .wb2regfile_o     ( wb2regfile       ),
    .wb2ctrl_o        ( wb2ctrl          ),
    .ctrl2wb_i        ( ctrl2wb          ),
    .wb_fwd_o         ( wb_fwd           ),
    .ready_o          ( wb_ready         ),
    .kill_o           ( clear            )
  );

  fir_xifu_ctrl i_ctrl (
    .clk_i            ( clk_i        ),
    .rst_ni           ( rst_ni       ),
    .xif_commit_i     ( xif_commit_i ),
    .id2ctrl_i        ( id2ctrl      ),
    .ctrl2ex_o        ( ctrl2ex      ),
    .wb2ctrl_i        ( wb2ctrl      ),
    .ctrl2wb_o        ( ctrl2wb      )
  );
  
  fir_xifu_regfile #(
    .NB_REGS ( NB_REGS )
  )i_regfile (
    .clk_i            ( clk_i      ),
    .rst_ni           ( rst_ni     ),
    .ex2regfile_i     ( ex2regfile ),
    .regfile2ex_o     ( regfile2ex ),
    .wb2regfile_i     ( wb2regfile )
  );
  
endmodule /* fir_xifu_top */
