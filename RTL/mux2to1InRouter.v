// 2 to 1 mux Size of DATA_SIZE + HEADER_SIZE + 3

`include "globalVariable.v"

module mux2to1InRouter (aIn, bIn, sel, dataOut);

input 	[`IN_ROUTER_SIZE-1:0] 	aIn, bIn;
input 									sel;
output 	[`IN_ROUTER_SIZE-1:0] 	dataOut;

genvar i;
generate
	for (i=0;i<`IN_ROUTER_SIZE;i=i+1)
	begin:mux2to1InRouter
		mux2to1 mux2to1 (
		.aIn		(aIn[i]),
		.bIn		(bIn[i]),
		.sel		(sel),
		.dataOut	(dataOut[i])		
		);	
	end
endgenerate

endmodule 