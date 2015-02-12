// Ejection Tree

`include "globalVariable.v"

module ejectTree (flit0, flit1, flit2, flit3, winningFlit);

input		[`IN_ROUTER_SIZE-1:0]		flit0, flit1, flit2, flit3;
output	[`IN_ROUTER_SIZE-1:0]		winningFlit;

wire		[`IN_ROUTER_SIZE-1:0]		winningFlitTemp1, winningFlitTemp2;

wire 	[`IN_ROUTER_SIZE-1:0] flit [3:0];


assign flit[0] = flit0[`PROD_VECTOR_LOCAL] ? flit0 : 0;
assign flit[1] = flit1[`PROD_VECTOR_LOCAL] ? flit1 : 0;
assign flit[2] = flit2[`PROD_VECTOR_LOCAL] ? flit2 : 0;
assign flit[3] = flit3[`PROD_VECTOR_LOCAL] ? flit3 : 0;


ejector ejector0St1(flit[0], flit[1], winningFlitTemp1);
ejector ejector1St1(flit[2], flit[3], winningFlitTemp2);
ejector ejectorSt2(winningFlitTemp1, winningFlitTemp2, winningFlit);


endmodule