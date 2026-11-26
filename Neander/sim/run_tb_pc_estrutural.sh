#!/usr/bin/env bash
# Script para compilação e simulação do PC Estrutural com Icarus Verilog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Compilando módulos com iverilog..."
iverilog -g2001 -o "$SCRIPT_DIR/sim_pc_estrutural" \
    "$ROOT_DIR/rtl/ff_d.v" \
    "$ROOT_DIR/rtl/pc_bit_slice.v" \
    "$ROOT_DIR/rtl/pc_estrutural.v" \
    "$ROOT_DIR/sim/tb_pc_estrutural.v"

echo "==> Executando simulação com vvp..."
cd "$SCRIPT_DIR"
if ! vvp "$SCRIPT_DIR/sim_pc_estrutural"; then
    echo "ERRO: Simulação falhou!" >&2
    exit 1
fi

echo "==> Simulação concluída com sucesso."
if [ -f "$SCRIPT_DIR/pc_estrutural.vcd" ]; then
    echo "Dica: Para visualizar os sinais no GTKWave, execute:"
    echo "  gtkwave pc_estrutural.vcd"
fi
