module signext_17bit_32bit(out, in);
    output [31:0] out;
    input [16:0] in;

    wire sign = in[16];
    assign out = { {15{sign}}, in };
endmodule
