module game_logic_controller(
    iClock, iReset,
    iRandomNumber,
    iState,
    oPipe1X, oPipe1Y,
    oPipe2X, oPipe2Y,
    oPipe3X, oPipe3Y,
);
    input iClock, iReset;
    input [31:0] iRandomNumber;
    input [1:0] iState;
    output reg signed [16:0] oPipe1X, oPipe1Y, oPipe2X, oPipe2Y, oPipe3X, oPipe3Y;

    localparam SCREEN_WIDTH = 640;
    localparam PIPE_WIDTH = 52;
    localparam PIPE_GAP_HEIGHT = 100;
    localparam PIPE_DISTANCE = 225;

    reg [31:0] timer;
    localparam TIMER_DIVIDER = 200000;

    always @(posedge iClock) begin
        if (iReset | iState != 1) begin
            oPipe1X <= SCREEN_WIDTH;
            oPipe1Y <= $signed(iRandomNumber % 151) + 100;
            oPipe2X <= SCREEN_WIDTH + PIPE_DISTANCE;
            oPipe2Y <= -1;
            oPipe3X <= SCREEN_WIDTH + PIPE_DISTANCE * 2;
            oPipe3Y <= -1;
            timer <= 0;
        end
        else begin
            if (oPipe1Y == -1) begin
                oPipe1Y <= $signed(iRandomNumber % 151) + 100;
            end
            else if (oPipe2Y == -1) begin
                oPipe2Y <= $signed(iRandomNumber % 151) + 100;
            end
            else if (oPipe3Y == -1) begin
                oPipe3Y <= $signed(iRandomNumber % 151) + 100;
            end
            else if (oPipe1X < -PIPE_WIDTH) begin
                oPipe1X <= SCREEN_WIDTH;
                oPipe1Y <= $signed(iRandomNumber % 151) + 100;
            end
            else if (oPipe2X < -PIPE_WIDTH) begin
                oPipe2X <= SCREEN_WIDTH;
                oPipe2Y <= $signed(iRandomNumber % 151) + 100;
            end
            else if (oPipe3X < -PIPE_WIDTH) begin
                oPipe3X <= SCREEN_WIDTH;
                oPipe3Y <= $signed(iRandomNumber % 151) + 100;
            end

            timer = timer + 1;
            if (timer >= TIMER_DIVIDER) begin
                timer = 0;
                oPipe1X <= oPipe1X - 1;
                oPipe2X <= oPipe2X - 1;
                oPipe3X <= oPipe3X - 1;
            end
        end
    end

endmodule
