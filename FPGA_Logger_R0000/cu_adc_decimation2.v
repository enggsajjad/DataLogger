module cu_adc_decimation2(

    input clk,
    input rst,
    input drdy,
	 input [15:0] datain,
	 input [2:0] rate,
	 
	 output [15:0] dataout,
	 output data_rdy
	 	 
	 );


reg [4:0] state;
reg [20:0] datareg;


reg ld_acc;
reg rst_acc;

reg data_rdy1;
reg data_rdy2;

wire [20:0] sum;
reg rst_cnt; 
reg inc_cnt; 
reg [4:0]cnt;
wire [4:0] s_rate; 
reg [15:0] dataout1;
reg [15:0] dataout2;



parameter Start=0, 
          ResetAccum=1, ChkDrdy=2,
			 WriteAccum=3, ChkCount=4,
			 IncCount=5, Delay1=6,
			 Stop=7;

//assign s_rate={rate[2],rate[2],rate[2],rate[1],rate[0]};
assign s_rate={{3{rate[2]}},rate[1],rate[0]};

always @(posedge clk or posedge rst)
if(rst)
begin
state<=Start;

ld_acc<=0;
rst_acc<=0;
data_rdy1<=0;
data_rdy2<=0;
inc_cnt<=0; 
rst_cnt<=0; 


end

else 
case(state)
Start:			begin //0
					ld_acc<=0;
					rst_acc<=0;
					data_rdy1<=0;
					data_rdy2<=0; 
					inc_cnt<=0; 
					rst_cnt<=0; 
					state<=ResetAccum;
					end
	
			
ResetAccum: 	begin //1
               rst_cnt<=1; 
					rst_acc<=1;
					state<=ChkDrdy;
					end

ChkDrdy:		   begin //6
               rst_acc<=0;
					rst_cnt<=0;
               inc_cnt<=0;					
					if (drdy)
					  	state<=WriteAccum;
					else
						state<=ChkDrdy;
					end
					
				
WriteAccum:   begin //3
					ld_acc<=1;
					state<=ChkCount;
					end	

ChkCount:   begin //3
					ld_acc<=0;
					if (cnt==s_rate)
					   state<=Delay1;
					else
                	state<=IncCount;				
					end	


IncCount:	begin //5
               inc_cnt<=1;
					state<=ChkDrdy;
					end

Delay1:     begin
            data_rdy1<=1;  				
            state<=Stop;
			   end
	
////////////////////////////////// 

Stop: 			begin
               data_rdy1<=0; 
					data_rdy2<=1; 
            	state<=Start;
					end
endcase


always @(posedge clk or posedge rst)
if(rst)
  	datareg<=0;
else if (rst_acc)
   datareg<=0;	
else if(ld_acc)
  	datareg<=sum;
else
  	datareg<=datareg;

always @(posedge clk or posedge rst)
if(rst)
  	cnt<=0;
else if (rst_cnt)
   cnt<=0;	
else if(inc_cnt)
  	cnt<=cnt+1;
else
  	cnt<=cnt;

//assign sum = {datain[15],datain[15],datain[15],datain[15],datain[15],datain} + datareg;
assign sum = {{5{datain[15]}},datain} + datareg;


always @(rate,datareg)
if (rate==3'b001)
   dataout1 =datareg[16:1];
else if (rate==3'b011)
	dataout1 =datareg[17:2];
else
   dataout1 =datareg[20:5];	


always @(posedge clk or posedge rst)
if(rst)
  	dataout2<=0;
else if (data_rdy1)
   dataout2<=dataout1;	
else 
  	dataout2<=dataout2;


assign dataout=dataout2;
assign data_rdy =data_rdy2;

endmodule
