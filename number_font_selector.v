module number_font_selector(oColorIndex, iClock, iAddress, iValue);
    input iClock;
    input [3:0] iValue;
    input [10:0] iAddress;
    output reg [5:0] oColorIndex;

    wire [5:0] font_0_cidx_out, font_1_cidx_out, font_2_cidx_out, font_3_cidx_out, font_4_cidx_out, font_5_cidx_out, font_6_cidx_out, font_7_cidx_out, font_8_cidx_out, font_9_cidx_out;

    font_048_pixelmap font_0 (
        .address(iAddress),
        .clock(iClock),
        .q(font_0_cidx_out)
    );
    font_049_pixelmap font_1 (
        .address(iAddress),
        .clock(iClock),
        .q(font_1_cidx_out)
    );
    font_050_pixelmap font_2 (
        .address(iAddress),
        .clock(iClock),
        .q(font_2_cidx_out)
    );
    font_051_pixelmap font_3 (
        .address(iAddress),
        .clock(iClock),
        .q(font_3_cidx_out)
    );
    font_052_pixelmap font_4 (
        .address(iAddress),
        .clock(iClock),
        .q(font_4_cidx_out)
    );
    font_053_pixelmap font_5 (
        .address(iAddress),
        .clock(iClock),
        .q(font_5_cidx_out)
    );
    font_054_pixelmap font_6 (
        .address(iAddress),
        .clock(iClock),
        .q(font_6_cidx_out)
    );
    font_055_pixelmap font_7 (
        .address(iAddress),
        .clock(iClock),
        .q(font_7_cidx_out)
    );
    font_056_pixelmap font_8 (
        .address(iAddress),
        .clock(iClock),
        .q(font_8_cidx_out)
    );
    font_057_pixelmap font_9 (
        .address(iAddress),
        .clock(iClock),
        .q(font_9_cidx_out)
    );

    always @* begin
        oColorIndex = (iValue == 0) ? font_0_cidx_out :
                      (iValue == 1) ? font_1_cidx_out :
                      (iValue == 2) ? font_2_cidx_out :
                      (iValue == 3) ? font_3_cidx_out :
                      (iValue == 4) ? font_4_cidx_out :
                      (iValue == 5) ? font_5_cidx_out :
                      (iValue == 6) ? font_6_cidx_out :
                      (iValue == 7) ? font_7_cidx_out :
                      (iValue == 8) ? font_8_cidx_out :
                      (iValue == 9) ? font_9_cidx_out : 0;
    end

endmodule