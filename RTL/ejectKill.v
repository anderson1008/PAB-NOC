// Ejection Kill 

`include "globalVariable.v"

module ejectKill (portIndex, winnerPort, validIn, winnerValid, validOut);

input	[`PORT_TAG_SIZE-1:0] portIndex, winnerPort;
input			validIn, winnerValid;
output		validOut;

assign validOut = (portIndex == winnerPort && validIn == 1 && winnerValid == 1) ? 0 : validIn;

endmodule