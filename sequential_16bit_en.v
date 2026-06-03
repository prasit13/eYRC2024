// Description: XIF coprocessor top-level, flattened pure-Verilog implementation.
//
// This single Verilog file replaces the following SystemVerilog sources:
//   xif_copro_pkg.sv, xif_copro_predecoder_pkg.sv, xif_copro_instr_pkg.sv,
//   xif_copro_controller.sv, xif_copro_decoder.sv, xif_copro_ex_stage.sv,
//   xif_copro_predecoder.sv, xif_copro_regfile.sv, fifo_v3.sv,
//   stream_fifo.sv and the internals of xif_copro.sv.
//
// All SystemVerilog-only constructs (interfaces, packages, structs, enums,
// typedefs, multidimensional packed arrays, 'logic', always_comb/always_ff,
// '0/'1 literals, unique/priority) have been removed so that the design is
// plain Verilog suitable for a FABulous eFPGA user design. The XIF interface
// signals are flattened into individual ports; the thin xif_copro.sv wrapper
// re-bundles them into the cv32e40x_if_xif SystemVerilog interface so that no
// changes are required in cv32e40x_tb_wrapper.
//
// Enumeration encodings (kept identical to xif_copro_pkg):
//   op_select : None=2'd0, RegA=2'd1, RegB=2'd2, CPU=2'd3
//   copro_op  : NONE=1'b0, BITREV=1'b1   (COPRO_OPERATION_BITS = $clog2(2) = 1)

