module regfile (
    clock,
    ctrl_writeEnable,
    ctrl_reset, ctrl_writeReg,
    ctrl_readRegA, ctrl_readRegB, data_writeReg,
    data_readRegA, data_readRegB
);
	genvar i, j;

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	output [31:0] data_readRegA, data_readRegB;

	// Logic for write
	wire [30:0] writeEnableToDFF;
	wire [31:0] decodedWriteAddress;
	onehot_decoder_32bit writeAddrDecoder(decodedWriteAddress, ctrl_writeReg);
	generate
		for(i = 0; i < 31; i = i + 1) begin: writeAndGate
			and _and(writeEnableToDFF[i], ctrl_writeEnable, decodedWriteAddress[i + 1]);	// address 0 is not used
		end
	endgenerate

	// Logic for read
	wire [992:0] dataFromDFF;
	wire [31:0] readEnableToBufferA, readEnableToBufferB;
	onehot_decoder_32bit readAddrDecoderA(readEnableToBufferA, ctrl_readRegA);
	onehot_decoder_32bit readAddrDecoderB(readEnableToBufferB, ctrl_readRegB);
	generate
		for(i = 0; i < 32; i = i + 1) begin: readMuxByte
			for(j = 0; j < 32; j = j + 1) begin: readMuxBit
				// Register 0 always outputs 0
				if (i == 0) begin
					assign data_readRegA[j] = readEnableToBufferA[i] ? 1'b0 : 1'bz;
					assign data_readRegB[j] = readEnableToBufferB[i] ? 1'b0 : 1'bz;
				end
				else begin
					assign data_readRegA[j] = readEnableToBufferA[i] ? dataFromDFF[(i - 1) * 32 + j] : 1'bz;
					assign data_readRegB[j] = readEnableToBufferB[i] ? dataFromDFF[(i - 1) * 32 + j] : 1'bz;
				end
			end
		end
	endgenerate

	// Registers
	generate
		for(i = 0; i < 31; i = i + 1) begin: dffes
			reg_32bit _reg(dataFromDFF[i * 32 + 32 - 1: i * 32], data_writeReg, clock, writeEnableToDFF[i], ctrl_reset);
		end
	endgenerate
endmodule
