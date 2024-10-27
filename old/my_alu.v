module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);

   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;

   wire [31:0] inv_operandB, xor_operand;
   wire csa_co;

   wire [31:0] ret_ari, ret_and, ret_or, ret_sll, ret_sra;

   genvar i;
   
   // Bitwise not for operand B
   generate
      for (i = 0; i < 32; i = i + 1) begin : invert_B
         not not1 (inv_operandB[i], data_operandB[i]);
      end
   endgenerate

   // Main arithmetic components
   csa_32bit csa(ret_ari, csa_co, overflow, data_operandA, ctrl_ALUopcode[0] ? inv_operandB : data_operandB, ctrl_ALUopcode[0]);
   band_32bit band(ret_and, data_operandA, data_operandB);
   bor_32bit bor(ret_or, data_operandA, data_operandB);
   sll_32bit sll(ret_sll, data_operandA, ctrl_shiftamt);
   sra_32bit sra(ret_sra, data_operandA, ctrl_shiftamt);

   // XOR of operand A and operand B then OR'ed every bits for isNotEqual
   generate
      for (i = 0; i < 32; i = i + 1) begin : xor_A_B
         xor xor1 (xor_operand[i], data_operandA[i], data_operandB[i]);
      end
   endgenerate
   allbit_or_32bit or_isNotEqual(isNotEqual, xor_operand);

   // XOR of sign of subtract result and overflow for isLessThan
   xor xor_isLessThan(isLessThan, ret_ari[31], overflow);

   // Output stage with MUX controlled by ALU opcode
   // 000=add, 001=sub, 010=and, 011=or, 100=sll, 101=sra
   assign data_result = 
   ctrl_ALUopcode[2]
      ? (ctrl_ALUopcode[0] ? ret_sra : ret_sll) // bit 2 = 1, judge bit 0
      : (ctrl_ALUopcode[1] ?  // bit 2 = 0, judge bit 1
         (ctrl_ALUopcode[0] ? ret_or : ret_and) // bit 1 = 1, judge bit 0
         : ret_ari); // bit 1 = 0, add or sub is controlled by CSA

endmodule
