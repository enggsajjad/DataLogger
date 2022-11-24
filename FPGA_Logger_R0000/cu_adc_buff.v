module cu_adc_buff
(
    input clk,
    input reset,
	 input start_pulse,
	 input drdy,
	 input stop_flag,
	 
	 output we,
	 output write_done,
	 output data_sel,
	 output [8:0] write_addr
);


   reg [8:0] addr;
   reg [4:0] state;
   reg inc_addr;
   reg rst_addr;

   reg we1;
   reg  write_done1;

   localparam  Start=0,
			      CheckDrdy=1, 
               Write1=2, 
               Write2=3,
			      IncAddr1=4,
               IncAddr2=5,
			      Write3=6, 
               Write4=7,
			      IncAddr3=8,
               IncAddr4=9,
			      CheckAddr=10,
			      WriteDone=11,
			      Stop=12;

   assign write_done=write_done1;
   assign we=we1;
   assign write_addr=addr;
   assign data_sel=addr[0];

   always @(posedge clk or posedge reset)
   if(reset)
      begin
      state<=Start;
      inc_addr<=0;
      rst_addr<=0;
      we1<=0;
      write_done1<=0; 
      end
   else 
      case(state)
      Start:			
         begin
      	write_done1<=0;
      	inc_addr<=0;
      	rst_addr<=1;
      	we1<=0;
      	if(start_pulse)
      		state<=CheckDrdy;
      	else
      		state<=Start;
      	end

      CheckDrdy:		
         begin
			if(drdy)
				state<=Write1;
			else
				state<=CheckDrdy;
			end
      ////// Write Enable command   ///////////
			
      Write1: 			
         begin
			rst_addr<=0;
			we1<=1;
			state<=Write2;
			end

      Write2:  		
         begin
			we1<=0;
			state<=IncAddr1;
			end

      IncAddr1: 		
         begin
			inc_addr<=1;
			state<=IncAddr2;
			end
					
      IncAddr2: 		
         begin
         inc_addr<=0;
			state<=Write3;
			end	

      Write3:
         begin
			we1<=1;
			state<=Write4;
			end

      Write4:  		
         begin
			we1<=0;
			state<=IncAddr3;
			end
					
      IncAddr3: 		
         begin
			inc_addr<=1;
			state<=IncAddr4;
			end
					
      IncAddr4: 		
         begin
       	inc_addr<=0;
			state<=CheckAddr;
			end						

      CheckAddr:   	
         begin
			if (addr[7:0]==0)
				//	if (addr[3:0]==0)
				state<=WriteDone;
			else
				state<=CheckDrdy;
			end
			
      WriteDone: 		
         begin
         write_done1<=1;
			state<=Stop;
			end

      Stop: 			
         begin
         write_done1<=0;
			if (stop_flag)
			   state<=Start;
			else	
			  state<=CheckDrdy;
			end
   endcase

   always @(posedge clk or posedge reset)
   if(reset)
     	addr<=0;
   else if (rst_addr)
      addr<=0;	
   else if(inc_addr)
     	addr<=addr+1;
   else
     	addr<=addr;

endmodule
