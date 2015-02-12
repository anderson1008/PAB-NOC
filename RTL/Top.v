// Top Module of CHIPPER Router

`include "globalVariable.v"

module Top (inPortE, inPortW, inPortN, inPortS, inPortLocal, injectReq, clk, reset, inPG, inWU, outPortE, outPortW, outPortN, outPortS, outPortLocal, injectGrant, outPG, outWU);


input		[`CHANNEL_SIZE-1:0]  inPortE, inPortW, inPortN, inPortS,inPortLocal;
input									clk, reset,injectReq;
input		[3:0]						inPG, inWU;
output reg		[`CHANNEL_SIZE-1:0]	outPortE, outPortW, outPortN, outPortS,outPortLocal;
output									injectGrant;
output		[3:0]						outPG, outWU;

wire		[`COORDINATE_SIZE-1:0] 		CURRENT_POSITION = {`CURRENT_POSITION_X,`CURRENT_POSITION_Y};
wire		[`COORDINATE_SIZE+`PKTID_SIZE-1:0]	counterGolden;
wire		[`IN_ROUTER_SIZE-1:0]		inRouterFlit [3:0];
wire		[`IN_ROUTER_SIZE-1:0]		inj2PipelineLatch [3:0];
wire		[3:0]						valid;
wire		[3:0]						validArrival;
wire		[3:0]   					productiveVector;
wire		[3:0]   					portPGTypeVector;
wire									pgEnable;
wire		[4*`PORT_STAT_SIZE-1:0]		portStatus;
wire		[`PORT_STAT_SIZE-1:0]		wPortStatus [3:0];
wire  	 	[`PG_ROUTER_LOAD_SIZE-1:0]  routerLoad;
wire   	 	[4*`PG_PORT_LOAD_SIZE-1:0]  portLoad; // [S, N, W, E]		
wire   	 	[`PG_PORT_LOAD_SIZE-1:0]  	wPortLoad [3:0]; // [S, N, W, E]
	
genvar i;

goldenCounter 	goldenCounter (reset, clk, counterGolden);
pgCounter		pgCounter(clk, reset, pgEnable);
loadTrack 		loadTrack(reset, clk, validArrival, productiveVector, pgEnable, portStatus, routerLoad, portLoad);
portPGLevel 	portPGLevel(reset, pgEnable, routerLoad, portPGTypeVector);

generate
	for (i=0;i<4;i=i+1) 
	begin : generate1
		// Split the bus
		assign validArrival[i] = inRouterFlit[i][`VALID];
		assign productiveVector[i] = inRouterFlit[0][`PROD_VECTOR_EAST+i]&inRouterFlit[1][`PROD_VECTOR_EAST+i]&inRouterFlit[2][`PROD_VECTOR_EAST+i]&inRouterFlit[3][`PROD_VECTOR_EAST+i];
		assign wPortLoad[i] = portLoad[i*`PG_PORT_LOAD_SIZE+:`PG_PORT_LOAD_SIZE];
		
		// PG each data channel
		fsmPG fsmPG(clk, reset, portPGTypeVector[i], wPortLoad[i], pgEnable, inPG[i], inWU[i], wPortStatus[i], outPG[i], outWU[i]);
		
		// aggregate the bus segment
		assign portStatus[i*`PORT_STAT_SIZE+:`PORT_STAT_SIZE] = wPortStatus[i];
	end
endgenerate


