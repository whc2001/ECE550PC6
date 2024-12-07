/**
 * NOTE: you should not need to change this file! This file will be swapped out for a grading
 * "skeleton" for testing. We will also remove your imem and dmem file.
 *
 * NOTE: skeleton should be your top-level module!
 *
 * This skeleton file serves as a wrapper around the processor to provide certain control signals
 * and interfaces to memory elements. This structure allows for easier testing, as it is easier to
 * inspect which signals the processor tries to assert when.
 */

module skeleton(clock, resetn, imem_clock, dmem_clock, processor_clock, regfile_clock,
	leds,
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,
	ps2_clock, ps2_data,
	VGA_CLK,
	VGA_HS,
	VGA_VS,
	VGA_BLANK,
	VGA_SYNC,
	VGA_R,
	VGA_G,
	VGA_B,
	);
	input clock, resetn;	
	output imem_clock, dmem_clock, processor_clock, regfile_clock;
	inout ps2_data, ps2_clock;
	output [7:0] leds;
	output [6:0] seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC;
	output [7:0] VGA_R, VGA_G, VGA_B;
	
	/** Reset Logic **/
	wire reset;
	Reset_Delay r0 (.iCLK(clock),.oRESET(DLY_RST));
	assign reset = (~resetn) | (~DLY_RST);

	/** Debug LEDs **/
	reg [7:0] led_buf = 8'h00;
	wire [3:0] dig0, dig1, dig2, dig3, dig4, dig5, dig6, dig7;
	Hexadecimal_To_Seven_Segment hex1(dig0, seg1);
	Hexadecimal_To_Seven_Segment hex2(dig1, seg2);
	Hexadecimal_To_Seven_Segment hex3(dig2, seg3);
	Hexadecimal_To_Seven_Segment hex4(dig3, seg4);
	Hexadecimal_To_Seven_Segment hex5(dig4, seg5);
	Hexadecimal_To_Seven_Segment hex6(dig5, seg6);
	Hexadecimal_To_Seven_Segment hex7(dig6, seg7);
	Hexadecimal_To_Seven_Segment hex8(dig7, seg8);

	/** Clock **/
	wire ps2ctrl_clock, game_clock;
	assign imem_clock = ~clock;
	assign dmem_clock = clock;
	clock_divider_quarter div1(regfile_clock, clock, reset);
	clock_divider_quarter div2(processor_clock, clock, reset);
	clock_divider_quarter div3(ps2ctrl_clock, clock, reset);
	clock_divider_quarter div4(game_clock, clock, reset);

	/** IMEM **/
	// Figure out how to generate a Quartus syncram component and commit the generated verilog file.
	// Make sure you configure it correctly!
	wire [11:0] address_imem;
	wire [31:0] q_imem;
	imem my_imem(
		.address	(address_imem),			// address of data
		.clock	 (imem_clock),				 // you may need to invert the clock
		.q		 (q_imem)				  // the raw instruction
	);

	/** DMEM **/
	// Figure out how to generate a Quartus syncram component and commit the generated verilog file.
	// Make sure you configure it correctly!
	wire [11:0] address_dmem;
	wire [31:0] data;
	wire wren;
	wire [31:0] q_dmem;
	dmem my_dmem(
		.address	(address_dmem),	  // address of data
		.clock	 (dmem_clock),				 // may need to invert the clock
		.data		(data),	// data you want to write
		.wren		(wren),	 // write enable
		.q		 (q_dmem)	// data from dmem
	);

	/** REGFILE **/
	// Instantiate your regfile
	wire ctrl_writeEnable;
	wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	wire [31:0] data_writeReg;
	wire [31:0] data_readRegA, data_readRegB;
	regfile my_regfile(
		regfile_clock,
		ctrl_writeEnable,
		reset,
		ctrl_writeReg,
		ctrl_readRegA,
		ctrl_readRegB,
		data_writeReg,
		data_readRegA,
		data_readRegB
	);

	/** Registers **/
	reg [1:0] game_state;
	reg signed [31:0] bird_y;
	reg [31:0] score;
	wire w_game_state, w_bird_y, w_score;
	wire [31:0] val_out;

	/** Random **/
	reg [31:0] seed;
	wire signed [31:0] random;
	wire random_reset;
	pseudo_random_generator(random, clock, random_reset, ~seed);

	/** Game Logic **/
	wire [31:0] test;
	assign dig0 = (test % 10);
	assign dig1 = ((test / 10) % 10);
	assign dig2 = ((test / 100) % 10);
	assign dig3 = ((test / 1000) % 10);
	wire [31:0] pipe_1_x, pipe_1_y, pipe_2_x, pipe_2_y, pipe_3_x, pipe_3_y;
	game_logic_controller glc(
		game_clock, reset,
		random,
		game_state,
		pipe_1_x, pipe_1_y, pipe_2_x, pipe_2_y, pipe_3_x, pipe_3_y,
		test,
	);
	
	/** PS2 Keyboard **/
	wire [1:0] space_state;
	wire reset_space_state;
	PS2_Interface myps2(ps2ctrl_clock, ~reset, ps2_clock, ps2_data, space_state, reset_space_state);

	/** VGA controller **/
	wire DLY_RST, VGA_CTRL_CLK, VGA_CLK, AUD_CTRL_CLK;
	wire [18:0] ADDR;
	wire [23:0] rgb_data_raw;
	VGA_Audio_PLL pll (.areset(~DLY_RST),.inclk0(clock),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK));
	vga_controller vga_ctrl(.iRST_n(~reset),
								.iVGA_CLK(VGA_CLK),
								.oBLANK_n(VGA_BLANK),
								.oHS(VGA_HS),
								.oVS(VGA_VS),
								.b_data(VGA_B),
								.g_data(VGA_G),
								.r_data(VGA_R),
								.ADDR(ADDR),
								.rgb_data_raw(rgb_data_raw)
							);
	game_render_controller renderer(.oPixel(rgb_data_raw), 
								.iClock(VGA_CLK),
								.iAddress(ADDR),
								.iReset(reset),
								.iScreen(game_state),
								.iBGScroll(game_state == 1),
								.iBirdY(bird_y),
								.iScore(score),
								.iPipe1X(pipe_1_x),
								.iPipe1Y(pipe_1_y),
								.iPipe2X(pipe_2_x),
								.iPipe2Y(pipe_2_y),
								.iPipe3X(pipe_3_x),
								.iPipe3Y(pipe_3_y)
								);

	/** PROCESSOR **/
	processor my_processor(
		// Control signals
		processor_clock,						 // I: The master clock
		reset,						 // I: A reset signal

		// Imem
		address_imem,				  // O: The address of the data to get from imem
		q_imem,						// I: The data from imem

		// Dmem
		address_dmem,				  // O: The address of the data to get or put from/to dmem
		data,						  // O: The data to write to dmem
		wren,						  // O: Write enable for dmem
		q_dmem,						// I: The data from dmem

		// Regfile
		ctrl_writeEnable,			  // O: Write enable for regfile
		ctrl_writeReg,				 // O: Register to write to in regfile
		ctrl_readRegA,				 // O: Register to read from port A of regfile
		ctrl_readRegB,				 // O: Register to read from port B of regfile
		data_writeReg,				 // O: Data to write to for regfile
		data_readRegA,				 // I: Data from port A of regfile
		data_readRegB,				  // I: Data from port B of regfile

		space_state,
		reset_space_state,

		random_reset,

		w_game_state,
		w_bird_y,
		w_score,
		val_out,
	);

	always @(posedge clock) begin
		if (reset) begin
			game_state <= 0;
			bird_y <= 0;
			score <= 0;
			seed <= 0;
		end

		else begin
			seed <= seed + 1;

			if(w_game_state) game_state <= val_out;
			if(w_bird_y) bird_y <= val_out;
			if(w_score) score <= val_out;
		// if (space_state == 2'd1 && !reset_space_state) begin
		// 	if (screen == 0)
		// 		random_reset <= 1'b1;
		// 	screen <= (screen + 1) % 3;
		// 	reset_space_state <= 1'b1;
		// end
		// else if (space_state == 2'd2 && !reset_space_state) begin
		// 	reset_space_state <= 1'b1;
		// end
		// else begin
		// 	reset_space_state <= 1'b0;
		// 	random_reset <= 1'b0;
		// end
		end
	end
	
endmodule
