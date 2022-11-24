
module decimation
(
   input clk,
   input reset,
   input [2:0] rate,
   output drdy,
   output [15:0] dataout,
   /// adc interface
   input SDIN, //from adc
   input nDRDY,// from ADC
   //output SDOUT;//to adc 
   output SCLK, //to adc 
   output nCS// to adc 
);

   wire [15:0] dout1;
   wire drdy1;
   // Instantiate the module
   adc adc (
      .clk(clk), 
      .reset(reset), 
      .nDRDY(nDRDY), //from adc
      .SDIN(SDIN), ////from adc 
      //.SDOUT(SDOUT1), //to adc
      .SCLK(SCLK), //to adc
      .nCS(nCS), //to adc
      .drdy(drdy1), //local signal
      .dataout(dout1) //16 bit data at 32ks rate
   );

   // Instantiate the module
   cu_decimation cu2 (
      .clk(clk), 
      .reset(reset), 
      .drdy(drdy1), //input
      .datain(dout1),//16 bit data in 
      .rate(rate), //select decimation 16k or 8k or 1k
      .dataout(dataout), //16 bit decimated data at 16k or 8k or 1k
      .data_rdy(drdy)    //ready for decimated data 
   );
endmodule
