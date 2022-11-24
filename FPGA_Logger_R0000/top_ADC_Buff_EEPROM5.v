
module top_ADC_buff_EEPROM5(

input clk,
input res,
input start_pulse, //from uC
//input sel_uC,      //from uC
output data_done,  //to uC

///////////////
input pulse_in,   //from uC
//input sel1,        //from uC
//input [1:0] sel_u,        //from uC

output relayAp,   //to relayA
output  relayAn,  //to relayA
output  relayBp,  //to relayB
output  relayBn,  //to relayB
 
/////////
//input Clk_Slct,   //from uC
output  Clk_Out,  //to filter IC 


//////////

///////uController SPI
input SDOUTu,
input SCLKu,
input CSu,
output SDINu,

//////
//// ADC SPI
input nDRDY,
input SDIN1,
//output SDOUT1,
output SCLK1,
//output nCS1,


//// FLASH SPI
input SDOUTe,
output SDINe,
output SCLKe,
output [3:0] CSe
//output nCSb
   
	);

//////////
wire SDOUTf;
wire SCLKf;

wire CSf;

///eeprom
//wire nCS;

/////////
wire  load_data;
reg [7:0] dataout;
wire spi_busy;

wire page_done;


reg [15:0] page_addr;

wire [7:0] start_addr;
wire [7:0] stop_addr;
wire [7:0] read_addr;

wire [7:0] dout;
reg [1:0] sel_eeprom;
wire [2:0] sel_data;

wire data_done1;// Instantiate the module
wire [7:0] datain;

wire [7:0] select_reg;
wire [2:0] rate;

assign select_reg=0;
assign start_addr=0;//start_addr_reg;
assign stop_addr=4;//stop_addr_reg;

assign data_done=data_done1;

//assign sel1=select_reg[0];
//assign sel_u=select_reg[2:1];

assign sel_clk=0;//select_reg[6];
assign sel_relay=0;//select_reg[5];

assign rate=001;

assign SDINu=SDOUTe; //connect SDOUT pin of eeprom to SDIN pin of uC 

mux_eeprom mux1 (

    .sel1(select_reg[0]), //connect CSu to CSe (default CSf is connected with CSe)
    .sel_u(select_reg[2:1]), 
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
top_ADC_buff2 t1 (
    .clk(clk), 
    .res(res), 
    .start_pulse(start_pulse), 
    .write_done(write_done), 
    .rate(rate), 
    .read_addr(read_addr), 
    .dout(dout),
	 
    .nDRDY(nDRDY), //from adc
    .SDIN1(SDIN1), //from adc
    .SCLK1(SCLK1), //to adc
    .nCS1()//nCS1 permanentaly low
    );

	 
 assign datain=dataout;
/////////////////////////////////////////////////////////////////	 
// Instantiate the module
SPI_EEPROM spi2 (
    .clk(clk), 
    .reset(res), 
    .ld_data(load_data),//from cu2
    .datain(datain),      //from buff
	 .SCLK(SCLKf),       //to mux and then to eeprom
    .SDOUT(SDOUTf),     //to mux and then eeprom
	 .SPI_busy(spi_busy) //to control unit
    );


// Instantiate the module
cu_buff_eeprom cu2 (
    .clk(clk), 
    .rst(res), 
    .start_pulse(write_done), //input from cu1 
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

always @(posedge clk or posedge res)
if(res)
  	sel_eeprom<=0;
	
else if (start_pulse)
   sel_eeprom<=0;

else if(page_done)
  	sel_eeprom<=sel_eeprom+1;
else
  	sel_eeprom<=sel_eeprom;



always @(posedge clk or posedge res)
if(res)
  	page_addr<=0;
else if (start_pulse)
   page_addr<=start_addr;

else if((page_done)&&(sel_eeprom[0]))//for two memories(otherwise sel_eeprom==2'b11)
  	page_addr<=page_addr+1;
else
  	page_addr<=page_addr;

assign data_done1=(page_addr==stop_addr)?1:0;

// Instantiate the module
Filter_clk2 filt1 (
    .clk(clk), 
    .rst(res), 
    .Clk_Slct(sel_clk), 
    .Clk_Out(Clk_Out)
    );
	 
	 
// Instantiate the module
relays rel1 (
    .pulse_in(pulse_in), 
    .sel(sel_relay), 
    .relayAp(relayAp), 
    .relayAn(relayAn), 
    .relayBp(relayBp), 
    .relayBn(relayBn)
    );
	 
endmodule
