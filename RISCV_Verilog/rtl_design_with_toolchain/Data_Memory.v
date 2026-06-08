module Data_Memory(clk,rst_n,WE,WD,A,RD);

    input clk,rst_n;
    input WE; //Write Enable signal
    input [31:0]A,WD; //memory address and Write Data (data to store in memory)
    output [31:0]RD; //Read Data from memory

    reg [31:0] mem [0:1023]; //This creates a memory array of 1024 locations, each location is 32 bits

    always @ (posedge clk)
    begin
        if(WE)
            mem[A] <= WD;
    end

    //asynchronous read
    assign RD = (~rst_n) ? 32'd0 : mem[A];


    always @ (posedge clk) begin
        $writememh("dmemory.hex",mem);
    end


endmodule