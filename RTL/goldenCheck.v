// Golden Check

`include "globalVariable.v"

module goldenCheck (pktID, src, counterGolden, golden);

input		[`COORDINATE_SIZE+`PKTID_SIZE-1:0] 	counterGolden; // {PKTID, srcX, srcY}
input 	[`PKTID_SIZE-1:0] 						pktID;
input 	[`COORDINATE_SIZE-1:0] 					src;
output    												golden;	
		
assign golden = (counterGolden[`COORDINATE_SIZE+`PKTID_SIZE-1:`COORDINATE_SIZE] == pktID && counterGolden[`COORDINATE_SIZE-1:0] == src) ? 1 : 0; // Warning V318 can be ignored.
		

endmodule
