// Generate filter clock as sel=0 then filter_clk = 40K
//                         sel=1 then filter_clk = 400K
module filter_clk
(
   input clk,
   input reset,
   input sel,

   output filter_clk
);
	 
 
   reg [9:0] cnt;


   assign filter_clk=(sel)?cnt[5]:cnt[8];


   always @(posedge clk or posedge reset)
   if (reset)
   	cnt<=0;
   else	
      cnt<=cnt+1;
	
endmodule