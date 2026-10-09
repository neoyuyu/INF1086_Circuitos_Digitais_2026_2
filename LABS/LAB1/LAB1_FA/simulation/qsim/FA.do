onerror {quit -f}
vlib work
vlog -work work FA.vo
vlog -work work FA.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.FA_vlg_vec_tst
vcd file -direction FA.msim.vcd
vcd add -internal FA_vlg_vec_tst/*
vcd add -internal FA_vlg_vec_tst/i1/*
add wave /*
run -all
