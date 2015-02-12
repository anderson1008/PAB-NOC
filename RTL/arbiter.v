// Arbiter

`include "globalVariable.v"

module arbiter (GP0, GP1, inPktID0, inPktID1, valid0, valid1,winner);
	input GP0, GP1;
	input [`FLITNUM_SIZE-1:0]	inPktID0, inPktID1;
	input	valid0, valid1;
	
	output reg winner;
	
	always @ * begin
	// both flits compete the same channel.
		if (valid0 == 1 && valid1 == 1) begin
			if (GP0 == 1 && GP1 == 1) begin
				winner <= (inPktID1 < inPktID0) ? 1 : 0; // warning VER-318 can be ignored. 
			end
			else if (GP0 == 1) begin
				winner <= 0;
			end
			else if (GP1 == 1) begin
				winner <= 1;
			end
			else begin
				//winner <= ($random % 2) ? 1 : 0; // this is not synthesizable
				// The above code is not synthesizable.
				// So, just assign winner to be 0 in this case by doing nothing.
			        // It may cause fairness issue.
			end
		end
	
	// only one flit compete the channel.
		else if (valid0 == 1) 
			winner <= 0;
		else if (valid1 == 1)
			winner <= 1;
	end
	


endmodule