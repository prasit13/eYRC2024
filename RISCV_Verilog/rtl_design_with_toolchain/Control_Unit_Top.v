module Control_Unit_Top(Op,RegWrite,ImmSrc,ALUSrcA,ALUSrcB,MemWrite,ResultSrc,
Branch,funct3,funct7,ALUControl,Jump);

    input [6:0]Op,funct7;
    input [2:0]funct3;
    output RegWrite,ALUSrcA,MemWrite,Branch, Jump;
    output [2:0]ImmSrc;
    output [3:0]ALUControl;
    output [1:0] ResultSrc, ALUSrcB;
    

    wire [1:0]ALUOp;

    Main_Decoder Main_Decoder(
                .Op(Op),
                .RegWrite(RegWrite),
                .ImmSrc(ImmSrc),
                .MemWrite(MemWrite),
                .ResultSrc(ResultSrc),
                .Branch(Branch),
                .ALUSrcA(ALUSrcA),
                .ALUOp(ALUOp),
                .Jump(Jump),
                .ALUSrcB(ALUSrcB)
    );

    ALU_Decoder ALU_Decoder(
                            .ALUOp(ALUOp),
                            .funct3(funct3),
                            .funct7(funct7),
                            .op(Op),
                            .ALUControl(ALUControl)
    );

endmodule