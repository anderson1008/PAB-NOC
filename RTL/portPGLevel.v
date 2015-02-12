// update port status based on the load of a router

`include "globalVariable.v"

module portPGLevel (reset, pgEnable, routerLoad, portPGTypeVector);

input reset, pgEnable;
input [`PG_ROUTER_LOAD_SIZE-1:0] routerLoad;
output reg [3:0] portPGTypeVector;

always @ * begin
	if (~reset) begin
		portPGTypeVector <= {`PERMANENT, `PERMANENT, `PERMANENT, `PERMANENT};
	end
	else begin
		if (pgEnable) begin
			if (routerLoad <= `PG_THRESHOLD_LV3) 
				portPGTypeVector <= {`PERMANENT,`PERMANENT,`NONPERMANENT,`NONPERMANENT};	// [S, N, W, E]			
			else if (routerLoad <= `PG_THRESHOLD_LV2) 
				portPGTypeVector <= {`PERMANENT,`PERMANENT,`NONPERMANENT,`NONPERMANENT};	// [S, N, W, E]
			else
				portPGTypeVector <= {`PERMANENT, `PERMANENT, `PERMANENT, `PERMANENT}; // [S, N, W, E]
		end
	end
end

endmodule