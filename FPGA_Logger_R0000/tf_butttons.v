`timescale 1ns/1ns

module tf_butttons();

// DATE:     09:50:37 10/14/2014 
// MODULE:   test_buttons
// DESIGN:   test_buttons
// FILENAME: tf_butttons.v
// PROJECT:  debouncing
// VERSION:  


// Inputs
    reg clk;
    reg reset;
    reg [4:0] sw;


// Outputs

    wire pos_tick;
    wire neg_tick;
    wire tx;


// Bidirs


// Instantiate the UUT
    test_buttons uut (
        .clk(clk), 
        .reset(reset), 
        .sw(sw), 
        .sw_clear(sw_clear), 
        .pos_tick(pos_tick), 
        .neg_tick(neg_tick), 
        .ser_out(ser_out)
        );


// Initialize Inputs

        initial begin
            clk = 0;
            reset = 0;
            sw = 5'b11111;

		#2000 reset = 1;
		#100 reset = 0;
		//Button 1
		//switch without glitches
		#1000 sw[0] = 0;
		#45_000 sw[0] = 1;

		//Button 2
		//switch with glitches
		//glitch while rising
		#4000_000 sw[1] = 0;
		#500 sw[1] = 1;
		#500 sw[1] = 0;
		#500 sw[1] = 1;
		#500 sw[1] = 0;
		#45_000 sw[1] = 1;
		//glitch while falling
		#500 sw[1] = 0;
		#500 sw[1] = 1;
		#500 sw[1] = 0;
		#500 sw[1] = 1;


		//Button 3
		//switch without glitches
		#4_000_000 sw[2] = 0;
		#45_000 sw[2] = 1;



		//Button 4
		//switch with glitches
		//glitch while rising
		#4_000_000 sw[3] = 0;
		#500 sw[3] = 1;
		#500 sw[3] = 0;
		#500 sw[3] = 1;
		#500 sw[3] = 0;
		#45_000 sw[3] = 1;
		//glitch while falling
		#500 sw[3] = 0;
		#500 sw[3] = 1;
		#500 sw[3] = 0;
		#500 sw[3] = 1;        


		//Button 5
		//switch with glitches
		//glitch while rising
		#4000_000 sw[4] = 0;
		#500 sw[4] = 1;
		#500 sw[4] = 0;
		#500 sw[4] = 1;
		#500 sw[4] = 0;
		#45_000 sw[4] = 1;
		//glitch while falling
		#500 sw[4] = 0;
		#500 sw[4] = 1;
		#500 sw[4] = 0;
		#500 sw[4] = 1;        

	   end

always //50MHz
#10 clk = ~clk;


endmodule

