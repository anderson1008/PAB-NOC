// Ejector

`include "globalVariable.v"

module ejector (flit0, flit1, winningFlit);

input		[`IN_ROUTER_SIZE-1:0]			flit0, flit1;
output	[`IN_ROUTER_SIZE-1:0]			winningFlit;

wire winner;

arbiter ejectArbiter(
	.GP0					(flit0[`GOLDEN]), 
	.GP1					(flit1[`GOLDEN]), 
	.inPktID0			(flit0[`FLIT_NUM]), 
	.inPktID1			(flit1[`FLIT_NUM]), 
	.valid0				(flit0[`PROD_VECTOR_LOCAL]), 
	.valid1				(flit1[`PROD_VECTOR_LOCAL]),
	.winner				(winner)
);

assign winningFlit = winner ? flit1 : flit0;

endmodule
