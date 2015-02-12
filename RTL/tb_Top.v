// test bench for CHIPPER Router

`include "globalVariable.v"
module tb_Top;

reg [`PKTID_SIZE-1:0]			inPktID [4:0];
reg [`FLITNUM_SIZE-1:0] 		inFlitNum [4:0];
reg [`COORDINATE_SIZE-1:0]		inSrc [4:0];
reg [`COORDINATE_SIZE-1:0]		inDst [4:0];
reg [`FLITTYPE_SIZE-1:0]		inType[4:0]; 
reg	[3:0]						inPG, inWU;
reg clk, reset, injectReq;

wire injectGrant;
wire [3:0]						outPG, outWU;
wire [`PKTID_SIZE-1:0]			outPktID [4:0];
wire [`FLITNUM_SIZE-1:0] 		outFlitNum [4:0];
wire [`COORDINATE_SIZE-1:0]	outSrc [4:0];
wire [`COORDINATE_SIZE-1:0]	outDst [4:0];
wire [`FLITTYPE_SIZE-1:0]		outType[4:0]; 
wire [`CHANNEL_SIZE-1:0]		w_outFlit[4:0];
wire [`PG_COUNTER_SIZE-1:0] 	pgCountValue =  tb_Top.Top.pgCounter.pgCountValue;
reg [`DATA_SIZE-1:0]			data[4:0];

Top Top (
	.inPortE				({inPktID[0],inFlitNum[0],inSrc[0],inDst[0],inType[0],data[0]}), 
	.inPortW				({inPktID[1],inFlitNum[1],inSrc[1],inDst[1],inType[1],data[1]}), 
	.inPortN				({inPktID[2],inFlitNum[2],inSrc[2],inDst[2],inType[2],data[2]}), 
	.inPortS				({inPktID[3],inFlitNum[3],inSrc[3],inDst[3],inType[3],data[3]}), 
	.inPortLocal		({inPktID[4],inFlitNum[4],inSrc[4],inDst[4],inType[4],data[4]}), 
	.injectReq			(injectReq), 
	.clk					(clk), 
	.reset				(reset), 
	.inPG				(inPG),
	.inWU				(inWU),
	.outPG				(outPG),
	.outWU				(outWU),
	.outPortE			(w_outFlit[0]), 
	.outPortW			(w_outFlit[1]), 
	.outPortN			(w_outFlit[2]), 
	.outPortS			(w_outFlit[3]), 
	.outPortLocal		(w_outFlit[4]), 
	.injectGrant		(injectGrant)
); 

