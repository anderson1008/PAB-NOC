// track loads on each port and in each router. Also, when a port is disabled, use to track the potential deflection.
// After RC

`include "globalVariable.v"

module loadTrack (reset, clk, valid, productiveVector, pgEnable, portStatus, routerLoad, portLoad);

input		clk, reset,pgEnable;
input [3:0] valid;
input [3:0] productiveVector;
input [4*`PORT_STAT_SIZE-1:0] portStatus; // [S, N, W, E]
output [`PG_ROUTER_LOAD_SIZE-1:0] routerLoad;
output [4*`PG_PORT_LOAD_SIZE-1:0] portLoad; // [S, N, W, E]	

wire [`PORT_STAT_SIZE-1:0] wPortStatus [3:0];
genvar i;
generate
	for (i=0; i<4; i= i+1) begin : split_bus
		assign wPortStatus[i] = portStatus[i*`PORT_STAT_SIZE+:`PORT_STAT_SIZE];
	end
endgenerate

reg [`PG_PORT_LOAD_SIZE-1:0] portUtilization [3:0];
reg [2:0] j;
always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		for (j=0;j<4;j=j+1) 
			portUtilization[j] <= 0;
	end
	else begin
		if (~pgEnable) begin
			for (j=0;j<4;j=j+1) 
				if ((valid[j] && (wPortStatus[j] == `ACTIVE))| (productiveVector[j] && (wPortStatus[j] == `INACTIVE)))
					portUtilization[j] <= portUtilization[j] + 1;
		end
		else 
			for (j=0;j<4;j=j+1) 
				portUtilization[j] <= 0;	
	end
end
		
assign routerLoad = portUtilization[3]+portUtilization[2]+portUtilization[1]+portUtilization[0];
assign portLoad = {portUtilization[3],portUtilization[2],portUtilization[1],portUtilization[0]};

endmodule
