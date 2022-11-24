`timescale 1ns/1ns

module tf_expQ8();

// DATE:     19:52:58 10/08/2014 
// MODULE:   debounce_explicit
// DESIGN:   debounce_explicit
// FILENAME: tf_db_exp.v
// PROJECT:  debounce
// VERSION:  


// Inputs
    reg clk;
    reg reset;
    reg [4:0] sw;


// Outputs
    wire sw_clear;
    wire pos_tick;
    wire neg_tick;
    wire [2:0] kcode;


// Bidirs


// Instantiate the UUT
    buttons uut (
               .clk(clk), 
               .reset(reset), 
               .sw(sw), 
               .sw_clear(sw_clear), 
               .pos_tick(pos_tick),
               .neg_tick(neg_tick),
               .kcode(kcode)
               );


// Initialize Inputs

        initial begin
            clk = 0;
            reset = 0;
            sw = 5'b00000;

		#20000 reset = 1;
		#100 reset = 0;
		//Button 1
		//switch without glitches
		#10000 sw[0] = 1;
		#500_000 sw[0] = 0;

		//Button 2
		//switch with glitches
		//glitch while rising
		#500_000 sw[1] = 1;
		#500 sw[1] = 0;
		#500 sw[1] = 1;
		#500 sw[1] = 0;
		#500 sw[1] = 1;
		#400_000 sw[1] = 0;
		//glitch while falling
		#500 sw[1] = 1;
		#500 sw[1] = 0;
		#500 sw[1] = 1;
		#500 sw[1] = 0;


		//Button 3
		//switch without glitches
		#25_000_000 sw[2] = 1;
		#45_000 sw[2] = 0;



		//Button 4
		//switch with glitches
		//glitch while rising
		#4_000_000 sw[3] = 1;
		#500 sw[3] = 0;
		#500 sw[3] = 1;
		#500 sw[3] = 0;
		#500 sw[3] = 1;
		#45_000 sw[3] = 0;
		//glitch while falling
		#500 sw[3] = 1;
		#500 sw[3] = 0;
		#500 sw[3] = 1;
		#500 sw[3] = 0;        


		//Button 5
		//switch with glitches
		//glitch while rising
		#4000_000 sw[4] = 1;
		#500 sw[4] = 0;
		#500 sw[4] = 1;
		#500 sw[4] = 0;
		#500 sw[4] = 1;
		#45_000 sw[4] = 0;
		//glitch while falling
		#500 sw[4] = 1;
		#500 sw[4] = 0;
		#500 sw[4] = 1;
		#500 sw[4] = 0;        

	   end

always //50MHz
#10 clk = ~clk;


endmodule

