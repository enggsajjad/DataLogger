`timescale 1ns / 1ns


module tf_mux_eeprom;

	// Inputs
	reg sel1;
	reg [1:0] sel_u;
	reg [1:0] sel_f;
	reg CSf;
	reg CSu;

	// Outputs
	wire [3:0] CSe;

	// Instantiate the Unit Under Test (UUT)
	mux_eeprom uut (
		.sel1(sel1), 
		.sel_u(sel_u), 
		.sel_f(sel_f), 
		.CSf(CSf), 
		.CSu(CSu), 
		.CSe(CSe)
	);

	initial begin
		// Initialize Inputs
		sel1 = 0;
		sel_u = 0;
		sel_f = 0;
		CSf = 0;
		CSu = 0;

		// Wait 100 ns for global reset to finish
		#100 CSf=0;
		#100 CSu=1;
		#100 CSf=0;
		#100 CSu=1;
		
		sel1 = 1;
		
		#100 CSf=1;
		#100 CSu=0;
		#100 CSf=1;
		#100 CSu=0;
		
		sel_u = 1;
		sel_f = 0;
		
		#100 CSf=1;
		#100 CSu=0;
		#100 CSf=1;
		#100 CSu=0;
		
		#100 CSf=0;
		#100 CSu=1;
		#100 CSf=0;
		#100 CSu=1;
        
		// Add stimulus here

	end
      
endmodule

