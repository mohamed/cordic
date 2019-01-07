
SRCS := cordic.sv skid_buffer.sv register.sv

VERILATOR          := verilator
VERILATOR_ARGS      = -Wall -Irtl --unroll-count 256 --top-module cordic

IVERILOG           := iverilog
IVERILOG_ARGS       = -Wall -g2012 -I. -y. -o simv

all: cordic_tb.v ${SRCS}

lint: ${SRCS}
	${VERILATOR} ${VERILATOR_ARGS} --lint-only $^

sim: ${SRCS} cordic_tb.v
	${IVERILOG} ${IVERILOG_ARGS} $^
	./simv

clean:
	${RM} simv *.vcd
