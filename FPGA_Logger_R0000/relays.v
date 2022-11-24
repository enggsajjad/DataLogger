// Controls the impedence relays, and generate a pulse to latch the specific relay
module relays
(
   input clk,
   input reset,
   input gen_pulse,
   input sel,
   output relayAp,relayAn,relayBp,relayBn,
   output pulse_out
);
   
   localparam N = 15;//1.48ms @ 22118400
   reg [N-1:0] cnt;
   reg pulse;

   assign pulse_out = pulse;

   always @(posedge clk, posedge reset)
   if (reset)
      cnt <= {N{1'b1}};
   else if (gen_pulse)
      cnt <= 0;
   else if(cnt == {N{1'b1}})
      cnt <= cnt;
   else
      cnt <= cnt + 1;

   always @(posedge clk, posedge reset)
   if (reset)
      pulse <= 0;
   else if (cnt == 1)
      pulse <= 1;
   else if(cnt == {N{1'b1}})
      pulse <= 0;
   else
      pulse <= pulse;

   //Current, 324ohm
   assign relayAp=(sel==0)? pulse:1'b0;
   assign relayBn=(sel==0)? pulse:1'b0;

   //No Current, 50ohm
   assign relayAn=(sel==1)? pulse:1'b0;
   assign relayBp=(sel==1)? pulse:1'b0;

endmodule
