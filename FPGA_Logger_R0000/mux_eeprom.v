
module mux_eeprom
(
    input sel1,
    input [1:0] sel_u,
    input [1:0] sel_f,
    input CSf,
    input CSu,
	 
	 input SCLKf,
    input SCLKu,
	 
	 input SDOUTf,
    input SDOUTu,
	 
	 output SCLK,
	 output SDOUT,
	 
    output [3:0] CSe
    );


wire CS;
wire [1:0] sel;

assign CS=(sel1)?CSu:CSf;
assign SCLK=(sel1)?SCLKu:SCLKf;
assign SDOUT=(sel1)?SDOUTu:SDOUTf;


assign sel=(sel1)?sel_u:sel_f;

assign CSe[0]=(sel==0)?CS:1'b1;
assign CSe[1]=(sel==1)?CS:1'b1;
assign CSe[2]=(sel==2)?CS:1'b1;
assign CSe[3]=(sel==3)?CS:1'b1;


endmodule
