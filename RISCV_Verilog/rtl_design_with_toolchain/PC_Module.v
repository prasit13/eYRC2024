module PC_Module(clk,rst_n,PC, PCSrcE,PCTargetE, PCPlus4F, en_n);
    input clk,rst_n;
    input en_n; //enable=> 0: Normal PC update, 1: PC reset to 0
    input PCSrcE; // Control signal for branch/jump selection
    input [31:0] PCPlus4F,PCTargetE;
    output reg [31:0]PC;
    
    wire [31:0]PC_Next;

    Mux MUX_FETCH(
        .in0(PCPlus4F),
        .in1(PCTargetE),
        .s(PCSrcE),
        .out(PC_Next)
    );

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n == 1'b0)
            PC <= 32'd0;
        else if(!en_n)
            PC <= PC_Next;
        else
            PC <= 32'd0;
    end   

endmodule