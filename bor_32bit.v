module bor_32bit(out, in1, in2);
    output [31:0] out;
    input [31:0] in1, in2;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: ors
            or _or(out[i], in1[i], in2[i]);
        end
    endgenerate
endmodule
