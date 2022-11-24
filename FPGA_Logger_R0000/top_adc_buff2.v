
module top_ADC_buff2(

input clk,
input res,
input start_pulse,

input [7:0] read_addr,
input [2:0] rate,

output write_done,//256 bytes are written in memory
output [7:0] dout,

//// ADC SPI
input nDRDY,
input SDIN1,
//output SDOUT1,
output SCLK1,
output nCS1
  
	);




//assign sel_uC=0;
	 
wire drdy;
wire [15:0] dataout;
wire we;
wire data_sel;

wire [8:0] write_addr;

wire [7:0] din;

/*
reg [15:0] test_cnt;

always @(posedge clk or posedge res)
if (res)
	test_cnt<=0;
else if (start_pulse)
     test_cnt<=0;
else if (drdy)
	test_cnt<=test_cnt+1;
else
    	test_cnt<=test_cnt;
*/

// Instantiate the module
SPI_ADC_Decimation spi1 (
    .clk(clk), 
    .res(res), 
    
	 .SDIN(SDIN1), 
    .nDRDY(nDRDY), 
    .SCLK(SCLK1), 
    .nCS(nCS1),
	 .rate(rate),
	 .drdy(drdy), //
    .dataout(dataout) //16 bit data
    //.dataout() 
    	 
    );
// Instantiate the module
cu_adc_buff cu1 (
    .clk(clk), 
    .rst(res), 
	 .start_pulse(start_pulse),//to start writing data in buffer 
    .drdy(drdy),
    .stop_flag(1'b0), 	 
    .we(we), //output to buff
	 .data_sel(data_sel),
    .write_done(write_done),// 256 bytes are written in buffer
	 .write_addr(write_addr) // buffer write address
    );
	 

// Instantiate the module
ping_pongbuffer p1 (
    .clk(clk), 
    .we(we), 
    .din(din), 
    .read_addr(read_addr), //read data address
    .write_addr(write_addr), //write data address
    .dout(dout) //8 bit data out
    );

assign din =(data_sel==1)? dataout[15:8]:dataout[7:0];
//assign din =(data_sel==1)?test_cnt[15:8]:test_cnt[7:0];


endmodule
