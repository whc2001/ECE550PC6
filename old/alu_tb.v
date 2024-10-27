`timescale 1 ns / 100 ps

module alu_tb();

	// inputs to the ALU are reg type

	reg            clock;
	reg [31:0] data_operandA, data_operandB, data_expected;
	reg [4:0] ctrl_ALUopcode, ctrl_shiftamt;


	// outputs from the ALU are wire type
	wire [31:0] data_result;
	wire isNotEqual, isLessThan, overflow;

	// Tracking the number of errors
	integer errors;
	integer index;    // for testing...


	// Instantiate ALU
	alu alu_ut(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt,
		data_result, isNotEqual, isLessThan, overflow);

	initial

	begin
				for(index = 0; index < 32; index = index + 1)
			begin
					assign data_expected = $signed(32'h80000000) >>> index;
					$display("**%h", data_expected);
				end
			
		$display($time, " << Starting the Simulation >>");
		clock = 1'b0;    // at time 0
		errors = 0;

		checkOr();
		checkAnd();
		checkAdd();
		checkSub();
		checkSLL();
		checkSRA();

		checkNE();
		checkLT();
		checkOverflow();

		if(errors == 0) begin
			$display("The simulation completed without errors");
		end
		else begin
			$display("The simulation failed with %d errors", errors);
		end

		$stop;
	end

	// Clock generator
	always
		 #10     clock = ~clock;

	task checkOr;
		begin
			$display("==== Checking Or ====");

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00011;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in OR (test 1); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 2); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 3); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 4); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'hA5A5A5A5) begin
				$display("**Error in OR (test 5); expected: %h, actual: %h", 32'hA5A5A5A5, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 6); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'hA5A5A5A5;

			@(negedge clock);
			if(data_result !== 32'hA5A5A5A5) begin
				$display("**Error in OR (test 7); expected: %h, actual: %h", 32'hA5A5A5A5, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'hA5A5A5A5;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 8); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'h5A5A5A5A;
			
			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in OR (test 9); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h12345678;
			assign data_operandB = 32'h87654321;

			@(negedge clock);
			if(data_result !== 32'h97755779) begin
				$display("**Error in OR (test 10); expected: %h, actual: %h", 32'h97755779, data_result);
				errors = errors + 1;
			end
		end
	endtask

	task checkAnd;
		begin
			$display("==== Checking And ====");

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00010;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 5); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 6); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 7); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'hFFFFFFFF) begin
				$display("**Error in AND (test 8); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end


			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 9); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(data_result !== 32'hA5A5A5A5) begin
				$display("**Error in AND (test 10); expected: %h, actual: %h", 32'hA5A5A5A5, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'hA5A5A5A5;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 11); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'hA5A5A5A5;

			@(negedge clock);
			if(data_result !== 32'hA5A5A5A5) begin
				$display("**Error in AND (test 12); expected: %h, actual: %h", 32'hA5A5A5A5, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'h5A5A5A5A;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in AND (test 13); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h12345678;
			assign data_operandB = 32'h87654321;

			@(negedge clock);
			if(data_result !== 32'h02244220) begin
				$display("**Error in AND (test 14); expected: %h, actual: %h", 32'h02244220, data_result);
				errors = errors + 1;
			end
		end
	endtask

	task checkAdd;
		begin
			$display("==== Checking Add ====");
			
			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00000;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in ADD (test 9); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			for(index = 0; index < 31; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h00000001 << index;
				assign data_operandB = 32'h00000001 << index;

				assign data_expected = 32'h00000001 << (index + 1);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in ADD (test 17 part %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end
		end
	endtask

	task checkSub;
		begin
			$display("==== Checking Subtract ====");
			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00001;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in SUB (test 10); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end
		end
	endtask

	task checkSLL;
		begin
			$display("==== Checking Shift Left Logically ====");

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00100;
			assign data_operandB = 32'h00000000;

			assign data_operandA = 32'h00000001;
			assign ctrl_shiftamt = 5'b00000;

			@(negedge clock);
			if(data_result !== 32'h00000001) begin
				$display("**Error in SLL (test 1); expected: %h, actual: %h", 32'h00000001, data_result);
				errors = errors + 1;
			end

			for(index = 0; index < 5; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h00000001;
				assign ctrl_shiftamt = 5'b00001 << index;

				assign data_expected = 32'h00000001 << (2**index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SLL (test 2 part %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 4; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h00000001;
				assign ctrl_shiftamt = 5'b00011 << index;

				assign data_expected = 32'h00000001 << ((2**index) + (2**(index + 1)));

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SLL (test 3 part %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end
		end
	endtask

	task checkSRA;
		begin
			$display("==== Checking Shift Right Arithmetically ====");
			
			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00101;
			assign data_operandB = 32'h00000000;

			assign data_operandA = 32'h00000000;
			assign ctrl_shiftamt = 5'b00000;

			@(negedge clock);
			if(data_result !== 32'h00000000) begin
				$display("**Error in SRA (test 1); expected: %h, actual: %h", 32'h00000000, data_result);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h80000000;
			assign ctrl_shiftamt = 5'b00000;

			@(negedge clock);
			if(data_result !== 32'h80000000) begin
				$display("**Error in SRA (test 2); expected: %h, actual: %h", 32'hFFFFFFFF, data_result);
				errors = errors + 1;
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h00000000;
				assign ctrl_shiftamt = index;

				@(negedge clock);
				if(data_result !== 32'h00000000) begin
					$display("**Error in SRA (test 3 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h80000000;
				assign ctrl_shiftamt = index;

				assign data_expected = $signed($signed(32'h80000000) >>> index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SRA (test 4 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'hAAAAAAAA;
				assign ctrl_shiftamt = index;

				assign data_expected = $signed($signed(32'hAAAAAAAA) >>> index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SRA (test 5 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h55555555;
				assign ctrl_shiftamt = index;

				assign data_expected = $signed($signed(32'h55555555) >>> index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SRA (test 6 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h12345678;
				assign ctrl_shiftamt = index;

				assign data_expected = $signed($signed(32'h12345678) >>> index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SRA (test 7 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end

			for(index = 0; index < 32; index = index + 1)
			begin
				@(negedge clock);
				assign data_operandA = 32'h87654321;
				assign ctrl_shiftamt = index;

				assign data_expected = $signed($signed(32'h87654321) >>> index);

				@(negedge clock);
				if(data_result !== data_expected) begin
					$display("**Error in SRA (test 8 amount %d); expected: %h, actual: %h", index, data_expected, data_result);
					errors = errors + 1;
				end
			end
		end
	endtask

	task checkNE;
		begin
			$display("==== Checking Not Equal ====");

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00001;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(isNotEqual !== 1'b0) begin
				$display("**Error in isNotEqual (test 1); expected: %b, actual: %b", 1'b0, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(isNotEqual !== 1'b0) begin
				$display("**Error in isNotEqual (test 2); expected: %b, actual: %b", 1'b0, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(isNotEqual !== 1'b1) begin
				$display("**Error in isNotEqual (test 3); expected: %b, actual: %b", 1'b1, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(isNotEqual !== 1'b1) begin
				$display("**Error in isNotEqual (test 4); expected: %b, actual: %b", 1'b1, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'hA5A5A5A5;

			@(negedge clock);
			if(isNotEqual !== 1'b0) begin
				$display("**Error in isNotEqual (test 5); expected: %b, actual: %b", 1'b0, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hA5A5A5A5;
			assign data_operandB = 32'h5A5A5A5A;

			@(negedge clock);
			if(isNotEqual !== 1'b1) begin
				$display("**Error in isNotEqual (test 6); expected: %b, actual: %b", 1'b1, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h12345678;
			assign data_operandB = 32'h87654321;

			@(negedge clock);
			if(isNotEqual !== 1'b1) begin
				$display("**Error in isNotEqual (test 7); expected: %b, actual: %b", 1'b1, isNotEqual);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h12345678;
			assign data_operandB = 32'h12345678;

			@(negedge clock);
			if(isNotEqual !== 1'b0) begin
				$display("**Error in isNotEqual (test 8); expected: %b, actual: %b", 1'b0, isNotEqual);
				errors = errors + 1;
			end
		end
	endtask

	task checkLT;
		begin
			$display("==== Checking Less Than ====");
			
			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00001;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(isLessThan !== 1'b0) begin
				$display("**Error in isLessThan (test 1); expected: %b, actual: %b", 1'b0, isLessThan);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h0FFFFFFF;
			assign data_operandB = 32'hFFFFFFFF;

			@(negedge clock);
			if(isLessThan !== 1'b0) begin
				$display("**Error in isLessThan (test 2); expected: %b, actual: %b", 1'b0, isLessThan);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'hFFFFFFFF;
			assign data_operandB = 32'h0FFFFFFF;

			@(negedge clock);
			if(isLessThan !== 1'b1) begin
				$display("**Error in isLessThan (test 3); expected: %b, actual: %b", 1'b1, isLessThan);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h7FFFFFFF;
			assign data_operandB = 32'h80000000;

			@(negedge clock);
			if(isLessThan !== 1'b0) begin
				$display("**Error in isLessThan (test 3); expected: %b, actual: %b", 1'b0, isLessThan);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h80000000;
			assign data_operandB = 32'h7FFFFFFF;

			@(negedge clock);
			if(isLessThan !== 1'b1) begin
				$display("**Error in isLessThan (test 3); expected: %b, actual: %b", 1'b1, isLessThan);
				errors = errors + 1;
			end

			// Less than with overflow
			@(negedge clock);
			assign data_operandA = 32'h80000001;
			assign data_operandB = 32'h7FFFFFFF;

			@(negedge clock);
			if(isLessThan !== 1'b1) begin
				$display("**Error in isLessThan (test 3); expected: %b, actual: %b", 1'b1, isLessThan);
				errors = errors + 1;
			end
		end
	endtask

	task checkOverflow;
		begin
			$display("==== Checking Overflow ====");

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00000;
			assign ctrl_shiftamt = 5'b00000;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(overflow !== 1'b0) begin
				$display("**Error in overflow (test 15); expected: %b, actual: %b", 1'b0, overflow);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h80000000;
			assign data_operandB = 32'h80000000;

			@(negedge clock);
			if(overflow !== 1'b1) begin
				$display("**Error in overflow (test 20); expected: %b, actual: %b", 1'b1, overflow);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h40000000;
			assign data_operandB = 32'h40000000;

			@(negedge clock);
			if(overflow !== 1'b1) begin
				$display("**Error in overflow (test 21); expected: %b, actual: %b", 1'b1, overflow);
				errors = errors + 1;
			end

			@(negedge clock);
			assign ctrl_ALUopcode = 5'b00001;

			assign data_operandA = 32'h00000000;
			assign data_operandB = 32'h00000000;

			@(negedge clock);
			if(overflow !== 1'b0) begin
				$display("**Error in overflow (test 16); expected: %b, actual: %b", 1'b0, overflow);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h80000000;
			assign data_operandB = 32'h80000000;

			@(negedge clock);
			if(overflow !== 1'b0) begin
				$display("**Error in overflow (test 22); expected: %b, actual: %b", 1'b0, overflow);
				errors = errors + 1;
			end

			@(negedge clock);
			assign data_operandA = 32'h80000000;
			assign data_operandB = 32'h0F000000;

			@(negedge clock);
			if(overflow !== 1'b1) begin
				$display("**Error in overflow (test 25); expected: %b, actual: %b", 1'b1, overflow);
				errors = errors + 1;
			end
		end
	endtask
endmodule
