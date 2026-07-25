# Compiler & Simulator
VX          = iverilog
SIM         = vvp
VIEWER      = gtkwave

TARGET      = ./tb/*
SRCS        = ./**/*.sv

OUT         = ./build/sim.out
WAVE        = ./build/dump.vcd

all: sim

compile: $(SRCS)
	$(VX) -g2012 -o $(OUT) $(SRCS)

sim: compile
	$(SIM) $(OUT)

waves: sim
	$(VIEWER) $(WAVE) &

clean:
	rm -f $(OUT) $(WAVE)
