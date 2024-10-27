transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/skeleton.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/processor.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/imem.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/dmem.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/dffe.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/regfile.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/alu.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/clock_divider.v}
vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/reg_12bit.v}

vlog -vlog01compat -work work +incdir+E:/Ass/ECE550/Project {E:/Ass/ECE550/Project/skeleton_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  skeleton_tb

add wave *
view structure
view signals
run -all
