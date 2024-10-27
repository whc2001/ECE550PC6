module rca_16bit(out, co, ovf, in1, in2, ci);
	input ci;
	input [15:0] in1, in2;
	output co, ovf;
	output [15:0] out;
	wire [14:0] carry;
	
	// generative for to create 16 full adders, use genertive if since condition in ternary is forbidden
	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin: full_adders
			if (i == 0) begin
				full_adder fa0(out[0], carry[0], in1[0], in2[0], ci);
			end
			else if (i == 15) begin
				full_adder fa15(out[15], co, in1[15], in2[15], carry[14]);
				xor ovf_det(ovf, carry[14], co);
			end
			else begin
				full_adder fa(out[i], carry[i], in1[i], in2[i], carry[i - 1]);
			end
		end
	endgenerate
endmodule
