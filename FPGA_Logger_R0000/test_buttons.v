module test_buttons
   (
    input wire clk, reset,
    input wire [4:0] sw,
    output wire pos_tick,neg_tick,
    output wire tx
   );



wire [2:0] kcode;


// Instantiate the module
//fsmd_expQ5 navigation (
//fsmd_expQ6 navigation (
//fsmd_expQ7 navigation (
buttons navigation (
    .clk(clk), 
    .reset(reset), 
    .sw(sw), 
    .pos_tick(pos_tick), 
    .neg_tick(neg_tick), 
    .kcode(kcode)
    );





   // Instantiate the module
   uart_tx #(.crystal(22118400), .baud(9600)) trans (
    .clk(clk), 
    .reset(reset), 
    .din_rdy(pos_tick), 
    .din_byte({5'b00000,kcode}), 
    .tx(tx), 
    .tx_done()
    );





endmodule
