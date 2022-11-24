module uart_rx
#
(
parameter   crystal = 22118400,  //default
            baud = 19200
)
(
   // inputs
   input clk,
   input reset,
   input rx,
   // outputs
   output rx_done,
   output [7:0] dout_byte
);

   reg [4:0] bcnt;// bit count
   reg [4:0] scnt;//sample count
   reg [3:0] state;//state
   reg [1:0] shift1;//shift register for rx; detect negedge
   reg rx_done_reg;
   reg inc_scnt;
   reg rst_scnt;
   reg inc_bcnt;
   reg rst_bcnt;
   reg busy;
   reg enb_shift;// enable shifting
   reg baud_tick;
   reg [7:0] dout_byte_reg;
   reg [9:0] shift_reg;
   reg [7:0] baud_cnt;
   wire nedge_rx;

   //parameter crsytalclk= 22118400; //(in hertz)
   //parameter baud  = 9600;
   localparam div   = crystal/(baud*16) - 1;

   localparam
      Start=0,
      Chk_Enable=1,
      Inc_SCount=2,
      SCount_Delay=3,
      Enable_Shift=4,
      Chk_SCount=5,
      Inc_BCount=6,
      BCount_Delay=7,
      Chk_BCount=8,
      RxDone=9;
              
   // detect input data negedge
   always @(posedge clk or posedge reset)
   begin
   if (reset)
      shift1 <= 0;
   else
      shift1 <= {shift1[0],rx};
   end

   assign nedge_rx = shift1[1]&(~shift1[0]);


   // Sample Count
   always @(posedge clk or posedge reset)
   begin
   if(reset)
      scnt <= 0; 
   else if (rst_scnt)
      scnt <= 0;
   else if (inc_scnt)
      scnt <= scnt+1;
   else 
      scnt <= scnt;   	
   end
   
   //Bit Count
   always @(posedge clk or posedge reset)
   begin
   if(reset)
      bcnt <=0;
   else if(rst_bcnt)
      bcnt <=0; 	   
   else if(inc_bcnt)
      bcnt <= bcnt+1;
   else
      bcnt <= bcnt;	
   end

   // shift right incoming data
   always @(posedge clk or posedge reset)
   begin
   if (reset)
      shift_reg <= 10'b000;
   else if (enb_shift)
      shift_reg <= {rx, shift_reg[9:1]}; 
   else
      shift_reg <= shift_reg; 
   end
   
      // Load complete data byte into dout_byte
   always @(posedge clk or posedge reset)
   begin
   if (reset)
      dout_byte_reg <= 0;
   else if (rx_done_reg)
      dout_byte_reg <= shift_reg[8:1];
   else
      dout_byte_reg <= dout_byte_reg;
   end

   assign dout_byte = dout_byte_reg;
   assign rx_done = rx_done_reg;

   always @(posedge clk or posedge reset)
   if(reset)
      begin
      rx_done_reg<=0;
      inc_scnt<=0;
      rst_scnt<=1;
      inc_bcnt<=0;
      rst_bcnt<=1;
      busy<=1;
      enb_shift<=0;
      state<=Start;
      end
   else 
      case(state)
      Start:			
         begin
         rx_done_reg<=0;
         inc_scnt<=0;
         rst_scnt<=1;
         inc_bcnt<=0;
         rst_bcnt<=1;
         busy<=1;
         enb_shift<=0;
         if(nedge_rx)
            state<=Chk_Enable;
         else
            state<=Start;
         end
      Chk_Enable:   
         begin
         busy<=0;
         rst_scnt<=0;
         rst_bcnt<=0;
         if (baud_tick)
            state<=Inc_SCount;
         else
            state<=Chk_Enable;
         end
      Inc_SCount: 		
         begin
         inc_scnt<=1;
         state<=SCount_Delay;
         end
      SCount_Delay:
         begin
         inc_scnt<=0;
         state<=Enable_Shift;
         end					
      Enable_Shift:    
         begin
         if (scnt==8)
            enb_shift <= 1;
         else
            enb_shift<=enb_shift;
         // generate rx_done_reg; enhance loopback continuously at STOP=1.5bits
         if((scnt ==15) && (bcnt==9))
            rx_done_reg <= 1;
         else
            rx_done_reg <= rx_done_reg;
         state<=Chk_SCount;
         end					
      Chk_SCount:  
         begin
         enb_shift<=0;
         rx_done_reg <=0;
         if (scnt[4])//==16
            state<=Inc_BCount;
         else
            state<=Chk_Enable;
         end					
      Inc_BCount: 	
         begin
         inc_bcnt<=1;
         rst_scnt<=1;
         state<=BCount_Delay;
         end
      BCount_Delay: 		
         begin
         inc_bcnt<=0;
         rst_scnt<=0;
         state<=Chk_BCount;
         end
      Chk_BCount:  
         begin
         if (bcnt==10)
         state<=RxDone;
         else
         state<=Chk_Enable;
         end					
      RxDone: 		
         begin
         busy<=1;
         state<=Start;
         end
   endcase


   // generate baud rate; baud ticks
   always @(posedge clk or posedge reset)
   if(reset)
   	baud_cnt<=0;
   else if (nedge_rx & busy)//start of new byte
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