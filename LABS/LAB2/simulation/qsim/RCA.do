onerror {quit -f}
vlib work
vlog -work work RCA.vo
vlog -work work RCA.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.RCA_vlg_vec_tst
vcd file -direction RCA.msim.vcd
vcd add -internal RCA_vlg_vec_tst/*
vcd add -internal RCA_vlg_vec_tst/i1/*
add wave /*
run -all
