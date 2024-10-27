module sll_32bit(out, in, shift_amt);
    output [31:0] out;
    input [31:0] in;
    input [4:0] shift_amt;
    wire [31:0] shift_1_ret, shift_2_ret, shift_4_ret, shift_8_ret;

    genvar i;

    // shift of in by 0 or 1 according to shift_amt[0] to shift_1_ret
    generate
        for (i = 0; i < 32; i = i + 1) begin: shift_1
            if (i == 0) begin
                assign shift_1_ret[0] = shift_amt[0] ? 1'b0 : in[0];
            end
            else begin
                assign shift_1_ret[i] = shift_amt[0] ? in[i - 1] : in[i];
            end
        end
    endgenerate

    // shift of shift_1_ret by 0 or 2 according to shift_amt[1] to shift_2_ret
    generate
        for (i = 0; i < 32; i = i + 1) begin: shift_2
            if (i < 2) begin
                assign shift_2_ret[i] = shift_amt[1] ? 1'b0 : shift_1_ret[i];
            end
            else begin
                assign shift_2_ret[i] = shift_amt[1] ? shift_1_ret[i - 2] : shift_1_ret[i];
            end
        end
    endgenerate

    // shift of shift_2_ret by 0 or 4 according to shift_amt[2] to shift_4_ret
    generate
        for (i = 0; i < 32; i = i + 1) begin: shift_4
            if (i < 4) begin
                assign shift_4_ret[i] = shift_amt[2] ? 1'b0 : shift_2_ret[i];
            end
            else begin
                assign shift_4_ret[i] = shift_amt[2] ? shift_2_ret[i - 4] : shift_2_ret[i];
            end
        end
    endgenerate

    // shift of shift_4_ret by 0 or 8 according to shift_amt[3] to shift_8_ret
    generate
        for (i = 0; i < 32; i = i + 1) begin: shift_8
            if (i < 8) begin
                assign shift_8_ret[i] = shift_amt[3] ? 1'b0 : shift_4_ret[i];
            end
            else begin
                assign shift_8_ret[i] = shift_amt[3] ? shift_4_ret[i - 8] : shift_4_ret[i];
            end
        end
    endgenerate

    // shift of shift_8_ret by 0 or 16 according to shift_amt[4] to out
    generate
        for (i = 0; i < 32; i = i + 1) begin: shift_16
            if (i < 16) begin
                assign out[i] = shift_amt[4] ? 1'b0 : shift_8_ret[i];
            end
            else begin
                assign out[i] = shift_amt[4] ? shift_8_ret[i - 16] : shift_8_ret[i];
            end
        end
    endgenerate

endmodule
