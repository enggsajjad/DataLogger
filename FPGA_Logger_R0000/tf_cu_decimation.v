`timescale 1ns / 1ns



module tf_cu_decimation;

	// Inputs
	reg clk;
	reg reset;
	reg drdy;
	reg [15:0] datain;

	// Outputs
	wire [15:0] dataout;
	wire data_rdy;
	reg [2:0] rate;
   integer k;
	// Instantiate the Unit Under Test (UUT)
	cu_decimation uut (
		.clk(clk), 
		.reset(reset), 
		.drdy(drdy), 
		.datain(datain), 
		.dataout(dataout),
      .rate(rate),      		
		.data_rdy(data_rdy)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		drdy = 0;
		datain = 10;
		rate=3'b001;

		// Wait 100 ns for global reset to finish
		#100 reset=1;
		#100 reset=0;
		
		
		
		 for (k=0;k<3075;k=k+1)
           begin
			  #100 drdy =0;
			  #100 drdy =1;
			  #40 drdy =0;
			  #1000 datain=datain-1;
			  end	
        
		// Add stimulus here

	end
 

always
#20 clk = ~clk; 
 
endmodule

