module game_render_controller(oPixel, iClock, iAddress, iBirdY, iScore);

	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;

	input [18:0] iAddress;  // 640*480 = 307200
	input iClock;
	input [9:0] iBirdY;
	input [15:0] iScore;
	output [23:0] oPixel;

	/** Color Mapper **/
	reg [12:0] color_cidx_in;
	color_map cm (
		.address(color_cidx_in),
		.clock(iClock),
		.q(oPixel)
	);

	/** Background Pixel Mapper **/
	localparam BG_WIDTH = 260;
	localparam BG_HEIGHT = 480;
	reg [16:0] bg_pidx_in;
	wire [15:0] bg_cidx_out;
	bg_pixelmap bg (
		.address(bg_pidx_in),
		.clock(iClock),
		.q(bg_cidx_out)
	);
	 
	/** Background Scroll Timer **/
	localparam BG_SCROLL_SPEED_DIVIDER = 25000;
	reg [31:0] bg_timer;
	reg [8:0] bg_cur_x;
	
	/** Bird Pixel Mapper **/
	localparam BIRD_WIDTH = 34;
	localparam BIRD_HEIGHT = 24;
	reg is_in_bird_area;
	reg [9:0] bird_pidx_in; 
	wire [15:0] bird_0_cidx_out, bird_1_cidx_out, bird_2_cidx_out;
	reg [15:0] bird_cidx_out;
	bird2_0_pixelmap bird_0 (
		.address(bird_pidx_in),
		.clock(iClock),
		.q(bird_0_cidx_out)
	);
	bird2_1_pixelmap bird_1 (
		.address(bird_pidx_in),
		.clock(iClock),
		.q(bird_1_cidx_out)
	);
	bird2_2_pixelmap bird_2 (
		.address(bird_pidx_in),
		.clock(iClock),
		.q(bird_2_cidx_out)
	);

	/** Bird Flapping Timer **/
	localparam BIRD_FLAP_SPEED_DIVIDER = 150000;
	reg [31:0] bird_flap_timer;
	reg [1:0] bird_flap_state;

	/** Score Number **/
	localparam NUMBER_WIDTH = 24;
	localparam NUMBER_HEIGHT = 44;
	localparam SCORE_OFFSET_X = 10;
	localparam SCORE_OFFSET_Y = 10;
	localparam SCORE_MARGIN = 5;
	reg [15:0] score;
	reg [3:0] score_digit;

	reg is_in_score_tens_area, is_in_score_ones_area;
	reg [10:0] number_pidx_in;
	wire [15:0] number_cidx_out;
	number_font_selector num(
		.oColorIndex(number_cidx_out),
		.iClock(iClock),
		.iAddress(number_pidx_in),
		.iValue(score_digit)
	);

	/** Address to Coordinate **/
	wire [31:0] x, y;
	assign x = iAddress % SCREEN_WIDTH;
	assign y = iAddress / SCREEN_WIDTH;
	
	/** Rendering Logic - Timer Calculating **/
	always @(posedge iClock) begin
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
	always @* begin
		/** Background **/
		bg_pidx_in = ((x + bg_cur_x) % BG_WIDTH) + (y * BG_WIDTH);

		/** Bird **/
		is_in_bird_area = (x >= ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2)))
							&& (x < ((SCREEN_WIDTH / 2) + (BIRD_WIDTH / 2))) 
							&& (y >= iBirdY) 
							&& (y < (iBirdY + BIRD_HEIGHT));
		bird_pidx_in = is_in_bird_area ? (x - ((SCREEN_WIDTH / 2) - (BIRD_WIDTH / 2))) + ((y - iBirdY) * BIRD_WIDTH) : 0;
		bird_cidx_out = (bird_flap_state == 0) ? bird_0_cidx_out : ((bird_flap_state == 1) ? bird_1_cidx_out : bird_2_cidx_out);

		/** Score **/
		is_in_score_tens_area = (x >= SCORE_OFFSET_X)
									&& (x < (SCORE_OFFSET_X + NUMBER_WIDTH))
									&& (y >= SCORE_OFFSET_Y)
									&& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		is_in_score_ones_area = (x >= (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN))
									&& (x < (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN + NUMBER_WIDTH))
									&& (y >= SCORE_OFFSET_Y)
									&& (y < (SCORE_OFFSET_Y + NUMBER_HEIGHT));
		score = iScore > 99 ? 99 : iScore;
		score_digit = is_in_score_tens_area ? (score / 10) : (is_in_score_ones_area ? (score % 10) : 0);
		number_pidx_in = is_in_score_tens_area
							? (x - SCORE_OFFSET_X) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH) 
							: (is_in_score_ones_area 
								? (x - (SCORE_OFFSET_X + NUMBER_WIDTH + SCORE_MARGIN)) + ((y - SCORE_OFFSET_Y) * NUMBER_WIDTH) 
								: 0);
	end

	/** Rendering Logic - Pixel Rendering **/
	always @(posedge iClock) begin
		color_cidx_in = (is_in_bird_area & (bird_cidx_out != 0)) 
							? bird_cidx_out
							: (((is_in_score_tens_area | is_in_score_ones_area) & (number_cidx_out != 0))
								? number_cidx_out 
								: bg_cidx_out);
	end

endmodule
