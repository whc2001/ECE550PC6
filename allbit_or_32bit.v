module allbit_or_32bit(out, in);
    input [31:0] in;
    output out;
    
    wire [15:0] or1;
    wire [7:0] or2;
    wire [3:0] or3;
    wire [1:0] or4;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : or_32_16
            or _or (or1[i], in[2 * i], in[2 * i + 1]);
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin : or_16_8
            or _or (or2[i], or1[2 * i], or1[2 * i + 1]);
        end
    endgenerate

    generate
        for (i = 0; i < 4; i = i + 1) begin : or_8_4
            or _or (or3[i], or2[2 * i], or2[2 * i + 1]);
        end
    endgenerate

    generate
        for (i = 0; i < 2; i = i + 1) begin : or_4_2
            or _or (or4[i], or3[2 * i], or3[2 * i + 1]);
        end
    endgenerate

    or or_2_1 (out, or4[0], or4[1]);

endmodule
