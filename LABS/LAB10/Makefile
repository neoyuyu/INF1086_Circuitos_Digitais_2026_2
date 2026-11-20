TOP ?=
TB ?=
BG ?= white
BUILD_DIR := build

ALL_V := $(wildcard *.v)
TB_FILES := $(wildcard *tb*.v *testbench*.v)
SRCS ?= $(filter-out $(TB_FILES),$(ALL_V))
SIM_SRCS ?= $(ALL_V)

RTL_NAME := $(if $(TOP),$(TOP),rtl)
YOSYS_PREP := $(if $(TOP),prep -top $(TOP),prep -auto-top)

VVP_OUT := $(BUILD_DIR)/sim.vvp
JSON_OUT := $(BUILD_DIR)/$(RTL_NAME).json
SVG_OUT := $(BUILD_DIR)/$(RTL_NAME).svg
HTML_OUT := $(BUILD_DIR)/digitaljs.html
DIGITALJS_RENDER := /home/gabriel/.local/share/digitaljs/render.js
VCD ?=

IVERILOG_FLAGS := -Wall $(if $(TB),-s $(TB),)

.PHONY: all compile sim wave vis rtl clean help

all: compile vis

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

compile: $(VVP_OUT)

$(VVP_OUT): $(SIM_SRCS) | $(BUILD_DIR)
	@test -n "$(SIM_SRCS)" || (echo "Erro: nenhum arquivo .v encontrado." && exit 1)
	iverilog $(IVERILOG_FLAGS) -o $@ $(SIM_SRCS)

sim: $(VVP_OUT)
	vvp $(VVP_OUT)

wave: sim
	@vcd_file="$(VCD)"; \
	if [ -z "$$vcd_file" ]; then \
		vcd_file=$$(ls -t *.vcd $(BUILD_DIR)/*.vcd 2>/dev/null | head -n 1); \
	fi; \
	if [ -z "$$vcd_file" ]; then \
		echo "Erro: nenhum arquivo .vcd encontrado. Verifique \$$dumpfile no testbench ou passe VCD=arquivo.vcd."; \
		exit 1; \
	fi; \
	echo "Abrindo $$vcd_file no GTKWave..."; \
	gtkwave "$$vcd_file" &

vis: $(SVG_OUT)

$(JSON_OUT): $(SRCS) | $(BUILD_DIR)
	@test -n "$(SRCS)" || (echo "Erro: nenhum arquivo .v de design encontrado (SRCS vazio)." && exit 1)
	yosys -q -p "read_verilog $(SRCS); $(YOSYS_PREP); write_json $@"

$(SVG_OUT): $(JSON_OUT)
	netlistsvg $< -o $@
	sed -i '0,/<svg[^>]*>/s||&\n  <rect width="100%" height="100%" fill="$(BG)" stroke="none"/>|' $@

$(HTML_OUT): $(SRCS) | $(BUILD_DIR)
	@test -n "$(SRCS)" || (echo "Erro: nenhum arquivo .v de design encontrado (SRCS vazio)." && exit 1)
	node $(DIGITALJS_RENDER) $(if $(TOP),--top $(TOP),) -o $@ $(SRCS)

rtl: $(HTML_OUT)
	xdg-open $(HTML_OUT) >/dev/null 2>&1 &

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Uso: make [alvo] [VAR=valor]"
	@echo ""
	@echo "Alvos:"
	@echo "  all      - Compila com iverilog e gera o SVG do RTL (padrao)"
	@echo "  compile  - Compila todos os .v com iverilog em $(VVP_OUT)"
	@echo "  sim      - Compila e executa a simulacao com vvp"
	@echo "  wave     - Executa a simulacao e abre o .vcd mais recente no gtkwave"
	@echo "  rtl      - Gera e abre o esquematico RTL interativo no DigitalJS local"
	@echo "  vis      - Gera o esquematico RTL estatico em $(SVG_OUT) (yosys + netlistsvg)"
	@echo "  clean    - Remove o diretorio $(BUILD_DIR)"
	@echo ""
	@echo "Variaveis:"
	@echo "  TOP=$(TOP)   - Modulo top-level para o RTL (yosys)"
	@echo "  TB=$(TB)      - Modulo do testbench (opcional, para iverilog -s)"
	@echo "  VCD=...       - Caminho explicito do .vcd para o gtkwave"
	@echo "  BG=$(BG)     - Cor de fundo do SVG"
