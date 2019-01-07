// Based on: http://fpgacpu.ca/fpga/Pipeline_Skid_Buffer.html

//`define USE_ENUM

module skid_buffer #(
  parameter integer DATA_WIDTH = 8
)(
  input  logic                   clk_i,
  input  logic                   rst_ni,

  input  logic                   input_valid_i,
  output logic                   input_ready_o,
  input  logic [DATA_WIDTH-1:0]  input_data_i,

  output logic                   output_valid_o,
  input  logic                   output_ready_i,
  output logic [DATA_WIDTH-1:0]  output_data_o
);

logic data_buffer_wren;
logic data_out_wren;
logic use_buffered_data;
logic insert;
logic remove;
logic load, flow, fill, flush, unload; // state transitions
logic [DATA_WIDTH-1:0]  selected_data;
logic [DATA_WIDTH-1:0]  data_buffer_out;

localparam STATE_BITS = 2;

`ifndef USE_ENUM

localparam [STATE_BITS-1:0] EMPTY = 2'b00;
localparam [STATE_BITS-1:0] BUSY = 2'b01;
localparam [STATE_BITS-1:0] FULL = 2'b10;

logic [STATE_BITS-1:0] state_d, state_q;

`else

typedef enum logic [STATE_BITS-1:0] {
  EMPTY,  // Output and buffer registers are both empty
  BUSY,   // Output register holds data
  FULL  // Both output and buffer register hold data
} state_t;
// There is no case where only the buffer register would hold data.
state_t state_d, state_q;

`endif

/*
  STATE TRANSITIONS

                 /--\ +- flow
                 |  |
          load   |  v   fill
 -------   +    ------   +    ------
|       | ---> |      | ---> |      |
| Empty |      | Busy |      | Full |
|       | <--- |      | <--- |      |
 -------    -   ------    -   ------
         unload         flush

*/

// registers
register #(
  .DATA_WIDTH(DATA_WIDTH),
  .RESET_VALUE(0)
) data_buffer_reg (
  .clk_i    (clk_i),
  .rst_ni   (rst_ni),
  .enable_i (data_buffer_wren),
  .data_i   (input_data_i),
  .data_o   (data_buffer_out)
);

register #(
  .DATA_WIDTH  (DATA_WIDTH),
  .RESET_VALUE (0)
) data_out_reg (
  .clk_i      (clk_i),
  .rst_ni     (rst_ni),
  .enable_i   (data_out_wren),
  .data_i     (selected_data),
  .data_o     (output_data_o)
);

register #(
  .DATA_WIDTH     (1),
  .RESET_VALUE    (1)
) input_ready_reg (
  .clk_i          (clk_i),
  .rst_ni         (rst_ni),
  .enable_i       (1'b1),
  .data_i         (state_d != FULL),
  .data_o         (input_ready_o)
);

register #(
  .DATA_WIDTH     (1),
  .RESET_VALUE    (0)
) output_valid_reg (
  .clk_i     (clk_i),
  .rst_ni    (rst_ni),
  .enable_i  (1'b1),
  .data_i    (state_d != EMPTY),
  .data_o    (output_valid_o)
);

always_comb begin
  selected_data = (use_buffered_data == 1'b1) ? data_buffer_out : input_data_i;
end

always_comb begin
  // condition to insert and remove
  insert            = (input_valid_i  == 1'b1) && (input_ready_o  == 1'b1);
  remove            = (output_valid_o == 1'b1) && (output_ready_i == 1'b1);
  // multiplexers
  data_out_wren     = (load  == 1'b1) || (flow == 1'b1) || (flush == 1'b1);
  data_buffer_wren  = (fill  == 1'b1);
  use_buffered_data = (flush == 1'b1);
end

always_comb begin
  // state transitions
  load    = (state_q == EMPTY) && (insert == 1'b1) && (remove == 1'b0);
  flow    = (state_q == BUSY)  && (insert == 1'b1) && (remove == 1'b1);
  fill    = (state_q == BUSY)  && (insert == 1'b1) && (remove == 1'b0);
  flush   = (state_q == FULL)  && (insert == 1'b0) && (remove == 1'b1);
  unload  = (state_q == BUSY)  && (insert == 1'b0) && (remove == 1'b1);
end

always_comb begin
  state_d = state_q;
  unique case (state_q)
    EMPTY: begin
      if (load == 1'b1)   state_d = BUSY;
    end
    BUSY: begin
      if (flow == 1'b1)   state_d = BUSY;
      if (fill == 1'b1)   state_d = FULL;
      if (unload == 1'b1) state_d = EMPTY;
    end
    FULL: begin
      if (flush == 1'b1)  state_d = BUSY;
    end
    default: begin
      state_d = EMPTY;
    end
  endcase
end

always_ff @(posedge clk_i) begin
  if (~rst_ni) begin
    state_q <= EMPTY;
  end else begin
    state_q <= state_d;
  end
end

endmodule
