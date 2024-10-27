onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /skeleton_tb/clock
add wave -noupdate /skeleton_tb/reset
add wave -noupdate /skeleton_tb/total_cycles
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1189472 ps} 0}
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
WaveRestoreZoom {1016080 ps} {1548956 ps}
