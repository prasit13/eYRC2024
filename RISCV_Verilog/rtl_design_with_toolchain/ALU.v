module ALU(A,B,Result,ALUControl,OverFlow,Zero,Negative);

input  [31:0] A; 
input  [31:0] B;
input [3:0] ALUControl; //4-bit control signal selecting the operation
output reg  [31:0] Result;
output wire Zero; //high when result is 0
output wire Negative; //sign bit of result
output reg OverFlow; //signed overflow flag

wire [31:0] Sum;


assign Sum = A + (ALUControl[0] ? ~B : B) + ALUControl[0];  // sub using 1's complement


assign Zero = (|Result) ? 1'b0:1'b1;
assign Negative = Result[31]; //MSB indicates sign in signed 2’s complement numbers.


always @ (*) begin
        OverFlow = ~(ALUControl[0] ^ B[31] ^ A[31]) & (A[31] ^ Sum[31]) & (~ALUControl[1]); //This detects signed overflow only for ADD/SUB operations. Overflow occurs when: 1.adding two positives gives negative, 2.adding two negatives gives positive, 3.subtracting numbers of opposite sign gives wrong sign
		casex (ALUControl)
				4'b0000: Result = Sum;				                // sum or diff (ADD)
				4'b0001: Result = Sum;				                // sum or diff (SUB)
				4'b0010: Result = A & B;	                        // and
				4'b0011: Result = A | B;	                        // or
				4'b0100: Result = A << B[4:0];	                    // sll, slli
				4'b0101: Result = {{30{1'b0}}, OverFlow ^ Sum[31]}; //slt, slti
				4'b0110: Result = A ^ B;                            // Xor
				4'b0111: Result = A >> B[4:0];                      // shift logic (Shift Right Logical)
				4'b1000: Result = ($unsigned(A) < $unsigned(B));    //sltu, stlui
				4'b1111: Result = A >>> B[4:0];                     //shift arithmetic right
				default: Result = 32'd0;
		endcase
        
end

endmodule