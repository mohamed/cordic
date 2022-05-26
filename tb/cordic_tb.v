`timescale 1ns/1ps

`include "macros.svh"

module cordic_tb;

localparam int I = 15;
localparam int F = 16;
localparam int WIDTH = (I + F + 1);
localparam int STEP = 10;
localparam int S = 1024;

logic clk_i, rst_ni;
logic valid_i;
logic [WIDTH-1:0] x_data_i, y_data_i;
logic valid_o;
logic [WIDTH-1:0] data_o;

int idx;
real expected[S];
int fd;
logic [31:0] seed;
int j;
real sqrt;

`define gen_data \
    x_data_i = {$random(seed)}; \
    y_data_i = {$random(seed)}; \
    x_data_i[WIDTH-1:WIDTH-6] = 0; \
    y_data_i[WIDTH-1:WIDTH-6] = 0; \
    expected[idx++] = $sqrt($pow(`fixed2real(x_data_i,F),2.0) + $pow(`fixed2real(y_data_i,F),2.0));

`define print_data \
    $display("input = %f^2 + %f^2", `fixed2real(x_data_i,F), `fixed2real(y_data_i,F));

initial begin
  $dumpfile("trace.vcd");
  $dumpvars(0, cordic_tb);
  fd = $fopen("cordic_results.csv","w");
  clk_i = 1;
  rst_ni = 1;
  x_data_i = 0;
  y_data_i = 0;
  valid_i = 0;
  idx = 0;
  seed = 7;
  j = 0;
  expected[idx++] = 5.0;
  expected[idx++] = 10.0;
  expected[idx++] = 277.0;
  expected[idx++] = 3.0;

  #(STEP)  rst_ni = 0;
  #(2*STEP)  rst_ni = 1;
  #(STEP/2)
  #(STEP) y_data_i = `real2fixed(3.0,I,F); x_data_i = `real2fixed(4.0,I,F);
  valid_i = 1;
  #(STEP) y_data_i = `real2fixed(6.0,I,F);  x_data_i = `real2fixed(8.0,I,F);
  #(STEP) y_data_i = `real2fixed(252.0,I,F); x_data_i = `real2fixed(115.0,I,F);
  #(STEP) y_data_i = `real2fixed($sqrt(2),I,F); x_data_i = `real2fixed($sqrt(7),I,F);
  for (int i = 4; i < S; i++) begin
    #(STEP) `gen_data
  end
  #(STEP) valid_i = 0; x_data_i = '0; y_data_i = '0;
  #(1000*STEP) $fclose(fd); $finish;
end

always begin
  #(STEP / 2) clk_i = ~clk_i;
end

always begin
  #(STEP) if (valid_o) begin
    sqrt = `fixed2real(data_o,F);
    $fdisplay(fd, "%f,%f", sqrt, expected[j]);
    j++;
  end
end

cordic #(
  .Q_I(I),
  .Q_F(F)
) dut (
  .*
);

endmodule

