module reg_12bit(q, d, clk, en, clr);
    input [11:0] d;
    input clk, en, clr;
    output [11:0] q;

    genvar i;
    generate
        for(i = 0; i < 12; i = i + 1) begin: dffes
            dffe_ref _dffe(q[i], d[i], clk, en, clr);
        end
    endgenerate

endmodule
