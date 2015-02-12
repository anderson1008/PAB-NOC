// Power Gating Counter

`include "globalVariable.v"

module pgCounter (clk, reset, pgEnable);

input clk, reset;
output  pgEnable;

reg  [`PG_COUNTER_SIZE-1:0] pgCountValue;

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		pgCountValue = 0;
	end
	else begin
		if (pgCountValue == `EPOCH_PG-1) begin
			pgCountValue = 0;
		end
		else begin
			pgCountValue = pgCountValue + 1'd1;
		end
	end	
end

assign pgEnable = (pgCountValue == `EPOCH_PG-1) ? 1 : 0;	// Warning V318 can be ignored.
/*
output reg  pgEnable = 0;

reg  [`PG_COUNTER_SIZE-1:0] pgCountValue = 0;

always @ (posedge clk or negedge reset) begin
	if (~reset) begin
		pgEnable = 0;
		pgCountValue = 0;
	end
	else begin
		if (pgCountValue == `EPOCH_PG-1) begin
			pgCountValue = 0;
			pgEnable = 1;
		end
		else begin
			pgCountValue = pgCountValue + 1'd1;
			pgEnable = 0;
		end
	end	
end
*/
endmodule
