// injectArb

`include "globalVariable.v"

module injectArb (valid, injectReq, portStatus, injectGrant, grant);

input		[3:0]						valid;
input		[4*`PORT_STAT_SIZE-1:0]		portStatus;
input									injectReq;
output									injectGrant;
output	[3:0]							grant;

wire	[`PORT_STAT_SIZE-1:0]	wPortStatus [3:0];
genvar i;
generate
	for (i=0; i<4; i= i+1) begin : split_bus
		assign wPortStatus[i] = portStatus[i*`PORT_STAT_SIZE+:`PORT_STAT_SIZE];
	end
endgenerate

assign grant[0] = ~valid[0] & (wPortStatus[0]==`ACTIVE) & injectReq;
assign grant[1] = ~grant[0] & (wPortStatus[1]==`ACTIVE) & ~valid[1] & injectReq;
assign grant[2] = ~grant[1] & (wPortStatus[2]==`ACTIVE) & ~valid[2] & injectReq;
assign grant[3] = ~grant[2] & (wPortStatus[3]==`ACTIVE) & ~valid[3] & injectReq;
assign injectGrant = grant[0] | grant[1] | grant[2] | grant[3];

endmodule