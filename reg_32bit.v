module reg_32bit(q, d, clk, en, clr);
    input [31:0] d;
    input clk, en, clr;
    output [31:0] q;

    genvar i;
    generate
        for(i = 0; i < 32; i = i + 1) begin: dffes
            dffe_ref _dffe(q[i], d[i], clk, en, clr);
        end
    endgenerate

endmodule
