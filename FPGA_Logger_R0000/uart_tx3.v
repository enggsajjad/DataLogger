module uart_tx
#
(
parameter   crystal = 22118400,  //default
            baud = 9600
)
(
   //Input
   input clk,
   input reset,
   input din_rdy,
   input [7:0] din_byte,
   //Output
   output tx,
   output tx_done
);

   reg [8:0] data_buf;
   reg [3:0] bcnt;// Bit Count
   reg [3:0] scnt;// Samples Count
   reg [3:0] state;
   reg baud_tick;
   reg [7:0] baud_cnt;
   reg tx_done_reg;
   reg inc_scnt;
   reg rst_scnt;
   reg inc_bcnt;
   reg rst_bcnt;
   reg enb_shift;

   localparam div = crystal/(baud*16) - 1;
   localparam
      Start=0,
      Enable_Shift=1,
      Chk_Enable=2,
      Inc_SCount=3,
      Chk_SCount=4,
      Inc_BCount=5,
      Chk_BCount=6,
      TxDone=7,
      Stop=8;

   // shift left for tranmission on tx
   always @(posedge clk or posedge reset)
   begin
   if(reset)
   	data_buf <= 9'h1ff;
   else if(enb_shift) ///din_rdy
   	data_buf <= {din_byte,1'b0};	// at just arriving the start_bit_sig, we load data into data_bffer
   else if (inc_bcnt)
      data_buf <= {1'b1,data_buf[8:1]};
   else 
       data_buf <= data_buf;		     
   end

   assign tx = data_buf[0];
   assign tx_done = tx_done_reg;

   // counter that count no. of shifted bits
   always @(posedge clk or posedge reset)
   begin
   if(reset)
   	bcnt <= 0;
   else if (rst_bcnt)
   	bcnt <= 0;
   else  if (inc_bcnt)
   	bcnt<=bcnt+1;
   else
   	bcnt <= bcnt;
   end

   // counter that sample each bit 16 times
   always @(posedge clk or posedge reset)
   begin
   if(reset)
   	scnt <= 0;
   else if (rst_scnt)
   	scnt <= 0;
   else  if (inc_scnt)
   	scnt<=scnt+1;
   else
   	scnt<=scnt;
   end



   always @(posedge clk or posedge reset)
   if(reset)
      begin
      tx_done_reg<=0;
      inc_scnt<=0;
      rst_scnt<=1;
      inc_bcnt<=0;
      rst_bcnt<=1;
      enb_shift<=0;
      state<=Start;
      end
   else 
   case(state)
      Start:			
         begin
         tx_done_reg<=0;
         inc_scnt<=0;
         rst_scnt<=1;
         inc_bcnt<=0;
         rst_bcnt<=1;
         enb_shift<=0;
         if(din_rdy)
         	state<=Enable_Shift;
         else
         	state<=Start;
         end
      Enable_Shift:		
         begin
         enb_shift<=1;
         rst_scnt<=0;
         rst_bcnt<=0;
         state<=Chk_Enable;
         end
      Chk_Enable:
         begin
         enb_shift<=0;
         if (baud_tick)
         	state<=Inc_SCount;
         else
         	state<=Chk_Enable;
         end
      Inc_SCount: 		
         begin
         inc_scnt<=1;
         state<=Chk_SCount;
         end
      Chk_SCount:  
         begin
         inc_scnt<=0;
         if (scnt == 15)
             state<=Inc_BCount;
         else
             state<=Chk_Enable;
         end					
      Inc_BCount: 		
         begin
         inc_bcnt<=1;
         state<=Chk_BCount;
         end
      Chk_BCount:   
         begin
         inc_bcnt<=0;
         if (bcnt==9) //actual value=9,here 2 stop bits are send
         	state<=TxDone;
         else
         	state<=Chk_Enable;
         end				
      TxDone: 		
         begin
         tx_done_reg<=1; 
         state<=Stop;
         end
      Stop: 			
         begin
         tx_done_reg<=0;
         state<=Start;
         end
   endcase

   // generate baudrate; baud_tick
   always @(posedge clk or posedge reset)
   if(reset)
   	baud_cnt<=0;
   else if (din_rdy)
      baud_cnt<=0;	
   else if (baud_cnt == div)
   	baud_cnt<=0;
   else
   	baud_cnt<=baud_cnt+1;

   always @(posedge clk or posedge reset)
   if(reset)
   	baud_tick<=0;
   else if (baud_cnt == div)
   	baud_tick<=1;
   else
   	baud_tick<=0;

endmodule