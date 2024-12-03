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
	output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC;
	output [7:0] VGA_R, VGA_G, VGA_B;
	
	/** HW Reset **/
	wire reset;
	assign reset = ~resetn;
	
	/** Debug LEDs **/
	reg [7:0]	led_buf = 8'h00;
	assign leds = led_buf;
	
	/** Init Clock **/
	assign imem_clock = ~clock;
	assign dmem_clock = clock;
	clock_divider_quarter div1(regfile_clock, clock, reset);
	clock_divider_quarter div2(processor_clock, clock, reset);


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


	/** Test **/
	reg [1:0] screen;
	
	/** PS2 Keyboard **/
	wire [1:0] space_state;
	reg reset_space_state;
	PS2_Interface myps2(clock, ~reset, ps2_clock, ps2_data, space_state, reset_space_state);
	
	/** Test Logic **/
	reg signed [16:0] pipe_1_x, pipe_2_x, pipe_3_x;	// X is the left side of the gap between the pipes
	reg signed [16:0] pipe_1_y, pipe_2_y, pipe_3_y;	// Y is the top of the gap between the pipes (bottom of the top pipe)
	localparam PIPE_SPEED_DIVIDER = 500000;
	reg [31:0] pipe_timer;

	/** VGA controller **/
	wire DLY_RST, VGA_CTRL_CLK, VGA_CLK, AUD_CTRL_CLK;
	wire [18:0] ADDR;
	wire [23:0] rgb_data_raw;
	Reset_Delay r0 (.iCLK(clock),.oRESET(DLY_RST));
	VGA_Audio_PLL pll (.areset(~DLY_RST),.inclk0(clock),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK));
	vga_controller vga_ctrl(.iRST_n(DLY_RST & resetn),	// Low enabled
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
								.iClock(clock),
								.iAddress(ADDR),
								.iReset(reset),
								.iWScreen(1'b1),
								.iScreen(screen),
								.iWBGScroll(1'b1),
								.iBGScroll(screen == 1),
								.iWBirdY(1'b0),
								.iWScore(0),
								.iWPipe1X(1'b1),
								.iPipe1X(160),
								.iWPipe1Y(1'b1),
								.iPipe1Y(100),
								.iWPipe2X(1'b1),
								.iPipe2X(320),
								.iWPipe2Y(1'b1),
								.iPipe2Y(200),
								.iWPipe3X(1'b1),
								.iPipe3X(480),
								.iWPipe3Y(1'b1),
								.iPipe3Y(300),
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

	);
	
	// Test logic
	always @(posedge clock) begin
		if (reset | ~DLY_RST) begin
			screen = 0;
		end
		
		if (space_state == 2'd1 && !reset_space_state) begin
			led_buf = 8'b1;
			screen = (screen + 1) % 3;
			reset_space_state = 1'b1;
		end
		else if (space_state == 2'd2 && !reset_space_state) begin
			led_buf = 8'b0;
			reset_space_state = 1'b1;
		end
		else begin
			reset_space_state = 1'b0;
		end
	end
	
endmodule
