module game_logic_controller(
	iClock, iReset,
	iRandomNumber,
	iState,
	oPipe1X, oPipe1Y,
	oPipe2X, oPipe2Y,
	oPipe3X, oPipe3Y,
	oTest,
);
	input iClock, iReset;
	input [31:0] iRandomNumber;
	input [1:0] iState;
	output reg signed [31:0] oPipe1X, oPipe1Y, oPipe2X, oPipe2Y, oPipe3X, oPipe3Y;
	output reg [31:0] oTest;

	localparam signed INVALID = -1;
	localparam signed SCREEN_WIDTH = 640;
	localparam signed PIPE_WIDTH = 52;
	localparam signed PIPE_GAP_HEIGHT = 100;
	localparam signed PIPE_DISTANCE = 275;
	localparam signed PIPE_Y_MIN = 50;
	
	reg [7:0] rand_pre;
	reg signed [31:0] rand_pos;
	reg [31:0] timer;
	localparam TIMER_DIVIDER = 50000;

	always @(posedge iClock) begin
		// Use sync assignment for random
		rand_pre = (iRandomNumber[7:0]) % 8'd200;
		rand_pos = 32'd80 + { 24'b0, rand_pre };

		if (iReset | (iState == 0)) begin
			oPipe1X <= SCREEN_WIDTH;
			oPipe1Y <= rand_pos;
			oTest <= 9876;
			oPipe2X <= SCREEN_WIDTH + PIPE_DISTANCE;
			oPipe2Y <= INVALID;
			oPipe3X <= SCREEN_WIDTH + PIPE_DISTANCE * 2;
			oPipe3Y <= INVALID;
			timer <= 0;
		end
		else if (iState == 1) begin
			if (oPipe1Y == INVALID) begin
				oPipe1Y <= rand_pos;
				oTest <= rand_pos;
			end
			else if (oPipe2Y == INVALID) begin
				oPipe2Y <= rand_pos;
				oTest <= rand_pos;
			end
			else if (oPipe3Y == INVALID) begin
				oPipe3Y <= rand_pos;
				oTest <= rand_pos;
			end
			else if (oPipe1X < -PIPE_WIDTH) begin
				oPipe1X <= oPipe3X + PIPE_DISTANCE;
				oPipe1Y <= rand_pos;
				oTest <= rand_pos;
			end
			else if (oPipe2X < -PIPE_WIDTH) begin
				oPipe2X <= oPipe1X + PIPE_DISTANCE;
				oPipe2Y <= rand_pos;
				oTest <= rand_pos;
			end
			else if (oPipe3X < -PIPE_WIDTH) begin
				oPipe3X <= oPipe2X + PIPE_DISTANCE;
				oPipe3Y <= rand_pos;
				oTest <= rand_pos;
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
