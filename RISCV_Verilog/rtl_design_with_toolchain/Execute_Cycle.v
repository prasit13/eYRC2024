// This module implements the Execute (EX) stage.
//
// Main responsibilities:
// 1. ALU operations
// 2. Branch target calculation
// 3. Branch decision generation
// 4. Forwarding / bypassing for hazard resolution
// 5. EX/MEM pipeline register generation
module Execute_Cycle(clk, rst_n, RegWriteE, ResultSrcE, MemWriteE, BranchE, ALUControlE, ALUSrcAE, ALUSrcBE, JumpE,
RD1E,RD2E, PCE, RdE, ImmExtE,PCPlus4E, PCSrcE, PCTargetE, RegWriteM, ResultSrcM, MemWriteM, ALUResultM, 
WriteDataM, RdM, PCPlus4M, ResultW, ForwardAE, ForwardBE);

//IO
input clk, rst_n;

input RegWriteE; // Register write enable
input MemWriteE; // Memory write enable
input BranchE; // Branch instruction
input JumpE; // Jump instruction
input [3:0] ALUControlE;  // ALU control signal (Generated from control unit)
// ALU source selection signals
input ALUSrcAE;
input [1:0] ALUSrcBE;
// Writeback source selection
input [1:0] ResultSrcE;

input [4:0] RdE;// Destination register number
input [31:0] RD1E,RD2E; // Register operands
input [31:0] PCE, ImmExtE, PCPlus4E;
input [31:0] ResultW; // Result forwarded from WB stage
input [1:0] ForwardAE, ForwardBE; // Forwarding control signals

output PCSrcE; // Branch control signal
output RegWriteM, MemWriteM; // Control signals to MEM stage
output [31:0] PCPlus4M, PCTargetE; //PC + 4 value forwarded and Branch/jump target address
output [31:0] ALUResultM; // ALU result
output [31:0] WriteDataM; // Data to be written into memory
output [4:0] RdM; // Destination register forwarded
output [1:0] ResultSrcM; // Writeback source selection forwarded

//Internal wires
wire [31:0] SrcAE, SrcBE; // Actual ALU operands
wire [31:0] ALUResultE; // Raw ALU result from EX stage
wire ZeroE; // Zero flag from ALU
wire [31:0]RD2E_Mux; // Forwarded version of RD2E
wire [31:0]SrcAE_Inter; // Intermediate forwarded source A

//Regs
reg RegWriteM_reg, MemWriteM_reg;
reg [31:0] ALUResultM_reg, WriteDataM_reg, PCPlus4M_reg;
reg [4:0] RdM_reg;
reg [1:0] ResultSrcM_reg;

ALU ALU_E (
    .A(SrcAE),
    .B(SrcBE),
    .Result(ALUResultE),
    .ALUControl(ALUControlE),
    .OverFlow(),
    .Zero(ZeroE),
    .Negative()
);

PC_Adder ADDER_E(
    .in1(PCE),
    .in2(ImmExtE),
    .out(PCTargetE)
);

Mux_3_by_1 MUX3X1_1(
    .in00(RD1E),
    .in01(ResultW),
    .in10(ALUResultM),
    .s(ForwardAE),
    .out(SrcAE_Inter)
);

Mux_3_by_1 MUX3X1_2(
    .in00(RD2E),
    .in01(ResultW),
    .in10(ALUResultM),
    .s(ForwardBE),
    .out(RD2E_Mux)
);

Mux_3_by_1 MUX3X1_3(
    .in00(RD2E_Mux),
    .in01(ImmExtE),
    .in10(PCTargetE),
    .s(ALUSrcBE),
    .out(SrcBE)
);

assign SrcAE=(ALUSrcAE) ? 32'b0:SrcAE_Inter; //FINAL OPERAND A SELECTION




always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        RegWriteM_reg<=RegWriteE;
        ResultSrcM_reg<=ResultSrcE;
        MemWriteM_reg<=MemWriteE;
        ALUResultM_reg<=ALUResultE;
        WriteDataM_reg<=RD2E_Mux;
        RdM_reg<=RdE;
        PCPlus4M_reg<=PCPlus4E;
    end
    else begin
        RegWriteM_reg<=1'b0;
        ResultSrcM_reg<=2'd0;
        MemWriteM_reg<=1'd0;
        ALUResultM_reg<=32'd0;
        WriteDataM_reg<=32'd0;
        RdM_reg<=5'd0;
        PCPlus4M_reg<=32'd0;
    end
end

//Output Assignment
assign RegWriteM=RegWriteM_reg;
assign ResultSrcM=ResultSrcM_reg;
assign MemWriteM=MemWriteM_reg;
assign ALUResultM=ALUResultM_reg;
assign WriteDataM=WriteDataM_reg;
assign RdM=RdM_reg;
assign PCPlus4M=PCPlus4M_reg;

assign PCSrcE = (JumpE | (BranchE & ZeroE));


endmodule