onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /skeleton_tb/sk/imem_clock
add wave -noupdate /skeleton_tb/sk/dmem_clock
add wave -noupdate /skeleton_tb/sk/regfile_clock
add wave -noupdate /skeleton_tb/sk/processor_clock
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/pc_out
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/address_imem
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/q_imem
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/address_dmem
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data
add wave -noupdate /skeleton_tb/sk/my_processor/wren
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/q_dmem
add wave -noupdate /skeleton_tb/sk/my_processor/ctrl_writeEnable
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_writeReg
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_writeReg
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_readRegA
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/ctrl_readRegB
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_readRegA
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/data_readRegB
add wave -noupdate -radix unsigned /skeleton_tb/sk/my_processor/alu_op_in
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/alu_operand_b
add wave -noupdate -radix decimal /skeleton_tb/sk/my_processor/alu_result
add wave -noupdate -radix decimal -childformat {{{/skeleton_tb/sk/my_regfile/registers[31]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[30]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[29]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[28]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[27]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[26]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[25]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[24]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[23]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[22]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[21]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[20]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[19]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[18]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[17]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[16]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[15]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[14]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[13]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[12]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[11]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[10]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[9]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[8]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[7]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[6]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[5]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[4]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[3]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[2]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[1]} -radix decimal} {{/skeleton_tb/sk/my_regfile/registers[0]} -radix decimal}} -expand -subitemconfig {{/skeleton_tb/sk/my_regfile/registers[31]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[30]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[29]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[28]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[27]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[26]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[25]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[24]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[23]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[22]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[21]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[20]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[19]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[18]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[17]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[16]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[15]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[14]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[13]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[12]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[11]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[10]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[9]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[8]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[7]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[6]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[5]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[4]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[3]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[2]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[1]} {-height 15 -radix decimal} {/skeleton_tb/sk/my_regfile/registers[0]} {-height 15 -radix decimal}} /skeleton_tb/sk/my_regfile/registers
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {685574 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 309
configure wave -valuecolwidth 100
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
WaveRestoreZoom {316194 ps} {849070 ps}