// =============================================================================
// xif_copro_verilog : flattened coprocessor top level
// =============================================================================
module xif_copro_verilog #(
  parameter XLEN               = 32,
  parameter INPUT_BUFFER_DEPTH = 1,
  parameter FORWARDING         = 1
) (
  // Clock and Reset
  input  wire        clk_i,
  input  wire        rst_ni,

  // ---- Compressed interface (coproc_compressed) ----
  input  wire        compressed_valid_i,
  output wire        compressed_ready_o,
  output wire [31:0] compressed_resp_instr_o,
  output wire        compressed_resp_accept_o,

  // ---- Issue interface (coproc_issue) ----
  input  wire        issue_valid_i,
  output wire        issue_ready_o,
  input  wire [31:0] issue_req_instr_i,
  input  wire [1:0]  issue_req_mode_i,
  input  wire [3:0]  issue_req_id_i,
  input  wire [63:0] issue_req_rs_i,        // {rs[1], rs[0]}, X_NUM_RS*X_RFR_WIDTH
  input  wire [1:0]  issue_req_rs_valid_i,
  output wire        issue_resp_accept_o,
  output wire        issue_resp_writeback_o,
  output wire        issue_resp_dualwrite_o,
  output wire [2:0]  issue_resp_dualread_o,
  output wire        issue_resp_loadstore_o,
  output wire        issue_resp_ecswrite_o,
  output wire        issue_resp_exc_o,

  // ---- Commit interface (coproc_commit) ----
  input  wire        commit_valid_i,
  input  wire        commit_kill_i,
  input  wire [3:0]  commit_id_i,

  // ---- Memory request/response interface (coproc_mem) ----
  output wire        mem_valid_o,
  input  wire        mem_ready_i,
  output wire [3:0]  mem_req_id_o,
  output wire [1:0]  mem_req_mode_o,
  output wire        mem_req_we_o,
  output wire [2:0]  mem_req_size_o,
  output wire [3:0]  mem_req_be_o,         // X_MEM_WIDTH/8
  output wire [1:0]  mem_req_attr_o,
  output wire [31:0] mem_req_wdata_o,      // X_MEM_WIDTH
  output wire        mem_req_last_o,
  output wire        mem_req_spec_o,
  output wire [31:0] mem_req_addr_o,
  input  wire        mem_resp_exc_i,
  input  wire [5:0]  mem_resp_exccode_i,
  input  wire        mem_resp_dbg_i,

  // ---- Memory result interface (coproc_mem_result) ----
  input  wire        mem_result_valid_i,
  input  wire [31:0] mem_result_rdata_i,   // X_MEM_WIDTH
  input  wire        mem_result_err_i,
  input  wire        mem_result_dbg_i,

  // ---- Result interface (coproc_result) ----
  output wire        result_valid_o,
  input  wire        result_ready_i,
  output wire [3:0]  result_id_o,
  output wire [31:0] result_data_o,        // X_RFW_WIDTH
  output wire [4:0]  result_rd_o,
  output wire        result_we_o,          // X_RFW_WIDTH/XLEN = 1
  output wire [5:0]  result_ecsdata_o,
  output wire [2:0]  result_ecswe_o,
  output wire        result_exc_o,
  output wire [5:0]  result_exccode_o,
  output wire        result_err_o,
  output wire        result_dbg_o
);

  // ---------------------------------------------------------------------------
  // Local parameters (replacing xif_copro_pkg)
  // ---------------------------------------------------------------------------
  localparam X_NUM_RS    = 2;
  localparam X_ID_WIDTH  = 4;
  localparam X_RFR_WIDTH = 32;

  // op_select encodings
  localparam OP_NONE = 2'd0;
  localparam OP_REGA = 2'd1;
  localparam OP_REGB = 2'd2;
  localparam OP_CPU  = 2'd3;

  // copro_op encodings
  localparam CO_NONE   = 1'b0;
  localparam CO_BITREV = 1'b1;

  // Stream FIFO data widths (flattened struct widths)
  //   offloaded_data_t : {rs1[31:0], rs0[31:0], instr[31:0], id[3:0], mode[1:0]}
  localparam IN_FIFO_W  = 2*X_RFR_WIDTH + 32 + X_ID_WIDTH + 2; // 102
  //   mem_metadata_t   : {id[3:0], rd[4:0], we, exc, exccode[5:0], dbg}
  localparam MEM_FIFO_W = X_ID_WIDTH + 5 + 1 + 1 + 6 + 1;      // 18
  //   x_result_t       : {id[3:0], data[31:0], rd[4:0], we, ecsdata[5:0],
  //                       ecswe[2:0], exc, exccode[5:0], err, dbg}
  localparam RES_FIFO_W = X_ID_WIDTH + 32 + 5 + 1 + 6 + 3 + 1 + 6 + 1 + 1; // 60

  // ---------------------------------------------------------------------------
  // Internal nets
  // ---------------------------------------------------------------------------
  // Predecoder
  wire        prd_rsp_accept;
  wire        prd_rsp_loadstore;
  wire        prd_rsp_writeback;
  wire [1:0]  prd_rsp_use_gprs;

  // Decoder
  wire        dec_copro_op;
  wire [1:0]  dec_op_select_0;
  wire [1:0]  dec_op_select_1;
  wire        dec_rd_is_copro;
  wire        dec_use_copro;
  wire        dec_is_store;
  wire        dec_is_load;

  // Input buffer
  wire                  in_buf_push_valid;
  wire                  in_buf_push_ready;
  wire                  in_buf_pop_valid;
  wire                  in_buf_pop_ready;
  wire [IN_FIFO_W-1:0]  in_buf_push_data;
  wire [IN_FIFO_W-1:0]  in_buf_pop_data;

  // Input buffer pop fields (unpack)
  wire [31:0] pop_rs1   = in_buf_pop_data[IN_FIFO_W-1   : IN_FIFO_W-32];  // [101:70]
  wire [31:0] pop_rs0   = in_buf_pop_data[IN_FIFO_W-33  : IN_FIFO_W-64];  // [69:38]
  wire [31:0] pop_instr = in_buf_pop_data[IN_FIFO_W-65  : IN_FIFO_W-96];  // [37:6]
  wire [3:0]  pop_id    = in_buf_pop_data[5:2];
  wire [1:0]  pop_mode  = in_buf_pop_data[1:0];

  // Forwarding
  wire [X_NUM_RS-1:0] ex_fwd;
  wire [X_NUM_RS-1:0] lsu_fwd;

  // Operands and register file
  wire [XLEN-1:0]        operand0;
  wire [XLEN-1:0]        operand1;
  wire [X_RFR_WIDTH-1:0] copreg_operands_0;
  wire [X_RFR_WIDTH-1:0] copreg_operands_1;
  wire [4:0]             copreg_raddr_0;
  wire [4:0]             copreg_raddr_1;
  reg  [4:0]             copreg_wb_addr;
  reg  [X_RFR_WIDTH-1:0] copreg_wb_data;
  wire                   copreg_we;
  reg  [31:0]            offset;

  // Memory request
  reg  [31:0] mem_req_wdata_r;
  reg  [31:0] mem_req_addr_r;

  // Memory buffer
  wire                   mem_push_valid;
  wire                   mem_push_ready;
  wire                   mem_pop_ready;
  wire [MEM_FIFO_W-1:0]  mem_push_data;
  wire [MEM_FIFO_W-1:0]  mem_pop_data;

  // Memory buffer pop fields (unpack)
  wire [3:0] mem_pop_id      = mem_pop_data[MEM_FIFO_W-1 : MEM_FIFO_W-4]; // [17:14]
  wire [4:0] mem_pop_rd      = mem_pop_data[13:9];
  wire       mem_pop_we      = mem_pop_data[8];
  wire       mem_pop_exc     = mem_pop_data[7];
  wire [5:0] mem_pop_exccode = mem_pop_data[6:1];
  wire       mem_pop_dbg     = mem_pop_data[0];

  // Execution stage
  wire [3:0]      ex_tag_in_id;
  wire [4:0]      ex_tag_in_addr;
  wire            ex_tag_in_rd_is_copro;
  wire [3:0]      ex_tag_out_id;
  wire [4:0]      ex_tag_out_addr;
  wire            ex_tag_out_rd_is_copro;
  wire            ex_in_valid;
  wire            ex_in_ready;
  wire            ex_out_valid;
  wire            ex_out_ready;
  wire [XLEN-1:0] data_result;

  // Result buffer
  wire                  result_push_valid;
  wire                  result_pop_valid;
  reg  [RES_FIFO_W-1:0] result_push_data;
  wire [RES_FIFO_W-1:0] result_pop_data;

  // Result push fields
  wire [3:0]  rp_id      = mem_result_valid_i ? mem_pop_id : ex_tag_out_id;
  wire [31:0] rp_data    = data_result;
  wire [4:0]  rp_rd      = ex_tag_out_addr;
  wire        rp_exc     = mem_pop_exc;
  wire [5:0]  rp_exccode = mem_pop_exccode;
  wire        rp_dbg     = mem_pop_dbg | (mem_result_valid_i & mem_result_dbg_i);
  wire        rp_err     = mem_result_valid_i & mem_result_err_i;
  reg         rp_we;
  reg  [2:0]  rp_ecswe;
  reg  [5:0]  rp_ecsdata;

  // ==========
  // Compressed
  // ==========
  // Compressed instructions are not supported here.
  assign compressed_ready_o       = compressed_valid_i;
  assign compressed_resp_instr_o  = 32'b0;
  assign compressed_resp_accept_o = 1'b0;

  // ==========
  // Predecoder
  // ==========
  xcv_predecoder xcv_predecoder_i (
    .prd_req_instr_i    (issue_req_instr_i),
    .prd_rsp_accept_o   (prd_rsp_accept),
    .prd_rsp_loadstore_o(prd_rsp_loadstore),
    .prd_rsp_writeback_o(prd_rsp_writeback),
    .prd_rsp_use_gprs_o (prd_rsp_use_gprs)
  );

  // Issue response
  assign issue_resp_accept_o    = prd_rsp_accept;
  assign issue_resp_writeback_o = prd_rsp_writeback;
  assign issue_resp_dualwrite_o = 1'b0;
  assign issue_resp_dualread_o  = 3'b0;
  assign issue_resp_loadstore_o = prd_rsp_loadstore;
  assign issue_resp_ecswrite_o  = 1'b0;
  assign issue_resp_exc_o       = 1'b0;

  // =======
  // Decoder
  // =======
  xcv_decoder xcv_decoder_i (
    .instr_i      (pop_instr),
    .copro_op_o   (dec_copro_op),
    .op_select_0_o(dec_op_select_0),
    .op_select_1_o(dec_op_select_1),
    .rd_is_copro_o(dec_rd_is_copro),
    .use_copro_o  (dec_use_copro),
    .is_store_o   (dec_is_store),
    .is_load_o    (dec_is_load)
  );

  // =================
  // Input Stream FIFO
  // =================
  assign in_buf_push_valid = issue_valid_i & issue_ready_o & issue_resp_accept_o;

  // Only the X_NUM_RS least significant registers are used.
  assign in_buf_push_data = {issue_req_rs_i[63:32],   // rs[1]
                             issue_req_rs_i[31:0],     // rs[0]
                             issue_req_instr_i,
                             issue_req_id_i,
                             issue_req_mode_i};

  xcv_stream_fifo #(
    .FALL_THROUGH(1),
    .DATA_WIDTH  (IN_FIFO_W),
    .DEPTH       (INPUT_BUFFER_DEPTH)
  ) input_stream_fifo_i (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .flush_i   (1'b0),
    .testmode_i(1'b0),
    .usage_o   (),
    .data_i    (in_buf_push_data),
    .valid_i   (in_buf_push_valid),
    .ready_o   (in_buf_push_ready),
    .data_o    (in_buf_pop_data),
    .valid_o   (in_buf_pop_valid),
    .ready_i   (in_buf_pop_ready)
  );

  // =================================
  // Memory request/response interface
  // =================================
  assign mem_req_id_o    = pop_id;
  assign mem_req_mode_o  = pop_mode;
  assign mem_req_size_o  = 3'b010;  // 32-bit word
  assign mem_req_be_o    = 4'b1111;
  assign mem_req_attr_o  = 2'b00;
  assign mem_req_last_o  = 1'b1;
  assign mem_req_spec_o  = 1'b0;
  assign mem_req_wdata_o = mem_req_wdata_r;
  assign mem_req_addr_o  = mem_req_addr_r;

  // Write data mux
  always @(*) begin
    if (ex_fwd[1]) begin
      mem_req_wdata_r = data_result;
    end else if (lsu_fwd[1]) begin
      mem_req_wdata_r = mem_result_rdata_i;
    end else begin
      mem_req_wdata_r = copreg_operands_1;
    end
  end

  // Load/store address calculation
  always @(*) begin
    if (~mem_req_we_o) begin  // load: I-type immediate
      offset = {{20{pop_instr[31]}}, pop_instr[31:20]};
    end else begin            // store: S-type immediate
      offset = {{20{pop_instr[31]}}, pop_instr[31:25], pop_instr[11:7]};
    end
    mem_req_addr_r = pop_rs0 + offset;
  end

  // ==============================
  // Memory Instruction Stream FIFO
  // ==============================
  assign mem_push_data = {pop_id,              // id     [17:14]
                          pop_instr[11:7],     // rd     [13:9]
                          dec_is_load,         // we     [8]
                          mem_resp_exc_i,      // exc    [7]
                          mem_resp_exccode_i,  // exccode[6:1]
                          mem_resp_dbg_i};     // dbg    [0]

  xcv_stream_fifo #(
    .FALL_THROUGH(0),
    .DATA_WIDTH  (MEM_FIFO_W),
    .DEPTH       (3)
  ) mem_stream_fifo_i (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .flush_i   (1'b0),
    .testmode_i(1'b0),
    .usage_o   (),
    .data_i    (mem_push_data),
    .valid_i   (mem_push_valid),
    .ready_o   (mem_push_ready),
    .data_o    (mem_pop_data),
    .valid_o   (),
    .ready_i   (mem_pop_ready)
  );

  // ==========
  // Controller
  // ==========
  xcv_controller #(
    .FORWARDING(FORWARDING)
  ) xcv_controller_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // Predecoder
    .prd_rsp_use_gprs_i(prd_rsp_use_gprs),

    // Issue Interface
    .xif_issue_req_rs_valid_i(issue_req_rs_valid_i),
    .xif_issue_ready_o       (issue_ready_o),

    // Commit Interface
    .commit_valid_i(commit_valid_i),
    .commit_kill_i (commit_kill_i),
    .commit_id_i   (commit_id_i),

    // Input Buffer
    .in_buf_push_ready_i(in_buf_push_ready),
    .in_buf_pop_valid_i (in_buf_pop_valid),
    .in_buf_pop_ready_o (in_buf_pop_ready),

    // Register
    .rd_is_copro_i   (ex_tag_out_rd_is_copro),
    .ex_out_addr_i   (ex_tag_out_addr),
    .copreg_wb_addr_i(copreg_wb_addr),
    .rd_i            (pop_instr[11:7]),
    .copreg_we_o     (copreg_we),

    // Dependency Check and Forwarding
    .rd_in_is_copro_i(dec_rd_is_copro),
    .rs1_i           (copreg_raddr_0),
    .rs2_i           (copreg_raddr_1),
    .ex_fwd_o        (ex_fwd),
    .lsu_fwd_o       (lsu_fwd),
    .op_select_0_i   (dec_op_select_0),
    .op_select_1_i   (dec_op_select_1),

    // Memory Instruction
    .is_load_i (dec_is_load),
    .is_store_i(dec_is_store),

    // Memory Request/Response Interface
    .xif_mem_valid_o (mem_valid_o),
    .xif_mem_ready_i (mem_ready_i),
    .xif_mem_req_we_o(mem_req_we_o),
    .xif_mem_req_id_i(pop_id),

    // Memory Buffer
    .mem_push_valid_o (mem_push_valid),
    .mem_push_ready_i (mem_push_ready),
    .mem_pop_ready_o  (mem_pop_ready),
    .mem_pop_data_we_i(mem_pop_we),
    .mem_pop_data_rd_i(mem_pop_rd),

    // Memory Result Interface
    .xif_mem_result_valid_i(mem_result_valid_i),

    // Execution stage
    .use_copro_i   (dec_use_copro),
    .ex_in_valid_o (ex_in_valid),
    .ex_in_ready_i (ex_in_ready),
    .ex_in_id_i    (pop_id),
    .ex_out_valid_i(ex_out_valid),
    .ex_out_ready_o(ex_out_ready),

    // Result Interface
    .xif_result_valid_o (result_valid_o),
    .xif_result_id_i    (result_id_o),
    .result_push_valid_o(result_push_valid),
    .result_pop_valid_i (result_pop_valid)
  );

  // ============================
  // Coprocessor Register File
  // ============================
  assign copreg_raddr_0 = pop_instr[19:15];
  assign copreg_raddr_1 = pop_instr[24:20];

  // Writeback data mux
  always @(*) begin
    copreg_wb_data = data_result;
    if (mem_result_valid_i) begin
      copreg_wb_data = mem_result_rdata_i;
    end
  end

  // Writeback address mux
  always @(*) begin
    copreg_wb_addr = ex_tag_out_addr;
    if (mem_result_valid_i) begin
      copreg_wb_addr = mem_pop_rd;
    end else if (~dec_use_copro & ~ex_out_valid) begin
      copreg_wb_addr = pop_instr[11:7];
    end
  end

  xcv_regfile #(
    .DATA_WIDTH(X_RFR_WIDTH)
  ) xcv_regfile_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .raddr_0_i(copreg_raddr_0),
    .raddr_1_i(copreg_raddr_1),
    .rdata_0_o(copreg_operands_0),
    .rdata_1_o(copreg_operands_1),
    .waddr_i  (copreg_wb_addr),
    .wdata_i  (copreg_wb_data),
    .we_i     (copreg_we)
  );

  // =================
  // Operand Selection
  // =================
  // operand 0
  reg [XLEN-1:0] operand0_r;
  always @(*) begin
    case (dec_op_select_0)
      OP_CPU: begin
        if (ex_fwd[0]) operand0_r = data_result;
        else           operand0_r = pop_rs0; // X_RFR_WIDTH == XLEN
      end
      OP_REGA, OP_REGB: begin
        if (ex_fwd[0] & (dec_copro_op != CO_NONE)) begin
          operand0_r = data_result;
        end else if (lsu_fwd[0] & (dec_copro_op != CO_NONE)) begin
          operand0_r = mem_result_rdata_i;
        end else begin
          operand0_r = copreg_operands_0;
        end
      end
      default: operand0_r = {XLEN{1'b1}};
    endcase
  end
  assign operand0 = operand0_r;

  // operand 1
  reg [XLEN-1:0] operand1_r;
  always @(*) begin
    case (dec_op_select_1)
      OP_CPU: begin
        if (ex_fwd[1]) operand1_r = data_result;
        else           operand1_r = pop_rs1;
      end
      OP_REGA, OP_REGB: begin
        if (ex_fwd[1] & (dec_copro_op != CO_NONE)) begin
          operand1_r = data_result;
        end else if (lsu_fwd[1] & (dec_copro_op != CO_NONE)) begin
          operand1_r = mem_result_rdata_i;
        end else begin
          operand1_r = copreg_operands_1;
        end
      end
      default: operand1_r = {XLEN{1'b1}};
    endcase
  end
  assign operand1 = operand1_r;

  // ===============
  // Execution stage
  // ===============
  assign ex_tag_in_addr        = pop_instr[11:7];  // rd
  assign ex_tag_in_rd_is_copro = dec_rd_is_copro;
  assign ex_tag_in_id          = pop_id;

  xcv_ex_stage #(
    .XLEN(XLEN)
  ) xcv_ex_stage_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .operand_a_i(operand0),
    .operand_b_i(operand1),
    .operator_i (dec_copro_op),
    .tag_id_i         (ex_tag_in_id),
    .tag_addr_i       (ex_tag_in_addr),
    .tag_rd_is_copro_i(ex_tag_in_rd_is_copro),

    .in_valid_i (ex_in_valid),
    .in_ready_o (ex_in_ready),
    .out_valid_o(ex_out_valid),
    .out_ready_i(ex_out_ready),

    .tag_id_o         (ex_tag_out_id),
    .tag_addr_o       (ex_tag_out_addr),
    .tag_rd_is_copro_o(ex_tag_out_rd_is_copro),
    .result_o         (data_result)
  );

  // ========================
  // Result Interface Signals
  // ========================
  always @(*) begin
    rp_we = 1'b0;
    if (ex_out_valid & ~ex_tag_out_rd_is_copro) begin
      rp_we = 1'b1;
    end
  end

  always @(*) begin
    rp_ecswe   = 3'b0;
    rp_ecsdata = 6'b0;
    if (ex_out_valid & ex_tag_out_rd_is_copro) begin
      rp_ecswe   = 3'b010;
      rp_ecsdata = 6'b001100;
    end
  end

  always @(*) begin
    result_push_data = {rp_id,        // [59:56]
                        rp_data,       // [55:24]
                        rp_rd,         // [23:19]
                        rp_we,         // [18]
                        rp_ecsdata,    // [17:12]
                        rp_ecswe,      // [11:9]
                        rp_exc,        // [8]
                        rp_exccode,    // [7:2]
                        rp_err,        // [1]
                        rp_dbg};       // [0]
  end

  xcv_stream_fifo #(
    .FALL_THROUGH(1),
    .DATA_WIDTH  (RES_FIFO_W),
    .DEPTH       (1)
  ) result_fifo_i (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .flush_i   (1'b0),
    .testmode_i(1'b0),
    .usage_o   (),
    .data_i    (result_push_data),
    .valid_i   (result_push_valid),
    .ready_o   (),
    .data_o    (result_pop_data),
    .valid_o   (result_pop_valid),
    .ready_i   (result_ready_i)
  );

  // Result pop fields (unpack to flattened result interface)
  assign result_id_o      = result_pop_data[RES_FIFO_W-1 : RES_FIFO_W-4]; // [59:56]
  assign result_data_o    = result_pop_data[55:24];
  assign result_rd_o      = result_pop_data[23:19];
  assign result_we_o      = result_pop_data[18];
  assign result_ecsdata_o = result_pop_data[17:12];
  assign result_ecswe_o   = result_pop_data[11:9];
  assign result_exc_o     = result_pop_data[8];
  assign result_exccode_o = result_pop_data[7:2];
  assign result_err_o     = result_pop_data[1];
  assign result_dbg_o     = result_pop_data[0];

endmodule


// =============================================================================
// xcv_predecoder : decides whether an offloaded instruction is accepted
//   (NUM_INSTR == 1, single BITREV entry)
// =============================================================================
module xcv_predecoder (
  input  wire [31:0] prd_req_instr_i,
  output wire        prd_rsp_accept_o,
  output wire        prd_rsp_loadstore_o,
  output wire        prd_rsp_writeback_o,
  output wire [1:0]  prd_rsp_use_gprs_o
);
  // OFFLOAD_INSTR[0] : BITREV
  localparam [31:0] BITREV_INSTR = 32'b00000_10_00000_00000_111_00000_0101011;
  localparam [31:0] BITREV_MASK  = 32'b11111_11_00000_00000_111_00000_1111111;

  wire instr_sel = ((BITREV_MASK & prd_req_instr_i) == BITREV_INSTR);

  assign prd_rsp_accept_o    = instr_sel ? 1'b1  : 1'b0;
  assign prd_rsp_writeback_o = instr_sel ? 1'b1  : 1'b0;
  assign prd_rsp_loadstore_o = instr_sel ? 1'b0  : 1'b0;
  assign prd_rsp_use_gprs_o  = instr_sel ? 2'b01 : 2'b00;
endmodule


// =============================================================================
// xcv_decoder : decodes the popped instruction
// =============================================================================
module xcv_decoder (
  input  wire [31:0] instr_i,
  output reg         copro_op_o,     // NONE=0, BITREV=1
  output reg  [1:0]  op_select_0_o,
  output reg  [1:0]  op_select_1_o,
  output reg         rd_is_copro_o,
  output reg         use_copro_o,
  output reg         is_store_o,
  output reg         is_load_o
);
  localparam CO_NONE   = 1'b0;
  localparam CO_BITREV = 1'b1;
  localparam OP_NONE   = 2'd0;
  localparam OP_CPU    = 2'd3;

  always @(*) begin
    copro_op_o    = CO_NONE;
    use_copro_o   = 1'b1;
    op_select_0_o = OP_NONE;
    op_select_1_o = OP_NONE;
    is_store_o    = 1'b0;
    is_load_o     = 1'b0;
    rd_is_copro_o = 1'b0;

    casez (instr_i)
      // BITREV
      32'b00000_10_?????_?????_111_?????_0101011: begin
        copro_op_o    = CO_BITREV;
        op_select_0_o = OP_CPU;
      end
      default: begin
        use_copro_o = 1'b0;
      end
    endcase
  end
endmodule


// =============================================================================
// xcv_controller : coprocessor controller (flattened)
// =============================================================================
module xcv_controller #(
  parameter FORWARDING = 1
) (
  input  wire       clk_i,
  input  wire       rst_ni,

  // Predecoder
  input  wire [1:0] prd_rsp_use_gprs_i,

  // Issue Interface
  input  wire [1:0] xif_issue_req_rs_valid_i,
  output wire       xif_issue_ready_o,

  // Commit Interface
  input  wire       commit_valid_i,
  input  wire       commit_kill_i,
  input  wire [3:0] commit_id_i,

  // Input Buffer
  input  wire       in_buf_push_ready_i,
  input  wire       in_buf_pop_valid_i,
  output reg        in_buf_pop_ready_o,

  // Register
  input  wire       rd_is_copro_i,
  input  wire [4:0] ex_out_addr_i,
  input  wire [4:0] copreg_wb_addr_i,
  input  wire [4:0] rd_i,
  output reg        copreg_we_o,

  // Dependency Check and Forwarding
  input  wire       rd_in_is_copro_i,
  input  wire [4:0] rs1_i,
  input  wire [4:0] rs2_i,
  output reg  [1:0] ex_fwd_o,
  output reg  [1:0] lsu_fwd_o,
  input  wire [1:0] op_select_0_i,
  input  wire [1:0] op_select_1_i,

  // Memory Instruction
  input  wire       is_load_i,
  input  wire       is_store_i,

  // Memory Request/Response Interface
  output reg        xif_mem_valid_o,
  input  wire       xif_mem_ready_i,
  output wire       xif_mem_req_we_o,
  input  wire [3:0] xif_mem_req_id_i,

  // Memory Buffer
  output wire       mem_push_valid_o,
  input  wire       mem_push_ready_i,
  output wire       mem_pop_ready_o,
  input  wire       mem_pop_data_we_i,
  input  wire [4:0] mem_pop_data_rd_i,

  // Memory Result Interface
  input  wire       xif_mem_result_valid_i,

  // Execution stage
  input  wire       use_copro_i,
  output wire       ex_in_valid_o,
  input  wire       ex_in_ready_i,
  input  wire [3:0] ex_in_id_i,
  input  wire       ex_out_valid_i,
  output wire       ex_out_ready_o,

  // Result Interface
  output wire       xif_result_valid_o,
  input  wire [3:0] xif_result_id_i,
  output wire       result_push_valid_o,
  input  wire       result_pop_valid_i
);
  localparam OP_REGA = 2'd1;
  localparam OP_REGB = 2'd2;

  // Dependency check and forwarding
  wire dep_rs1;
  wire dep_rs2;
  wire dep_rs;
  wire dep_rd;
  wire vo0;  // valid_operands[0]
  wire vo1;  // valid_operands[1]

  // Handshakes
  wire ex_in_hs;
  wire ex_out_hs;
  wire x_mem_req_hs;

  // Status signals and scoreboards
  reg         instr_inflight;
  reg  [31:0] rd_scoreboard_d;
  reg  [31:0] rd_scoreboard_q;
  reg  [15:0] commit_scoreboard_d;   // 2**X_ID_WIDTH = 16
  reg  [15:0] commit_scoreboard_q;

  // ===============
  // Issue Interface
  // ===============
  assign xif_issue_ready_o = ((prd_rsp_use_gprs_i[0] & xif_issue_req_rs_valid_i[0])
                              | !prd_rsp_use_gprs_i[0])
                           & ((prd_rsp_use_gprs_i[1] & xif_issue_req_rs_valid_i[1])
                              | !prd_rsp_use_gprs_i[1])
                           & in_buf_push_ready_i;

  // ============
  // Input Buffer
  // ============
  always @(*) begin
    in_buf_pop_ready_o = 1'b0;
    if (ex_in_hs | x_mem_req_hs) begin
      in_buf_pop_ready_o = 1'b1;
    end
  end

  // =========================
  // Coprocessor Register File
  // =========================
  always @(*) begin
    copreg_we_o = 1'b0;
    if ((ex_out_hs & rd_is_copro_i) | (mem_pop_data_we_i & xif_mem_result_valid_i)) begin
      copreg_we_o = 1'b1;
    end
  end

  // ===============================
  // Dependency Check and Forwarding
  // ===============================
  assign dep_rs1 = rd_scoreboard_q[rs1_i] & in_buf_pop_valid_i & (op_select_0_i == OP_REGA);
  assign dep_rs2 = rd_scoreboard_q[rs2_i] & in_buf_pop_valid_i & (op_select_1_i == OP_REGB);
  assign dep_rs  = (dep_rs1 & ~(ex_fwd_o[0] | lsu_fwd_o[0]))
                 | (dep_rs2 & ~(ex_fwd_o[1] | lsu_fwd_o[1]));
  assign dep_rd  = rd_scoreboard_q[rd_i] & rd_in_is_copro_i
                 & ~((ex_out_hs | xif_mem_result_valid_i)
                     & copreg_we_o & (copreg_wb_addr_i == rd_i));

  assign vo0 = (op_select_0_i == OP_REGA);
  assign vo1 = (op_select_1_i == OP_REGB);

  always @(*) begin
    ex_fwd_o[0]  = 1'b0;
    ex_fwd_o[1]  = 1'b0;
    lsu_fwd_o[0] = 1'b0;
    lsu_fwd_o[1] = 1'b0;
    if (FORWARDING) begin
      ex_fwd_o[0] = vo0 & ex_out_hs & rd_is_copro_i & (rs1_i == ex_out_addr_i);
      ex_fwd_o[1] = vo1 & ex_out_hs & rd_is_copro_i & (rs2_i == ex_out_addr_i);

      lsu_fwd_o[0] = vo0 & xif_mem_result_valid_i & mem_pop_data_we_i
                   & (rs1_i == mem_pop_data_rd_i);
      lsu_fwd_o[1] = vo1 & xif_mem_result_valid_i & mem_pop_data_we_i
                   & (rs2_i == mem_pop_data_rd_i);
    end
  end

  // ==================================
  // Memory Interface and Memory Buffer
  // ==================================
  assign x_mem_req_hs = xif_mem_valid_o & xif_mem_ready_i;

  assign mem_push_valid_o = x_mem_req_hs;
  assign mem_pop_ready_o  = xif_mem_result_valid_i;

  always @(*) begin
    xif_mem_valid_o = 1'b0;
    if ((is_load_i | is_store_i) & ~dep_rs & ~dep_rd & in_buf_pop_valid_i & mem_push_ready_i
        & (commit_scoreboard_q[xif_mem_req_id_i] | commit_scoreboard_d[xif_mem_req_id_i])) begin
      xif_mem_valid_o = 1'b1;
    end
  end

  assign xif_mem_req_we_o = is_store_i;

  // ===============
  // Execution Stage
  // ===============
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      instr_inflight <= 1'b0;
    end else if (ex_in_hs) begin
      instr_inflight <= 1'b1;
    end else if (ex_out_hs) begin
      instr_inflight <= 1'b0;
    end
  end

  assign ex_in_hs  = ex_in_valid_o & ex_in_ready_i;
  assign ex_out_hs = ex_out_valid_i & ex_out_ready_o;

  assign ex_out_ready_o = ~xif_mem_result_valid_i;

  assign ex_in_valid_o = use_copro_i & in_buf_pop_valid_i
                       & (commit_scoreboard_q[ex_in_id_i] | commit_scoreboard_d[ex_in_id_i])
                       & ~dep_rs & ~dep_rd
                       & (ex_out_valid_i | ~instr_inflight);

  // ================
  // Result Interface
  // ================
  assign xif_result_valid_o  = ex_out_valid_i | xif_mem_result_valid_i | result_pop_valid_i;
  assign result_push_valid_o = ex_out_hs | xif_mem_result_valid_i;

  // =============================
  // Status Signals and Scoreboard
  // =============================
  always @(*) begin
    rd_scoreboard_d = rd_scoreboard_q;

    if ((ex_in_hs & rd_in_is_copro_i) | (x_mem_req_hs & is_load_i & in_buf_pop_valid_i)) begin
      rd_scoreboard_d[rd_i] = 1'b1;
    end

    if (ex_out_hs & ~(ex_in_hs & (copreg_wb_addr_i == rd_i))) begin
      rd_scoreboard_d[copreg_wb_addr_i] = 1'b0;
    end else if (xif_mem_result_valid_i & mem_pop_data_we_i
                 & ~(ex_in_hs & rd_in_is_copro_i & (mem_pop_data_rd_i == rd_i))) begin
      rd_scoreboard_d[mem_pop_data_rd_i] = 1'b0;
    end
  end

  always @(*) begin
    commit_scoreboard_d = commit_scoreboard_q;
    if (commit_valid_i & ~commit_kill_i) begin
      commit_scoreboard_d[commit_id_i] = 1'b1;
    end
    if (xif_result_valid_o) begin
      commit_scoreboard_d[xif_result_id_i] = 1'b0;
    end
  end

  always @(posedge clk_i) begin
    if (~rst_ni) begin
      rd_scoreboard_q     <= 32'b0;
      commit_scoreboard_q <= 16'b0;
    end else begin
      rd_scoreboard_q     <= rd_scoreboard_d;
      commit_scoreboard_q <= commit_scoreboard_d;
    end
  end
endmodule


// =============================================================================
// xcv_regfile : coprocessor register file (32 entries, 2R/1W)
// =============================================================================
module xcv_regfile #(
  parameter DATA_WIDTH = 32
) (
  input  wire                  clk_i,
  input  wire                  rst_ni,
  input  wire [4:0]            raddr_0_i,
  input  wire [4:0]            raddr_1_i,
  output reg  [DATA_WIDTH-1:0] rdata_0_o,
  output reg  [DATA_WIDTH-1:0] rdata_1_o,
  input  wire [4:0]            waddr_i,
  input  wire [DATA_WIDTH-1:0] wdata_i,
  input  wire                  we_i
);
  localparam NUM_WORDS = 32;

  reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];
  integer i;

  always @(posedge clk_i) begin
    if (~rst_ni) begin
      for (i = 0; i < NUM_WORDS; i = i + 1) begin
        mem[i] <= {DATA_WIDTH{1'b0}};
      end
    end else if (we_i) begin
      mem[waddr_i] <= wdata_i;
    end
  end

  always @(*) begin
    rdata_0_o = mem[raddr_0_i];
    rdata_1_o = mem[raddr_1_i];
  end
endmodule


// =============================================================================
// xcv_ex_stage : coprocessor execution stage (bit-reverse)
//   tag : {id[3:0], addr[4:0], rd_is_copro}
// =============================================================================
module xcv_ex_stage #(
  parameter XLEN = 32
) (
  input  wire            clk_i,
  input  wire            rst_ni,

  // Input signals
  input  wire [XLEN-1:0] operand_a_i,
  input  wire [XLEN-1:0] operand_b_i,
  input  wire            operator_i,    // NONE=0, BITREV=1
  input  wire [3:0]      tag_id_i,
  input  wire [4:0]      tag_addr_i,
  input  wire            tag_rd_is_copro_i,

  // Handshakes
  input  wire            in_valid_i,
  output wire            in_ready_o,
  output wire            out_valid_o,
  input  wire            out_ready_i,

  // Output signals
  output reg  [3:0]      tag_id_o,
  output reg  [4:0]      tag_addr_o,
  output reg             tag_rd_is_copro_o,
  output reg  [XLEN-1:0] result_o
);
  localparam CO_NONE   = 1'b0;
  localparam CO_BITREV = 1'b1;

  // Data signals
  reg [XLEN-1:0] bitrev_result;

  // Register signals
  reg [XLEN-1:0] operand_a;
  reg [XLEN-1:0] operand_b;
  reg            operator;

  // Handshakes
  wire input_hs;
  wire output_hs;

  // Control
  reg       instr_in_flight;
  reg [3:0] latency_d;
  reg [3:0] latency_q;

  integer i;

  assign input_hs  = in_valid_i & in_ready_o;
  assign output_hs = out_valid_o & out_ready_i;

  // Bit reverse operation
  always @(*) begin
    case (operator)
      CO_BITREV: begin
        bitrev_result = {XLEN{1'b0}};
        for (i = 0; i < XLEN; i = i + 1) begin
          bitrev_result[i] = operand_a[XLEN-1-i];
        end
      end
      default: begin
        bitrev_result = {XLEN{1'b0}};
      end
    endcase
  end

  // Result output
  always @(*) begin
    result_o = {XLEN{1'b0}};
    case (operator)
      CO_BITREV: result_o = bitrev_result;
      default:   result_o = {XLEN{1'b0}};
    endcase
  end

  // Instruction in flight
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      instr_in_flight <= 1'b0;
    end else if (input_hs) begin
      instr_in_flight <= 1'b1;
    end else if (output_hs) begin
      instr_in_flight <= 1'b0;
    end
  end

  assign in_ready_o  = ~instr_in_flight | output_hs;
  assign out_valid_o = instr_in_flight & (latency_q == 4'd0);

  // Input register (with handshake enable)
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      operand_a         <= {XLEN{1'b0}};
      operand_b         <= {XLEN{1'b0}};
      operator          <= CO_NONE;
      tag_id_o          <= 4'b0;
      tag_addr_o        <= 5'b0;
      tag_rd_is_copro_o <= 1'b0;
    end else if (input_hs) begin
      operand_a         <= operand_a_i;
      operand_b         <= operand_b_i;
      operator          <= operator_i;
      tag_id_o          <= tag_id_i;
      tag_addr_o        <= tag_addr_i;
      tag_rd_is_copro_o <= tag_rd_is_copro_i;
    end else if (output_hs) begin
      operand_a         <= {XLEN{1'b0}};
      operand_b         <= {XLEN{1'b0}};
      operator          <= CO_NONE;
      tag_id_o          <= 4'b0;
      tag_addr_o        <= 5'b0;
      tag_rd_is_copro_o <= 1'b0;
    end
  end

  // Latency calculation (BITREV is single cycle -> latency 0)
  always @(*) begin
    latency_d = 4'b0000;
    case (operator)
      CO_BITREV: latency_d = 4'b0000;
      default:   latency_d = 4'b0000;
    endcase
  end

  always @(posedge clk_i) begin
    if (~rst_ni) begin
      latency_q <= 4'd0;
    end else if (input_hs) begin
      latency_q <= latency_d;
    end else if (latency_q > 4'd0) begin
      latency_q <= latency_q - 4'd1;
    end
  end
endmodule


// =============================================================================
// xcv_stream_fifo : ready/valid wrapper around xcv_fifo_v3
// =============================================================================
module xcv_stream_fifo #(
  parameter FALL_THROUGH = 1'b0,
  parameter DATA_WIDTH   = 32,
  parameter DEPTH        = 8,
  parameter ADDR_DEPTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
  input  wire                  clk_i,
  input  wire                  rst_ni,
  input  wire                  flush_i,
  input  wire                  testmode_i,
  output wire [ADDR_DEPTH-1:0] usage_o,
  // input interface
  input  wire [DATA_WIDTH-1:0] data_i,
  input  wire                  valid_i,
  output wire                  ready_o,
  // output interface
  output wire [DATA_WIDTH-1:0] data_o,
  output wire                  valid_o,
  input  wire                  ready_i
);
  wire push, pop;
  wire empty, full;

  assign push    = valid_i & ~full;
  assign pop     = ready_i & ~empty;
  assign ready_o = ~full;
  assign valid_o = ~empty;

  xcv_fifo_v3 #(
    .FALL_THROUGH(FALL_THROUGH),
    .DATA_WIDTH  (DATA_WIDTH),
    .DEPTH       (DEPTH)
  ) fifo_i (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .flush_i   (flush_i),
    .testmode_i(testmode_i),
    .full_o    (full),
    .empty_o   (empty),
    .usage_o   (usage_o),
    .data_i    (data_i),
    .push_i    (push),
    .data_o    (data_o),
    .pop_i     (pop)
  );
endmodule


// =============================================================================
// xcv_fifo_v3 : generic synchronous FIFO (flattened data, DEPTH > 0)
// =============================================================================
module xcv_fifo_v3 #(
  parameter FALL_THROUGH = 1'b0,
  parameter DATA_WIDTH   = 32,
  parameter DEPTH        = 8,
  parameter ADDR_DEPTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
  input  wire                  clk_i,
  input  wire                  rst_ni,
  input  wire                  flush_i,
  input  wire                  testmode_i,
  // status flags
  output wire                  full_o,
  output wire                  empty_o,
  output wire [ADDR_DEPTH-1:0] usage_o,
  // push
  input  wire [DATA_WIDTH-1:0] data_i,
  input  wire                  push_i,
  // pop
  output reg  [DATA_WIDTH-1:0] data_o,
  input  wire                  pop_i
);
  localparam FIFO_DEPTH = (DEPTH > 0) ? DEPTH : 1;

  reg  [ADDR_DEPTH-1:0] read_pointer_n,  read_pointer_q;
  reg  [ADDR_DEPTH-1:0] write_pointer_n, write_pointer_q;
  reg  [ADDR_DEPTH:0]   status_cnt_n,    status_cnt_q;

  reg  [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
  integer i;

  assign usage_o  = status_cnt_q[ADDR_DEPTH-1:0];
  assign full_o   = (status_cnt_q == FIFO_DEPTH[ADDR_DEPTH:0]);
  assign empty_o  = (status_cnt_q == 0) & ~(FALL_THROUGH & push_i);

  // Pointer / counter next-state
  always @(*) begin
    read_pointer_n  = read_pointer_q;
    write_pointer_n = write_pointer_q;
    status_cnt_n    = status_cnt_q;

    // push
    if (push_i && ~full_o) begin
      if (write_pointer_q == FIFO_DEPTH[ADDR_DEPTH-1:0] - 1)
        write_pointer_n = {ADDR_DEPTH{1'b0}};
      else
        write_pointer_n = write_pointer_q + 1'b1;
      status_cnt_n = status_cnt_q + 1'b1;
    end

    // pop
    if (pop_i && ~empty_o) begin
      if (read_pointer_q == FIFO_DEPTH[ADDR_DEPTH-1:0] - 1)
        read_pointer_n = {ADDR_DEPTH{1'b0}};
      else
        read_pointer_n = read_pointer_q + 1'b1;
      status_cnt_n = status_cnt_q - 1'b1;
    end

    // simultaneous push and pop keeps the count
    if (push_i && pop_i && ~full_o && ~empty_o)
      status_cnt_n = status_cnt_q;

    // fall-through: pass straight through without storing
    if (FALL_THROUGH && (status_cnt_q == 0) && push_i && pop_i) begin
      status_cnt_n    = status_cnt_q;
      read_pointer_n  = read_pointer_q;
      write_pointer_n = write_pointer_q;
    end
  end

  // Output data (with fall-through bypass)
  always @(*) begin
    if (FALL_THROUGH && (status_cnt_q == 0) && push_i)
      data_o = data_i;
    else
      data_o = mem[read_pointer_q];
  end

  // Pointer / counter registers
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      read_pointer_q  <= {ADDR_DEPTH{1'b0}};
      write_pointer_q <= {ADDR_DEPTH{1'b0}};
      status_cnt_q    <= {(ADDR_DEPTH+1){1'b0}};
    end else if (flush_i) begin
      read_pointer_q  <= {ADDR_DEPTH{1'b0}};
      write_pointer_q <= {ADDR_DEPTH{1'b0}};
      status_cnt_q    <= {(ADDR_DEPTH+1){1'b0}};
    end else begin
      read_pointer_q  <= read_pointer_n;
      write_pointer_q <= write_pointer_n;
      status_cnt_q    <= status_cnt_n;
    end
  end

  // Memory
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
        mem[i] <= {DATA_WIDTH{1'b0}};
      end
    end else if (push_i && ~full_o) begin
      mem[write_pointer_q] <= data_i;
    end
  end
endmodule
// AUTO-GENERATED: 'top' packs the XIF interface into flat cin/cout buses
// for mapping onto the FABulous eFPGA (cin<->XIN_D_I, cout<->XOUT_D_O).
module top(input clk, input [157:0] cin, output [187:0] cout);
  xif_copro_verilog xcv (
    .clk_i(clk),
    .rst_ni(cin[0]),
    .compressed_valid_i(cin[1]),
    .issue_valid_i(cin[2]),
    .issue_req_instr_i(cin[34:3]),
    .issue_req_mode_i(cin[36:35]),
    .issue_req_id_i(cin[40:37]),
    .issue_req_rs_i(cin[104:41]),
    .issue_req_rs_valid_i(cin[106:105]),
    .commit_valid_i(cin[107]),
    .commit_kill_i(cin[108]),
    .commit_id_i(cin[112:109]),
    .mem_ready_i(cin[113]),
    .mem_resp_exc_i(cin[114]),
    .mem_resp_exccode_i(cin[120:115]),
    .mem_resp_dbg_i(cin[121]),
    .mem_result_valid_i(cin[122]),
    .mem_result_rdata_i(cin[154:123]),
    .mem_result_err_i(cin[155]),
    .mem_result_dbg_i(cin[156]),
    .result_ready_i(cin[157]),
    .compressed_ready_o(cout[0]),
    .compressed_resp_instr_o(cout[32:1]),
    .compressed_resp_accept_o(cout[33]),
    .issue_ready_o(cout[34]),
    .issue_resp_accept_o(cout[35]),
    .issue_resp_writeback_o(cout[36]),
    .issue_resp_dualwrite_o(cout[37]),
    .issue_resp_dualread_o(cout[40:38]),
    .issue_resp_loadstore_o(cout[41]),
    .issue_resp_ecswrite_o(cout[42]),
    .issue_resp_exc_o(cout[43]),
    .mem_valid_o(cout[44]),
    .mem_req_id_o(cout[48:45]),
    .mem_req_mode_o(cout[50:49]),
    .mem_req_we_o(cout[51]),
    .mem_req_size_o(cout[54:52]),
    .mem_req_be_o(cout[58:55]),
    .mem_req_attr_o(cout[60:59]),
    .mem_req_wdata_o(cout[92:61]),
    .mem_req_last_o(cout[93]),
    .mem_req_spec_o(cout[94]),
    .mem_req_addr_o(cout[126:95]),
    .result_valid_o(cout[127]),
    .result_id_o(cout[131:128]),
    .result_data_o(cout[163:132]),
    .result_rd_o(cout[168:164]),
    .result_we_o(cout[169]),
    .result_ecsdata_o(cout[175:170]),
    .result_ecswe_o(cout[178:176]),
    .result_exc_o(cout[179]),
    .result_exccode_o(cout[185:180]),
    .result_err_o(cout[186]),
    .result_dbg_o(cout[187])
  );
endmodule
