
`timescale 1ns/1ns
module tf_relays();

// DATE:     23:02:50 10/16/2014 
// MODULE:   relays
// DESIGN:   relays
// FILENAME: tf_relays.v
// PROJECT:  data_loggerVer5
// VERSION:  


// Inputs
    reg clk;
    reg reset;
    reg gen_pulse;
    reg sel;


// Outputs
    wire relayAp;
    wire relayAn;
    wire relayBp;
    wire relayBn;


// Bidirs


// Instantiate the UUT
    relays uut (
        .clk(clk), 
        .reset(reset), 
        .gen_pulse(gen_pulse), 
        .sel(sel), 
        .relayAp(relayAp), 
        .relayAn(relayAn), 
        .relayBp(relayBp), 
        .relayBn(relayBn)
        );


// Initialize Inputs
        initial begin
         clk = 0;
         reset = 0;
         gen_pulse = 0;
         sel = 0;
         #1000 reset  =1;
         #1000  reset  =0;

         #1000 gen_pulse  =1;
         #1000  gen_pulse  =0;

         #10_000_000  sel  =1;//10ms

         #1000 gen_pulse  =1;
         #1000  gen_pulse  =0;
        end
//@ 22118400
always
#23 clk = ~clk;
endmodule

