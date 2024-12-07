module game_render_controller(oPixel, iClock, iAddress, iReset,
	iScreen,
	iBGScroll,
	iBirdY,
	iScore, 
	iPipe1X, iPipe1Y,
	iPipe2X, iPipe2Y,
	iPipe3X, iPipe3Y,
	);

	localparam signed SCREEN_WIDTH = 640;
	localparam signed SCREEN_HEIGHT = 480;

	output [23:0] oPixel;
	input [18:0] iAddress;  // 640*480 = 307200
	input iClock, iReset;
	input iBGScroll;
	input [1:0] iScreen;
	input signed [31:0] iBirdY;
	input [31:0] iScore;
	input signed [31:0] iPipe1X, iPipe2X, iPipe3X;
	input signed [31:0] iPipe1Y, iPipe2Y, iPipe3Y;
	
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
	reg bg_scroll;
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
	
	/** Main Title **/
	localparam TITLE_WIDTH = 178;
	localparam TITLE_HEIGHT = 48;
	localparam TITLE_OFFSET_X = (SCREEN_WIDTH / 2) - (TITLE_WIDTH / 2);
	localparam TITLE_OFFSET_Y = (SCREEN_HEIGHT / 2) - (TITLE_HEIGHT / 2) - 100;
	reg is_in_title_area;
	reg [13:0] title_pidx_in;
	wire [5:0] title_cidx_out;
	title_pixelmap title (
		.address(title_pidx_in),
		.clock(~iClock),
		.q(title_cidx_out)
	);

	/** Play Button **/
	localparam PLAY_BUTTON_WIDTH = 116;
	localparam PLAY_BUTTON_HEIGHT = 70;
	localparam PLAY_BUTTON_OFFSET_X = (SCREEN_WIDTH / 2) - (PLAY_BUTTON_WIDTH / 2);
	localparam PLAY_BUTTON_OFFSET_Y = (SCREEN_HEIGHT / 2) - (PLAY_BUTTON_HEIGHT / 2) + 100;
	reg is_in_play_button_area;
	reg [12:0] play_button_pidx_in;
	wire [5:0] play_button_cidx_out;
	button_play_pixelmap play_button (
		.address(play_button_pidx_in),
		.clock(~iClock),
		.q(play_button_cidx_out)
	);

	/** Game Over **/
	localparam GAME_OVER_WIDTH = 204;
	localparam GAME_OVER_HEIGHT = 54;
	localparam GAME_OVER_OFFSET_X = (SCREEN_WIDTH / 2) - (GAME_OVER_WIDTH / 2);
	localparam GAME_OVER_OFFSET_Y = (SCREEN_HEIGHT / 2) - (GAME_OVER_HEIGHT / 2);
	reg is_in_game_over_area;
	reg [13:0] game_over_pidx_in;
	wire [5:0] game_over_cidx_out;
	text_game_over_pixelmap game_over (
		.address(game_over_pidx_in),
		.clock(~iClock),
		.q(game_over_cidx_out)
	);

	/** Current Screen **/
	localparam SCREEN_TITLE = 0;
	localparam SCREEN_PLAY = 1;
	localparam SCREEN_GAME_OVER = 2;
	
	/** Address to Coordinate **/
	wire signed [31:0] x, y;
	assign x = iAddress % SCREEN_WIDTH;
	assign y = iAddress / SCREEN_WIDTH;

	/** Rendering Logic - Timer Calculating **/
	always @(posedge iClock) begin
		/** Reset Logic **/
		if (iReset == 1'b1) begin
			bg_cur_x <= 0;
			bird_flap_state <= 0;
		end

		/** Per Frame Logic **/
		if (iAddress == 0) begin
			/** Background Scrolling **/
			if (iBGScroll) begin
				bg_timer <= bg_timer + 1;
				if (bg_timer >= BG_SCROLL_SPEED_DIVIDER) begin
					bg_timer <= 0;
					bg_cur_x <= (bg_cur_x + 1) % BG_WIDTH;
				end
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
	always @(*) begin
		/** Background **/
		bg_pidx_in <= ((x + bg_cur_x) % BG_WIDTH) + (y * BG_WIDTH);

		/** Bird **/
		is_in_bird_area <= (x >= ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2)))
							& (x < ((SCREEN_WIDTH / 2) + (BIRD_WIDTH / 2))) 
							& (y >= iBirdY) 
							& (y < (iBirdY + BIRD_HEIGHT));
		bird_pidx_in <= is_in_bird_area ? (x - ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2))) + ((y - iBirdY) * BIRD_WIDTH) : 0;
		bird_cidx_out <= (bird_flap_state == 0) ? bird_0_cidx_out : ((bird_flap_state == 1) ? bird_1_cidx_out : bird_2_cidx_out);

		/** Score **/
		is_in_score_digit1_area <= (x >= SCORE_OFFSET_X)
									& (x < (SCORE_OFFSET_X + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		is_in_score_digit2_area <= (x >= (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN))
									& (x < (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		is_in_score_digit3_area <= (x >= (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2))
									& (x < (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2 + NUMBER_WIDTH))
									& (y >= SCORE_OFFSET_Y)
									& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		score_digit_count <= (iScore > 99) ? 3 : ((iScore > 9) ? 2 : 1);
		score_current_digit <= is_in_score_digit1_area 
								? score_digit_count == 3 ? ((iScore / 100) % 10) : (score_digit_count == 2 ? ((iScore / 10) % 10) : iScore)
								: (is_in_score_digit2_area 
									? score_digit_count == 3 ? ((iScore / 10) % 10) : (score_digit_count == 2 ? (iScore % 10) : 0)
									: (is_in_score_digit3_area 
										? score_digit_count == 3 ? (iScore % 10) : 0
										: 0));
		number_pidx_in <= is_in_score_digit1_area
							? (x - SCORE_OFFSET_X) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH) 
							: ((is_in_score_digit2_area & (score_digit_count >= 2))
								? ((x - (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN)) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH))
								: ((is_in_score_digit3_area & (score_digit_count >= 3))
									? ((x - (SCORE_OFFSET_X + (NUMBER_WIDTH + SCORE_MARGIN) * 2)) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH)) 
									: 0));

		/** Pipes **/
		pipe_1_valid <= (iPipe1X >= -PIPE_WIDTH)
							& (iPipe1X < SCREEN_WIDTH)
							& (iPipe1Y >= 0)
							& (iPipe1Y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);
		pipe_2_valid <= (iPipe2X >= -PIPE_WIDTH)
							& (iPipe2X < SCREEN_WIDTH)
							& (iPipe2Y >= 0)
							& (iPipe2Y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);
		pipe_3_valid <= (iPipe3X >= -PIPE_WIDTH)
							& (iPipe3X < SCREEN_WIDTH)
							& (iPipe3Y >= 0)
							& (iPipe3Y < SCREEN_HEIGHT - PIPE_GAP_HEIGHT);

		is_in_pipe_1_top_area <= pipe_1_valid
								& (x >= iPipe1X)
								& (x < iPipe1X + PIPE_WIDTH)
								& (y >= 0)
								& (y < iPipe1Y);
		is_in_pipe_2_top_area <= pipe_2_valid
								& (x >= iPipe2X)
								& (x < iPipe2X + PIPE_WIDTH)
								& (y >= 0)
								& (y < iPipe2Y);
		is_in_pipe_3_top_area <= pipe_3_valid
								& (x >= iPipe3X)
								& (x < iPipe3X + PIPE_WIDTH)
								& (y >= 0)
								& (y < iPipe3Y);
		is_in_pipe_1_bottom_area <= pipe_1_valid
								& (x >= iPipe1X)
								& (x < iPipe1X + PIPE_WIDTH)
								& (y >= iPipe1Y + PIPE_GAP_HEIGHT)
								& (y < SCREEN_HEIGHT);
		is_in_pipe_2_bottom_area <= pipe_2_valid 
								& (x >= iPipe2X)
								& (x < iPipe2X + PIPE_WIDTH)
								& (y >= iPipe2Y + PIPE_GAP_HEIGHT)
								& (y < SCREEN_HEIGHT);
		is_in_pipe_3_bottom_area <= pipe_3_valid 
								& (x >= iPipe3X)
								& (x < iPipe3X + PIPE_WIDTH)
								& (y >= iPipe3Y + PIPE_GAP_HEIGHT)
								& (y < SCREEN_HEIGHT);

		pipe_up_pidx_in <= is_in_pipe_1_top_area
							? ((x - iPipe1X) + ((y + (PIPE_HEIGHT - iPipe1Y)) * PIPE_WIDTH))
							: (is_in_pipe_2_top_area
								? ((x - iPipe2X) + ((y + (PIPE_HEIGHT - iPipe2Y)) * PIPE_WIDTH))
								: (is_in_pipe_3_top_area
									? ((x - iPipe3X) + ((y + (PIPE_HEIGHT - iPipe3Y)) * PIPE_WIDTH))
									: 0));
		pipe_down_pidx_in <= is_in_pipe_1_bottom_area
							? ((x - iPipe1X) + ((y - iPipe1Y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
							: (is_in_pipe_2_bottom_area
								? ((x - iPipe2X) + ((y - iPipe2Y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
								: (is_in_pipe_3_bottom_area
									? ((x - iPipe3X) + ((y - iPipe3Y - PIPE_GAP_HEIGHT) * PIPE_WIDTH))
									: 0));

		/** Title **/
		is_in_title_area <= (x >= TITLE_OFFSET_X)
							& (x < (TITLE_OFFSET_X + TITLE_WIDTH))
							& (y >= TITLE_OFFSET_Y)
							& (y < (TITLE_OFFSET_Y + TITLE_HEIGHT));
		title_pidx_in <= is_in_title_area ? (x - TITLE_OFFSET_X) + ((y - TITLE_OFFSET_Y) * TITLE_WIDTH) : 0;

		/** Play Button **/
		is_in_play_button_area <= (x >= PLAY_BUTTON_OFFSET_X)
								& (x < (PLAY_BUTTON_OFFSET_X + PLAY_BUTTON_WIDTH))
								& (y >= PLAY_BUTTON_OFFSET_Y)
								& (y < (PLAY_BUTTON_OFFSET_Y + PLAY_BUTTON_HEIGHT));
		play_button_pidx_in <= is_in_play_button_area ? (x - PLAY_BUTTON_OFFSET_X) + ((y - PLAY_BUTTON_OFFSET_Y) * PLAY_BUTTON_WIDTH) : 0;

		/** Game Over **/
		is_in_game_over_area <= (x >= GAME_OVER_OFFSET_X)
								& (x < (GAME_OVER_OFFSET_X + GAME_OVER_WIDTH))
								& (y >= GAME_OVER_OFFSET_Y)
								& (y < (GAME_OVER_OFFSET_Y + GAME_OVER_HEIGHT));
		game_over_pidx_in <= is_in_game_over_area ? (x - GAME_OVER_OFFSET_X) + ((y - GAME_OVER_OFFSET_Y) * GAME_OVER_WIDTH) : 0;
	end

	/** Rendering Logic - Pixel Rendering **/
	always @(posedge iClock) begin
		// switch by screen
		case (iScreen)
			SCREEN_TITLE: begin
				color_cidx_in <= ((is_in_title_area & (title_cidx_out != 0))
					? title_cidx_out
					: ((is_in_play_button_area & (play_button_cidx_out != 0))
					? play_button_cidx_out
					: bg_cidx_out));
			end
			SCREEN_PLAY: begin
				color_cidx_in <= (((is_in_score_digit1_area | is_in_score_digit2_area | is_in_score_digit3_area) & (number_cidx_out != 0)) 
					? number_cidx_out 
					: (((is_in_pipe_1_top_area | is_in_pipe_2_top_area | is_in_pipe_3_top_area) & (pipe_up_cidx_out != 0))
					? pipe_up_cidx_out
					: (((is_in_pipe_1_bottom_area | is_in_pipe_2_bottom_area | is_in_pipe_3_bottom_area) & (pipe_down_cidx_out != 0))
					? pipe_down_cidx_out
					: ((is_in_bird_area & (bird_cidx_out != 0)) 
					? bird_cidx_out
					: bg_cidx_out))));
			end
			SCREEN_GAME_OVER: begin
				color_cidx_in <= ((is_in_game_over_area & (game_over_cidx_out != 0))
					? game_over_cidx_out
					: (((is_in_score_digit1_area | is_in_score_digit2_area | is_in_score_digit3_area) & (number_cidx_out != 0)) 
					? number_cidx_out 
					: (((is_in_pipe_1_top_area | is_in_pipe_2_top_area | is_in_pipe_3_top_area) & (pipe_up_cidx_out != 0))
					? pipe_up_cidx_out
					: (((is_in_pipe_1_bottom_area | is_in_pipe_2_bottom_area | is_in_pipe_3_bottom_area) & (pipe_down_cidx_out != 0))
					? pipe_down_cidx_out
					: ((is_in_bird_area & (bird_cidx_out != 0)) 
					? bird_cidx_out
					: bg_cidx_out)))));
			end
			default: begin
				color_cidx_in <= 0;
			end
		endcase
	end
endmodule
