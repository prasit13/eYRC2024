module Memory_Cycle(
    clk, rst_n, RegWriteM, ResultSrcM, MemWriteM,
    ALUResultM, WriteDataM, RdM, PCPlus4M, ALUResultW,
    RegWriteW, ResultSrcW, ReadDataW, RdW, PCPlus4W
);

input clk,rst_n;
input RegWriteM; // Register write enable
input MemWriteM; // Memory write enable
input [31:0] ALUResultM, WriteDataM, PCPlus4M; //ALU output/address(Memory address from ALU in this case), Data to write into memory, PC + 4 value
input [4:0] RdM; // Destination register number
input [1:0] ResultSrcM; //Selects what gets written back to register file later: ALU Result or Memory Data or PC+4 (Select source for writeback result)

// Outputs going to WB stage
output [31:0] ReadDataW, PCPlus4W, ALUResultW;
output RegWriteW;
output [1:0] ResultSrcW;
output [4:0]RdW;

wire [31:0] ReadDataM; // Data read from data memory

Data_Memory DataMem(
    .clk(clk),
    .rst_n(rst_n),
    .WE(MemWriteM),
    .WD(WriteDataM),
    .A(ALUResultM),
    .RD(ReadDataM)
);

//Registers
reg [31:0] ReadDataW_reg, RdW_reg, PCPlus4W_reg, ALUResultW_reg;
reg RegWriteW_reg;
reg [1:0] ResultSrcW_reg;

always @(posedge clk or negedge rst_n) begin
    if(rst_n) begin
        ReadDataW_reg<=ReadDataM;
        RdW_reg<=RdM;
        PCPlus4W_reg<=PCPlus4M;
        ALUResultW_reg<=ALUResultM;
        RegWriteW_reg<=RegWriteM;
        ResultSrcW_reg<=ResultSrcM;
    end
    else begin
        ReadDataW_reg<=32'd0;
        RdW_reg<=5'd0;
        PCPlus4W_reg<=32'd0;
        ALUResultW_reg<=32'd0;
        RegWriteW_reg<=1'd0;
        ResultSrcW_reg<=2'd0;
    end
end

assign ReadDataW=ReadDataW_reg;
assign RdW=RdW_reg;
assign PCPlus4W=PCPlus4W_reg;
assign ALUResultW=ALUResultW_reg;
assign RegWriteW=RegWriteW_reg;
assign ResultSrcW=ResultSrcW_reg;

endmodule