onerror {quit -f}
vlib work
vlog -work work DivisorFrequencia.vo
vlog -work work DivisorFrequencia.vt
vsim -novopt -c -t 1ps -L cycloneiii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.DivisorFrequencia24_vlg_vec_tst
vcd file -direction DivisorFrequencia.msim.vcd
vcd add -internal DivisorFrequencia24_vlg_vec_tst/*
vcd add -internal DivisorFrequencia24_vlg_vec_tst/i1/*
add wave /*
run -all
