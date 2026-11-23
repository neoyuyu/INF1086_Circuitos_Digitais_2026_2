#!/usr/bin/env bash
# Script para compilação e simulação de reg_n_z com Icarus Verilog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Compilando módulos com iverilog..."
iverilog -g2001 -o "$SCRIPT_DIR/sim_reg_n_z" \
    "$ROOT_DIR/rtl/reg_n_z.v" \
    "$SCRIPT_DIR/tb_reg_n_z.v"

echo "==> Executando simulação com vvp..."
(
    cd "$SCRIPT_DIR"
    vvp "$SCRIPT_DIR/sim_reg_n_z"
)

echo "==> Simulação concluída com sucesso."
if [ -f "$SCRIPT_DIR/reg_n_z.vcd" ]; then
    echo "Dica: Para visualizar os sinais no GTKWave, execute:"
    echo "  gtkwave reg_n_z.vcd"
fi
