#!/usr/bin/env bash
# Script para compilação e simulação da Unidade de Controle com Icarus Verilog
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Compilando módulos com iverilog..."
iverilog -o "$SCRIPT_DIR/sim_uc" \
    "$ROOT_DIR/rtl/unidade_controle.v" \
    "$ROOT_DIR/rtl/decoder_4x11.v" \
    "$ROOT_DIR/rtl/temporizador.v" \
    "$ROOT_DIR/rtl/pc_estrutural.v" \
    "$ROOT_DIR/sim/tb_unidade_controle.v"

echo "==> Executando simulação com vvp..."
vvp "$SCRIPT_DIR/sim_uc"

echo "==> Simulação concluída com sucesso."
if [ -f "unidade_controle.vcd" ]; then
    echo "Dica: Para visualizar os sinais no GTKWave, execute:"
    echo "  gtkwave unidade_controle.vcd"
fi
