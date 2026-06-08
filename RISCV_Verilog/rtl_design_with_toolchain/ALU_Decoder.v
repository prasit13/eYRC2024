// Function:
// ---------
// Main decoder gives a high-level ALUOp.
// This module further decodes:
//   - funct3
//   - funct7
//   - opcode
//
// and generates the final ALU control signal.
module ALU_Decoder(ALUOp,funct3,funct7,op,ALUControl);

    input [1:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output reg [3:0]ALUControl;

wire RtypeSub;
assign RtypeSub = funct7[5] & op[5]; // TRUE for R-type subtract
always @ (*)
	case(ALUOp)
		2'b00: ALUControl = 4'b0000; // addition
		2'b01: ALUControl = 4'b0001; // subtraction
		default: case(funct3) // R–type or I–type ALU
				3'b000: if (RtypeSub)
							ALUControl = 4'b0001; // sub
						else
							ALUControl = 4'b0000; // add, addi
				3'b001: ALUControl = 4'b0100; // sll, slli
				3'b010: ALUControl = 4'b0101; // slt, slti
				3'b011: ALUControl = 4'b1000; // sltu, sltiu
				3'b100: ALUControl = 4'b0110; // xor, xori
				3'b101: if (~funct7)
							ALUControl = 4'b0111;	// srl
						else
							ALUControl = 4'b1111;  // sra
				3'b110: ALUControl = 4'b0011; // or, ori
				3'b111: ALUControl = 4'b0010; // and, andi
				default: ALUControl = 4'bxxxx; 
				endcase
	endcase
	
endmodule