TOP ?= top
BG ?= white
BUILD_DIR := build

SRCS := \
	top.v \
	ulaest.v \
	ha.v \
	cla_4bits.v \
	shl_4bits.v \
	shra_4bits.v \
	flag_n_4bits.v \
	flag_z_4bits.v \
	SEG_A.v \
	seg_b.v \
	seg_c.v \
	seg_D.v \
	seg_E.v \
	seg_f.v \
	seg_g.v

VVP_OUT := $(BUILD_DIR)/$(TOP).vvp
JSON_OUT := $(BUILD_DIR)/$(TOP).json
SVG_OUT := $(BUILD_DIR)/$(TOP).svg

.PHONY: all compile vis clean

all: compile vis

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

compile: $(VVP_OUT)

$(VVP_OUT): $(SRCS) | $(BUILD_DIR)
	iverilog -Wall -s $(TOP) -o $@ $(SRCS)

vis: $(SVG_OUT)

$(JSON_OUT): $(SRCS) | $(BUILD_DIR)
	yosys -q -p "read_verilog $(SRCS); prep -top $(TOP); write_json $@"

$(SVG_OUT): $(JSON_OUT)
	netlistsvg $< -o $@
	sed -i '0,/<svg[^>]*>/s||&\n  <rect width="100%" height="100%" fill="$(BG)" stroke="none"/>|' $@

clean:
	rm -rf $(BUILD_DIR)
