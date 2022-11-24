// SPI Interface to send command and data to EEPROM
module eeprom(clk,reset,ld_data,datain,SCLK,SDOUT,SPI_busy);

   input clk;
   input reset;
   input ld_data;
   input [7:0] datain;

   /// spi devices
   //input SDIN; //eeprom
   output SDOUT;//eeprom
   output SCLK; //eeprom
   //output nCS;//eeprom
   output SPI_busy;

   reg [6:0] clkdiv;
   reg [7:0] dataout;
   reg [1:0] shift2;

   wire nedgeSCLK;

   assign SPI_busy=clkdiv[6];

   always @(posedge clk or posedge reset)
   if (reset)
   	clkdiv<= 0;
   else if (ld_data)
   	clkdiv<=0;
   else if (clkdiv[6]==1)
     clkdiv <= clkdiv; 
   else 
     clkdiv <= clkdiv+1;
	   
   assign SCLK = (~clkdiv[6])& clkdiv[2];// 8 clocks

   /// get posedge and negedge of sclk
   always @(posedge clk or posedge reset)
   if (reset)
   	shift2 <= 0;
   else 
   	shift2<= {shift2[0],SCLK}; 
   
   assign nedgeSCLK= shift2[1]&(~shift2[0]);


   //******** Parallel in Serial Out ********************

   always @(posedge clk or posedge reset)
   if (reset)
   	dataout <= 0;
   else if (ld_data)
   	dataout <= datain;
   else if (nedgeSCLK)
   	dataout <= {dataout[6:0],1'b0};
   else 
   	dataout <= dataout;
	
   assign SDOUT = dataout[7];


endmodule
