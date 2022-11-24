////////////////////////
module Filter_clk2(

input clk,
input rst,
input Clk_Slct,

output Clk_Out
    );
	 
 
reg [9:0] cnt1;


assign Clk_Out=(Clk_Slct)?cnt1[5]:cnt1[8];


always @(posedge clk or posedge rst)
if (rst)
	cnt1<=0;
else	
   cnt1<=cnt1+1;
	
	


endmodule
