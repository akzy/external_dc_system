module bitwordclocks(pllin,wordclkout,bitclkout);
input pllin;
output wire  wordclkout, bitclkout;
reg [11:0] locclock;
pll2n pllclk(pllin,pllclock);  

always @ (posedge pllclock)
	begin
		locclock<=locclock+1;
	end
assign bitclkout = locclock[0]; 
assign wordclkout = locclock[4];
endmodule