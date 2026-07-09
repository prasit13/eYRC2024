// =====================================================================================
// kf_copro.v  --  16-stage PIPELINED Kalman-filter coprocessor  (step-2 rewrite)
//
// Derived from the 8-stage kf_copro_pipe.v.  Same XIF port list, same Q16.16
// arithmetic, same decode / cfg / auto-init fast paths / commit handling.
//
// Changes vs the 8-stage version:
//   1. Each Newton-Raphson iteration is split into THREE stages so no stage
//      chains two multipliers:
//        NRa: dx  = s_in * x_n        (1 mul)
//        NRb: tdx = 2 - dx            (32-bit subtract -> hard carry chain)
//        NRc: x_{n+1} = x_n * tdx     (1 mul)
//      4 iterations * 3 = 12 NR stages; S1, S2, S7, S8 unchanged -> STAGES = 16.
//   2. The 4-deep forwarding arrays (nr_pm*, nr_e_in, nr_nx*, nr_den) are gone.
//      Only ONE sample is ever in flight (stall blocks new issues) and all
//      pipeline roots (filter state x*/p*, coefficients, captured s1_y) are
//      stable while the pipeline runs, so every derived value is stable once
//      its wavefront cycle has passed.  S7/S8 read the S1/S2 output registers
//      directly; each register's active input path still spans exactly one
//      clock (producer written the cycle before the consumer samples it).
//      This saves ~450 FFs vs the 8-stage version and ~3000 vs 12-deep arrays.
//   3. All 34 qmul_booth_wallace instances are kept (no time-sharing).
//
// ─────────────────────────────────────────────────────────────────────────────────────
//  PIPELINE MAP  (NR_ITER = 4  →  STAGES = 16)
//
//   token bit   Name    Work                                Muls   Stage logic depth
//   ─────────   ─────   ─────────────────────────────────   ────   ─────────────────
//       0       S1      predict state + A·P                  10    mul + CSA + 1 carry chain
//       1       S2      Pm = A·P·Aᵀ+Q, e, S, NR seed          4    mul + CSA + 1 carry chain
//       2       N0a     dx0 = S·seed                          1    mul
//       3       N0b     tdx0 = 2 − dx0                        0    1 carry chain
//       4       N0c     x1 = seed·tdx0                        1    mul
//       5..7    N1a-c   iter 1  (dx1/tdx1/x2)                 2
//       8..10   N2a-c   iter 2  (dx2/tdx2/x3)                 2
//      11..13   N3a-c   iter 3  (dx3/tdx3/recip)              2
//      14       S7      gains k0..k2 = pm0i·recip             3    mul
//      15       S8      update x, P → writeback               9    mul + 1 carry chain
//                                                            ──
//                                                            34
//  Latency: 16 cycles per kf_step (+ fixed XIF handshake ≈ 9 → ~25 cyc/sample).
//  Throughput unchanged (recursive filter: no overlap possible anyway).
// =====================================================================================
`default_nettype none
module kf_copro #(
  parameter XLEN = 32, parameter INPUT_BUFFER_DEPTH = 1, parameter FORWARDING = 1,
  // ── Reset-default model constants (Q16.16) — paper-tuned values ──────────────────
  parameter signed [31:0] DEF_DT  = 32'sd1311,     // dt       = 0.02 s  (50 Hz)
  parameter signed [31:0] DEF_DT2 = 32'sd13,       // dt²/2   = 0.0002
  parameter signed [31:0] DEF_R   = 32'sd524288,   // R        = 8.0
  parameter signed [31:0] DEF_Q00 = 32'sd3277,     // Q[0,0]   = 0.05
  parameter signed [31:0] DEF_Q01 = 32'sd0,
  parameter signed [31:0] DEF_Q02 = 32'sd0,
  parameter signed [31:0] DEF_Q11 = 32'sd36045,    // Q[1,1]   = 0.55
  parameter signed [31:0] DEF_Q12 = 32'sd0,
  parameter signed [31:0] DEF_Q22 = 32'sd66,       // Q[2,2]   = 0.001
  parameter signed [31:0] DEF_P0H = 32'sd13107200, // P0 diag  = 200.0
  parameter signed [31:0] DEF_P0V = 32'sd13107200,
  parameter signed [31:0] DEF_P0A = 32'sd13107200
) (
  input  wire        clk_i, rst_ni,
  // ── XIF compressed (stub) ─────────────────────────────────────────────────────────
  input  wire        compressed_valid_i,
  output wire        compressed_ready_o,
  output wire [31:0] compressed_resp_instr_o,
  output wire        compressed_resp_accept_o,
  // ── XIF issue ─────────────────────────────────────────────────────────────────────
  input  wire        issue_valid_i,
  output wire        issue_ready_o,
  input  wire [31:0] issue_req_instr_i,
  input  wire [1:0]  issue_req_mode_i,
  input  wire [3:0]  issue_req_id_i,
  input  wire [63:0] issue_req_rs_i,
  input  wire [1:0]  issue_req_rs_valid_i,
  output wire        issue_resp_accept_o,
  output wire        issue_resp_writeback_o,
  output wire        issue_resp_dualwrite_o,
  output wire [2:0]  issue_resp_dualread_o,
  output wire        issue_resp_loadstore_o,
  output wire        issue_resp_ecswrite_o,
  output wire        issue_resp_exc_o,
  // ── XIF commit ────────────────────────────────────────────────────────────────────
  input  wire        commit_valid_i,
  input  wire        commit_kill_i,
  input  wire [3:0]  commit_id_i,
  // ── XIF memory (unused) ───────────────────────────────────────────────────────────
  output wire        mem_valid_o,
  input  wire        mem_ready_i,
  output wire [3:0]  mem_req_id_o,
  output wire [1:0]  mem_req_mode_o,
  output wire        mem_req_we_o,
  output wire [2:0]  mem_req_size_o,
  output wire [3:0]  mem_req_be_o,
  output wire [1:0]  mem_req_attr_o,
  output wire [31:0] mem_req_wdata_o,
  output wire        mem_req_last_o,
  output wire        mem_req_spec_o,
  output wire [31:0] mem_req_addr_o,
  input  wire        mem_resp_exc_i,
  input  wire [5:0]  mem_resp_exccode_i,
  input  wire        mem_resp_dbg_i,
  input  wire        mem_result_valid_i,
  input  wire [31:0] mem_result_rdata_i,
  input  wire        mem_result_err_i,
  input  wire        mem_result_dbg_i,
  // ── XIF result ────────────────────────────────────────────────────────────────────
  output wire        result_valid_o,
  input  wire        result_ready_i,
  output wire [3:0]  result_id_o,
  output wire [31:0] result_data_o,
  output wire [4:0]  result_rd_o,
  output wire        result_we_o,
  output wire [5:0]  result_ecsdata_o,
  output wire [2:0]  result_ecswe_o,
  output wire        result_exc_o,
  output wire [5:0]  result_exccode_o,
  output wire        result_err_o,
  output wire        result_dbg_o
);

  // ── Pipeline constants ────────────────────────────────────────────────────────────
  localparam NR_ITER = 4;               // Newton-Raphson iterations for 1/s_in
  localparam STAGES  = 3*NR_ITER + 4;   // 16 total pipeline stages

  // ── Run-time coefficient registers (stable while pipeline is active) ──────────────
  reg signed [31:0] DT, DT2, R, Q00, Q01, Q02, Q11, Q12, Q22, P0H, P0V, P0A;

  // ── Persistent filter state (written only at stage S8 writeback) ──────────────────
  reg signed [31:0] x0, x1, x2;
  reg signed [31:0] p00, p01, p02, p11, p12, p22;
  reg               first;

  // ── Result / handshake registers ─────────────────────────────────────────────────
  reg        done;
  reg signed [31:0] data_q;
  reg [3:0]  id_q;
  reg [4:0]  rd_q;

  // ── Pipeline control ──────────────────────────────────────────────────────────────
  // pipe_valid: 1-hot shift register.
  //   Bit 0 → set at accept; shifts left each cycle.
  //   Bit STAGES-1 active at the writeback cycle.
  reg [STAGES-1:0] pipe_valid;
  reg              committed; // XIF commit (not-kill) arrived during pipeline
  reg              pipe_done; // pipeline finished but commit not yet received
  reg              fast_path_wait; // waiting for commit on a 1-cycle fast path

  // stall = refuse new issue while pipeline is live, commit is pending, or result
  //         has not been consumed yet.
  wire stall = (|pipe_valid) | pipe_done | done | fast_path_wait;

  // ── Decode (identical to kf_copro) ───────────────────────────────────────────────
  wire        ours    = (issue_req_instr_i[6:0]==7'h0B) & (issue_req_instr_i[14:12]==3'b000);
  wire [6:0]  f7      = issue_req_instr_i[31:25];
  wire        is_step = ours & (f7==7'd0);
  wire        is_cfg  = ours & (f7==7'd1);
  wire        is_op   = is_step | is_cfg;

  wire signed [31:0] y_in    = issue_req_rs_i[31:0];
  wire signed [31:0] cfg_val = issue_req_rs_i[31:0];
  wire [3:0]         cfg_idx = issue_req_rs_i[35:32]; // rs2 low nibble

  wire accept_hs  = issue_valid_i & issue_ready_o & is_op;
  wire commit_hit = commit_valid_i & (commit_id_i == id_q);

  // ============================================================================
  //  PIPELINE STAGE REGISTERS
  //  Naming convention:  s<N>_<signal> = output register of stage N.
  //  Single copies only: with one op in flight and stable roots, each register
  //  is re-written with the same (stable) value on every cycle after its
  //  wavefront cycle, so downstream stages can read it whenever they run.
  // ============================================================================

  // S1 → S2+   (s1_nx* also read directly by S8; stable from cycle 1 on)
  reg signed [31:0] s1_nx0,  s1_nx1,  s1_nx2;
  reg signed [31:0] s1_ap00, s1_ap01, s1_ap02;
  reg signed [31:0]          s1_ap11, s1_ap12, s1_ap22;
  reg signed [31:0] s1_y;    // measurement captured at accept; constant thereafter

  // S2 → NR/S7/S8   (single copies; read by N*, S7 and S8)
  reg signed [31:0] s2_pm00, s2_pm01, s2_pm02;
  reg signed [31:0] s2_pm11, s2_pm12, s2_pm22;
  reg signed [31:0] s2_e_in;    // innovation = y - nx0
  reg signed [31:0] s2_s_in;    // S = pm00 + R  (NR denominator, used by all iters)
  reg signed [31:0] s2_nr_seed; // NR seed = 2^(31 - MSB(s_in))

  // NR pipeline registers (per iteration: dx / tdx / x-next)
  reg signed [31:0] nr_dx  [0:NR_ITER-1]; // dx_i  = s_in * x_i     (end of N<i>a)
  reg signed [31:0] nr_tdx [0:NR_ITER-1]; // tdx_i = 2 - dx_i       (end of N<i>b)
  reg signed [31:0] nr_x   [0:NR_ITER-1]; // x_{i+1} = x_i * tdx_i  (end of N<i>c);
                                          // nr_x[3] = recip = 1/s_in

  // S7 → S8
  reg signed [31:0] s7_k0,  s7_k1,  s7_k2;

  // ============================================================================
  //  MSB FUNCTION  (priority encoder for Newton-Raphson seed)
  // ============================================================================
  function [5:0] msb_of;
    input [31:0] v; integer ii;
    begin
      msb_of = 6'd0;
      for (ii = 0; ii < 32; ii = ii + 1)
        if (v[ii]) msb_of = ii[5:0];
    end
  endfunction

  // ============================================================================
  //  STAGE 1 COMBINATIONAL  — Predict state nx* + P first pass (A·P)
  //  Reads directly from filter-state registers.
  //  These are stable the entire time the pipeline is active (stall is asserted).
  // ============================================================================
  wire signed [31:0] w_m_dt_x1,  w_m_dt2_x2, w_m_dt_x2;
  qmul_booth_wallace u01(.a(DT),  .b(x1),  .q(w_m_dt_x1));   // DT·x1
  qmul_booth_wallace u02(.a(DT2), .b(x2),  .q(w_m_dt2_x2));  // DT2·x2
  qmul_booth_wallace u03(.a(DT),  .b(x2),  .q(w_m_dt_x2));   // DT·x2

  wire signed [31:0] w_m_dt_p01,  w_m_dt2_p02, w_m_dt_p11;
  wire signed [31:0] w_m_dt2_p12, w_m_dt_p12,  w_m_dt2_p22, w_m_dt_p22;
  qmul_booth_wallace u04(.a(DT),  .b(p01), .q(w_m_dt_p01));
  qmul_booth_wallace u05(.a(DT2), .b(p02), .q(w_m_dt2_p02));
  qmul_booth_wallace u06(.a(DT),  .b(p11), .q(w_m_dt_p11));
  qmul_booth_wallace u07(.a(DT2), .b(p12), .q(w_m_dt2_p12));
  qmul_booth_wallace u08(.a(DT),  .b(p12), .q(w_m_dt_p12));
  qmul_booth_wallace u09(.a(DT2), .b(p22), .q(w_m_dt2_p22));
  qmul_booth_wallace u10(.a(DT),  .b(p22), .q(w_m_dt_p22));

  // S1 adder tree  (→ registered into s1_*)
  wire signed [31:0] w_nx0  = x0  + w_m_dt_x1  + w_m_dt2_x2;
  wire signed [31:0] w_nx1  = x1  + w_m_dt_x2;
  wire signed [31:0] w_nx2  = x2;
  wire signed [31:0] w_ap00 = p00 + w_m_dt_p01 + w_m_dt2_p02;
  wire signed [31:0] w_ap01 = p01 + w_m_dt_p11 + w_m_dt2_p12;
  wire signed [31:0] w_ap02 = p02 + w_m_dt_p12 + w_m_dt2_p22;
  wire signed [31:0] w_ap11 = p11 + w_m_dt_p12;
  wire signed [31:0] w_ap12 = p12 + w_m_dt_p22;
  wire signed [31:0] w_ap22 = p22;

  // ============================================================================
  //  STAGE 2 COMBINATIONAL  — Predict Pm (A·P·Aᵀ + Q) + innovation scalars
  //  Reads from s1_* registers.
  // ============================================================================
  wire signed [31:0] w_m_dt_ap01, w_m_dt2_ap02, w_m_dt_ap02, w_m_dt_ap12;
  qmul_booth_wallace u11(.a(DT),  .b(s1_ap01), .q(w_m_dt_ap01));
  qmul_booth_wallace u12(.a(DT2), .b(s1_ap02), .q(w_m_dt2_ap02));
  qmul_booth_wallace u13(.a(DT),  .b(s1_ap02), .q(w_m_dt_ap02));
  qmul_booth_wallace u14(.a(DT),  .b(s1_ap12), .q(w_m_dt_ap12));

  // S2 adder tree (→ registered into s2_*)
  wire signed [31:0] w_pm00 = s1_ap00 + w_m_dt_ap01 + w_m_dt2_ap02 + Q00;
  wire signed [31:0] w_pm01 = s1_ap01 + w_m_dt_ap02                + Q01;
  wire signed [31:0] w_pm02 = s1_ap02                               + Q02;
  wire signed [31:0] w_pm11 = s1_ap11 + w_m_dt_ap12                + Q11;
  wire signed [31:0] w_pm12 = s1_ap12                               + Q12;
  wire signed [31:0] w_pm22 = s1_ap22                               + Q22;
  wire signed [31:0] w_e_in = s1_y - s1_nx0;      // innovation:  y − x̂₀⁻
  wire signed [31:0] w_s_in = w_pm00 + R;         // S = H·P̃·Hᵀ + R = P̃₀₀ + R

  // Newton-Raphson seed: largest power-of-2 ≤ 1/s_in
  wire [5:0]         w_msb  = msb_of(w_s_in);
  wire signed [31:0] w_seed = 32'd1 << (6'd31 - w_msb); // 2^(31-MSB)

  // ============================================================================
  //  NR STAGES COMBINATIONAL — Newton-Raphson reciprocal, 3 stages / iteration
  //
  //  x_{n+1} = x_n · (2 − s_in · x_n)
  //  N<i>a:  w_dx<i>  = s_in · x_i            (registered into nr_dx[i])
  //  N<i>b:  w_tdx<i> = 2 − nr_dx[i]          (registered into nr_tdx[i])
  //  N<i>c:  w_xn<i+1>= x_i · nr_tdx[i]       (registered into nr_x[i])
  //  x_0 = s2_nr_seed;  x_i (i>0) = nr_x[i-1] — stable when read (single op
  //  in flight), so no per-stage forwarding copies are needed.
  // ============================================================================
  localparam signed [31:0] Q16_TWO = 32'sd131072; // 2.0 in Q16.16

  // iter 0  (x_0 = s2_nr_seed)
  wire signed [31:0] w_dx0, w_tdx0, w_xn1;
  qmul_booth_wallace u_dx0(.a(s2_s_in),    .b(s2_nr_seed), .q(w_dx0));
  assign w_tdx0 = Q16_TWO - nr_dx[0];
  qmul_booth_wallace u_xn1(.a(s2_nr_seed), .b(nr_tdx[0]),  .q(w_xn1));

  // iter 1  (x_1 = nr_x[0])
  wire signed [31:0] w_dx1, w_tdx1, w_xn2;
  qmul_booth_wallace u_dx1(.a(s2_s_in), .b(nr_x[0]),   .q(w_dx1));
  assign w_tdx1 = Q16_TWO - nr_dx[1];
  qmul_booth_wallace u_xn2(.a(nr_x[0]), .b(nr_tdx[1]), .q(w_xn2));

  // iter 2  (x_2 = nr_x[1])
  wire signed [31:0] w_dx2, w_tdx2, w_xn3;
  qmul_booth_wallace u_dx2(.a(s2_s_in), .b(nr_x[1]),   .q(w_dx2));
  assign w_tdx2 = Q16_TWO - nr_dx[2];
  qmul_booth_wallace u_xn3(.a(nr_x[1]), .b(nr_tdx[2]), .q(w_xn3));

  // iter 3  (x_3 = nr_x[2])  →  nr_x[3] = recip = 1/s_in
  wire signed [31:0] w_dx3, w_tdx3, w_xn4;
  qmul_booth_wallace u_dx3(.a(s2_s_in), .b(nr_x[2]),   .q(w_dx3));
  assign w_tdx3 = Q16_TWO - nr_dx[3];
  qmul_booth_wallace u_xn4(.a(nr_x[2]), .b(nr_tdx[3]), .q(w_xn4));

  // ============================================================================
  //  STAGE 7 COMBINATIONAL  — Kalman gains  (3 parallel muls)
  //  k_i = P̃_i0 / S  =  P̃_i0 · recip    (i = 0,1,2)
  //  Reads nr_x[3] (recip) and the stable s2_pm* registers.
  // ============================================================================
  wire signed [31:0] w_k0, w_k1, w_k2;
  qmul_booth_wallace u_k0(.a(s2_pm00), .b(nr_x[NR_ITER-1]), .q(w_k0));
  qmul_booth_wallace u_k1(.a(s2_pm01), .b(nr_x[NR_ITER-1]), .q(w_k1));
  qmul_booth_wallace u_k2(.a(s2_pm02), .b(nr_x[NR_ITER-1]), .q(w_k2));

  // ============================================================================
  //  STAGE 8 COMBINATIONAL  — Update state x and covariance P  (9 parallel muls)
  //  Reads s7_k* plus the stable s1_nx*, s2_e_in, s2_pm* registers.
  // ============================================================================
  wire signed [31:0] w_mk0e, w_mk1e, w_mk2e;
  qmul_booth_wallace u17(.a(s7_k0), .b(s2_e_in), .q(w_mk0e));
  qmul_booth_wallace u18(.a(s7_k1), .b(s2_e_in), .q(w_mk1e));
  qmul_booth_wallace u19(.a(s7_k2), .b(s2_e_in), .q(w_mk2e));

  wire signed [31:0] w_ux0 = s1_nx0 + w_mk0e;  // updated state
  wire signed [31:0] w_ux1 = s1_nx1 + w_mk1e;
  wire signed [31:0] w_ux2 = s1_nx2 + w_mk2e;

  wire signed [31:0] w_mk0p00, w_mk0p01, w_mk0p02;
  wire signed [31:0] w_mk1p01, w_mk1p02, w_mk2p02;
  qmul_booth_wallace u20(.a(s7_k0), .b(s2_pm00), .q(w_mk0p00));
  qmul_booth_wallace u21(.a(s7_k0), .b(s2_pm01), .q(w_mk0p01));
  qmul_booth_wallace u22(.a(s7_k0), .b(s2_pm02), .q(w_mk0p02));
  qmul_booth_wallace u23(.a(s7_k1), .b(s2_pm01), .q(w_mk1p01));
  qmul_booth_wallace u24(.a(s7_k1), .b(s2_pm02), .q(w_mk1p02));
  qmul_booth_wallace u25(.a(s7_k2), .b(s2_pm02), .q(w_mk2p02));

  wire signed [31:0] w_np00 = s2_pm00 - w_mk0p00; // updated covariance
  wire signed [31:0] w_np01 = s2_pm01 - w_mk0p01;
  wire signed [31:0] w_np02 = s2_pm02 - w_mk0p02;
  wire signed [31:0] w_np11 = s2_pm11 - w_mk1p01;
  wire signed [31:0] w_np12 = s2_pm12 - w_mk1p02;
  wire signed [31:0] w_np22 = s2_pm22 - w_mk2p02;

  // ============================================================================
  //  XIF ASSIGNS
  // ============================================================================
  assign issue_ready_o          = ~stall & (is_op ? (is_cfg ? (&issue_req_rs_valid_i)
                                                            :   issue_req_rs_valid_i[0]) : 1'b1);
  assign issue_resp_accept_o    = is_op;
  assign issue_resp_writeback_o = is_op;
  assign issue_resp_dualwrite_o = 1'b0;
  assign issue_resp_dualread_o  = 3'b0;
  assign issue_resp_loadstore_o = 1'b0;
  assign issue_resp_ecswrite_o  = 1'b0;
  assign issue_resp_exc_o       = 1'b0;

  assign compressed_ready_o       = compressed_valid_i;
  assign compressed_resp_instr_o  = 32'b0;
  assign compressed_resp_accept_o = 1'b0;
  assign mem_valid_o=1'b0; assign mem_req_id_o=4'b0; assign mem_req_mode_o=2'b0;
  assign mem_req_we_o=1'b0; assign mem_req_size_o=3'b0; assign mem_req_be_o=4'b0;
  assign mem_req_attr_o=2'b0; assign mem_req_wdata_o=32'b0; assign mem_req_last_o=1'b0;
  assign mem_req_spec_o=1'b0; assign mem_req_addr_o=32'b0;

  assign result_valid_o   = done;   assign result_id_o      = id_q;
  assign result_data_o    = data_q; assign result_rd_o      = rd_q;
  assign result_we_o      = 1'b1;   assign result_ecsdata_o = 6'b0;
  assign result_ecswe_o   = 3'b0;   assign result_exc_o     = 1'b0;
  assign result_exccode_o = 6'b0;   assign result_err_o     = 1'b0;
  assign result_dbg_o     = 1'b0;

  // ============================================================================
  //  CLOCK PROCESS
  // ============================================================================
  always @(posedge clk_i) begin
    if (~rst_ni) begin
      // ── Reset ──────────────────────────────────────────────────────────────
      pipe_valid <= {STAGES{1'b0}};
      committed  <= 1'b0;
      pipe_done  <= 1'b0;
      done       <= 1'b0;
      fast_path_wait <= 1'b0;
      first      <= 1'b1;
      x0<=0; x1<=0; x2<=0;
      p00<=0; p01<=0; p02<=0; p11<=0; p12<=0; p22<=0;
      data_q<=0; id_q<=0; rd_q<=0;
      DT<=DEF_DT;   DT2<=DEF_DT2; R<=DEF_R;
      Q00<=DEF_Q00; Q01<=DEF_Q01; Q02<=DEF_Q02;
      Q11<=DEF_Q11; Q12<=DEF_Q12; Q22<=DEF_Q22;
      P0H<=DEF_P0H; P0V<=DEF_P0V; P0A<=DEF_P0A;

      // Stage registers reset
      s1_nx0<=0; s1_nx1<=0; s1_nx2<=0; s1_y<=0;
      s1_ap00<=0; s1_ap01<=0; s1_ap02<=0; s1_ap11<=0; s1_ap12<=0; s1_ap22<=0;
      s2_pm00<=0; s2_pm01<=0; s2_pm02<=0;
      s2_pm11<=0; s2_pm12<=0; s2_pm22<=0;
      s2_e_in<=0; s2_s_in<=0; s2_nr_seed<=0;
      nr_dx[0]<=0;  nr_dx[1]<=0;  nr_dx[2]<=0;  nr_dx[3]<=0;
      nr_tdx[0]<=0; nr_tdx[1]<=0; nr_tdx[2]<=0; nr_tdx[3]<=0;
      nr_x[0]<=0;   nr_x[1]<=0;   nr_x[2]<=0;   nr_x[3]<=0;
      s7_k0<=0; s7_k1<=0; s7_k2<=0;

    end else begin

      // ── Result handshake ───────────────────────────────────────────────────
      if (done & result_ready_i)
        done <= 1'b0;

      // ── Commit / Kill during pipeline (pipe_valid active) ──────────────────
      if (commit_hit & |pipe_valid) begin
        if (commit_kill_i) begin
          pipe_valid <= {STAGES{1'b0}}; // flush pipeline immediately
          committed  <= 1'b0;
        end else begin
          committed  <= 1'b1;           // save approval; state written at S8
        end
      end

      // ── Commit / Kill after pipeline (pipe_done state) ─────────────────────
      if (pipe_done & commit_hit) begin
        if (~commit_kill_i) begin
          x0<=w_ux0; x1<=w_ux1; x2<=w_ux2;
          p00<=w_np00; p01<=w_np01; p02<=w_np02;
          p11<=w_np11; p12<=w_np12; p22<=w_np22;
          data_q <= w_ux0;
          first  <= 1'b0;
          done   <= 1'b1;
        end
        pipe_done <= 1'b0;
      end

      // Catch delayed commits for fast-path instructions (cfg or first)
      if (fast_path_wait & commit_hit) begin
        if (~commit_kill_i) done <= 1'b1;
        fast_path_wait <= 1'b0;
      end

      // ── Pipeline register advance ───────────────────────────────────────────
      // All stage registers are re-written every cycle while the token runs;
      // their inputs are stable after the producing stage's cycle (single op
      // in flight, stable roots), so each register holds its correct value
      // from its wavefront cycle until the pipeline ends.
      if (|pipe_valid) begin
        // ── Advance the 1-hot token ────────────────────────────────────────
        pipe_valid <= pipe_valid << 1;

        // ── S1 outputs (stable from cycle 1) ───────────────────────────────
        s1_nx0  <= w_nx0;  s1_nx1  <= w_nx1;  s1_nx2  <= w_nx2;
        s1_ap00 <= w_ap00; s1_ap01 <= w_ap01; s1_ap02 <= w_ap02;
        s1_ap11 <= w_ap11; s1_ap12 <= w_ap12; s1_ap22 <= w_ap22;
        // s1_y was captured at accept; it stays constant during the pipeline.

        // ── S2 outputs (stable from cycle 2) ───────────────────────────────
        s2_pm00 <= w_pm00; s2_pm01 <= w_pm01; s2_pm02 <= w_pm02;
        s2_pm11 <= w_pm11; s2_pm12 <= w_pm12; s2_pm22 <= w_pm22;
        s2_e_in <= w_e_in; s2_s_in <= w_s_in; s2_nr_seed <= w_seed;

        // ── NR iterations: dx / tdx / x-next  (wavefront settles in order) ──
        nr_dx[0]  <= w_dx0;  nr_tdx[0] <= w_tdx0;  nr_x[0] <= w_xn1;
        nr_dx[1]  <= w_dx1;  nr_tdx[1] <= w_tdx1;  nr_x[1] <= w_xn2;
        nr_dx[2]  <= w_dx2;  nr_tdx[2] <= w_tdx2;  nr_x[2] <= w_xn3;
        nr_dx[3]  <= w_dx3;  nr_tdx[3] <= w_tdx3;  nr_x[3] <= w_xn4;

        // ── S7: Kalman gains (stable from cycle 15) ────────────────────────
        s7_k0 <= w_k0;  s7_k1 <= w_k1;  s7_k2 <= w_k2;

        // ── S8: State writeback (last pipeline stage) ──────────────────────
        if (pipe_valid[STAGES-1]) begin
          if (committed | (commit_hit & ~commit_kill_i)) begin
            // Commit already received: write state and signal done.
            x0<=w_ux0; x1<=w_ux1; x2<=w_ux2;
            p00<=w_np00; p01<=w_np01; p02<=w_np02;
            p11<=w_np11; p12<=w_np12; p22<=w_np22;
            data_q <= w_ux0;
            first  <= 1'b0;
            done   <= 1'b1;
          end else if (commit_hit & commit_kill_i) begin
            // Kill arrived exactly at writeback: discard computation.
            // pipe_valid will shift to 0; state is unchanged.
          end else begin
            // No commit yet. Enter post-pipeline wait state.
            // All stage registers freeze (stall prevents new issue), so
            // w_ux* / w_np* remain valid combinationally until commit arrives.
            pipe_done <= 1'b1;
          end
          committed <= 1'b0; // clear regardless
        end
      end // if |pipe_valid

      // ── Accept new instruction ─────────────────────────────────────────────
      if (accept_hs) begin
        id_q <= issue_req_id_i;
        rd_q <= issue_req_instr_i[11:7];

        if (is_cfg) begin
          // ── Config write: 1-cycle fast path (no pipeline) ─────────────────
          case (cfg_idx)
            4'd0:  R   <= cfg_val;
            4'd1:  Q00 <= cfg_val;
            4'd2:  Q01 <= cfg_val;
            4'd3:  Q02 <= cfg_val;
            4'd4:  Q11 <= cfg_val;
            4'd5:  Q12 <= cfg_val;
            4'd6:  Q22 <= cfg_val;
            4'd7:  P0H <= cfg_val;
            4'd8:  P0V <= cfg_val;
            4'd9:  P0A <= cfg_val;
            4'd10: DT  <= cfg_val;
            4'd11: DT2 <= cfg_val;
            4'd15: first <= 1'b1; // REINIT: re-seed on next kf_step
            default: ;
          endcase
          data_q <= cfg_val; // ack

          if (commit_hit & ~commit_kill_i) done <= 1'b1;
          else if (~commit_hit) fast_path_wait <= 1'b1; // Wait for commit

        end else if (first) begin
          // ── Auto-init: 1-cycle fast path (no pipeline) ────────────────────
          x0<=y_in; x1<=0; x2<=0;
          p00<=P0H; p01<=0; p02<=0; p11<=P0V; p12<=0; p22<=P0A;
          first  <= 1'b0;
          data_q <= y_in;

          if (commit_hit & ~commit_kill_i) done <= 1'b1;
          else if (~commit_hit) fast_path_wait <= 1'b1; // Wait for commit

        end else begin
          // ── kf_step: launch 16-stage pipeline ─────────────────────────────
          pipe_valid <= {{(STAGES-1){1'b0}}, 1'b1};
          committed  <= 1'b0;
          pipe_done  <= 1'b0;
          s1_y       <= y_in; // capture measurement before rs_i may change

          // Handle simultaneous accept + commit (common on short-pipeline cores)
          if (commit_hit & commit_kill_i)
            pipe_valid <= {STAGES{1'b0}}; // instantly killed; don't even start
          else if (commit_hit)
            committed  <= 1'b1;           // commit arrived with accept
        end
      end
    end // ~rst_ni
  end // always
endmodule
`default_nettype wire
