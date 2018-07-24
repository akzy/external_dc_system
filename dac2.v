
/* 
--------- Timings are good. So is life. ----------
*/

module dac2(
bitclk,
vin,
wout1, //word clk
bout1, //bit clk
dout1, //data
tm,
nw,
busybee
);

//----------Output Ports--------------
	output wire wout1,dout1,bout1;
	output reg busybee;
//------------Input Ports--------------
	input bitclk,nw;
	input [15:0] vin;
	input [5:0] tm;
	
//------------Internal Variables---------	
	
	reg [15:0] vlvl;
	reg [25:0] outreg=26'b01001001001001001001001001;
	reg [5:0]  timer;//,channel
	reg vstate,enable,done,busy,bout,dout =1'b0;
	reg rnd2;
	reg load,wout=1'b1;
	reg [5:0] COUNTUP=33;
	reg [4:0] COUNTDOWN=5'b00000;	
		
	integer iword=0; //word pins offset
	integer ibit=-1; //bit clk pins offset
	integer idat=1; //data pin offset
	integer channel;
	integer rst;
	
	wire bitclk_out;
	
//-------------Code Starts Here-------
	
	assign wout1=wout;
	assign bout1=bout;
	assign dout1=dout;

	always@(posedge bitclk)
	begin
		COUNTUP<=COUNTUP+1;
		case (COUNTUP)
		0: begin
				vlvl<=vin;				
				timer<=tm;
			end
		1: begin
				bout<=1'b0;
				dout<=vlvl[15];
				wout<=1'b0;				
			end
		2: begin
				
				bout<=1'b1;				
			end
		3: begin
				bout<=1'b0;
				dout<=vlvl[14];
			end
		4: begin
				bout<=1'b1;
			end
		5: begin
				bout<=1'b0;
				dout<=vlvl[13];
			end
		6: begin
				bout<=1'b1;
			end
		7: begin
				bout<=1'b0;
				dout<=vlvl[12];
			end
		8: begin
				bout<=1'b1;
			end
		9: begin
				bout<=1'b0;
				dout<=vlvl[11];
			end
		10: begin
				bout<=1'b1;
			end
		11: begin
				bout<=1'b0;
				dout<=vlvl[10];
			end
		12: begin
				bout<=1'b1;
			end
		13: begin
				bout<=1'b0;
				dout<=vlvl[9];
			end
		14: begin
				bout<=1'b1;
			end
		15: begin
				bout<=1'b0;
				dout<=vlvl[8];
			end
		16: begin
				bout<=1'b1;				
			end
		17: begin
				bout<=1'b0;
				dout<=vlvl[7];
			end
		18: begin
				bout<=1'b1;
				wout<=1'b1;
			end
		19: begin
				bout<=1'b0;
				dout<=vlvl[6];
			end
		20: begin
				bout<=1'b1;
			end
		21: begin
				bout<=1'b0;
				dout<=vlvl[5];
			end
		22: begin
				bout<=1'b1;
			end
		23: begin
				bout<=1'b0;
				dout<=vlvl[4];
			end
		24: begin
				bout<=1'b1;
			end
		25: begin
				bout<=1'b0;
				dout<=vlvl[3];
			end
		26: begin
				bout<=1'b1;
			end
		27: begin
				bout<=1'b0;
				dout<=vlvl[2];
			end
		28: begin
				bout<=1'b1;
			end
		29: begin
				bout<=1'b0;
				dout<=vlvl[1];
			end
		30: begin
				bout<=1'b1;
				busybee<=1'b0;				
			end
		31: begin
				bout<=1'b0;
				dout<=vlvl[0];

			end
		32: begin
				bout<=1'b1;
				//COUNTUP<=1;
				if(nw)
				begin
					vlvl<=vin;					
					timer<=tm;
					rnd2<=1'b0;	
					COUNTUP<=1'b1;
					busybee<=1'b1;
				end else if(!nw&!rnd2)
				begin
					rnd2<=1'b1;
					COUNTUP<=1'b1;
				end else if(rnd2)
				begin
					wout<=1'b1;
					COUNTUP<=33;
				end
			end
		33:begin //Also known as end of days
				bout<=1'b0; //23 for channel 8
				dout<=1'b0; //25 for channel 8
				wout<=1'b1; //24 for channel 8 
				COUNTUP<=33;
				busybee<=1'b0;
				if (nw)
				begin
					vlvl<=vin;					
					timer<=tm;
					rnd2<=1'b0;
					COUNTUP<=1;
					busybee<=1'b1;
				end
			end
		endcase	
	end	
	endmodule