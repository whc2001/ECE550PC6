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
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK,
	AUD_XCK,
	);
	input clock, resetn;	
	output imem_clock, dmem_clock, processor_clock, regfile_clock;
	inout ps2_data, ps2_clock;
	output [8:0] leds;
	output [6:0] seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC;
	output [7:0] VGA_R, VGA_G, VGA_B;
	inout AUD_BCLK;
	output AUD_DACDAT;
	inout AUD_DACLRCK;
	output AUD_XCK;
	
	/** Reset Logic **/
	wire reset;
	Reset_Delay r0 (.iCLK(clock),.oRESET(DLY_RST));
	assign reset = (~resetn) | (~DLY_RST);

	/** Clock **/
	wire ps2ctrl_clock, game_clock;
	assign imem_clock = ~clock;
	assign dmem_clock = clock;
	clock_divider_quarter div1(regfile_clock, clock, reset);
	clock_divider_quarter div2(processor_clock, clock, reset);
	clock_divider_quarter div3(ps2ctrl_clock, clock, reset);
	clock_divider_quarter div4(game_clock, clock, reset);
	wire DLY_RST, VGA_CTRL_CLK, VGA_CLK, AUD_CTRL_CLK;
	VGA_Audio_PLL pll (.areset(~DLY_RST),.inclk0(clock),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK));
	assign AUD_XCK = AUD_CTRL_CLK;

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
	wire w_game_state, w_bird_y, w_score, w_sound;
	wire [31:0] val_out;

	/** Game Logic **/
	wire signed [31:0] pipe_1_x, pipe_1_y, pipe_2_x, pipe_2_y, pipe_3_x, pipe_3_y;
	reg [31:0] seed;
	wire signed [31:0] random;
	wire random_reset;
	pseudo_random_generator game_rng(
		.iClock(game_clock),
		.iReset(reset | random_reset),
		.iSeed(seed),
		.iLower(30),
		.iUpper(260),
		.oValue(random)
	);
	game_logic_controller glc(
		game_clock, reset,
		random,
		game_state,
		pipe_1_x, pipe_1_y, pipe_2_x, pipe_2_y, pipe_3_x, pipe_3_y,
	);
	
	/** PS2 Keyboard **/
	wire [1:0] space_state;
	wire reset_space_state;
	PS2_Interface myps2(ps2ctrl_clock, ~reset, ps2_clock, ps2_data, space_state, reset_space_state);

	/** VGA controller **/

	wire [18:0] ADDR;
	wire [23:0] rgb_data_raw;
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
								
	/** Audio **/
	reg jump_play, score_play, death_play;
	wire ch1_en, ch2_en, ch3_en;
	wire [15:0] ch1_f, ch2_f, ch3_f;
	adio_codec psg (
				.iRST_N( ~reset ),
				.iCLK_18_4( AUD_CTRL_CLK ),
				.oAUD_BCK( AUD_BCLK ),
				.oAUD_DATA( AUD_DACDAT ),
				.oAUD_LRCK( AUD_DACLRCK ),																
				.ch1_en(ch1_en),
				.ch2_en(ch2_en),
				.ch3_en(ch3_en),
				.ch4_en(0),
				.ch1_f(ch1_f),
				.ch2_f(ch2_f),
				.ch3_f(ch3_f),
				.ch4_f(0),
				);
	se_jump _jump(
		.iClock(AUD_CTRL_CLK),
		.iTrig(jump_play),
		.oEnable(ch1_en),
		.oFreq(ch1_f)
	);
	se_score _score(
		.iClock(AUD_CTRL_CLK),
		.iTrig(score_play),
		.oEnable(ch2_en),
		.oFreq(ch2_f)
	);
	se_death _death(
		.iClock(AUD_CTRL_CLK),
		.iTrig(death_play),
		.oEnable(ch3_en),
		.oFreq(ch3_f)
	);

	/** Onboard LEDs **/
	assign leds = { game_state[0], 8'b0 };
	wire thousandsDigitEn, hundredsDigitEn, tensDigitEn, onesDigitEn;
	wire [3:0] thousandsDigit, hundredsDigit, tensDigit, onesDigit;
	assign thousandsDigitEn = (game_state[0] | game_state[1]) & (score >= 1000);
	assign hundredsDigitEn = (game_state[0] | game_state[1]) & (score >= 100);
	assign tensDigitEn = (game_state[0] | game_state[1]) & (score >= 10);
	assign onesDigitEn = (game_state[0] | game_state[1]);
	assign thousandsDigit = (score / 1000) % 10;
	assign hundredsDigit = (score / 100) % 10;
	assign tensDigit = (score / 10) % 10;
	assign onesDigit = score % 10;
	Hexadecimal_To_Seven_Segment hex5(thousandsDigitEn, thousandsDigit, seg4);
	Hexadecimal_To_Seven_Segment hex6(hundredsDigitEn, hundredsDigit, seg3);
	Hexadecimal_To_Seven_Segment hex7(tensDigitEn, tensDigit, seg2);
	Hexadecimal_To_Seven_Segment hex8(onesDigitEn, onesDigit, seg1);
	Hexadecimal_To_Seven_Segment hex1(1'b0, 0, seg5);
	Hexadecimal_To_Seven_Segment hex2(1'b0, 0, seg6);
	Hexadecimal_To_Seven_Segment hex3(1'b0, 0, seg7);
	Hexadecimal_To_Seven_Segment hex4(1'b0, 0, seg8);

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
		w_sound,
		val_out,
		
		pipe_1_x,
		pipe_1_y,
		pipe_2_x,
		pipe_2_y,
		pipe_3_x,
		pipe_3_y,
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
			if(w_sound) begin
				if (val_out == 0) jump_play <= 1;
				else if (val_out == 1) score_play <= 1;
				else if (val_out == 2) death_play <= 1;
			end
			else begin
				jump_play <= 0;
				score_play <= 0;
				death_play <= 0;
			end
		end
	end
	
endmodule
