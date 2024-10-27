module onehot_decoder_32bit(out, in);
    input [4:0] in;
    output [31:0] out;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : ands
            allbit_and_5bit _and(out[i], ~(in ^ i));
        end
    endgenerate
endmodule
