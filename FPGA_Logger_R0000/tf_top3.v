`timescale 1ns / 1ns


module tf_top3;

	// Inputs
	reg clk;
	reg res;
	reg start_pulse;
	reg pulse_in;
	
	reg nDRDY;
	reg SDIN1;
	wire SCLK1;
	
/////////////	
	reg CSu;
	reg SDOUTu;
	reg SCLKu;
	wire SDINu;
/////////////////

/////////
   reg SDOUTe; 
	wire SDIN; 
   wire SCLKe; 
   wire [3:0] CSe;

/////////

	
	
/////////////	
	wire relayAp; 
   wire relayAn; 
   wire relayBp; 
   wire relayBn; 
   wire Clk_Out; 
/////////////////////	
	
reg [1:0] shift1;
reg [1:0] shift2;
reg [15:0] shift3;
reg [15:0] cnt;

wire pedge;
wire nedge;
wire data_done;
	
	
	// Instantiate the module
top_ADC_buff_EEPROM5 top3 (
    .clk(clk), 
    .res(res), 
    .start_pulse(start_pulse), 
    .data_done(data_done), 
    .pulse_in(pulse_in), 
    .relayAp(relayAp), 
    .relayAn(relayAn), 
    .relayBp(relayBp), 
    .relayBn(relayBn), 
    .Clk_Out(Clk_Out), 
    .SDOUTu(SDOUTu), 
    .SCLKu(SCLKu), 
    .CSu(CSu), 
    .SDINu(SDINu), 
    .nDRDY(nDRDY), 
    .SDIN1(SDIN1), 
    .SCLK1(SCLK1), 
    .SDOUTe(SDOUTe), 
    .SDINe(SDINe), 
    .SCLKe(SCLKe), 
    .CSe(CSe)
    );
	
	
	
	// Instantiate the Unit Under Test (UUT)

	initial begin
		// Initialize Inputs
		clk = 0;
		res = 0;
		start_pulse = 0;
		nDRDY = 0;
		SDIN1 =0 ;
		
		CSu=0;
	   SDOUTu=0;
	   SCLKu=0;
		SDOUTe=0;
		pulse_in=0;

		// Wait 100 ns for global reset to finish
		#100 res=1;
		#100 res=0;
       

      #100 start_pulse=1;
		#100 start_pulse=0;	

		//#35_000_000 res=1;
		//#100 res=0;
		//#5_000_000 start_pulse=1;
		//#100 start_pulse=0;
		// Add stimulus here

	end
always 
#20 clk = ~clk; 

always @(shift3)
SDIN1=shift3[15];

always @(posedge clk  or posedge res)
if (res)
	shift1<= 0;
else 
	shift1<={shift1[0],nDRDY};

assign pedge=(~shift1[1])&shift1[0];

always @(posedge clk or posedge res)
if (res)
	cnt<= 0;
else if (pedge)
	cnt<=cnt+1;
else
  cnt <=cnt;	


always @(posedge clk  or posedge res)
if (res)
	shift2<= 0;
else 
	shift2<={shift2[0],SCLK1};

assign nedge=(shift2[1])&(~shift2[0]);

always @(posedge clk  or posedge res)
if (res)
	shift3<= 0;
else if (pedge)
  shift3<=cnt;
else if (nedge)  
	shift3<={shift3[14:0],1'b0};
else
  shift3<=shift3;	

	
always 
begin
#31000 nDRDY=1;
#250 nDRDY=0;
end


endmodule
