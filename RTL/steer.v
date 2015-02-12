// Steering Function 

`include "globalVariable.v"

module steer (productiveVector, stage, desirePort);
	input [`PROD_VECTOR_SIZE-2:0] productiveVector;
	input							stage;
	output	reg						desirePort;
	
	always @ * begin
		if (stage == 0) begin
			if (productiveVector[0] || productiveVector[1])
				desirePort <= 1;
			else if (productiveVector[2] || productiveVector[3])
				desirePort <= 0;
		end
		else begin
			if (productiveVector[3] || productiveVector[1])
				desirePort <= 1;
			else if (productiveVector[2] || productiveVector[0])
				desirePort <= 0;
		end
	end

endmodule