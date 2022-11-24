`timescale 1ns / 1ns


module tf_top_adc_buff2;

	// Inputs
	reg clk;
	reg res;
	reg start_pulse;
	reg [7:0] read_addr;
	reg nDRDY;
	reg SDIN1;
	reg [2:0] rate;

	// Outputs
	wire write_done;
	wire toggle_buff;
	wire [7:0] dout;
	wire SCLK1;
	wire nCS1;
	reg [15:0] cnt;
	reg [15:0] shift3;
	reg [1:0] shift1;
   reg [1:0] shift2;
	wire drdy_sync;
	wire sclk_nedge;
	reg [9:0] cnt2;

	// Instantiate the Unit Under Test (UUT)
	top_ADC_buff2 uut (
		.clk(clk), 
		.res(res), 
		.start_pulse(start_pulse), 
		.write_done(write_done),
      .rate(rate),  		
		.read_addr(read_addr), 
		.dout(dout), 
		.nDRDY(nDRDY), 
		.SDIN1(SDIN1), 
		.SCLK1(SCLK1), 
		.nCS1(nCS1)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		res = 0;
		rate=1;
		start_pulse = 0;
		read_addr = 0;
		nDRDY = 0;
		SDIN1 = 0;

		#100 res=1;
		#100 res=0;
       
		#100 start_pulse=1;
		#100 start_pulse=0;
      
		
	end
      
always 
#20 clk = ~clk; 

always @(posedge clk or posedge res)
if (res)
cnt2<=0;
else if(write_done)
cnt2<=0;
else if (cnt2==1023)
cnt2<=cnt2;
else
cnt2<=cnt2+1;

always @(cnt2)
 read_addr=cnt2[9:2];
	
always 
begin
#31000 nDRDY=1;
#200 nDRDY=0;
end

//
always @(shift3)
 SDIN1=shift3[15];


always @(posedge clk  or posedge res)
if (res)
	shift1<= 0;
else 
	shift1<={shift1[0],nDRDY};

assign drdy_sync=(~shift1[1])&shift1[0];

always @(posedge clk or posedge res)
if (res)
	cnt<= 0;
else if (drdy_sync)
	cnt<=cnt+1;
else
  cnt <=cnt;	


always @(posedge clk  or posedge res)
if (res)
	shift2<= 0;
else 
	shift2<={shift2[0],SCLK1};

assign sclk_nedge=(shift2[1])&(~shift2[0]);

always @(posedge clk  or posedge res)
if (res)
	shift3<= 0;
else if (drdy_sync)
  shift3<=cnt;
else if (sclk_nedge)  
	shift3<={shift3[14:0],1'b0};
else
  shift3<=shift3;	

	

endmodule