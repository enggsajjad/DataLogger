// Receiving ADC data using SPI Interface
module adc
(
   input clk,
   input reset,
   output drdy,//data recieved and ready for use
   output [15:0] dataout,

   // spi devices
   input SDIN, //from adc
   input nDRDY,// from ADC
   //output SDOUT;//to adc 
   output SCLK, //to adc 
   output nCS// to adc 
);



   reg [8:0] clkdiv;
   reg [2:0] shift1;
   reg [2:0] shift3;
   reg  [1:0] shift2;
   reg [15:0] datashift;
   reg [15:0] dataout1;


   wire drdy1;
   wire nedge_nDRDY;
   wire pedgeSCLK;

   assign nCS=1'b0;
   assign dataout=dataout1; 


   always @(posedge clk or posedge reset)
   if (reset)
   	shift1 <= 0;
   else 
   	shift1<= {shift1[1:0],nDRDY}; 
   assign nedge_nDRDY= (~shift1[2])&(shift1[1]);

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
   else if (nedge_nDRDY)
   	clkdiv<=0;
   else if (clkdiv[8]==1)
   //else if (clkdiv[7]==1)
     clkdiv <= clkdiv; 
   else 
     clkdiv <= clkdiv+1;
	   
//   assign SCLK = (~clkdiv[7])& clkdiv[2];
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
