module hardwaretest2(
GPIO_1,
GPIO_0,
CLOCK_50,
nwFIFO,
ch,
rdempty,
fifobus,
vbus,
busiestbee,
nwDAC,
RXF,
USBCLOCK,
datain,
channel,
SW
);

//----------Output Ports--------------

//output nwFIFO,rdempty,bitclk;
output rdempty;
output nwFIFO;
output [5:0] ch,channel;
output [31:0] fifobus;
output [33:0] GPIO_0;
output [33:0] GPIO_1;
output [63:0] busiestbee;
//------------Input Ports-------------- 
input CLOCK_50, RXF, USBCLOCK,SW;
//input nwFIFO;
input [7:0] datain;
//input [63:0] busiestbee;


//------------Inout Ports--------------

//------------Internal Variables---------

wire [5:0] tm;
output wire [15:0] vbus;
output wire [63:0] nwDAC;


//-------------Code Starts Here-------
bitwordclocks wrdbtclk(CLOCK_50,wordclk,bitclk)	;
	readusb rdusbhw(
		datain[7:0], //data bus in
		fifobus[31:0],//32 bits
		RXF , // Enable counting, driven by RXF# from FT2232H
		USBCLOCK , // clock input from FT2232H
		bitclk, 	//fpga clock
		GPIO_0[6] , // output to FT2232H RD#
		GPIO_0[3] , // output to FT2232H WR#
		GPIO_0[2] , // output to FT2232H OE#
		GPIO_0[4],  // output to FT2232H SI/WUA#
		rdempty,
		rdfull,		
		nwFIFO,
		SW
	);		
	byte4data datasort( 
		fifobus[31:0], //32bit data in
		bitclk, //clock in
		vbus[15:0], //16bit voltage
		ch[5:0],  //channel out
		tm[5:0],  //timer out
		rdempty , // Enable 
		nwFIFO, //data is different
		nwDAC,
		busiestbee,
		channel
	);	
	
	genvar i;
	generate
	for(i=1;i<=9;i=i+1) //i up to channels 
		begin : a_name
			dac2 DaccyMcDacFace(
			bitclk,
			vbus[15:0],
			GPIO_1[3*i], //wordclk channel 7 is 24
			GPIO_1[3*i-1], //bitclk channel 7 is 23 
			GPIO_1[3*i+1], //data channel 7 is 25
			tm[5:0],
			nwDAC[i],
			busiestbee[i]
			);
		end
	endgenerate	
endmodule 