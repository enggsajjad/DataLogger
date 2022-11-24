module cu_rx( clk,
                  reset,
                  rx,
                  start_adr,
                  stop_adr,
                  status,
                  pkt_done,
                  rx_done1
);
input clk;
input reset;
input rx;
output [23:0] start_adr;
output [23:0] stop_adr;
output [23:0] status;
output reg pkt_done;
output reg rx_done1;

reg [23:0] status;
reg [23:0] start_adr;
reg [23:0] stop_adr;
reg [23:0] shift;

reg [4:0] state;
wire rx_done;
wire [7:0] dout_byte;
reg inc_cnt;
reg [2:0] nibble_cnt;
reg rst_cnt;
wire latch_start_adr;
wire latch_stop_adr;
wire latch_status;
reg latch_hdr;
//reg latch_start_adr;
//reg latch_stop_adr;
//reg latch_status;

reg [3:0] hdr;

always @(posedge clk or posedge reset)
if(reset)
   rx_done1 <=0;
else  if (rx_done)
   rx_done1 <= ~rx_done1;
else
   rx_done1 <= rx_done1;


/*
always @(posedge rx_done or posedge reset)
if(reset)
   rx_done1 <=0;
else // if (rx_done)
   rx_done1 <= ~rx_done1;
//else
//   rx_done1 <= rx_done1;


uart_rx0 instance_name (
    .clk(clk), 
    .rst(reset), 
    .ser_in(rx), 
    .dout_byte(dout_byte), 
    .dout_byte_rdy(rx_done)
    );
*/
// Instantiate the module

uart_rx # (.crystal(16384000), .baud(57600))  recv
 (
    .clk(clk), 
    .reset(reset), 
    .rx(rx), 
    .rx_done(rx_done), 
    .dout_byte(dout_byte)
    );


localparam Idle=0,
			Chk_Header=1,
         Nibble = 5,
         Nib_Done=6,
			Chk_Cnt=7,
         Received1=10,
         Received0=11,
         Latch_Header1 = 12,
         Latch_Header0 = 13,
         Chk_RxDone    = 14;


always @(posedge clk or posedge reset)
if (reset)
   begin
   inc_cnt <= 0;
   rst_cnt <= 1;
   //latch_start_adr <= 0;
   //latch_stop_adr <= 0;
   //latch_status <=0;
   latch_hdr <=0;
   pkt_done <= 0;
   state <= Idle;
   end
else
case(state)
   Idle:
      begin
      inc_cnt <= 0;
      rst_cnt <= 1;
      //latch_start_adr <= 0;
      //latch_stop_adr <= 0;
      //latch_status <=0;
      latch_hdr <=0;
      pkt_done <= 0;
      state <= Chk_RxDone;
      end
   Chk_RxDone:
      if(rx_done)
         state <= Chk_Header;
      else
         state <= Chk_RxDone;
   Chk_Header:
       //if((dout_byte[7] == 1) || (dout_byte[6] == 1)  || (dout_byte[5] == 1) )
       if((dout_byte == 8'hc0) || (dout_byte == 8'ha0)  || (dout_byte == 8'h80) )
         state <= Latch_Header1;//Nibble;
       else
         state <= Chk_RxDone;// Idle
   Latch_Header1:
      begin
         latch_hdr <= 1;
         state <= Latch_Header0;
      end
   Latch_Header0:
      begin
         latch_hdr <= 0;
         rst_cnt <= 0;
         state <= Nibble;
      end
   Nibble:
      begin
      if(rx_done)
         begin
         
         inc_cnt <= 1;
         state <= Nib_Done;
         end
       else
         begin
          state <= Nibble;
          //rst_cnt <= 0;
         end
      end
   Nib_Done:
      begin
      inc_cnt <= 0;
      state <= Chk_Cnt;
      end
   Chk_Cnt:
      begin
      if(nibble_cnt==6)
         state <= Received1;
      else
         state <=  Nibble;
      end
   Received1:
      begin
      pkt_done <= 1;
      state <= Received0;
      end
      /*begin
         if(hdr[3:1]==4)
            latch_start_adr <= 1;
         else if(hdr[3:1]==5)
            latch_stop_adr <= 1;
         else if(hdr[3:1]==6)
            latch_status <= 1;
         state <= Received0;
      end */
   Received0:
      begin
         //latch_start_adr <= 0;
         //latch_stop_adr <= 0;
         //latch_status <= 0;
         pkt_done <= 0;
         state <= Idle;
      end
   
endcase

assign latch_start_adr = (hdr[3:1]==4)? pkt_done:0;
assign latch_stop_adr = (hdr[3:1]==5)? pkt_done:0;
assign latch_status = (hdr[3:1]==6)? pkt_done:0;

//load status byte
always @(posedge clk or posedge reset)
if (reset)
   status <=0;
else if (latch_status)
   status <= shift;
else
   status <= status;

//load start address
always @(posedge clk or posedge reset)
if (reset)
   start_adr <=0;
else if (latch_start_adr)
   start_adr <= shift;
else
   start_adr <= start_adr;

//load stop address
always @(posedge clk or posedge reset)
if (reset)
   stop_adr <=0;
else if (latch_stop_adr)
   stop_adr <= shift;
else
   stop_adr <= stop_adr;

//load header
always @(posedge clk or posedge reset)
if (reset)
   hdr <=0;
else if (latch_hdr)
   hdr <= dout_byte[7:4];
else
   hdr <= hdr;

//Shift Data Recieved from the RX
always @(posedge clk or posedge reset)
if (reset)
   shift <=0;
else if (inc_cnt)
   shift <= {shift[19:0],dout_byte[3:0]};
else
   shift <= shift;

// Nibble Counter
always @(posedge clk or posedge reset)
if (reset)
   nibble_cnt <=0;
else if (rst_cnt)
   nibble_cnt <=0;
else if (inc_cnt)
   nibble_cnt <= nibble_cnt + 1;
else
   nibble_cnt <= nibble_cnt;

endmodule