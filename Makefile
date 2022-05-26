
SRCS := rtl/cordic.sv
TOP  := cordic

VERILATOR          := verilator
VERILATOR_ARGS      = -Wall -Irtl --unroll-count 256 --top-module $(TOP)

IVERILOG           := iverilog
IVERILOG_ARGS       = -Wall -g2012 -Irtl -o simv

YOSYS               = yosys
YS_CONSTR           = example.constr
LIBERTY_LIB         = example1_typ.lib
PERIOD_PS           = 2000

.PHONY: all lint sim synth sta clean

all: tb/$(TOP)_tb.v ${SRCS}

lint: ${SRCS}
	${VERILATOR} ${VERILATOR_ARGS} --lint-only $^

sim: ${SRCS} tb/$(TOP)_tb.v
	${IVERILOG} ${IVERILOG_ARGS} $^
	./simv

${LIBERTY_LIB}:
	wget -O $@ https://raw.githubusercontent.com/The-OpenROAD-Project/OpenSTA/master/examples/example1_typ.lib

synth: ${LIBERTY_LIB} $(SRCS)
	${YOSYS} -p "read_verilog -sv $(SRCS); \
		synth -top $(TOP) -flatten; \
		dfflibmap -liberty ${LIBERTY_LIB}; \
		abc -D ${PERIOD_PS} -constr ${YS_CONSTR} -liberty ${LIBERTY_LIB}; \
		opt_clean; \
		stat -liberty ${LIBERTY_LIB}; \
		write_verilog netlist.v"

sta: ${LIBERTY_LIB} netlist.v
	sta opensta.tcl

clean:
	${RM} simv *.vcd *.csv

