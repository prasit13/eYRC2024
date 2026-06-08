module Mux (in0,in1,s,out);

    input [31:0]in0,in1;
    input s;
    output [31:0]out;

    assign out = (~s) ? in0 : in1 ;
    
endmodule

module Mux_3_by_1 (in00,in01,in10,s,out);
    input [31:0] in00,in01,in10;
    input [1:0] s;
    output [31:0] out;

    assign out = (s == 2'b00) ? in00 : (s == 2'b01) ? in01 : (s == 2'b10) ? in10 : 32'h00000000;
    
endmodule