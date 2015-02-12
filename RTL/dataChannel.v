// A Data Channel

`include "globalVariable.v"

module dataChannel (clk, reset, inPort, counterGolden, injectGrant,winningFlitPortTag, winningFlitValid, inRouterFlitLocal,inner_wire_in1, inner_wire_in2,swap1, swap2, inner_wire_out1, inner_wire_out2,outPort);

input                                              clk, reset;
input          [`CHANNEL_SIZE-1:0]                 inPort;
input          [`COORDINATE_SIZE+`PKTID_SIZE-1:0]  counterGolden;
input          [`PORT_TAG_SIZE-1:0]                winningFlitPortTag;
input                                              winningFlitValid, injectGrant, swap1, swap2;
input          [`IN_ROUTER_SIZE-1:0]	            inRouterFlitLocal;
input          [`IN_ROUTER_SIZE-1:0]	            inner_wire_in1, inner_wire_in2;
output         [`IN_ROUTER_SIZE-1:0]	            inner_wire_out1, inner_wire_out2;
output   reg   [`CHANNEL_SIZE-1:0]                 outPort;

reg      [`CHANNEL_SIZE-1:0]  inputLatch;

always @ (posedge clk or negedge reset) begin
   if (~reset) begin
      inputLatch<= 0;
   end   
   else begin
      inputLatch <= inPort;
   end
end

wire  [`COORDINATE_SIZE-1:0]        CURRENT_POSITION = {`CURRENT_POSITION_X,`CURRENT_POSITION_Y};
wire  [`IN_ROUTER_SIZE-1:0]         inRouterFlit;

routerComputation RC (
.flit                     (inputLatch), 
.CURRENT_POSITION         (CURRENT_POSITION), 
.counterGolden            (counterGolden), 
.PORT_INDEX               (3'd0), // use East port as an example
.inRouterFlit            (inRouterFlit)
);
   
wire valid;

ejectKill ejectKill(
.portIndex         (inRouterFlit[`PORT_TAG]), 
.winnerPort         (winningFlitPortTag), 
.validIn            (inRouterFlit[`VALID]),
.winnerValid      (winningFlitValid),
.validOut         (valid)  // check if there is any racing
);

wire  [`IN_ROUTER_SIZE-1:0]		inj2PipelineLatch;
reg   [`IN_ROUTER_SIZE-1:0]      pipelineLatch;
mux2to1InRouter Inject (
.aIn					({valid,inRouterFlit[`IN_ROUTER_SIZE-2:0]}), 
.bIn					(inRouterFlitLocal), 
.sel					(injectGrant), 
.dataOut				(inj2PipelineLatch)
);

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		pipelineLatch <= 0;
	end
	else begin 
		pipelineLatch <= inj2PipelineLatch;
	end
end

wire	[`IN_ROUTER_SIZE-1:0]   straightFlit [1:0];
wire	[`IN_ROUTER_SIZE-1:0]   interStageFlit;
wire	[`IN_ROUTER_SIZE-1:0]   w_outPort;

demux1to2InRouter demux0(
	.dataIn			(pipelineLatch), 
	.sel				(swap1), 
	.aOut				(straightFlit[0]), 
	.bOut				(inner_wire_out1)
);

mux2to1InRouter mux0(
	.aIn				(straightFlit[0]), 
	.bIn				(inner_wire_in1), 
	.sel				(swap1), 
	.dataOut			(interStageFlit)
);
	
demux1to2InRouter demux1(
	.dataIn			(interStageFlit), 
	.sel				(swap2), 
	.aOut				(straightFlit[1]), 
	.bOut				(inner_wire_out2)
);

mux2to1InRouter mux1(
	.aIn				(straightFlit[1]), 
	.bIn				(inner_wire_in2), 
	.sel				(swap2), 
	.dataOut			(w_outPort)
);

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		outPort <= 0;
	end
	else begin 
		outPort <= w_outPort[`CHANNEL_SIZE-1:0];
	end
end

endmodule