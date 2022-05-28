// Copyright (c) 2022, Mohamed A. Bamakhrama
// All rights reserved

// Calculates the following expression:
// sqrt(pow(x_data_i,2) + pow(y_data_i,2))
//
// It does so by utilizing the CORDIC algorithm. The inputs and output
// are by default in Q16.F16 fixed-point format.
// The datapath is fully pipelined and supports a new input
// every clock cycle


`include "macros.svh"

module cordic #(
    parameter int Q_I   = 15,             // bits for integer part
    parameter int Q_F   = 16,             // bits for fractional part
    parameter int WIDTH = Q_I + Q_F + 1   // Total width of data. Auto calcaulted from Q_I and Q_F
)(
    input  logic                      clk_i,
    input  logic                      rst_ni,

    // input port
    input  logic                      valid_i,
    input  logic signed [WIDTH-1:0]   x_data_i,
    input  logic signed [WIDTH-1:0]   y_data_i,

    // output port
    output logic                      valid_o,
    output logic [WIDTH-1:0]          data_o
);

  localparam int STAGES = (11);
  // CORDIC gain up to 10 decimal digits
  localparam logic signed [64-1:0] realGain = 64'h000000009b75eda8;
  localparam logic signed [WIDTH-1:0] fixedGain = `SLICE(realGain,WIDTH);

  `STATIC_ASSERT((Q_I+Q_F+1) == WIDTH)
  `STATIC_ASSERT(WIDTH < 64)

  typedef logic signed [WIDTH-1:0] data_t;

  /* verilator lint_off UNUSED */
  logic signed [2*WIDTH-1:0] final_d, final_q;
  data_t x_d[STAGES], y_d[STAGES], x_q[STAGES], y_q[STAGES];
  logic sign[STAGES];
  logic valid_d[STAGES+1], valid_q[STAGES+1];

  always_comb begin
    valid_d[0] = valid_i;
    for (int i = 1; i < (STAGES+1); i++) begin
      valid_d[i] = valid_q[i-1];
    end
    valid_o = valid_q[STAGES];
  end

  genvar j;
  generate
    for (j = 0; j < (STAGES+1); j++) begin: gen_valid
      `DFF(clk_i,rst_ni,valid_d[j],valid_q[j],'0)
    end: gen_valid
  endgenerate

  `DFFE(clk_i,rst_ni,valid_i,x_data_i,x_q[0],'0)
  `DFFE(clk_i,rst_ni,valid_i,y_data_i,y_q[0],'0)

  genvar i;
  generate
    for (i = 1; i < STAGES; i++) begin: gen_cordic
      `DFFE(clk_i,rst_ni,valid_q[i-1],x_d[i],x_q[i],'0)
      `DFFE(clk_i,rst_ni,valid_q[i-1],y_d[i],y_q[i],'0)

      // Implement the CORDIC stage
      assign sign[i-1] = y_q[i-1][WIDTH-1];
      assign x_d[i] = (sign[i-1] ? x_q[i-1]-(y_q[i-1] >>> (i-1)) : x_q[i-1]+(y_q[i-1] >>> (i-1)));
      assign y_d[i] = (sign[i-1] ? y_q[i-1]+(x_q[i-1] >>> (i-1)) : y_q[i-1]-(x_q[i-1] >>> (i-1)));

    end: gen_cordic
  endgenerate

  // Multiply by the gain here
  assign final_d = x_q[STAGES-1] * fixedGain;
  `DFFE(clk_i,rst_ni,valid_q[STAGES-1],final_d,final_q,'0)
  assign data_o = `SLICE(final_q,WIDTH);

endmodule
