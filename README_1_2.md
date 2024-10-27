# ECE 550 Project Checkpoint 2

Haochen Wang (hw362)

## Introduction

This checkpoint implements the bitwise AND and OR, SLL and SRA operations, along with output of `isNotEqual` and `isLessThan` for the SUBTRACT operation for the ALU. The AND and OR are implemented using primitive logic gates array. The shifters are implemented using the barrel shifter method taught in class. The `isNotEqual` is calculated by XOR'ing the subtraction operands then OR'ing all bits of the result. The `isLessThan` is calculated by checking the sign bit of the subtraction result and comparing it with the overflow bit. Output is multiplexed using ternary multiplexer to check on corresponding bits of the opcode.

## Modules

### full_adder.v (PC1)

This is the full adder implemented in Recitation 2. It takes in three 1-bit `in1`, `in2`, and `ci`, and outputs 1-bit `out` and `co`.

### rca_16bit.v (PC1)

This is the 16-bit ripple carry adder that extends the 4-bit ripple carry adder implemented in Recitation 2. It takes in two 16-bit inputs `in1`, `in2` and 1-bit `ci`, and outputs a 16-bit `out`, 1-bit `co` and `ovf`. Generative for loop is used to instantiate 16 full adders. XOR gate is used to calculate overflow output.

### csa_32bit.v (PC1)

This is the 32-bit carry select adder that uses three 16-bit ripple carry adders. It takes in two 32-bit inputs `in1`, `in2` and 1-bit `cin`, and outputs 32-bit `out`, 1-bit `cout` and `ovf`. The three RCAs run in parallel and output is multiplexed using ternary operator.

### alu.v (PC1)

This is the main ALU module. Only the ADD and SUBTRACT operations are implemented using the 32-bit CSA. Generative for loop with NOT gate is used to calculate the invert of the second input for subtraction.

### allbit_or_32bit.v (PC2)

This is the bitwise reducing OR that takes in a 32-bit input `in` and reducing into a 1-bit `out` that is OR'ing all bits in the input. Generative for loop with OR gate is used. It's used to implement the `isNotEqual` operation in the ALU.

### band_32bit.v (PC2)

This is the bitwise AND gate array that takes in two 32-bit inputs `in1`, `in2` and outputs a 32-bit `out`. Generative for loop with AND gate is used. It's used to implement the bitwise AND operation in the ALU.

### bor_32bit.v (PC2)

This is the bitwise OR gate array that takes in two 32-bit inputs `in1`, `in2` and outputs a 32-bit `out`. Generative for loop with OR gate is used. It's used to implement the bitwise OR operation in the ALU.

### sll_32bit.v (PC2)

This is the 32-bit Shift Left Logically shifter that takes in a 32-bit input `in`, a 5-bit `shift_amt` and outputs a 32-bit `out`. The barrel shifting method is used, with multiplexer arrays to shift the number by 1, 2, 4, 8, and 16 bits one by one according to corresponding bits in `shift_amt`. It's used to implement the SLL operation in the ALU.

### sra_32bit.v (PC2)

This is the 32-bit Shift Right Arithmetically shifter that takes in a 32-bit input `in`, a 5-bit `shift_amt` and outputs a 32-bit `out`. The barrel shifting method is used, with multiplexer arrays to shift the number by 1, 2, 4, 8, and 16 bits one by one according to corresponding bits in `shift_amt`. Instead of padding zeros into the new bits, it takes `in[31]` which is the sign bit. It's used to implement the SRA operation in the ALU.
