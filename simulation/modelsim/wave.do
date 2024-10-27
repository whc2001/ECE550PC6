onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /skeleton_tb/clock
add wave -noupdate /skeleton_tb/reset
add wave -noupdate /skeleton_tb/total_cycles
add wave -noupdate /skeleton_tb/clock
add wave -noupdate /skeleton_tb/reset
add wave -noupdate /skeleton_tb/total_cycles
add wave -noupdate /skeleton_tb/clock
add wave -noupdate /skeleton_tb/reset
add wave -noupdate /skeleton_tb/total_cycles
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/pc_out
add wave -noupdate /skeleton_tb/sk/my_processor/opcode
add wave -noupdate /skeleton_tb/sk/my_processor/arith_r_type
add wave -noupdate /skeleton_tb/sk/my_processor/arith_i_type
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/r_rt
add wave -noupdate /skeleton_tb/sk/my_processor/r_shamt
add wave -noupdate /skeleton_tb/sk/my_processor/alu_op_in
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/i_rd
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/i_rs
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/i_imm
add wave -noupdate /skeleton_tb/sk/my_processor/alu_op_is_add
add wave -noupdate /skeleton_tb/sk/my_processor/alu_op_is_sub
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/alu_result
add wave -noupdate /skeleton_tb/sk/my_processor/alu_ne
add wave -noupdate /skeleton_tb/sk/my_processor/alu_lt
add wave -noupdate /skeleton_tb/sk/my_processor/alu_ovf
add wave -noupdate /skeleton_tb/sk/my_processor/ctrl_writeEnable
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_writeReg
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_readRegA
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_readRegB
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_writeReg
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_readRegA
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_readRegB
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/address_dmem
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data
add wave -noupdate /skeleton_tb/sk/my_processor/wren
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/q_dmem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {89938 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1776884 ps} {2043322 ps}
