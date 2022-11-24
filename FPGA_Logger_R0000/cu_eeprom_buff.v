module cu_eeprom_buff
(
	input clk,
	input reset,
	input start_pulse,
   input write_done,
	input spi_busy,
	input data_done,

	output load_data,
	output nCS,
	output [2:0] sel_data,
	output page_done,
	output [7:0] addr
);


	reg [9:0] addr1;
	reg [4:0] state;
	reg [2:0] sel_cnt;
	reg inc_addr;
	reg rst_addr;
	reg inc_sel;
	reg rst_sel;
	reg ld_data;
	reg CS;
	reg  page_done1;



localparam Start=0, 
            WriteEnable1=1, 
      		WriteEnable2=2,
      		WriteEnable3=3,
      		WritePage1=4,
      		WritePage2=5, 
      		WritePage3=6,
      		WritePage4=7,
      		WritePage5=8, 
      		WritePage6=9,
      		CheckBusy1=10,
      		CheckBusy2=11,
      		CheckBusy3=12,
      		Delay1=13, 
      		Delay2=14,
      	 	CheckSel=15,
      		CheckAddr=16,
      		CheckDataDone=17,
      		BlockDone1=18,
      		BlockDone2=19,
      		PageDone=20,
      		Stop=21,
            ChkWriteDone = 22;
		
   assign load_data=ld_data;
   assign nCS=CS;
   assign page_done=page_done1;
   assign addr=addr1[7:0] ;

   always @(posedge clk or posedge reset)
   if(reset)
   	begin
   	state<=Start;
   	inc_addr<=0;
   	rst_addr<=0;
   	inc_sel<=0;
   	rst_sel<=0;
   	ld_data<=0;
   	page_done1<=0; 
   	end
   else 
   	case(state)
   	Start:			
   		begin
   		rst_addr<=1;
   		page_done1<=0; 
   		inc_sel<=0;
   		rst_sel<=1;
   		CS<=1;
   		if(start_pulse)
   			state<=ChkWriteDone;//WriteEnable1;
   		else
   			state<=Start;
   		end
      ChkWriteDone:
         if(write_done)
   			state<=WriteEnable1;
   		else
   			state<=ChkWriteDone;
   	////// Write Enable command   ///////////
   	WriteEnable1: 	
   	   begin
			CS<=0;
         rst_addr<=0;
			rst_sel<=0;
			state<=WriteEnable2;
			end

      WriteEnable2:  
         begin 
			ld_data<=1;
			state<=WriteEnable3;
			end

      WriteEnable3:  
         begin
			ld_data<=0;
			state<=CheckBusy1;
			end	

      CheckBusy1:  	
         begin
			if (spi_busy==1)
				state<=Delay1;
			else
				state<=CheckBusy1;
			end
		
      Delay1:			
         begin
         CS<=1;
         inc_sel<=1;
			state<=Delay2;
			end

      Delay2:
      	begin
			inc_sel<=0;
			state<=WritePage1;
			end

      /// Write page instruction + page address (4 bytes) 

      WritePage1:		
         begin
			CS<=0;
			ld_data<=1;
			state<=WritePage2;
			end

      WritePage2:  	
         begin
			ld_data<=0;
			state<=WritePage3;
			end

      WritePage3:  	
         begin
			inc_sel<=1;
			state<=CheckBusy2;
			end	

      //// check spi busy flag
      CheckBusy2:  	
         begin
			inc_sel<=0;
			if (spi_busy==1)
				 state<=CheckSel;
		   else
			   state<=CheckBusy2;
			end

      CheckSel:   	
         begin
			if (sel_data==5)
				 state<=WritePage4;
			else
				 state<=WritePage1;
			end

      /// Write 256 data bytes
      WritePage4:		
         begin
			ld_data<=1;
			state<=WritePage5;
			end

      WritePage5:  	
         begin
			ld_data<=0;
			state<=WritePage6;
			end

      WritePage6:  	
         begin
			inc_addr<=1;
			state<=CheckBusy3;
			end	

      //// check spi busy flag
      CheckBusy3:  	
         begin 
			inc_addr<=0;
			if (spi_busy==1)
				 state<=CheckAddr;
		   else
			  	state<=CheckBusy3;
			end


      CheckAddr:   	
         begin
			if (addr1[8])
			//if (addr1[9])
			//if (addr1[5])
				 begin
				 page_done1<=1;
				 state<=PageDone;
				 end
			else
				 state<=WritePage4;
			end

      PageDone: 		
         begin
         page_done1<=0; 
			CS<=1;
			rst_sel<=1;
			rst_addr<=1;
			state<=CheckDataDone;
			end              					
										
      CheckDataDone:  
         begin
         page_done1<=0;
			rst_sel<=0;
			rst_addr<=0;
			if (data_done)   //to stop here
				state<=Start;//CheckDataDone;
			else
            state<=Stop;					
		   end

      Stop: 			
         begin
      	state<=ChkWriteDone;//Start;
			end
   endcase



   always @(posedge clk or posedge reset)
   if(reset)
     	addr1<=0;
   else if (rst_addr)
      addr1<=0;	
   else if(inc_addr)
     	addr1<=addr1+1;
   else
     	addr1<=addr1;


   always @(posedge clk or posedge reset)
   if(reset)
     	sel_cnt<=0;
   else if (rst_sel)
      sel_cnt<=0;	
   else if(inc_sel)
     	sel_cnt<=sel_cnt+1;
   else
     	sel_cnt<=sel_cnt;


   assign sel_data=sel_cnt;


endmodule
