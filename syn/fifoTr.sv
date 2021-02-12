// fifoTr.sv
// fifo transpose

module fifoTr
  #(
  parameter DEPTH=8,
  parameter BITS=8,
  parameter DELAY=0
  )
  (
  input clk,rst_n,
  input [1:0] ctl,
  input signed [BITS-1:0] in [DEPTH-1:0],
  output signed [BITS-1:0] out
  );

// DELAY: for zero padding
localparam LEN = DEPTH + DELAY;

reg signed [BITS-1:0] fiforeg [LEN-1:0];
reg signed [BITS-1:0] fiforeg_in [LEN-1:0];

// output
assign out = fiforeg[0];

// fifo regs inputs
always_comb begin
  case (ctl)
    2'b01: begin // parallel load
      fiforeg_in[LEN-1:DELAY] = in[DEPTH-1:0]; // load Ain
      for (int x = 0; x < DELAY; x++) // add buffers
        fiforeg_in[x] = 0;
    end
    2'b10: begin // shift
      fiforeg_in[LEN-1] = 0;
      for (int x = 0; x < LEN-1; x++)
        fiforeg_in[x] = fiforeg[x+1];
    end
    default: fiforeg_in[LEN-1:0] = fiforeg[LEN-1:0];
  endcase
end

// fifo regs
always @(posedge clk) begin
  if (!rst_n) begin
    for (int i = 0; i < LEN; i++)
      fiforeg[i] <= 0;
  end
  else
    fiforeg[LEN-1:0] <= fiforeg_in[LEN-1:0];
end

endmodule // fifo
