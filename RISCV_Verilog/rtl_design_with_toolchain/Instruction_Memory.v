module Instruction_Memory(rst_n,A,RD);

  input rst_n;
  input [31:0]A;
  output [31:0]RD; //instruction output

  reg [31:0] mem [0:63]; //Memory array of 64 location, each location is 32 bit wide
  
  assign RD = (rst_n == 1'b0) ? {32{1'b0}} : mem[A[31:2]];

  initial begin
    $readmemh("instructions.hex",mem);
  end


endmodule


// Why A[31:2]?

// RISC-style processors usually use:

// byte-addressed memory
// each instruction = 4 bytes = 32 bits

// So instruction addresses increase like:

// 0
// 4
// 8
// 12
// 16
// ...

// The lower 2 bits are always:

// 00

// because instructions are aligned to 4 bytes.

// Therefore:

// A[31:2]

// removes the lower 2 bits and converts byte address → word index.

// Example:

// Address A	A[31:2]	Memory Index
// 0	           0	   mem[0]
// 4	           1	   mem[1]
// 8	           2	   mem[2]
// 12	           3	   mem[3]

// example mem:
// 00000013
// 00100093
// 00200113
// 00308193
