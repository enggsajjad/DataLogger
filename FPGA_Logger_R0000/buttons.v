// FSM Using Synchronous State Machine
// Handle 5 buttons 
// sw idle state = HIGH, sw active state = LOW
// counter is reseted on each LOW, then counts to END
// another counter is reseted on each HIGH, then counts to END
// time to handle = maximum glitch duration
// Using single counter
//module fsmd_expQ5
//module fsmd_expQ6
//module fsmd_expQ7
module buttons
   (
    input wire clk, reset,
    input wire [4:0] sw,
    output reg neg_tick,pos_tick,
    output reg [2:0] kcode
   );

   // symbolic state declaration
   localparam  [3:0]
               IDLE              = 4'b0000,
               CHK_CNT1_END       = 4'b0001,
               GENERATE_PTICK     = 4'b0010,
               PTICK_GENERATED         = 4'b0011,
			      CHK_CNT2_END         = 4'b0100,
               GENERATE_NTICK         = 4'b0101,
               NTICK_GENERATED       = 4'b0110;


   // number of counter bits (2^N * 20ns = 40ms)
	// number of counter bits (2^11 * 20ns = 40us) N = 11 for simulation
   //localparam N=11;
   
   // N = log2(delay * crystal)
   
   localparam N=12;//Crystal 22118400 185us assumed maximum glitch time

   // signal declaration
   reg [3:0] state;
   reg [N-1:0] cnt1;
   wire cnt1_rst;
   reg next;   // constant input of the XOR, used for inversion the other
   reg sw_clear; //switch cleared from glitches

   always @(posedge clk, posedge reset)
   if (reset)
      cnt1 <= {N{1'b1}};
   else if (cnt1_rst)
      cnt1 <= 0;
   else if(cnt1 == {N{1'b1}})
      cnt1 <= cnt1;
   else
      cnt1 <= cnt1 + 1;

   assign cnt1_rst = (&sw) ^ (next);

   //State Machine
   always @(posedge clk, posedge reset)
   if(reset)
      begin
      state <= IDLE;                // default state: the same
      neg_tick <= 1'b0;          // default output: 0
      pos_tick <= 1'b0;          // default output: 0
      sw_clear <= 1'b0;
      next <= 1'b0;
      end
   else
   begin
   case (state)
   IDLE:
      begin
      neg_tick <= 1'b0;          // default output: 0
      pos_tick <= 1'b0;          // default output: 0
      sw_clear <= 1'b0;
      next <= 1'b0;
      state <= CHK_CNT1_END;
		end
	CHK_CNT1_END:
		 if(cnt1 == ({N{1'b1}} - 5))
   		state <= GENERATE_PTICK;
      else
         state <= CHK_CNT1_END;
   GENERATE_PTICK:
        begin
   		sw_clear <= 1'b1;
   		neg_tick <= 1'b1;
         state <= PTICK_GENERATED;
        end
   PTICK_GENERATED:
        begin
   		neg_tick <= 1'b0;
         next <= 1'b1;
         state <= CHK_CNT2_END;
         end
	CHK_CNT2_END:
		 if(cnt1 == ({N{1'b1}} - 5))
   		state <= GENERATE_NTICK;
      else
         state <= CHK_CNT2_END;
   GENERATE_NTICK:
        begin
   		sw_clear <= 1'b0;
   		pos_tick <= 1'b1;
         state <= NTICK_GENERATED;
        end
   NTICK_GENERATED:
        begin
   		pos_tick <= 1'b0;
         next <= 1'b0;
         state <= IDLE;
         end
	default: 
	    	state <= IDLE;
   endcase
   end
	
	//reg [2:0] kcode;
	always @(posedge clk, posedge reset)
	if(reset)
		kcode <=0;
	else if (neg_tick)
		case (sw)
		5'b11110: kcode <= 3'b001;
		5'b11101: kcode <= 3'b010;
		5'b11011: kcode <= 3'b011;
		5'b10111: kcode <= 3'b100;
		5'b01111: kcode <= 3'b101;
		default: kcode <= 3'b000;
		endcase
	else
		kcode <= kcode;
endmodule