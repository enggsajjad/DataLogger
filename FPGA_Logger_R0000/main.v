// Data Logger 
// FPGA and PIC PCB (revision 2.0)
module main
(
   input clk,
   input reset,
   input start_pulse, //from uC
   output data_done,  //to uC

   output relayAp,   //to relayA
   output  relayAn,  //to relayA
   output  relayBp,  //to relayB
   output  relayBn,  //to relayB
 
   output  filter_clk,  //to filter IC 

   ///////uController SPI ///////////
   input SDOUTu,
   input SCLKu,
   input CSu,
   output SDINu,

   //// ADC SPI /////////////////
   input nDRDY,
   input SDOUT1,
   //output SDIN1,
   output SCLK1,
   output CLK1,
   output CS1,
   output SYNC1,


   //// FLASH SPI ///////////////
   input SDOUTe,
   output SDINe,
   output SCLKe,
   output [3:0] CSe,
   //output nCSb
   
   //keypad
   input [4:0] sw,

   //UART
   input TXu,
   output RXu,
   input TXpc,
   output RXpc,
   input sel_uart ,

   output pCLK
);

   reg [1:0] sel_eeprom;
   reg [7:0] dataout;
   reg [15:0] page_addr;

   wire rx,tx;
   wire SDOUTf;
   wire SCLKf;
   wire CSf;
   ///eeprom
   //wire nCS;
   wire  load_data;

   wire spi_busy;
   wire page_done;

   //from uart_rx control unit
   wire [23:0] start_adr;
   wire [23:0] stop_adr;
   wire [23:0] status;
   wire sel_relay;
   wire [1:0] sel_clk;
   wire sel_spi;  // sel_spi = 1 then eeprom is connected to uc, 
                  //sel_spi = 0 then eeprom is connected to fpga
   wire [1:0] sel_CS;// sel_CS = 0 then eeprom_0 CS is connected to CSu, 
                     // sel_CS = 1 then eeprom_1 CS is connected to CSu, 
                     // sel_CS = 2 then eeprom_2 CS is connected to CSu, 
                     // sel_CS = 3 then eeprom_3 CS is connected to CSu, 
   //////////////////////////

   wire [7:0] read_addr;

   wire [7:0] dout;

   wire [2:0] sel_data;

   wire data_done1;// Instantiate the module
   wire [7:0] datain;

   wire [2:0] rate;
   wire [2:0] kcode; //navigation keypad code
   wire pos_tick; // negative edge when key
   wire pkt_done;

   assign data_done= data_done1;
   assign SDINu=SDOUTe; //connect SDOUT pin of eeprom to SDIN pin of uC 

   //uart multiplexer
   assign RXu = (sel_uart)? TXpc:tx;

   assign RXpc = (sel_uart)? TXu:1'b1;
   //wire tx2;
   //assign RXpc = tx2;
   
   assign rx = (sel_uart==0)? TXu:1'b1;

   reg [2:0] shift1;
   wire start_pulse_sync;
   always @(posedge clk or posedge reset)
   if (reset)
   	shift1 <= 0;
   else 
   	shift1<= {shift1[1:0],start_pulse}; 
   
   assign start_pulse_sync= (~shift1[2])&(shift1[1]);


   mux_eeprom mux1 (
       .sel1(sel_spi), //connect CSu to CSe (default CSf is connected with CSe)
       .sel_u(sel_CS), 
       .sel_f({1'b0,sel_eeprom[0]}), //for two memories (otherwise sel_eeprom)
       .CSf(CSf), 
       .CSu(CSu), 
       .SCLKf(SCLKf), //input from FPGA
       .SCLKu(SCLKu), //input from uC
       .SDOUTf(SDOUTf), //input from FPGA
       .SDOUTu(SDOUTu),//input from uC
       .SCLK(SCLKe),//output to eeprom 
       .SDOUT(SDINe), //output to eeprom  
       .CSe(CSe) //output to eeprom
    );


   // Instantiate the module
   adc_buff t1 (
       .clk(clk), 
       .reset(reset), 
       .start_pulse(start_pulse_sync), 
       .write_done(write_done), 
       .rate(rate), 
       .read_addr(read_addr), 
       .dout(dout),
       .nDRDY(nDRDY), //from adc
       .SDIN1(SDOUT1), //from adc
       .SCLK1(SCLK1), //to adc
       .nCS1()//nCS1 permanentaly low
       );

	
   
   

   // adc clock
   reg [3:0] acnt;
   always @(posedge clk or posedge reset)
   if (reset)
   	acnt<=0;
   else	
      acnt<=acnt+1;
   
   assign CLK1 = acnt[3];
	assign SYNC1 = 1'b1;
   assign CS1 = 1'b0;

   assign datain=dataout;

   // Instantiate the module
   eeprom spi2 (
       .clk(clk), 
       .reset(reset), 
       .ld_data(load_data),//from cu2
       .datain(datain),      //from buff
   	 .SCLK(SCLKf),       //to mux and then to eeprom
       .SDOUT(SDOUTf),     //to mux and then eeprom
   	 .SPI_busy(spi_busy) //to control unit
       );


   // Instantiate the module
   cu_eeprom_buff cu2 (
       .clk(clk), 
       .reset(reset), 
       .start_pulse(start_pulse_sync), //input from Microcontroller
       .write_done(write_done),  // input from cu_adc
       .spi_busy(spi_busy),      //input from spi2
       .load_data(load_data),    //output to eeprom spi interface to start spi transaction 
       .nCS(CSf),                //output to eeprom spi
       .page_done(page_done),
   	 .data_done(data_done1),	//input to stop data acquisition
       .sel_data(sel_data),	  //select data and commmand bytes
       .addr(read_addr)         //read data bytes from buffer
   	 );

   always @(sel_data,page_addr,dout)
   case(sel_data)
      0:dataout=8'h06;
      1:dataout=8'h02;
      2:dataout=page_addr[15:8]; //address[2]
      3:dataout=page_addr[7:0];          //address[1]
      4:dataout=8'h00;          //address[0]
      5:dataout=dout;
      default:dataout=dout;
   endcase

   always @(posedge clk or posedge reset)
   if(reset)
     	sel_eeprom<=0;
   else if (start_pulse_sync)
      sel_eeprom<=0;
   else if(page_done)
     	sel_eeprom<=sel_eeprom+1;
   else
     	sel_eeprom<=sel_eeprom;



   always @(posedge clk or posedge reset)
   if(reset)
     	page_addr<=0;
   else if (start_pulse_sync)
      page_addr<=start_adr[15:0];
   else if((page_done)&&(sel_eeprom[0]))//for two memories(otherwise sel_eeprom==2'b11)
     	page_addr<=page_addr+1;
   else
     	page_addr<=page_addr;

   assign data_done1=(page_addr==(stop_adr[15:0]+1))?1:0;

   
   assign rate = status[2:0];
   assign sel_clk = status[4:3]; // sel_clk[1] will be used in future
   assign sel_relay = status[5];
   assign sel_spi = status[8];
   assign sel_CS = status[10:9];

   // Instantiate the module
   filter_clk filt1(
       .clk(clk), 
       .reset(reset), 
       .sel(sel_clk[0]), //
       //.sel(sel_clk), //
       .filter_clk(filter_clk)
       );
	 
	 
   // Instantiate the module
   relays rel1 (
       .clk(clk), 
       .reset(reset), 
       .gen_pulse(pkt_done), 
       .sel(sel_relay), 
       .relayAp(relayAp), 
       .relayAn(relayAn), 
       .relayBp(relayBp), 
       .relayBn(relayBn),
       .pulse_out(pulse_out)
       );	 

   // Instantiate the module
   buttons navigation (
       .clk(clk), 
       .reset(reset), 
       .sw(sw), 
       .pos_tick(pos_tick), 
       .neg_tick(), 
       .kcode(kcode)
       );


   // Instantiate the module
   uart_tx #(.crystal(16384000), .baud(57600)) trans (
    .clk(clk), 
    .reset(reset), 
    .din_rdy(pos_tick), 
    .din_byte({1'b0,kcode,4'b0000}), 
    .tx(tx), 
    .tx_done()
    );


   // Instantiate the module
   cu_rx cu_rx1 (
    .clk(clk), 
    .reset(reset), 
    .rx(rx), 
    .start_adr(start_adr), 
    .stop_adr(stop_adr), 
    .status(status), 
    .pkt_done(pkt_done),
    .rx_done1(rx_done1)
    );


               /*

// Instantiate the module
test_cu test_cu1 (
    .clk(clk), 
    .reset(reset), 
    .start_adr(start_adr), 
    .stop_adr(stop_adr), 
    .status(status), 
    .pkt_done(pkt_done), 
    .tx2(tx2)
    );
                 */

    reg [1:0] pcnt;

   // adc clock
   always @(posedge clk)
      pcnt<=pcnt+1;
   
   assign pCLK = pcnt[0];

endmodule
