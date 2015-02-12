// 1 to 2 demux Size of DATA_SIZE + HEADER_SIZE

`include "globalVariable.v"

module demux1to2InRouter (dataIn, sel, aOut, bOut);

input 	[`IN_ROUTER_SIZE-1:0] 	dataIn;
input 												sel;
output 	[`IN_ROUTER_SIZE-1:0] 	aOut, bOut;

genvar i;
generate
	for (i=0;i<`IN_ROUTER_SIZE;i=i+1)
	begin:demux1to2InRouter
		demux2to1 demux2to1 (
		.dataIn	(dataIn[i]),
		.sel		(sel),
		.aOut		(aOut[i]),
		.bOut		(bOut[i])		
		);	
	end
endgenerate

endmodule 