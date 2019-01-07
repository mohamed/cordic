// Calculates the following expression:
// SQRT(pow(in_data_i[2*WIDTH-1:0],2) + pow(in_data_i[WIDTH-1:0],2) )
//
// It does so by utilizing the CORDIC algorithm. The inputs and output
// are in Q16.F16 fixed-point format.

module cordic #(
  parameter integer WIDTH = 32,
  parameter integer STAGES = 8
)(
  input  logic                      clk_i,
  input  logic                      rst_ni,

  // input port
  input  logic                      in_valid_i,
  input  logic signed [2*WIDTH-1:0] in_data_i,
  output logic                      in_ready_o,

  // output port
  output logic                      out_valid_o,
  output logic [WIDTH-1:0]          out_data_o,
  input  logic                      out_ready_i
);

typedef logic signed [WIDTH-1:0] data_t;

/* verilator lint_off UNUSED */
logic signed [2*WIDTH-1:0] data_d[STAGES+1], data_q[STAGES+1], data_out;
data_t x_d[STAGES+1], y_d[STAGES+1], x_q[STAGES+1], y_q[STAGES+1];
logic [STAGES:0] sign;
logic ready [STAGES+1], valid[STAGES+1];

skid_buffer #(
  .DATA_WIDTH(2*WIDTH)
) in_buf (
  .clk_i          (clk_i),
  .rst_ni         (rst_ni),
  .input_valid_i  (in_valid_i),
  .input_data_i   (in_data_i),
  .input_ready_o  (in_ready_o),
  .output_ready_i (ready[1]),
  .output_data_o  (data_q[0]),
  .output_valid_o (valid[0])
);


genvar i;
generate
for (i = 1; i < STAGES; i++) begin

  skid_buffer #(
    .DATA_WIDTH(2*WIDTH)
  ) stage_buf (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .input_valid_i  (valid[i-1]),
    .input_data_i   (data_d[i]),
    .input_ready_o  (ready[i]),
    .output_ready_i (ready[i+1]),
    .output_data_o  (data_q[i]),
    .output_valid_o (valid[i])
  );

  // Read the data if the handshake has occurred
  assign x_q[i-1] = valid[i-1] == 1'b1 && ready[i] == 1'b1 ? data_q[i-1][WIDTH-1:0] : '0;
  assign y_q[i-1] = valid[i-1] == 1'b1 && ready[i] == 1'b1 ? data_q[i-1][2*WIDTH-1:WIDTH] : '0;

  // Implement the CORDIC stage
  assign sign[i-1] = y_q[i-1][WIDTH-1];
  assign x_d[i] = (sign[i-1]? x_q[i-1] - (y_q[i-1] >>> (i-1)) : x_q[i-1] + (y_q[i-1] >>> (i-1)));
  assign y_d[i] = (sign[i-1]? y_q[i-1] + (x_q[i-1] >>> (i-1)) : y_q[i-1] - (x_q[i-1] >>> (i-1)));

  // Feed the the data to the next buffer
  assign data_d[i] = {y_d[i], x_d[i]};
end
endgenerate

assign out_valid_o = valid[STAGES-1];
assign ready[STAGES] = out_ready_i;

always_comb begin
  // Multiply by the gain here
  data_out = data_q[STAGES-1][WIDTH-1:0] * 32'b0000000000000000_1001101101110100;
  out_data_o = data_out[WIDTH+WIDTH/2-1:WIDTH/2];
end

endmodule
