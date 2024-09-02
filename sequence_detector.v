// Verilog code for Sequence Detector
    // Define Sequence Detector module
    module sequence_detector (
        input clock,
        input [3:0] number, // Define input ports clock, number
        output reg pattern // Define output port patter
    );


	 //////////////////////////////////////////////
    // Define your State Machine Parameters Here
    parameter ST_ONE = 2'b00;
	 parameter ST_ZERO = 2'b01;
	 parameter ST_NINE = 2'b10;
	 parameter ST_FOUR = 2'b11;
	 //////////////////////////////////////////////

    // defining 2-bit register
    reg [1:0] state = ST_ONE;

    initial begin // define initial state output register
        pattern = 0;
    end

    always @(posedge clock) begin
        pattern = 0;
        case (state)
			   ///////////////////////////////////////
				// Do not modify above part of the code
            // Write your state machine here
				ST_ONE: begin
					// you can read input inside always block like this
					 if (number == 1) begin
					      state = ST_ZERO; // you can assign output values for a register like this.
					 end
					 else begin
							state = ST_ONE; // write your own logic here
					 end
				end
				ST_ZERO: begin
					// you can read input inside always block like this
					 if (number == 0) begin
					      state = ST_NINE; // you can assign output values for a register like this.
					 end
					 else begin
							state = ST_ONE; // write your own logic here
					 end
				end
				ST_NINE: begin
					// you can read input inside always block like this
					 if (number == 9) begin
					      state = ST_FOUR; // you can assign output values for a register like this.
					 end
					 else begin
							state = ST_ONE; // write your own logic here
					 end
				end
				ST_FOUR: begin
					// you can read input inside always block like this
					 if (number == 4) begin
					      pattern = 1;
							state = ST_ONE; // you can assign output values for a register like this.
					 end
					 else begin
							state = ST_ONE; // write your own logic here
					 end
					 // Do not modify below part of the code
					 ///////////////////////////////////////
				end
        endcase
    end

    endmodule