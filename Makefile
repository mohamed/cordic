
SRCS := rtl/cordic.sv
TOP  := cordic

VERILATOR          := verilator
VERILATOR_ARGS      = -Wall +incdir+rtl

IVERILOG           := iverilog
IVERILOG_ARGS       = -Wall -g2012 -Irtl

YOSYS               = yosys
LIBERTY_LIB         = sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
PRIMITIVES          = sky130/verilog_model/primitives.v sky130/verilog_model/sky130_fd_sc_hd.v
PERIOD_PS           = 10000

.PHONY: all lint sim synth sta clean post_synth_sim

all: tb/$(TOP)_tb.v ${SRCS}

lint: ${SRCS}
	${VERILATOR} ${VERILATOR_ARGS} --lint-only $^

sim: ${SRCS} tb/$(TOP)_tb.v
	${VERILATOR} ${VERILATOR_ARGS} --timing --binary --trace $^
	./obj_dir/V$(TOP)

synth: ${LIBERTY_LIB} $(SRCS)
	${YOSYS} -p "read_verilog -sv $(SRCS); \
		synth -top $(TOP) -flatten; \
		dfflibmap -liberty ${LIBERTY_LIB}; \
		abc -D ${PERIOD_PS} -liberty ${LIBERTY_LIB}; \
		opt_clean -purge; \
		stat -liberty ${LIBERTY_LIB}; \
		write_verilog -noattr netlist.v"

sta: ${LIBERTY_LIB} netlist.v
	sta opensta.tcl

post_synth_sim: $(PRIMITIVES) netlist.v tb/cordic_tb.v
	$(IVERILOG) $(IVERILOG_ARGS) -o postsyn_simv $^
	./postsyn_simv

clean:
	${RM} simv postsyn_simv *.vcd *.csv
	${RM} -r obj_dir

