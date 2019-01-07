`timescale 1ns/1ps

`define WIDTH 32

module cordic_tb;

logic clk_i, rst_ni;
logic in_valid_i, out_ready_i;
logic [2*`WIDTH - 1 : 0] in_data_i;
wire in_ready_o, out_valid_o;
wire [`WIDTH-1:0] out_data_o;

localparam STEP = 10;
localparam sf = 2.0**-16.0;

initial begin
  $dumpfile("trace.vcd");
  $dumpvars(0, cordic_tb);
  clk_i = 1;
  rst_ni = 1;
  in_data_i = 0;
  in_valid_i = 0;
  out_ready_i = 1;
  #(STEP)  rst_ni = 0;
  #(2*STEP)  rst_ni = 1;
  #(STEP/2)
  #(STEP) in_data_i = 64'h00030000_00040000;
  in_valid_i = 1;
  $display("input = %f^2 + %f^2",
    $itor(in_data_i[`WIDTH-1:0]) * sf,
    $itor(in_data_i[2*`WIDTH-1:`WIDTH]) * sf
  );
  #(STEP) if (in_valid_i && out_ready_i) in_valid_i = 0; in_data_i = '0;
  #(7*STEP) $display("output = %b", out_data_o);
  $display("sqrt = %f",
    $itor(out_data_o) * sf);
  #(STEP) in_data_i = 64'h00060000_00080000;
  in_valid_i = 1;
  $display("input = %f^2 + %f^2",
    $itor(in_data_i[`WIDTH-1:0]) * sf,
    $itor(in_data_i[2*`WIDTH-1:`WIDTH]) * sf
  );
  #(STEP) if (in_valid_i && out_ready_i) in_valid_i = 0; in_data_i = '0;
  #(7*STEP) $display("output = %b", out_data_o);
  $display("sqrt = %f",
    $itor(out_data_o) * sf);
  #(STEP) in_data_i = 64'h00730000_00fc0000;
  in_valid_i = 1;
  $display("input = %f^2 + %f^2",
    $itor(in_data_i[`WIDTH-1:0]) * sf,
    $itor(in_data_i[2*`WIDTH-1:`WIDTH]) * sf
  );
  #(STEP) if (in_valid_i && out_ready_i) in_valid_i = 0; in_data_i = '0;
  #(7*STEP) $display("output = %b", out_data_o);
  $display("sqrt = %f",
    $itor(out_data_o) * sf);

  #(10*STEP) $finish;
end

always begin
  #(STEP / 2) clk_i = ~clk_i;
end

cordic #(
  .WIDTH(`WIDTH)
) dut (
  .*
);

endmodule

