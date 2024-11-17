# ECE 550 Project Checkpoint 4

Haochen Wang (hw362), Yongqi Shi (ys467)

## Introduction

This checkpoint implements a simple processor core with ADD, ADDI, SUB, AND, OR, SLL, SRA and SW/LW instrutctions. It works with a 50MHz master clock, loads and executes instructions from IMEM sequentially, and can read/write the DMEM.

## Modules

### dffe.v

This is the provided DFFE reference design that is implemented with behavioral Verilog. No changes are made to this module.

### alu.v

This is the provided ALU reference design that is implemented with behavioral Verilog. No changes are made to this module.

### regfile.v

This is the provided register file reference design that is implemented with behavioral Verilog. No changes are made to this module.

### clock_divider_quarter.v

This is a simple quarter clock divider implemented by chaining two DFFEs. The output clock is 1/4 of the input clock. This module is used to generate a 12.5MHz clock signal from the master 50MHz clock signal for the processor core and the regfile.

### reg_12bit.v

This is a single 12-bit register file that uses 12 instances of the DFFE module. The `d` and `q` are 12-bit instead of 32-bit. Generative for loop is used to instantiate 12 DFFEs. It is used as the Program Counter (PC) register in the processor core.

### signext_17bit_32bit.v

This is a sign extension module that extends a 17-bit input to a 32-bit output. The most significant bit of the input is connected to all the idling most significant bits of the output. This module is used to sign-extend the IMM value of the ADDI instruction.

### processor.v

This is the main processor design that is built upon with various forementioned modules. The datapath design on the slides are followed. 

### skeleton.v

This is the provided wrapper module that initiates all the components and enables testing. Four clock signals are generated: DMEM and IMEM is using the master 50MHz clock (inverted), and the regfile and the core is using quartered 12.5MHz clock. 