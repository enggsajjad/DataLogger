`timescale 1ns / 1ns

module tfwriteEEPROM;

	// Inputs
	reg clk;
	reg rst;
	reg start_pulse;
	reg spi_busy;

	// Outputs
	wire load_data;
	wire nCS;
	wire [7:0] dataout;
	integer i;

	// Instantiate the Unit Under Test (UUT)
	write_eeprom uut (
		.clk(clk), 
		.rst(rst), 
		.start_pulse(start_pulse), 
		.spi_busy(spi_busy), 
		.load_data(load_data), 
		.nCS(nCS), 
		.dataout(dataout)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		start_pulse = 0;
		spi_busy = 0;

		// Wait 100 ns for global reset to finish
		#100 rst=1;
		#100 rst=0;
		
	
		
		
		for (i=1;i<258;i=i+1)
		
		begin
		#100 start_pulse=1;
		#100 start_pulse=0;
		
		#10_00 spi_busy=1;
		#100 spi_busy=0;
		
	   end
		
        
		// Add stimulus here

	end

 
always 
#10 clk = ~clk; 
      
endmodule

