set_cmd_units -time ns
read_liberty sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog netlist.v
link_design cordic
create_clock -name clk -period 12.5 {clk_i}
report_checks
exit
