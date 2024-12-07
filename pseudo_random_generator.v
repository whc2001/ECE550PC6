module pseudo_random_generator(oValue, iClock, iReset, iSeed);
    output reg signed [31:0] oValue;
    input iClock, iReset;
    input [31:0] iSeed;
	 
	 wire fb = oValue[31] ^ oValue[29] ^ oValue[28] ^ oValue[27]
					^ oValue[23] ^ oValue[20] ^ oValue[19] ^ oValue[17]
					^ oValue[15] ^ oValue[14] ^ oValue[12] ^ oValue[11]
					^ oValue[9] ^ oValue[4] ^ oValue[3] ^ oValue[2];

    always @(posedge iClock or posedge iReset) begin
        if (iReset) begin
            oValue <= (iSeed == 0) ? 32'hFA114514 : iSeed;
        end
        else begin
            oValue <= { oValue[30:0], fb };
        end
    end
endmodule
