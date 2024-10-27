module clock_divider(clkout, clkin, reset);
	input clkin, reset;
	output clkout;
	
	wire dffe_in;

	not inv(dffe_in, clkout);
	dffe_ref dff(clkout, dffe_in, clkin, 1'b1, reset);
endmodule
