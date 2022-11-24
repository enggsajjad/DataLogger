module SPI_ADC
(
input clk,
input res,

output drdy,
output [15:0] dataout,


/// spi devices
input SDIN, //from adc
input nDRDY,// from ADC
//output SDOUT;//to adc 
output SCLK, //to adc 
output nCS// to adc 
);


wire drdy1;
reg [11:0] clkdiv;
reg [2:0] shift1;
reg [2:0] shift3;
reg  [1:0] shift2;
reg [15:0] datashift;
reg [15:0] dataout1;



wire nedgeDRDY1;
wire pedgeSCLK;
wire reset;
assign reset=res;
assign nCS=1'b0;
assign dataout=dataout1; 


always @(posedge clk or posedge reset)
if (reset)
	shift1 <= 7;
else 
	shift1<= {shift1[1:0],nDRDY}; 
assign nedgeDRDY1= (~shift1[2])&(shift1[1]);//posedge

always @(posedge clk or posedge reset)
if (reset)
	shift3 <= 0;
else 
	shift3<= {shift3[1:0],clkdiv[8]}; 
   
assign drdy1= (~shift3[1])&(shift3[0]);
assign drdy= (~shift3[2])& shift3[1]; //posedge
	

always @(posedge clk or posedge reset)
if (reset)
	clkdiv<= 0;
else if (nedgeDRDY1)
	clkdiv<=0;
else if (clkdiv[8]==1)
  clkdiv <= clkdiv; 
else 
  clkdiv <= clkdiv+1;
	   
assign SCLK = (~clkdiv[7])& clkdiv[2];


/// get posedge and negedge of sclk
always @(posedge clk or posedge reset)
if (reset)
	shift2 <= 0;
else 
	shift2<= {shift2[0],SCLK}; 
   
assign pedgeSCLK=(~shift2[1])& (shift2[0]);


//********** Serial in Parallel Out
always @(posedge clk or posedge reset)
if (reset)
	datashift <= 0;
else if (pedgeSCLK)
	datashift<= {datashift[14:0],SDIN}; 
else 
	datashift<= datashift;
	
always @(posedge clk or posedge reset)
if (reset)
	dataout1 <= 0;
else if (drdy1)
	dataout1 <= datashift;
else
	dataout1 <= dataout1;
	


endmodule
