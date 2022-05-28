
SRCS := rtl/cordic.sv
TOP  := cordic

VERILATOR          := verilator
VERILATOR_ARGS      = -Wall -Irtl --unroll-count 256 --top-module $(TOP)

IVERILOG           := iverilog
IVERILOG_ARGS       = -Wall -g2012 -Irtl -o simv

YOSYS               = yosys
YS_CONSTR           = example.constr
LIBERTY_LIB         = sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
PRIMITIVES          = sky130/verilog_model/primitives.v \
											sky130/verilog_model/sky130_fd_sc_hd.v
PERIOD_PS           = 12500

.PHONY: all lint sim synth sta clean post_synth_sim

all: tb/$(TOP)_tb.v ${SRCS}

lint: ${SRCS}
	${VERILATOR} ${VERILATOR_ARGS} --lint-only $^

sim: ${SRCS} tb/$(TOP)_tb.v
	${IVERILOG} ${IVERILOG_ARGS} $^
	./simv

synth: ${LIBERTY_LIB} $(SRCS)
	${YOSYS} -p "read_verilog -sv $(SRCS); \
		synth -top $(TOP) -flatten; \
		dfflibmap -liberty ${LIBERTY_LIB}; \
		abc -D ${PERIOD_PS} -liberty ${LIBERTY_LIB}; \
		opt_clean; \
		stat -liberty ${LIBERTY_LIB}; \
		write_verilog -noattr netlist.v"

sta: ${LIBERTY_LIB} netlist.v
	sta opensta.tcl

post_synth_sim: $(PRIMITIVES) netlist.v tb/cordic_tb.v
	$(IVERILOG) -g2012 -Irtl $^
	./a.out

clean:
	${RM} simv *.vcd *.csv

