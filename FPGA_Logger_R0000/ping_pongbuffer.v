
module ping_pongbuffer(
    input clk,
	 
    input we,
	 	 	 
	 input [7:0] din,
	 	 
	 input [7:0] read_addr,
	 input [8:0] write_addr,
	 	 
    output [7:0] dout
	 
   
    );

wire [8:0] addr1;
wire [8:0] addr2;


assign addr1={~addr2[8],read_addr};//8
assign addr2=write_addr;

RAMB4_S8_S8 dual_buff (
.DOA(dout), // Port A 8-bit data output
.DOB(), // Port B 8-bit data output
.ADDRA(addr1), // Port A 9-bit address input
.ADDRB(addr2), // Port B 9-bit address input
.CLKA(clk), // Port A clock input
.CLKB(clk), // Port B clock input
.DIA(), // Port A 8-bit data input
.DIB(din), // Port B 8-bit data input
.ENA(1'b1), // Port A RAM enable input
.ENB(1'b1), // Port B RAM enable input
.RSTA(1'b0), // Port A Synchronous reset input
.RSTB(1'b0), // Port B Synchronous reset input
.WEA(1'b0), // Port A RAM write enable input
.WEB(we) // Port B RAM write enable input
);
// End of RAMB4_S8_S8_inst instantiation








endmodule
