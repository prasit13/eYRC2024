// ================= FETCH STAGE =================
//
// This module implements the Instruction Fetch (IF) stage
// of a pipelined processor.
//
// Main functions:
// 1. Fetch instruction from instruction memory
// 2. Compute PC + 4 (next sequential instruction address)
// 3. Store fetched values into pipeline registers
// 4. Pass fetched instruction/data to Decode stage

module Fetch_Cycle(clk,rst_n,PCF,InstrD,PCD,PCPlus4D, PCPlus4F_Fed, en,clr);

input clk,rst_n;
input [31:0] PCF; //current Program Counter (Fetch stage PC)
input en, clr; //enable signal for pipeline register update and clear/flush signal

output [31:0] PCPlus4F_Fed; //direct PC+4 from fetch stage without register
output [31:0] PCPlus4D, PCD, InstrD; //PC, PC+4, instruction passed (through register) to decode stage

wire [31:0] InstrF,PCPlus4F; // InstrF: instruction fetched from instruction memory and PCPlus4F: PC + 4 calculated in Fetch stage

//REGs
reg [31:0] InstrF_reg, PCF_reg, PCPlus4F_reg;
assign PCPlus4F_Fed=PCPlus4F;

PC_Adder PCAdder(
    .in1(PCF),
    .in2(32'd4),
    .out(PCPlus4F)
);

Instruction_Memory I_MEM(
    .rst_n(rst_n),
    .A(PCF),
    .RD(InstrF)
);

always @(posedge clk or negedge rst_n) begin
    if(rst_n | ~clr | en) begin
        InstrF_reg<=InstrF;
        PCF_reg<=PCF;
        PCPlus4F_reg<=PCPlus4F;
    end
    else begin
        InstrF_reg<=32'd0;
        PCF_reg<=32'd0;
        PCPlus4F_reg<=32'd0; 
    end
end

assign InstrD=InstrF_reg;
assign PCD=PCF_reg;
assign PCPlus4D=PCPlus4F_reg;

endmodule