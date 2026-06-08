module Register_File(clk,rst_n,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk;
    input rst_n; //Used here only for read-output control.
    input WE3; //Controls whether write occurs, 1: write enabled, 0: no write
    input [4:0]A1,A2,A3; //A1: read address 1, A2: read address 2, A3: write address; e.g.- 5'b00001 => x1 reg
    input [31:0]WD3; //Data to be written into register A3
    output [31:0]RD1,RD2; //RD1: contents of register A1, RD2: contents of register A2

    reg [31:0] Register [0:31]; //32 registers, each 32 bits wide
    integer i;

    always @ (posedge clk)
    begin
        if(WE3 & (A3 != 5'h00)) //Write happens only if: 1. write enable is active and 2. destination register is NOT x0
            Register[A3] <= WD3;
    end

    //asynchronous reads
    assign RD1 = (rst_n==1'b0) ? 32'd0 : Register[A1];
    assign RD2 = (rst_n==1'b0) ? 32'd0 : Register[A2];

    //x0=32'h0000_0000 and x1...x31 = 32'hffff_ffff
    initial begin
        Register[0] = 32'h00000000;
        for (i=1; i<32; ++i) begin
            Register[i]=32'hffff_ffff;
        end
    end

    //writes all register contents into reg.hex
    always @(posedge clk) begin
        $writememh("reg.hex",Register);
    end
endmodule