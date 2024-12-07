 /**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB,                   // I: Data from port B of regfile

	space_state,
	reset_space_state,

	random_reseed,

	w_game_state,
	w_bird_y,
	w_score,
	val_out,
	
	pipe_1_x,
	pipe_1_y,
	pipe_2_x,
	pipe_2_y,
	pipe_3_x,
	pipe_3_y,
);

    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
	 
	 // PS2 Keyboard
	 input [1:0] space_state;
	 output reset_space_state;

	 // Random Number Generator
	 output random_reseed;

	 // Game Logic
	 output w_game_state, w_bird_y, w_score;
	 output [31:0] val_out;
	 input signed [31:0] pipe_1_x, pipe_1_y, pipe_2_x, pipe_2_y, pipe_3_x, pipe_3_y;
	 
	 /*** PC wires ***/
	 wire [11:0] pc_in, pc_out;
	 wire [11:0] pc_next, pc_branch;
	 wire bne_should_jump, blt_should_jump, bex_should_jump;
	 
	 /*** Instruction fetch ***/
    assign address_imem = pc_out;
	 wire [4:0] opcode = q_imem[31:27];
	 wire arith_r_type = ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0];
	 wire arith_i_type = ~opcode[4] & ~opcode[3] & opcode[2] & ~opcode[1] & opcode[0];
	 wire sw_type = ~opcode[4] & ~opcode[3] & opcode[2] & opcode[1] & opcode[0];
	 wire lw_type = ~opcode[4] & opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0];
	 wire j_type = ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & opcode[0];
	 wire bne_type = ~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1] & ~opcode[0];
	 wire jal_type = ~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1] & opcode[0];
	 wire jr_type = ~opcode[4] & ~opcode[3] & opcode[2] & ~opcode[1] & ~opcode[0];
	 wire blt_type = ~opcode[4] & ~opcode[3] & opcode[2] & opcode[1] & ~opcode[0];
	 wire bex_type = opcode[4] & ~opcode[3] & opcode[2] & opcode[1] & ~opcode[0];
	 wire setx_type = opcode[4] & ~opcode[3] & opcode[2] & ~opcode[1] & opcode[0];
	 wire pkey_type = opcode[4] & opcode[3] & opcode[2] & opcode[1] & opcode[0];
	 wire rsed_type = opcode[4] & opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0];
	 wire ssta_type = opcode[4] & opcode[3] & opcode[2] & ~opcode[1] & ~opcode[0];
	 wire spos_type = opcode[4] & opcode[3] & opcode[2] & ~opcode[1] & opcode[0];
	 wire sscr_type = opcode[4] & opcode[3] & opcode[2] & opcode[1] & ~opcode[0];
	 wire pobx1_type = ~opcode[4] & opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0];
	 wire pobx2_type = ~opcode[4] & opcode[3] & ~opcode[2] & ~opcode[1] & opcode[0];
	 wire pobx3_type = ~opcode[4] & opcode[3] & ~opcode[2] & opcode[1] & ~opcode[0];
	 wire poby1_type = ~opcode[4] & opcode[3] & opcode[2] & ~opcode[1] & ~opcode[0];
	 wire poby2_type = ~opcode[4] & opcode[3] & opcode[2] & ~opcode[1] & opcode[0];
	 wire poby3_type = ~opcode[4] & opcode[3] & opcode[2] & opcode[1] & ~opcode[0];
	 // Common shorthands
	 wire [4:0] rd = q_imem[26:22];
	 wire [4:0] rs = q_imem[21:17];
	 // R-type shorthands
	 wire [4:0] r_rt = q_imem[16:12];
	 wire [4:0] r_shamt = q_imem[11:7];
	 wire [4:0] r_aluop = q_imem[6:2];
	 // I-type shorthands
	 wire [16:0] i_imm = q_imem[16:0];
	 // JI-type shorthands
	 wire [26:0] ji_t = q_imem[26:0];
	 
	 /*** ALU ***/
	 wire [31:0] imm_signexted;
	 signext_17bit_32bit signext(imm_signexted, i_imm);
	 wire alu_op_is_add = ~r_aluop[4] & ~r_aluop[3] & ~r_aluop[2] & ~r_aluop[1] & ~r_aluop[0];
	 wire alu_op_is_sub = ~r_aluop[4] & ~r_aluop[3] & ~r_aluop[2] & ~r_aluop[1] & r_aluop[0];
	 wire [4:0] alu_op_in = (sw_type | lw_type) ? 5'd0 : (arith_r_type ? r_aluop : 5'd0);	// sw/lw/arith-i-type: add
	 wire [31:0] alu_result;
	 wire alu_ne, alu_lt, alu_ovf, alu_should_ovf;
	 wire [31:0] alu_ovf_code;
	 wire [31:0] alu_operand_b = bex_type ? 32'd0 : ((bne_type | blt_type | arith_r_type) ? data_readRegB : imm_signexted);
	 alu main_alu(
		.data_operandA(data_readRegA), .data_operandB(alu_operand_b),
		.ctrl_ALUopcode(alu_op_in), .ctrl_shiftamt(arith_r_type ? r_shamt : 5'b0), 
		.data_result(alu_result), 
		.isNotEqual(alu_ne), .isLessThan(alu_lt), .overflow(alu_ovf));
	 assign alu_ovf_code = arith_i_type ? 32'd2 : (alu_op_is_add ? 32'd1 : (alu_op_is_sub ? 32'd3 : 32'd0));
	 assign alu_should_ovf = (alu_op_is_add | alu_op_is_sub) & alu_ovf;
	 assign bne_should_jump = bne_type & alu_ne;
	 assign blt_should_jump = blt_type & alu_lt;
	 assign bex_should_jump = bex_type & alu_ne;
	 
	 /*** RegFile Operation ***/
	 assign ctrl_readRegA = (ssta_type | spos_type | sscr_type) ? rd : (bex_type ? 5'd30 : ((bne_type | blt_type | jr_type) ? rd : rs));
	 assign ctrl_readRegB = (bne_type | blt_type) ? rs : (sw_type ? rd : (arith_r_type ? r_rt : r_rt));	// If SW, read value of rd, otherwise for later
	 assign ctrl_writeReg = (pobx1_type | pobx2_type | pobx3_type | poby1_type | poby2_type | poby3_type) ? rd : (pkey_type ? rd : (jal_type ? 5'd31 : (lw_type ? rd : ((alu_should_ovf | setx_type) ? 5'd30 : rd))));	// If JAL, r31; If LW, write to rd
	 assign data_writeReg = pobx1_type ? pipe_1_x : poby1_type ? pipe_1_y : pobx2_type ? pipe_2_x : poby2_type ? pipe_2_y : pobx3_type ? pipe_3_x : poby3_type ? pipe_3_y : (pkey_type ? {30'd0, space_state} : (jal_type ? {20'd0, pc_next} : (lw_type ? q_dmem : (alu_should_ovf ? alu_ovf_code : (setx_type ? {5'd0, ji_t} : alu_result)))));	// If JAL, pc + 1; If LW, read from DMEM
	 assign ctrl_writeEnable = (pobx1_type | pobx2_type | pobx3_type | poby1_type | poby2_type | poby3_type) | pkey_type | arith_r_type | arith_i_type | lw_type | jal_type | setx_type;
	 
	 /*** DMEM Operation ***/
	 assign address_dmem = alu_result;
	 assign data = data_readRegB;
	 assign wren = sw_type;
	 
	 /*** PC Autoincrease ***/
	 reg_12bit pc(pc_out, pc_in, clock, 1'b1, reset);
	 alu pc_inc_alu(.data_operandA({20'b0, pc_out}), .data_operandB(32'd1), .ctrl_ALUopcode(5'd0), .data_result(pc_next));
	 alu pc_branch_alu(.data_operandA({20'b0, pc_next}), .data_operandB({15'b0, i_imm}), .ctrl_ALUopcode(5'd0), .data_result(pc_branch));
	 assign pc_in = (jal_type | j_type | bex_should_jump) ? ji_t : ((bne_should_jump | blt_should_jump) ? pc_branch : (jr_type ? data_readRegA : pc_next));	// changelater for JMP

	 /*** Keyboard ***/
	 assign reset_space_state = pkey_type;

	 /*** RNG ***/
	 assign random_reseed = rsed_type;

	 /*** Game Logic ***/
	 assign w_game_state = ssta_type;
	 assign w_bird_y = spos_type;
	 assign w_score = sscr_type;
	 assign val_out = data_readRegA;
endmodule
