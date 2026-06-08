`include "PC_Adder.v"
`include "Instruction_Memory.v"
`include "Fetch_Cycle.v"
`include "Main_Decoder.v"
`include "ALU_Decoder.v"
`include "Control_Unit_Top.v"
`include "Register_File.v"
`include "Sign_Extend.v"
`include "Decode_Cycle.v"
`include "Mux.v"
`include "ALU.v"
`include "Execute_Cycle.v"
`include "Data_Memory.v"
`include "Memory_Cycle.v"
`include "Writeback_Cycle.v"
`include "Hazard_Unit.v"
`include "PC_Module.v"
`include "pipeline_top.v"


module pipeline_tb;

reg rst_n;
reg clk=0;
integer i;

pipeline_top TEST(clk,rst_n);

initial begin
    rst_n=0;
    #20;
    rst_n=1;
    #630;
    $finish;
end

always @(posedge clk) begin
    $display("[%0t] fetched instruction: %h",$time, TEST.Fetch.InstrD);
end

initial begin
    forever #5 clk=~clk;
end



initial begin
    $dumpfile("wave.vcd");
    $dumpvars();
end

endmodule

//iverilog -o out.vvp pipeline_tb.v
//vvp out.vvp
//gtkwave wave.vcd

//https://riscvasm.lucasteske.dev/#

//riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 test.s -o test.elf
//riscv64-unknown-elf-objdump -d test.elf