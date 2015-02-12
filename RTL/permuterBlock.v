// Permuter Block

`include "globalVariable.v"

module permuterBlock (inFlit0, inFlit1, stage, position, portStatus, outFlit0, outFlit1);
input								stage, position;
input		[4*`PORT_STAT_SIZE-1:0]		portStatus;
input		[`IN_ROUTER_SIZE-1:0] 	inFlit0,inFlit1;
output 	[`IN_ROUTER_SIZE-1:0]	outFlit0, outFlit1;

wire    winningChannel, flit0DesiredPort, flit1DesiredPort;
wire	[`IN_ROUTER_SIZE-1:0] swapFlit [1:0];
wire	[`IN_ROUTER_SIZE-1:0] straightFlit [1:0];
reg		swap;

wire	[`PORT_STAT_SIZE-1:0]	wPortStatus [3:0];
genvar i;
generate
	for (i=0; i<4; i= i+1) begin : split_bus
		assign wPortStatus[i] = portStatus[i*`PORT_STAT_SIZE+:`PORT_STAT_SIZE];
	end
endgenerate


arbiter PNArbiter(
	.GP0					(inFlit0[`GOLDEN]), 
	.GP1					(inFlit1[`GOLDEN]), 
	.inPktID0			(inFlit0[`FLIT_NUM]), 
	.inPktID1			(inFlit1[`FLIT_NUM]), 
	.valid0				(inFlit0[`VALID]), 
	.valid1				(inFlit1[`VALID]),
	.winner				(winningChannel)
);

steer steerUp(inFlit0[`PROD_VECTOR_NO_LOCAL],stage,flit0DesiredPort);
steer steerDown(inFlit1[`PROD_VECTOR_NO_LOCAL],stage,flit1DesiredPort);

always @ * begin
	if (
		((stage==1'b0 && position==1'b0) && (wPortStatus[3]==`INACTIVE | wPortStatus[1]==`INACTIVE))
	|   ((stage==1'b0 && position==1'b1) && (wPortStatus[2]==`INACTIVE | wPortStatus[0]==`INACTIVE))
	|   ((stage==1'b1 && position==1'b0) && (wPortStatus[3]==`INACTIVE | wPortStatus[2]==`INACTIVE))
	|   ((stage==1'b1 && position==1'b1) && (wPortStatus[1]==`INACTIVE | wPortStatus[0]==`INACTIVE))
	)
		swap <= 0;
	else if ((winningChannel == 0 && flit0DesiredPort == 1) || (winningChannel == 1 && flit1DesiredPort == 0))
		swap <= 1;
end


demux1to2InRouter demux0(
	.dataIn			(inFlit0), 
	.sel				(swap), 
	.aOut				(straightFlit[0]), 
	.bOut				(swapFlit[0])
);
	
demux1to2InRouter demux1(
	.dataIn			(inFlit1), 
	.sel				(swap), 
	.aOut				(straightFlit[1]), 
	.bOut				(swapFlit[1])
);

mux2to1InRouter mux0(
	.aIn				(straightFlit[0]), 
	.bIn				(swapFlit[1]), 
	.sel				(swap), 
	.dataOut			(outFlit0)
);
	
mux2to1InRouter mux1(
	.aIn				(straightFlit[1]), 
	.bIn				(swapFlit[0]), 
	.sel				(swap), 
	.dataOut			(outFlit1)
);
	
endmodule
