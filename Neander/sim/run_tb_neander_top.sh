#!/usr/bin/env bash
# Compila e executa o testbench de integracao top-level (neander_top) com Icarus Verilog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Compilando modulos RTL e testbench top-level com iverilog..."
iverilog -o "$SCRIPT_DIR/sim_neander_top" \
    "$ROOT_DIR/rtl/mux.v" \
    "$ROOT_DIR/rtl/mux8bit.v" \
    "$ROOT_DIR/rtl/ff_d.v" \
    "$ROOT_DIR/rtl/bit_slice.v" \
    "$ROOT_DIR/rtl/reg8bit.v" \
    "$ROOT_DIR/rtl/pc_bit_slice.v" \
    "$ROOT_DIR/rtl/pc_estrutural.v" \
    "$ROOT_DIR/rtl/divisor_frequencia.v" \
    "$ROOT_DIR/rtl/run_step_mode.v" \
    "$ROOT_DIR/rtl/rdm.v" \
    "$ROOT_DIR/rtl/ula.v" \
    "$ROOT_DIR/rtl/codificador_neander.v" \
    "$ROOT_DIR/rtl/reg_n_z.v" \
    "$ROOT_DIR/rtl/decoder_4x11.v" \
    "$ROOT_DIR/rtl/temporizador.v" \
    "$ROOT_DIR/rtl/unidade_controle.v" \
    "$ROOT_DIR/rtl/conversor_bcd.v" \
    "$SCRIPT_DIR/altdpram_sim.v" \
    "$SCRIPT_DIR/neander_top_sim.v" \
    "$SCRIPT_DIR/tb_neander_top.v"

echo "==> Executando simulacao com vvp..."
vvp "$SCRIPT_DIR/sim_neander_top"

echo "==> Simulacao concluida com sucesso."
if [ -f "neander_top.vcd" ]; then
    echo "Dica: Para visualizar os sinais no GTKWave, execute:"
    echo "  gtkwave neander_top.vcd"
fi
