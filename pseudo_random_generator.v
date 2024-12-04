module pseudo_random_generator(oValue, iClock, iReset, iSeed);
    output reg [31:0] oValue;
    input iClock, iReset;
    input [31:0] iSeed;

    always @(posedge iClock or posedge iReset) begin
        if (iReset) begin
            oValue <= iSeed == 0 ? 32'hFA114514 : iSeed;
        end
        else begin
            oValue <= { oValue[30:0], (oValue[5] ^ oValue[7] ^ oValue[11] ^ oValue[13] ^ oValue[17] ^ oValue[19]) };
        end
    end
endmodule
