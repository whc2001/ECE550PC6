module game_render_controller(oPixel, iClock, iAddress, iReset,
	iBirdY, iScore, 
	iPipe1X, iPipe1Y, iPipe2X, iPipe2Y, iPipe3X, iPipe3Y,
	);

	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;

	output [23:0] oPixel;
	input [18:0] iAddress;  // 640*480 = 307200
	input iClock, iReset;
	input [9:0] iBirdY;
	input [15:0] iScore;
	input signed [16:0] iPipe1X, iPipe2X, iPipe3X;
	input signed [16:0] iPipe1Y, iPipe2Y, iPipe3Y;
	
	/** Color Mapper **/
	reg [5:0] color_cidx_in;
	color_map cm (
		.address(color_cidx_in),
		.clock(iClock),
		.q(oPixel)
	);

	/** Background Pixel Mapper **/
	localparam BG_WIDTH = 260;
	localparam BG_HEIGHT = 480;
	reg [16:0] bg_pidx_in;
	wire [5:0] bg_cidx_out;
	bg_pixelmap bg (
		.address(bg_pidx_in),
		.clock(~iClock),
		.q(bg_cidx_out)
	);
	 
	/** Background Scroll Timer **/
	localparam BG_SCROLL_SPEED_DIVIDER = 50000;
	reg [31:0] bg_timer;
	reg [8:0] bg_cur_x;
	
	/** Bird Pixel Mapper **/
	localparam BIRD_WIDTH = 34;
	localparam BIRD_HEIGHT = 24;
	reg is_in_bird_area;
	reg [9:0] bird_pidx_in; 
	wire [5:0] bird_0_cidx_out, bird_1_cidx_out, bird_2_cidx_out;
	reg [5:0] bird_cidx_out;
	bird2_0_pixelmap bird_0 (
		.address(bird_pidx_in),
		.clock(~iClock),
		.q(bird_0_cidx_out)
	);
	bird2_1_pixelmap bird_1 (
		.address(bird_pidx_in),
		.clock(~iClock),
		.q(bird_1_cidx_out)
	);
	bird2_2_pixelmap bird_2 (
		.address(bird_pidx_in),
		.clock(~iClock),
		.q(bird_2_cidx_out)
	);

	/** Bird Flapping Timer **/
	localparam BIRD_FLAP_SPEED_DIVIDER = 300000;
	reg [31:0] bird_flap_timer;
	reg [1:0] bird_flap_state;

	/** Pipe Pixel Mapper **/
	localparam PIPE_WIDTH = 52;
	localparam PIPE_HEIGHT = 380;
	localparam PIPE_GAP_HEIGHT = 100;

	reg signed [16:0] pipe_1_x, pipe_2_x, pipe_3_x;	// X is the left side of the gap between the pipes
	reg signed [16:0] pipe_1_y, pipe_2_y, pipe_3_y;	// Y is the top of the gap between the pipes (bottom of the top pipe)
	reg pipe_1_valid, pipe_2_valid, pipe_3_valid;
	reg is_in_pipe_1_top_area, is_in_pipe_1_bottom_area, is_in_pipe_2_top_area, is_in_pipe_2_bottom_area, is_in_pipe_3_top_area, is_in_pipe_3_bottom_area;
	reg [14:0] pipe_up_pidx_in;
	wire [5:0] pipe_up_cidx_out;
	reg [14:0] pipe_down_pidx_in;
	wire [5:0] pipe_down_cidx_out;
	pipe_up_pixelmap pipe_up (
		.address(pipe_up_pidx_in),
		.clock(~iClock),
		.q(pipe_up_cidx_out)
	);
	pipe_down_pixelmap pipe_down (
		.address(pipe_down_pidx_in),
		.clock(~iClock),
		.q(pipe_down_cidx_out)
	);

	/** Score Number **/
	localparam NUMBER_WIDTH = 24;
	localparam NUMBER_HEIGHT = 44;
	localparam SCORE_OFFSET_X = 5;
	localparam SCORE_OFFSET_Y = 5;
	localparam SCORE_MARGIN = 2;
	reg [15:0] score;
	reg [3:0] score_current_digit;

	reg is_in_score_digit1_area, is_in_score_digit2_area, is_in_score_digit3_area;
	reg [1:0] score_digit_count;
	reg [10:0] number_pidx_in;
	wire [5:0] number_cidx_out;
	number_font_selector num(
		.oColorIndex(number_cidx_out),
		.iClock(~iClock),
		.iAddress(number_pidx_in),
		.iValue(score_current_digit)
	);

	/** Address to Coordinate **/
	wire [31:0] x, y;
	assign x = iAddress % SCREEN_WIDTH;
	assign y = iAddress / SCREEN_WIDTH;

	/** Rendering Logic - Timer Calculating **/
	always @(posedge iClock) begin
		/** Reset Logic **/
		if (iReset == 1'b1) begin
			bg_cur_x = 0;
			bird_flap_state = 0;
		end
		
		/** Per Frame Logic **/
		if (iAddress == 0) begin
			/** Background Scrolling **/
			bg_timer <= bg_timer + 1;
			if (bg_timer >= BG_SCROLL_SPEED_DIVIDER) begin
				bg_timer <= 0;
				bg_cur_x <= (bg_cur_x + 1) % BG_WIDTH;
			end

			/** Bird Flapping **/
			bird_flap_timer <= bird_flap_timer + 1;
			if (bird_flap_timer >= BIRD_FLAP_SPEED_DIVIDER) begin
				bird_flap_timer <= 0;
				bird_flap_state <= (bird_flap_state + 1) % 3;
			end
		end
	end
	
	/** Rendering Logic - Pixel Presenting **/
	always @(iAddress) begin
		/** Background **/
		bg_pidx_in = ((x + bg_cur_x) % BG_WIDTH) + (y * BG_WIDTH);

		/** Bird **/
		is_in_bird_area = (x >= ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2)))
							& (x < ((SCREEN_WIDTH / 2) + (BIRD_WIDTH / 2))) 
							& (y >= iBirdY) 
							& (y < (iBirdY + BIRD_HEIGHT));
		bird_pidx_in = is_in_bird_area ? (x - ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2))) + ((y - iBirdY) * BIRD_WIDTH) : 0;
		bird_cidx_out = (bird_flap_state == 0) ? bird_0_cidx_out : ((bird_flap_state == 1) ? bird_1_cidx_out : bird_2_cidx_out);

		/** Score **/
		is_in_score_digit1_area = (x >= SCORE_OFFSET_X)
									& (x < (SCORE_OFFSET_X + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		is_in_score_digit2_area = (x >= (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN))
									& (x < (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		is_in_score_digit3_area = (x >= (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2))
									& (x < (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2 + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		score = iScore > 999 ? 999 : iScore;
		score_digit_count = score > 99 ? 3 : (score > 9 ? 2 : 1);
		score_current_digit = is_in_score_digit1_area 
								? score_digit_count == 3 ? score / 100 : (score_digit_count == 2 ? score / 10 : score)
								: (is_in_score_digit2_area 
									? score_digit_count == 3 ? (score % 100) / 10 : (score_digit_count == 2 ? score % 10 : 0)
									: (is_in_score_digit3_area 
										? score_digit_count == 3 ? score % 10 : 0
										: 0));
		number_pidx_in = is_in_score_digit1_area
							? (x - SCORE_OFFSET_X) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH) 
							: ((is_in_score_digit2_area & (score_digit_count >= 2))
								? ((x - (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN)) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH))
								: ((is_in_score_digit3_area & (score_digit_count >= 3))
									? ((x - (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2)) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH)) 
									: 0));

		/** Pipes **/
		pipe_1_x = iPipe1X;
		pipe_1_y = iPipe1Y;
		pipe_2_x = iPipe2X;
		pipe_2_y = iPipe2Y;
		pipe_3_x = iPipe3X;
		pipe_3_y = iPipe3Y;

		pipe_1_valid = (pipe_1_x >= -PIPE_WIDTH)
							& (pipe_1_x < SCREEN_WIDTH)
							& (pipe_1_y >= 0)
							& (pipe_1_y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);
		pipe_2_valid = (pipe_2_x >= -PIPE_WIDTH)
							& (pipe_2_x < SCREEN_WIDTH)
							& (pipe_2_y >= 0)
							& (pipe_2_y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);
		pipe_3_valid = (pipe_3_x >= -PIPE_WIDTH)
							& (pipe_3_x < SCREEN_WIDTH)
							& (pipe_3_y >= 0)
							& (pipe_3_y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);

		is_in_pipe_1_top_area = pipe_1_valid
								& ($signed(x) >= pipe_1_x)
								& ($signed(x) < pipe_1_x + PIPE_WIDTH)
								& ($signed(y) >= 0)
								& ($signed(y) < pipe_1_y);
		is_in_pipe_2_top_area = pipe_2_valid
								& ($signed(x) >= pipe_2_x)
								& ($signed(x) < pipe_2_x + PIPE_WIDTH)
								& ($signed(y) >= 0)
								& ($signed(y) < pipe_2_y);
		is_in_pipe_3_top_area = pipe_3_valid
								& ($signed(x) >= pipe_3_x)
								& ($signed(x) < pipe_3_x + PIPE_WIDTH)
								& ($signed(y) >= 0)
								& ($signed(y) < pipe_3_y);
		is_in_pipe_1_bottom_area = pipe_1_valid
								& ($signed(x) >= pipe_1_x)
								& ($signed(x) < pipe_1_x + PIPE_WIDTH)
								& ($signed(y) >= pipe_1_y + PIPE_GAP_HEIGHT)
								& ($signed(y) < SCREEN_HEIGHT);
		is_in_pipe_2_bottom_area = pipe_2_valid 
								& ($signed(x) >= pipe_2_x)
								& ($signed(x) < pipe_2_x + PIPE_WIDTH)
								& ($signed(y) >= pipe_2_y + PIPE_GAP_HEIGHT)
								& ($signed(y) < SCREEN_HEIGHT);
		is_in_pipe_3_bottom_area = pipe_3_valid 
								& ($signed(x) >= pipe_3_x)
								& ($signed(x) < pipe_3_x + PIPE_WIDTH)
								& ($signed(y) >= pipe_3_y + PIPE_GAP_HEIGHT)
								& ($signed(y) < SCREEN_HEIGHT);

		pipe_up_pidx_in = is_in_pipe_1_top_area
							? ((x - pipe_1_x) + ((y + (PIPE_HEIGHT - pipe_1_y)) * PIPE_WIDTH))
							: (is_in_pipe_2_top_area
								? ((x - pipe_2_x) + ((y + (PIPE_HEIGHT - pipe_2_y)) * PIPE_WIDTH))
								: (is_in_pipe_3_top_area
									? ((x - pipe_3_x) + ((y + (PIPE_HEIGHT - pipe_3_y)) * PIPE_WIDTH))
									: 0));
		pipe_down_pidx_in = is_in_pipe_1_bottom_area
							? ((x - pipe_1_x) + ((y - pipe_1_y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
							: (is_in_pipe_2_bottom_area
								? ((x - pipe_2_x) + ((y - pipe_2_y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
								: (is_in_pipe_3_bottom_area
									? ((x - pipe_3_x) + ((y - pipe_3_y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
									: 0));
	end

	/** Rendering Logic - Pixel Rendering **/
	always @(posedge iClock) begin
		color_cidx_in = (((is_in_score_digit1_area | is_in_score_digit2_area | is_in_score_digit3_area) & (number_cidx_out != 0)) 
					? number_cidx_out 
					: (((is_in_pipe_1_top_area | is_in_pipe_2_top_area | is_in_pipe_3_top_area) & (pipe_up_cidx_out != 0))
					? pipe_up_cidx_out
					: (((is_in_pipe_1_bottom_area | is_in_pipe_2_bottom_area | is_in_pipe_3_bottom_area) & (pipe_down_cidx_out != 0))
					? pipe_down_cidx_out
					: ((is_in_bird_area & (bird_cidx_out != 0)) 
					? bird_cidx_out
					: bg_cidx_out))));
	end
endmodule
