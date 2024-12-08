module pseudo_random_generator(
    input wire iClock,
    input wire iReset,
    input wire [31:0] iSeed,
    input wire [31:0] iLower,
    input wire [31:0] iUpper,
    output reg [31:0] oValue
);

    reg [31:0] lfsr;
    wire feedback;
    assign feedback = lfsr[31] ^ lfsr[30] ^ lfsr[29] ^ lfsr[9];

    always @(posedge iClock or posedge iReset) begin
        if (iReset) begin
            lfsr <= (iSeed != 0) ? iSeed : 32'hACE12468;
        end
        else begin
            lfsr <= { lfsr[30:0], feedback };
        end
    end

    wire [31:0] range = iUpper - iLower + 1;
    wire [63:0] mult_result = lfsr * range;
    wire [31:0] scaled_random = mult_result[63:32] + iLower;

    always @(posedge iClock or posedge iReset) begin
        if (iReset) begin
            oValue <= iLower;
        end
        else begin
            oValue <= scaled_random;
        end
    end

endmodule