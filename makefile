TEST ?= matcher

BUILD_DIR := build
TEST_FILE := tests/$(TEST).f
OUTPUT := $(BUILD_DIR)/$(TEST).vvp

.PHONY: sim run clean

setup_default:
	mkdir -p Vivado
	export _JAVA_AWT_WM_NONREPARENTING=1; \
	export PATH="$$PATH:$(HOME)/src/Vivado/2024.2/bin"; \
	vivado -mode batch -source ./scripts/setup.tcl

clean:
	rm -rf Vivado
	rm *.jou
	rm *.log
	rm -rf $(BUILD_DIR)

sim:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(dir $(OUTPUT))
	iverilog -g2012 -o $(OUTPUT) -c $(TEST_FILE)

run: sim
	vvp $(OUTPUT)

sim_all:
	@for test in $(shell ls tests/**/*.f); do \
		test_name=$$(basename $$test .f); \
		echo "Running test: $$test_name"; \
		make TEST=$$test_name run; \
	done