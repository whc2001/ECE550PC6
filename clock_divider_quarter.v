module clock_divider_quarter(clkout, clkin, reset);
	input clkin, reset;
	output reg clkout;
	
	reg [31:0] i;
	
	localparam DIV = 4;
	
	always @(posedge clkin or posedge reset) begin
		if (reset) begin
			i <= 0;
			clkout <= 0;
		end
		else begin
			i <= (i + 1) % DIV;
			if (i == DIV - 1) clkout <= ~clkout;
		end
	end
//	wire dffe1_out, dffe1_in, dffe2_in;
//
//	not inv1(dffe1_in, dffe1_out);
//	dffe_ref dff1(dffe1_out, dffe1_in, clkin, 1'b1, reset);
//	
//	not inv2(dffe2_in, clkout);
//	dffe_ref dff2(clkout, dffe2_in, dffe1_out, 1'b1, reset);
endmodule
