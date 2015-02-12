// Permutation Network

`include "globalVariable.v"

module permutationNetwork (inFlitE, inFlitW, inFlitN, inFlitS, portStatus, outFlitE, outFlitW, outFlitN, outFlitS);
	input 	[`IN_ROUTER_SIZE - 1:0] 	inFlitE, inFlitW, inFlitN, inFlitS;
	input 	[4*`PORT_STAT_SIZE-1:0]		portStatus; // [S, N, W, E]	
	output 	[`IN_ROUTER_SIZE - 1:0] 	outFlitE, outFlitW, outFlitN, outFlitS;
	
	wire	[`IN_ROUTER_SIZE-1:0] swapFlit [1:0];
	wire	[`IN_ROUTER_SIZE-1:0] straightFlit [1:0];
	
	permuterBlock PN00(inFlitN, inFlitE, 1'b0, 1'b0, portStatus, straightFlit[0], swapFlit[0]);
	permuterBlock PN01(inFlitS, inFlitW, 1'b0, 1'b1, portStatus, swapFlit[1], straightFlit[1]);
	permuterBlock PN10(straightFlit[0], swapFlit[1], 1'b1, 1'b0, portStatus, outFlitN, outFlitS);
	permuterBlock PN11(swapFlit[0], straightFlit[1], 1'b1, 1'b1, portStatus, outFlitE, outFlitW);
	
endmodule