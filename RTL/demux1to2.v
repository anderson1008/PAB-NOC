// demux 1 to 2

module demux2to1 (dataIn, sel, aOut, bOut);

input 	dataIn, sel;
output	aOut, bOut;

assign aOut = sel ? 0 : dataIn;
assign bOut = sel ? dataIn : 0;

endmodule