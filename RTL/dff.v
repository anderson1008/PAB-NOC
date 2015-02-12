// DFF with asyn reset

`include "globalVariable.v"

module DFF (dataIn, clk, reset, dataOut);

input clk, reset;
input [`CHANNEL_SIZE-1:0] dataIn;
output reg [`CHANNEL_SIZE-1:0] dataOut;

always @ (posedge clk or negedge reset)
	if (~reset)
		dataOut <= 1'b0;
	else
		dataOut <= dataIn;

endmodule
