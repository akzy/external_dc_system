	/*
----- Reads from um232h to fpga -------
Zak Romaszko
This module is designed read from um232h in synchrnous fifo mode. This device provides an 8bit word every clock (at 60MHz)
for which this module provides the pins needed to read ONLY. This 8bit word is then loaded into a fifo on the fpga to jump
between the USB fifo clock and the FPGA clock domain. The output is provided as a 32bit word. 
*/
//module readusb(
//indat, 	 //data pins to um232h
//out32 ,   // Output 
//rxf ,  // Enable counting, driven by RXF# from FT2232H
//clkusb ,  // clock input from FT2232H
//clkfpga,  //fpga clock
//read_n ,  // output to FT2232H RD#
//write_n , // output to FT2232H WR#
//out_en ,  // output to FT2232H OE#
//send_im,  // output to FT2232H SI/WUA#
//rdempty,
//rdfull,
//rdreq,
//SW 		 //negedge triggers
//);
////----------Output Ports--------------
//
//output [31:0] out32;
//output read_n; 	//read_n low for data
//output reg write_n = 1'b1; //send high to read
//output reg send_im = 1'b0; //not sure xD
//output reg out_en = 1'b0; 	//send low OE#
////output rdemptyout;
//output rdfull;
//
////------------Input Ports--------------
//input [7:0] indat;
//input rdreq,clkusb,clkfpga,rxf;
//input SW;
//
////------------Internal Variables---------
//wire enable,notread_n;
//output wire rdempty;
//assign enable=!rxf;
////assign rdreq=rdreqreg;
////assign rdemptyout=rdemptyreg;
//reg rst=1'b1;
//reg rdreqreg ;
//reg rdemptyreg;
//reg [1:0] state = 2'b0;
////-------------Code Starts Here-------
//
//fifo	fifo_inst (
//	indat,   	//8bit data from USB to FPGA ---- data
//	clkfpga, 	//FPGA clock ---- reading clock
//	rdreq,		//request reading from FPGA fifo 
//	clkusb,  	//USB Clock ---- writing clock
//	enable, 	//write to FPGA fifo from USB fifo ---- INPUT FROM USB FIFO MODULE. RXF goes low when data about to be loaded
//	out32,   	//32bit data for FPGA
//	rdempty,		//1 when nothing to read OUTPUT FROM FPGA FIFO MODULE
//	rdfull,  	//1 when full. Probably not needed OUTPUT FROM FPGA FIFO MODULE
//	notread_n, 	//allows writing to FPGA fifo OUTPUT FROM FPGA FIFO MODULE ----write side is empty
//	read_n   	//stops writing to FPGA fifo OUTPUT FROM  FPGA FIFO MODULE ----write side is full
//	);
//
//endmodule

	/*
----- Reads from um232h to fpga -------
Zak Romaszko
This module is designed read from um232h in synchrnous fifo mode. This device provides an 8bit word every clock (at 60MHz)
for which this module provides the pins needed to read ONLY. This 8bit word is then loaded into a fifo on the fpga to jump
between the USB fifo clock and the FPGA clock domain. The output is provided as a 32bit word. 
*/

module readusb(
indat, 	 //data pins to um232h
out32 ,   // Output 
rxf ,  // Enable counting, driven by RXF# from FT2232H
clkusb ,  // clock input from FT2232H
clkfpga,  //fpga clock
read_n ,  // output to FT2232H RD#
write_n , // output to FT2232H WR#
out_en ,  // output to FT2232H OE#
send_im,  // output to FT2232H SI/WUA#
rdemptyout,
rdfull,
rdreqin,
SW 		 //negedge triggers
);

//----------Output Ports--------------

output [31:0] out32;
output read_n; 	//read_n low for data
output reg write_n = 1'b1; //send high to read
output reg send_im = 1'b0; //not sure xD
output reg out_en = 1'b0; 	//send low OE#
output rdemptyout;
output rdfull;

//------------Input Ports--------------
input [7:0] indat;
input rdreqin,clkusb,clkfpga,rxf;
input SW;

//------------Internal Variables---------
wire enable,notread_n;
wire rdempty;
assign enable=!rxf;
assign rdreq=rdreqreg;
assign rdemptyout=rdemptyreg;
reg rst=1'b1;
reg rdreqreg=1'b0; 
reg rdemptyreg=1'b1;
reg [1:0] state = 2'b0;
reg [1:0] count=2'b0;
//-------------Code Starts Here-------
always @(posedge clkfpga)
begin
	if (!SW)
	begin
		rdreqreg<=1'b0;
		rdemptyreg<=1'b1;
	end 
	else begin
		rdreqreg<=rdreqin;
		rdemptyreg<=rdempty;
	end
	//count<=count+1;
end



//always @(posedge clkfpga)
//begin
//	rdreqreg<=rdreqin;
//	rdemptyreg<=rdempty;	
//end
fifo	fifo_inst (
	indat,   	//8bit data from USB to FPGA ---- data
	clkfpga,		//count		//FPGA clock ---- reading clock
	rdreq,		//request reading from FPGA fifo 
	clkusb,  	//USB Clock ---- writing clock
	enable, 		//write to FPGA fifo from USB fifo ---- INPUT FROM USB FIFO MODULE. RXF goes low when data about to be loaded
	out32,   	//32bit data for FPGA
	rdempty,		//1 when nothing to read OUTPUT FROM FPGA FIFO MODULE
	rdfull,  	//1 when full. Probably not needed OUTPUT FROM FPGA FIFO MODULE
	notread_n, 	//allows writing to FPGA fifo OUTPUT FROM FPGA FIFO MODULE ----write side is empty
	read_n   	//stops writing to FPGA fifo OUTPUT FROM  FPGA FIFO MODULE ----write side is full
	);

endmodule

