module full_adder(out, co, in1, in2, ci);
	input in1, in2, ci;
	output out, co;
	wire in1_xor_in2, in1_and_in2, in1_xor_in2_and_ci;
	
	xor(in1_xor_in2, in1, in2);
	and(in1_and_in2, in1, in2);
	and(in1_xor_in2_and_ci, in1_xor_in2, ci);
	xor(out, in1_xor_in2, ci);
	or(co, in1_and_in2, in1_xor_in2_and_ci);
endmodule
