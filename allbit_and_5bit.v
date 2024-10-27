module allbit_and_5bit(out, in);
    input [4:0] in;
    output out;
    wire and01, and23, and0123;

    and and0(and01, in[0], in[1]);
    and and1(and23, in[2], in[3]);
    and and2(and0123, and01, and23);
    and and3(out, and0123, in[4]);
endmodule
