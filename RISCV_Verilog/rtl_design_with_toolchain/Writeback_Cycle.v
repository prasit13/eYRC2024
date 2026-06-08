module Writeback_Cycle(
    clk, rst_n, ReadDataW, ResultSrcW, ALUResultW, 
    PCPlus4W, ResultW
);

input clk, rst_n; 
input [1:0] ResultSrcW; //ResultSrcW determines which data source is selected
input [31:0] PCPlus4W, ALUResultW, ReadDataW; //PC+4 value, Result produced by ALU, Data coming from Data Memory

output [31:0] ResultW; //Final selected value that will be written back into the register file

Mux_3_by_1 result_mux(    
.in00(ALUResultW),
.in01(ReadDataW),
.in10(PCPlus4W),
.s(ResultSrcW),
.out(ResultW)
);

endmodule