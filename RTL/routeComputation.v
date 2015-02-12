// Route Computation

`include "globalVariable.v"

module routerComputation (flit, CURRENT_POSITION, counterGolden, PORT_INDEX, inRouterFlit);

input		[`COORDINATE_SIZE-1:0]	CURRENT_POSITION;
input		[`CHANNEL_SIZE-1:0]		flit;
input		[`PORT_TAG_SIZE-1:0]							PORT_INDEX;
input		[`COORDINATE_SIZE+`PKTID_SIZE-1:0] counterGolden;
output	[`IN_ROUTER_SIZE-1:0]	inRouterFlit;

wire	[`COORDINATE_SIZE-1:0]	src, dest;
wire	[`PKTID_SIZE-1:0] 		pktID;
wire  [`FLITNUM_SIZE-1:0]		flitNum;
wire									valid, w_golden,golden;
wire	[`PROD_VECTOR_SIZE-1:0]							productiveVector, w_productiveVector;
wire 	[`COORDINATE_SIZE/2:0] deltaX, deltaY; // 1 bit longer than currPosition

// Extract each flied
assign	src = flit [`SRC];
assign	dest = flit [`DST];
assign	pktID = flit [`PKT_ID];
assign	flitNum = flit [`FLIT_NUM];
// end Extract each filed

// compute productive vector
wire doneX, doneY;
assign	deltaX = {1'b0,CURRENT_POSITION[`COORDINATE_SIZE-1:`COORDINATE_SIZE-3]} - {1'b0,dest[`COORDINATE_SIZE-1:`COORDINATE_SIZE-3]};
assign	deltaY = {1'b0,CURRENT_POSITION[`COORDINATE_SIZE-4:0]} - {1'b0, dest[`COORDINATE_SIZE-4:0]};
assign 	doneX = (deltaX == 0) ? 1 : 0;	
assign 	doneY = (deltaY == 0) ? 1 : 0;	
assign 	w_productiveVector[0] = ~doneX & deltaX[`COORDINATE_SIZE/2];  // +X -> East
assign 	w_productiveVector[1] = ~doneX & ~deltaX[`COORDINATE_SIZE/2];   // -X -> West
assign 	w_productiveVector[2] = ~doneY & deltaY[`COORDINATE_SIZE/2];  // +Y -> North
assign 	w_productiveVector[3] = ~doneY & ~deltaY[`COORDINATE_SIZE/2];   // -Y -> South
assign 	w_productiveVector[4] = doneX & doneY;	// local port
// end compute productive vector

// check valid
assign valid = (flit != 0) ? 1 : 0; // Warning V318 can be ignored.
// end check valid

// check golden
goldenCheck glodenCheck(
	.pktID				(pktID), 
	.src					(src), 
	.counterGolden		(counterGolden), 
	.golden				(w_golden)
);
// end check golden

wire [`PORT_TAG_SIZE-1:0] portIndex;
assign portIndex = valid ? PORT_INDEX : 0;
assign golden = valid ? w_golden : 0;
assign productiveVector = valid ? w_productiveVector : 0;

assign inRouterFlit = {valid, golden, portIndex, productiveVector, flit};

endmodule
