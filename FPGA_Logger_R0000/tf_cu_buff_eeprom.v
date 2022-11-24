`timescale 1ns / 1ns


module tf_cu_buff_eeprom;

	// Inputs
	reg clk;
	reg rst;
	reg start_pulse;
	reg spi_busy;
	reg data_done;

	// Outputs
	wire load_data;
	wire nCS;
	wire [2:0] sel_data;
	wire sel_eeprom;
	wire page_done;
	wire block_done;
	wire [7:0] addr;
	integer i;

	// Instantiate the Unit Under Test (UUT)
	cu_buff_eeprom uut (
		.clk(clk), 
		.rst(rst), 
		.start_pulse(start_pulse), 
		.spi_busy(spi_busy), 
		.data_done(data_done), 
		.load_data(load_data), 
		.nCS(nCS), 
		.sel_data(sel_data), 
		.page_done(page_done), 
		.addr(addr)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		start_pulse = 0;
		spi_busy = 0;
		data_done = 0;

		// Wait 100 ns for global reset to finish
		#100 rst=1;
		#100 rst=0;
		
		#100 start_pulse=1;
		#100 start_pulse=0;
		
		for (i=0;i<600;i=i+1)
		begin
		#10000 spi_busy=1;
		#100 spi_busy=0;
		end
		
        
		// Add stimulus here

	end

always
#10 clk =~clk;      
endmodule

