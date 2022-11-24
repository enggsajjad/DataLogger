module cu_buff_eeprom(

	input clk,
	input rst,
	input start_pulse,
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

	//wire [15:0] dout;

	reg inc_addr;
	reg rst_addr;

	reg inc_sel;
	reg rst_sel;

	reg ld_data;
	reg CS;
	reg  page_done1;



parameter Start=0, 
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
		Stop=21;
		
assign load_data=ld_data;
assign nCS=CS;
assign page_done=page_done1;
assign addr=addr1[7:0] ;

always @(posedge clk or posedge rst)
if(rst)
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
		begin //0
		rst_addr<=1;
		page_done1<=0; 
		//block_done1<=0;
		inc_sel<=0;
		rst_sel<=1;
		CS<=1;
		if(start_pulse)
			state<=WriteEnable1;
		else
			state<=Start;
		end
	////// Write Enable command   ///////////
	WriteEnable1: 	
	begin //1
					CS<=0;
               rst_addr<=0;
					rst_sel<=0;
					state<=WriteEnable2;
					end

WriteEnable2:  begin //2
					ld_data<=1;
					state<=WriteEnable3;
					end

				
WriteEnable3:  begin //3
					ld_data<=0;
					state<=CheckBusy1;
					end	


CheckBusy1:  	begin //4
					if (spi_busy==1)
						state<=Delay1;
					else
						state<=CheckBusy1;
					end
					
Delay1:			begin//5
               CS<=1;
               inc_sel<=1;
					state<=Delay2;
					end

Delay2:			begin //6
					inc_sel<=0;
					
					state<=WritePage1;
					end
	
////////////////////////////////// 

/// Write page instruction + page address (4 bytes) 

WritePage1:		begin //7
					CS<=0;
					ld_data<=1;
					state<=WritePage2;
					end

WritePage2:  	begin //8
					ld_data<=0;
					state<=WritePage3;
					end

				
WritePage3:  	begin //9
					inc_sel<=1;
					state<=CheckBusy2;
					end	


//// check spi busy flag
CheckBusy2:  	begin    //10
					inc_sel<=0;
					if (spi_busy==1)
						 state<=CheckSel;
				   else
					   state<=CheckBusy2;
					end


///////////////////////////////////

CheckSel:   	begin //11
					if (sel_data==5)
						 state<=WritePage4;
					else
						 state<=WritePage1;
					end



/// Write 256 data bytes
WritePage4:		begin //7
					ld_data<=1;
					state<=WritePage5;
					end

WritePage5:  	begin //8
					ld_data<=0;
					state<=WritePage6;
					end

				
WritePage6:  	begin //9
					inc_addr<=1;
					state<=CheckBusy3;
					end	


//// check spi busy flag
CheckBusy3:  	begin    //10
					inc_addr<=0;
					if (spi_busy==1)
						 state<=CheckAddr;
				   else
					  	state<=CheckBusy3;
					end


///////////////////////////////////
CheckAddr:   	begin //11
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

PageDone: 		begin //13
               page_done1<=0; 
					CS<=1;
					rst_sel<=1;
					rst_addr<=1;
					state<=CheckDataDone;
					end              					
										
CheckDataDone:  
               begin //13
               page_done1<=0;
					rst_sel<=0;
					rst_addr<=0;
					
					if (data_done)   //to stop here
						state<=CheckDataDone;
					else
                  state<=Stop;					
				   end
Stop: 			begin
					
            	state<=Start;
					end
endcase



always @(posedge clk or posedge rst)
if(rst)
  	addr1<=0;
else if (rst_addr)
   addr1<=0;	
else if(inc_addr)
  	addr1<=addr1+1;
else
  	addr1<=addr1;


always @(posedge clk or posedge rst)
if(rst)
  	sel_cnt<=0;
else if (rst_sel)
   sel_cnt<=0;	
else if(inc_sel)
  	sel_cnt<=sel_cnt+1;
else
  	sel_cnt<=sel_cnt;


assign sel_data=sel_cnt;


endmodule