reg		[`CHANNEL_SIZE-1:0]  inPort [4:0];


// input latch
always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		inPort[0] <= 0;
		inPort[1] <= 0;
		inPort[2] <= 0;
		inPort[3] <= 0;
		inPort[4] <= 0;
	end	
	else begin
		inPort[0] <= inPortE;
		inPort[1] <= inPortW;
		inPort[2] <= inPortN;
		inPort[3] <= inPortS;
		inPort[4] <= inPortLocal;
	end
end

generate
	for (i=0;i<3'd4;i=i+1)
	begin : generate2
		routerComputation RC (
		.flit							(inPort[i]), 
		.CURRENT_POSITION			(CURRENT_POSITION), 
		.counterGolden				(counterGolden), 
		.PORT_INDEX					(i[2:0]), 
		.inRouterFlit				(inRouterFlit[i])
		);		
	end
endgenerate

wire	[`IN_ROUTER_SIZE-1:0]		winningFlit;
ejectTree ejectTree(
	.flit0			(inRouterFlit[2]), 
	.flit1			(inRouterFlit[0]), 
	.flit2			(inRouterFlit[3]), 
	.flit3			(inRouterFlit[1]), 
	.winningFlit	(winningFlit)
);


generate
	for (i=0;i<4;i=i+1)
	begin	: generate3
		ejectKill ejectKill(
		.portIndex			(inRouterFlit[i][`PORT_TAG]), 
		.winnerPort			(winningFlit[`PORT_TAG]), 
		.validIn			(inRouterFlit[i][`VALID]),
		.winnerValid		(winningFlit[`VALID]),
		.validOut			(valid[i])  // check if there is any racing
		);
	end	
endgenerate

wire		[3:0]			grant; // inject channel selection

injectArb injectArb(
	.valid				(valid), 
	.injectReq			(injectReq),
	.portStatus			(portStatus),
	.injectGrant		(injectGrant), 
	.grant				(grant)
);

wire		[`IN_ROUTER_SIZE-1:0]	inRouterFlitLocal;

routerComputation RCLocal (
	.flit							(inPort[4]), 
	.CURRENT_POSITION			(CURRENT_POSITION), 
	.counterGolden				(counterGolden), 
	.PORT_INDEX					(3'b100), 
	.inRouterFlit				(inRouterFlitLocal)
);		

generate
	for (i=0;i<4;i=i+1)
	begin	: generate4
		mux2to1InRouter Inject (
			.aIn					({valid[i],inRouterFlit[i][`IN_ROUTER_SIZE-2:0]}), 
			.bIn					(inRouterFlitLocal), 
			.sel					(grant[i]), 
			.dataOut				(inj2PipelineLatch[i])
		);
	end	
endgenerate

reg	[`IN_ROUTER_SIZE-1:0]	pipelineLatch [3:0];

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		pipelineLatch[0] <= 0;
		pipelineLatch[1] <= 0;
		pipelineLatch[2] <= 0;
		pipelineLatch[3] <= 0;
		outPortLocal <= 0;
	end
	else begin 
		pipelineLatch[0] <= inj2PipelineLatch[0];
		pipelineLatch[1] <= inj2PipelineLatch[1];
		pipelineLatch[2] <= inj2PipelineLatch[2];
		pipelineLatch[3] <= inj2PipelineLatch[3];
		outPortLocal <= winningFlit;
	end
end

wire	[`IN_ROUTER_SIZE-1:0]	w_outPort [3:0];

permutationNetwork permutationNetwork(
	.inFlitE			(pipelineLatch[0]), 
	.inFlitW			(pipelineLatch[1]), 
	.inFlitN			(pipelineLatch[2]), 
	.inFlitS			(pipelineLatch[3]),
	.portStatus			(portStatus),
	.outFlitE		(w_outPort[0]), 
	.outFlitW		(w_outPort[1]), 
	.outFlitN		(w_outPort[2]), 
	.outFlitS		(w_outPort[3])
);


always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		outPortE <= 0;
		outPortW <= 0;
		outPortN <= 0;
		outPortS <= 0;
	end
	else begin 
		outPortE <= w_outPort[0][`CHANNEL_SIZE-1:0];
		outPortW <= w_outPort[1][`CHANNEL_SIZE-1:0];
		outPortN <= w_outPort[2][`CHANNEL_SIZE-1:0];
		outPortS <= w_outPort[3][`CHANNEL_SIZE-1:0];
	end
end


endmodule
