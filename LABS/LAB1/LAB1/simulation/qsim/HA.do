onerror {quit -f}
vlib work
vlog -work work HA.vo
vlog -work work HA.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.HA_vlg_vec_tst
vcd file -direction HA.msim.vcd
vcd add -internal HA_vlg_vec_tst/*
vcd add -internal HA_vlg_vec_tst/i1/*
add wave /*
run -all
