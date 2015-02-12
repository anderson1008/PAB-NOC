// determine the golden packet

`include "globalVariable.v"

module goldenCounter (reset, clk, counterGolden);

input reset, clk;
output reg [`COORDINATE_SIZE+`PKTID_SIZE-1:0] counterGolden; // {PKTID, srcX, srcY}

// internal counter       
reg 		[7:0]			counter;

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		counter <= 0;
		counterGolden <= 0;
	end
	else begin
		if (counter != `EPOCH_GOLDEN) begin
			counter <= counter + 1;
		end
		else begin
			counter <= 0;
			counterGolden <= counterGolden + 1;
		end
	end
end

endmodule