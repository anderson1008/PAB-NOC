// FSM of Power Gating Process

`include "globalVariable.v"

module fsmPG (clk, reset, portType, portLoad, pgEnable, inPG, inWU, portStatus, outPG, outWU);

input									clk, reset, portType, pgEnable, inPG, inWU;
input		[`PG_PORT_LOAD_SIZE-1:0]	portLoad;

output reg  [`PORT_STAT_SIZE-1:0] 		portStatus;
output reg								outPG;
output reg								outWU;


wire [5:0] control;
reg  [4:0] delay;

assign control [0] = (portType == `PERMANENT) ? 1 : 0;   // Warning V318 can be ignored.
assign control [1] = (portLoad < `PG_THRESHOLD_PORT) ? 1 : 0; // Warning V318 can be ignored.
assign control [2] = inPG;
assign control [3] = (delay == 0) ? 1 : 0;	// Warning V318 can be ignored.
assign control [4] = inWU;
assign control [5] = pgEnable;

always @ (portStatus or delay) begin
	case (portStatus)
		`ACTIVE: 
			; // no operation
		`WAIT_PG_HIGH:
			outPG = 1'b1;
		`INACTIVE: 
			delay = `WAKE_UP_DELAY;
		`WAKE_UP_TX: begin
			outWU = 1'b1;
			delay = delay - 1;
		end
		`WAKE_UP_RX:	
			delay = delay - 1;
		`WAIT_PG_LOW: begin
			outPG = 1'b0;
			outWU = 1'b0;
		end	
		`WAIT_WU_LOW:
			outPG = 1'b0;
		default: begin
			outPG = 1'b0;
			outWU = 1'b0;
		end
	endcase
end

always @ (posedge clk or negedge reset) begin
	if (~reset)
		portStatus = `ACTIVE;
	else begin
		case (portStatus)
			`ACTIVE: 
				if (control[0]==0 && control[1]==1 && control[5]==1) portStatus = `WAIT_PG_HIGH;
			`WAIT_PG_HIGH:
				if (control[2]==1) portStatus = `INACTIVE;
			`INACTIVE: begin
				if ((control[0]==1  && control[5]==1) | (control[1]==0  && control[5]==1)) portStatus = `WAKE_UP_TX;
				else if (control[4] == 1) portStatus = `WAKE_UP_RX;
			end
			`WAKE_UP_TX:
				if (control[3]==1) portStatus = `WAIT_PG_LOW;
			`WAKE_UP_RX:
				if (control[3]==1) portStatus = `WAIT_WU_LOW;
			`WAIT_PG_LOW:
				if (control[2]==0) portStatus = `ACTIVE;
			`WAIT_WU_LOW:
				if (control[4]==0) portStatus = `ACTIVE;
			default:
				portStatus = `ACTIVE;
		endcase
	end
end
 
endmodule
