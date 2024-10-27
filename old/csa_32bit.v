module csa_32bit(out, co, ovf, in1, in2, ci);
	input ci;
	input [31:0] in1, in2;
	output co, ovf;
	output [31:0] out;
	wire lower_carry, lower_ovf;
	wire [15:0] higher_sum_lc0, higher_sum_lc1;
	wire higher_co_lc0, higher_co_lc1;
	wire higher_ovf_lc0, higher_ovf_lc1;

	rca_16bit lower(out[15:0], lower_carry, lower_ovf, in1[15:0], in2[15:0], ci);
	rca_16bit higher0(higher_sum_lc0[15:0], higher_co_lc0, higher_ovf_lc0, in1[31:16], in2[31:16], 1'b0);
	rca_16bit higher1(higher_sum_lc1[15:0], higher_co_lc1, higher_ovf_lc1, in1[31:16], in2[31:16], 1'b1);
	
	assign out[31:16] = lower_carry ? higher_sum_lc1 : higher_sum_lc0;
	assign co = lower_carry ? higher_co_lc1 : higher_co_lc0;
	assign ovf = lower_carry ? higher_ovf_lc1 : higher_ovf_lc0;
endmodule
