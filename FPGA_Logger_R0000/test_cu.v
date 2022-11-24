module test_cu(   input clk,
                  input reset,
                  input [23:0] start_adr,
                  input [23:0] stop_adr,
                  input [23:0] status,
                  input pkt_done,
                  output tx2


   );

   // Instantiate the module
   //wire din_rdy;
   reg [7:0] byt;
   wire din_rdy;

   uart_tx #(.crystal(22118400), .baud(57600)) trans2 (
    .clk(clk), 
    .reset(reset), 
    .din_rdy(din_rdy), 
    .din_byte(byt), 
    .tx(tx2), 
    .tx_done()
    );
    
   reg [19:0] cnt2;
   always @(posedge clk or posedge reset)
   if(reset)
     	cnt2<=0;
   else if (pkt_done)
      cnt2<=0;
   else if (20'h90000)
     	cnt2<=cnt2;
   else
     	cnt2<=cnt2+1;

   always @(*)
   case (cnt2[19:16])
      0: byt = start_adr[7:0];
      1: byt = start_adr[15:8];
      2: byt = start_adr[23:16];
      3: byt = stop_adr[7:0];
      4: byt = stop_adr[15:8];
      5: byt = stop_adr[23:16];
      6: byt = status[7:0];
      7: byt = status[15:8];
      8: byt = status[23:16];
      default: byt = 0; 
   endcase

   assign din_rdy = (cnt2[15:0] == 16'hfffa) ?1:0;

endmodule
