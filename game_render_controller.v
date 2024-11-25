module game_render_controller(oPixel, iClock, iAddress);

	localparam SCREEN_WIDTH = 640;
	localparam SCREEN_HEIGHT = 480;

	input [18:0] iAddress;  // 640*480 = 307200
	input iClock;
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


	/** Rendering Logic - Element Calculating **/
	wire [31:0] x, y;
	assign x = iAddress % SCREEN_WIDTH;
	assign y = iAddress / SCREEN_WIDTH;
	
	always @(posedge iClock) begin
		/** Background Scrolling **/
		if (iAddress == 0) begin
			bg_timer <= bg_timer + 1;
			if (bg_timer >= BG_SCROLL_SPEED_DIVIDER) begin
				bg_timer <= 0;
				bg_cur_x <= (bg_cur_x + 1) % BG_WIDTH;
			end
		end
	end
	
	/** Rendering Logic - Pixel Presenting **/
	always @* begin
		bg_pidx_in = ((x + bg_cur_x) % BG_WIDTH) + (y * BG_WIDTH);
		color_cidx_in = bg_cidx_out;
	end

endmodule
