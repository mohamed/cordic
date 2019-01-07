module register #(
  parameter DATA_WIDTH  = 0,
  parameter RESET_VALUE = 0
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  input  logic                     enable_i,
  input  logic [DATA_WIDTH-1:0]    data_i,
  output logic [DATA_WIDTH-1:0]    data_o
);

always_ff @(posedge clk_i) begin
  if (!rst_ni) begin
    data_o <= RESET_VALUE;
  end else begin
    if (enable_i == 1'b1) begin
      data_o <= data_i;
    end
  end
end

endmodule