genvar i;
generate
	for (i=0;i<5;i=i+1) begin
		assign outPktID[i] = w_outFlit[i][`PKT_ID];
		assign outFlitNum[i] = w_outFlit[i][`FLIT_NUM];
		assign outSrc[i] = w_outFlit[i][`SRC];
		assign outDst[i] = w_outFlit[i][`DST];
		assign outType[i] = w_outFlit[i][`TYPE];
	end
endgenerate

always @ *
	#5 clk <= ~clk;

always @ (posedge clk) 
	$monitor ("@%0dns South=%d North=%d West=%d East=%d", $time, 
	tb_Top.Top.portStatus[3*`PORT_STAT_SIZE+:`PORT_STAT_SIZE], tb_Top.Top.portStatus[2*`PORT_STAT_SIZE+:`PORT_STAT_SIZE], tb_Top.Top.portStatus[1*`PORT_STAT_SIZE+:`PORT_STAT_SIZE], tb_Top.Top.portStatus[0*`PORT_STAT_SIZE+:`PORT_STAT_SIZE],);
	
initial begin
	$dumpfile ("Top.vcd"); // output the value of signals
	$dumpvars (0,Top);	// Coupled with $dumpfile command, specify which signals to output. use instance name
	
	// Initialization
	clk = 0;
	reset = 0;
	injectReq = 0;
	inPG = 4'b0000;
	inWU = 4'b0000;
	inPktID[0] = 8'd0;	inPktID[1] = 8'd0;	inPktID[2] = 8'd0;	inPktID[3] = 8'd0;	inPktID[4] = 8'd0; 
	inFlitNum[0] = 2'd0;	inFlitNum[1] = 2'd0;	inFlitNum[2] = 2'd0;	inFlitNum[3] = 2'd0;	inFlitNum[4] = 2'd0;
	inSrc[0] = 6'o0;		inSrc[1] = 6'o0; 		inSrc[2] = 6'o0; 		inSrc[3] = 6'o0; 		inSrc[4] = 6'o0;
	inDst[0] = 6'o0; 		inDst[1] = 6'o0; 		inDst[2] = 6'o0; 		inDst[3] = 6'o0; 		inDst[4] = 6'o0;
	inType[0] = 2'd0;		inType[1] = 2'd0;		inType[2] = 2'd0;		inType[3] = 2'd0;		inType[4] = 2'd0;
	data[0] = 128'd0;		data[1] = 128'd0;		data[2] = 128'd0;		data[3] = 128'd0;		data[4] = 128'd0;
	// Simulation starts here.
	# 10;
	reset = 1;
	
	// Test1
	// Pkt 0 and Pkt 1 compete for the North port. Pkt0 should win. Pkt 1 should be deflected.
	// Pkt 2 and pkt 3 compete for local port. The result is pseudorandom. 
	// Pkt 4 will inject to either the channel 2 or 3, depending on the ejection result. Then, it will be deflected.
	inPktID[0] = 8'd0;		inPktID[1] = 8'd1;		inPktID[2] = 8'd2;		inPktID[3] = 8'd3;		inPktID[4] = 8'd4;
	inFlitNum[0] = 2'd0;	inFlitNum[1] = 2'd0;	inFlitNum[2] = 2'd0;	inFlitNum[3] = 2'd0;	inFlitNum[4] = 2'd0;
	inSrc[0] = 6'o00;		inSrc[1] = 6'o00; 		inSrc[2] = 6'o00; 		inSrc[3] = 6'o00; 		inSrc[4] = 6'o00;
	inDst[0] = 6'o12; 		inDst[1] = 6'o12; 		inDst[2] = 6'o11; 		inDst[3] = 6'o11; 		inDst[4] = 6'o12;
	inType[0] = 2'd0;		inType[1] = 2'd0;		inType[2] = 2'd0;		inType[3] = 2'd0;		inType[4] = 2'd0;
	data[0] = 128'd0;		data[1] = 128'd1;		data[2] = 128'd2;		data[3] = 128'd3;		data[4] = 128'd4;
	injectReq = 1;

	# 10;
	// Test2
	// Pkt 0 and pkt 1 compete for the North port again. Pkt1 should win since its inFlitNum is smaller than that of Pkt0;
	// Pkt 2 and pkt 3 compete for the East port. The result is pseudorandom.
	// The injection request of pkt4 is denied.
	inPktID[0] = 8'd0;		inPktID[1] = 8'd0;		inPktID[2] = 8'd1;		inPktID[3] = 8'd1;		inPktID[4] = 8'd4;
	inFlitNum[0] = 2'd1;	inFlitNum[1] = 2'd0;	inFlitNum[2] = 2'd1;	inFlitNum[3] = 2'd0;	inFlitNum[4] = 2'd1;
	inSrc[0] = 6'o00;		inSrc[1] = 6'o00; 		inSrc[2] = 6'o00; 		inSrc[3] = 6'o00; 		inSrc[4] = 6'o00;
	inDst[0] = 6'o12; 		inDst[1] = 6'o12; 		inDst[2] = 6'o21; 		inDst[3] = 6'o21; 		inDst[4] = 6'o21;
	inType[0] = 2'd0;		inType[1] = 2'd0;		inType[2] = 2'd0;		inType[3] = 2'd0;		inType[3] = 2'd0;
	data[0] = 128'd5;		data[1] = 128'd6;		data[2] = 128'd7;		data[3] = 128'd8;		data[4] = 128'd9;
	injectReq = 1;
	
	# 10;
	inPktID[0] = 8'd0;	inPktID[1] = 8'd0;	inPktID[2] = 8'd0;	inPktID[3] = 8'd0;	inPktID[4] = 8'd0; 
	inFlitNum[0] = 2'd0;	inFlitNum[1] = 2'd0;	inFlitNum[2] = 2'd0;	inFlitNum[3] = 2'd0;	inFlitNum[4] = 2'd0;
	inSrc[0] = 6'o0;		inSrc[1] = 6'o0; 		inSrc[2] = 6'o0; 		inSrc[3] = 6'o0; 		inSrc[4] = 6'o0;
	inDst[0] = 6'o0; 		inDst[1] = 6'o0; 		inDst[2] = 6'o0; 		inDst[3] = 6'o0; 		inDst[4] = 6'o0;
	inType[0] = 2'd0;		inType[1] = 2'd0;		inType[2] = 2'd0;		inType[3] = 2'd0;		inType[4] = 2'd0;
	data[0] = 128'd0;		data[1] = 128'd0;		data[2] = 128'd0;		data[3] = 128'd0;		data[4] = 128'd0;
	
	# 9970;
	
	
	
	// Test2
	// Pkt 0 and pkt 1 compete for the North port again. Pkt1 should win since its inFlitNum is smaller than that of Pkt0;
	// Pkt 2 and pkt 3 compete for the East port. The result is pseudorandom.
	// The injection request of pkt4 is denied.
	inPktID[2] = 8'd1;		inPktID[3] = 8'd2;		inPktID[4] = 8'd4;
	inFlitNum[2] = 2'd1;	inFlitNum[3] = 2'd0; 	inFlitNum[4] = 2'd1;
	inSrc[2] = 6'o00;		inSrc[3] = 6'o00; 		inSrc[4] = 6'o00;
	inDst[2] = 6'o21; 		inDst[3] = 6'o01; 		inDst[4] = 6'o21;
	inType[2] = 2'd0;		inType[3] = 2'd0;		inType[4] = 2'd0;
	data[2] = 128'd5;		data[3] = 128'd6;		data[4] = 128'd9;
	injectReq = 1;	
	
	# 5;
	inPG = 4'b0011; // emulate the PG signal coming form the neighboring router
	
end	

initial begin
	# 10100; $finish;	// simulation ends here.	
end
	
	
endmodule