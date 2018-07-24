module hardware3(GPIO_0,GPIO_0_IN,GPIO_1,GPIO_1_IN,LED,CLOCK_50,KEY,SW);

//----------Output Ports--------------
output [7:0] LED;

//------------Input Ports--------------
input [1:0] GPIO_0_IN, GPIO_1_IN;
input CLOCK_50;
input [1:0] KEY;
input [3:0] SW;


//------------Inout Ports--------------
inout [33:0] GPIO_0,GPIO_1;
//------------Internal Variables---------

wire [15:0] vbus; //voltage data link
wire [31:0] fifobus;
//wire bitclk,wordclk,nw,rdempty,rdfull,rdreq,df;
wire bitclk,wordclk,nwFIFO,rdempty,rdfull,rdreq,df;
wire [255:0] nwDAC,busiestbee;
wire [7:0] ch,tm; //channel and timer links
wire [10:0] wordclks,bitclks,datas;


//-------------Code Starts Here-------


//	byte4data disp(
//		GPIO_1[33:26], //data bus in
//		vbus[15:0],//voltage out
//		GPIO_0[5] , // Enable counting, driven by RXF# from FT2232H
//		GPIO_0_IN[0] , // clock input from FT2232H
//		GPIO_0[6] , // output to FT2232H RD#
//		GPIO_0[3] , // output to FT2232H WR#
//		GPIO_0[2] , // output to FT2232H OE#
//		GPIO_0[4]  // output to FT2232H SI/WUA#
//		//GPIO_0[1]  // monitor CLK 60 from Morphic IO pins
//	);

//	dac1 DaccyMcDacFace(
//		CLOCK_50,//GPIO_0_IN[0], //clock in
//		vbus[15:0], //voltage in
//		GPIO_1[25], //serial data out
//		GPIO_1[24], //word clock out
//		GPIO_1[23] //bit clock out
//	);
	reg [2:0] swtcount =3'b0;
	reg [7:0] ledbuffer;
	reg [63:0] busiestbeebuffer = 64'b0;
	assign LED=ledbuffer;
//	assign nwFIFO=nwFIFObuffer;
//	reg nwFIFObuffer;
//	assign busiestbee=busiestbeebuffer;
//	reg reset=1'b1;
//	always @(posedge GPIO_0_IN[0])
//	begin
//		if (reset&&!GPIO_0[5])
//		begin
//			ledbuffer<=GPIO_1[33:26];
//			reset<=1'b0;
//		end
//	end

	bitwordclocks wrdbtclk(CLOCK_50,wordclk,bitclk)	; //creates bit and word clocks	
//	always @(posedge bitclk)
//	begin
//		if (!rdempty)
//		begin
//			nwFIFObuffer<=1'b1;
//		end
//	end
//	always @(posedge bitclk)
//	begin
//		if (nwDAC[ch]==1'b1)
//		begin
//			busiestbeebuffer[ch]<=1'b1;
//			#16;
//			busiestbeebuffer[ch]=1'b0;
//		end else
//		begin
//			busiestbeebuffer=64'b0;
//		end
//	end
	readusb rdusbhw(
		GPIO_1[33:26], //data bus in
		fifobus[31:0],//32 bits
		GPIO_0[5] , // Enable counting, driven by RXF# from FT2232H
		GPIO_0_IN[0] , // clock input from FT2232H
		bitclk, 	//fpga clock
		GPIO_0[6] , // output to FT2232H RD#
		GPIO_0[3] , // output to FT2232H WR#
		GPIO_0[2] , // output to FT2232H OE#
		GPIO_0[4],  // output to FT2232H SI/WUA#
		rdempty,
		rdfull,		
		nwFIFO,
		SW[0]
	);
//		readusb rdusbhw( //how it will be implemented
//		GPIO_1[12:5], //data bus in
//		fifobus[31:0],//32 bits
//		GPIO_0[0] , // Enable counting, driven by RXF# from FT2232H
//		GPIO_0_IN[0] , // clock input from FT2232H
//		bitclk, 	//fpga clock
//		GPIO_0[1] , // output to FT2232H RD#
//		GPIO_0[2] , // output to FT2232H WR#
//		GPIO_0[4] , // output to FT2232H OE#
//		GPIO_0[3],  // output to FT2232H SI/WUA#
//		rdempty,
//		rdfull,		
//		nwFIFO,
//		GPIO_0[33]
//	);
	byte4data datasort( 
		fifobus[31:0], //32bit data in
		bitclk, //clock in
		vbus[15:0], //16bit voltage
		ch[5:0],  //channel out
		tm[5:0],  //timer out
		rdempty , // Enable 
		nwFIFO, //1 when new data is required 0 when data is different
		nwDAC,		
		busiestbee
	);

	genvar i;
	generate
	for(i=1;i<=8;i=i+1) //i up to channels 
		begin : a_name
			dac2 DaccyMcDacFace(
			bitclk,
			vbus[15:0],
			GPIO_1[3*i], //wordclk channel 8 is 24
			GPIO_1[3*i-1], //bitclk channel 8 is 23 
			GPIO_1[3*i+1], //data channel 8 is 25
			tm[5:0],
			nwDAC[i],
			busiestbee[i]
			);
		end
	endgenerate	
//	generate
//	for(i=1;i<=8;i=i+1) //i up to channels 
//		begin : a_name
//			dac2 DaccyMcDacFace(
//			bitclk,
//			vbus[15:0],
//			GPIO_1[(3*i)+1], //wordclk channel 8 is 24
//			GPIO_1[3*i], //bitclk channel 8 is 23 
//			GPIO_1[(3*i)+2], //data channel 8 is 25
//			tm[5:0],
//			nwDAC[i],
//			busiestbee[i]
//			);
//		end
//	endgenerate	
	
	always @(negedge KEY[0])
	begin
		swtcount=swtcount+1;
	end	
	always @(posedge bitclk)
	begin	
		case (swtcount)
		0: begin
				ledbuffer<=fifobus[7:0];
			end
		1: begin
				ledbuffer<=fifobus[15:8];
			end
		2: begin
				ledbuffer<=fifobus[23:16];
			end
		3: begin
				ledbuffer<=fifobus[31:24];
			end
		4: begin
				ledbuffer<=vbus[7:0];
			end
		5: begin 
				ledbuffer<=vbus[15:8];
			end
		6: begin
				ledbuffer<=ch[5:0];
			end
		endcase
	end
endmodule 