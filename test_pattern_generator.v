module test_pattern_generator(q, addr);
	input	[18:0] addr;
	output [23:0] q;
	
	reg [23:0] data;
	
	assign q = data;
	
	always @(addr) begin
		data = addr < 153600 ? {8'h9E, 8'hE0, 8'h00} : {8'h60, 8'h52, 8'h39};	// BGR
	end
endmodule
