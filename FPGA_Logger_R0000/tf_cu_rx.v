`timescale 1ps / 1ps

module tf_cu_rx();

parameter XTL= 22118400; //(in hertz)
parameter BAUD  = 9600 ;  //57600 //19200  //9600
parameter NANO  = 1_000_000_000;
parameter BIT_TIME   = 104166667;//1000*NANO/(BAUD)  ;



// DATE:     15:18:50 10/16/2014 
// MODULE:   interface
// DESIGN:   interface
// FILENAME: tf_interface.v
// PROJECT:  data_loggerVer3
// VERSION:  


// Inputs
    reg clk;
    reg reset;
    reg rx;
    wire [23:0] start_adr;
    wire [23:0] stop_adr;
    wire [23:0] status;
    wire pkt_done;

    reg [7:0] byt [20:0];
    reg [7:0] val;
    integer i,j;

initial
begin
//start
byt[0] = 192;//128;
byt[1] = 1;
byt[2] = 1;
byt[3] = 2;
byt[4] = 2;
byt[5] = 3;
byt[6] = 3;

//stop
byt[7] = 192;//160;
byt[8] = 4;
byt[9] = 4;
byt[10] = 5;
byt[11] = 5;
byt[12] = 6;
byt[13] = 6;

//status
byt[14] = 192;
byt[15] = 7;
byt[16] = 7;
byt[17] = 8;
byt[18] = 8;
byt[19] = 9;
byt[20] = 9;
end
// Instantiate the UUT
    cu_rx c3 (
        .clk(clk), 
        .reset(reset), 
        .rx(rx),
        .start_adr(start_adr),
        .stop_adr(stop_adr),
        .status(status),
        .pkt_done(pkt_done)
        );


// Initialize Inputs
        initial begin
            clk = 0;
            reset = 0;
		rx=1;		
		#1000000 reset  =1;
		#100000  reset  =0;
		#100000  reset  =0;
      //9600 Baud rate
      //start address
      
      for(j=0;j<21;j=j+1)
      begin
         val = byt[j];
         #BIT_TIME rx =0;//start
         for(i=0;i<8;i=i+1)
            #BIT_TIME rx = val[i];
         #BIT_TIME rx =1;//stop
         #BIT_TIME rx =1;//stop
      end
/*
		#BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =1;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //1
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //2
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //3
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //4
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //5
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
      ///////////////////////

      //stop address
		#BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =1;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //1
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //2
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //3
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //4
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //5
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
      ///////////////////////
      
      //status
      		#BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =1;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //1
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //2
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //3
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //4
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //5
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
      ///////////////////////            


     //start address 
		#BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =1;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //1
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =1;//2
		#BIT_TIME rx =1;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //2
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //3
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

       //4
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =0;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
       //5
      #BIT_TIME rx =0;//start
		#BIT_TIME rx =0;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop

      #BIT_TIME rx =0;//start
		#BIT_TIME rx =1;//bit 0
		#BIT_TIME rx =1;//1
		#BIT_TIME rx =0;//2
		#BIT_TIME rx =0;//3
		#BIT_TIME rx =0;//4
		#BIT_TIME rx =0;//5
		#BIT_TIME rx =0;//6
		#BIT_TIME rx =0;//7
		#BIT_TIME rx =1;//stop
      #BIT_TIME rx =1;//stop
      ///////////////////////
*/
       end
//22118400Hz
always
#22_605 clk = ~clk;

endmodule
