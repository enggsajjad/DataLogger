`timescale 1ns / 1ns


module tf_adc;

	// Inputs
	reg clk;
	reg reset;
	reg nDRDY;
	
	reg SDIN;
	
	// Outputs
	//wire SDOUT;
	wire SCLK;
	wire nCS;
	wire drdy;

	// Bidirs
	wire [15:0] dataout;

// Instantiate the module
adc instance_name (
    .clk(clk), 
    .reset(reset), 
    .nDRDY(nDRDY), 
    .SDIN(SDIN), 
    //.SDOUT(SDOUT), 
    .SCLK(SCLK), 
    .nCS(nCS), 
    .drdy(drdy), 
    .dataout(dataout)
    );



	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		nDRDY = 1;
		SDIN = 1;
		
		// Wait 100 ns for global reset to finish
		#100 reset=1;
		#100 reset=0;
				
		#1000 nDRDY=0;
		#200 nDRDY=1;
		
		#100_000 nDRDY=0;
		#200 nDRDY=1;
		
        
		// Add stimulus here

	end
 
always
#50 clk=~clk;



endmodule

