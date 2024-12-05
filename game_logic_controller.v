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
    output reg signed [31:0] oTest;

    localparam signed INVALID = -1;
    localparam SCREEN_WIDTH = 640;
    localparam PIPE_WIDTH = 52;
    localparam PIPE_GAP_HEIGHT = 100;
    localparam PIPE_DISTANCE = 275;

    reg [31:0] rand;
    reg [31:0] timer;
    localparam TIMER_DIVIDER = 200000;

    always @(posedge iClock) begin
        rand <= $unsigned(iRandomNumber[11:4]) + 40;

        if (iReset | iState == 0) begin
            oPipe1X <= SCREEN_WIDTH;
            oPipe1Y <= rand;
            oPipe2X <= SCREEN_WIDTH + PIPE_DISTANCE;
            oPipe2Y <= INVALID;
            oPipe3X <= SCREEN_WIDTH + PIPE_DISTANCE * 2;
            oPipe3Y <= INVALID;
            timer <= 0;
        end
        else if (iState == 1) begin
            if (oPipe1Y == INVALID) begin
                oPipe1Y <= rand;
            end
            else if (oPipe2Y == INVALID) begin
                oPipe2Y <= rand;
            end
            else if (oPipe3Y == INVALID) begin
                oPipe3Y <= rand;
            end
            else if (oPipe1X < -PIPE_WIDTH) begin
                oPipe1X <= oPipe3X + PIPE_DISTANCE;
                oPipe1Y <= rand;
            end
            else if (oPipe2X < -PIPE_WIDTH) begin
                oPipe2X <= oPipe1X + PIPE_DISTANCE;
                oPipe2Y <= rand;
            end
            else if (oPipe3X < -PIPE_WIDTH) begin
                oPipe3X <= oPipe2X + PIPE_DISTANCE;
                oPipe3Y <= rand;
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
