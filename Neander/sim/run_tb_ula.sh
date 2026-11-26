#!/usr/bin/env bash
# Script para compilacao e simulacao da ULA com Icarus Verilog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Compilando modulos com iverilog..."
iverilog -g2001 -Wall -Wno-timescale -o "$SCRIPT_DIR/sim_ula" \
    "$ROOT_DIR/rtl/ula.v" \
    "$ROOT_DIR/sim/tb_ula.v"

echo "==> Executando simulacao com vvp..."
cd "$SCRIPT_DIR"
vvp "$SCRIPT_DIR/sim_ula"

echo "==> Simulacao concluida com sucesso."
if [ -f "$SCRIPT_DIR/ula.vcd" ]; then
    echo "Dica: Para visualizar os sinais no GTKWave, execute:"
    echo "  gtkwave ula.vcd"
fi
