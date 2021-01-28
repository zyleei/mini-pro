// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo
  #(
  parameter DEPTH=8,
  parameter BITS=64
  )
  (
  input clk,rst_n,en,
  input [BITS-1:0] d,
  output [BITS-1:0] q
  );
  // your RTL code here
reg [BITS-1:0] fiforeg [0:DEPTH-1];
wire [BITS-1:0] fifo_in [0:DEPTH-1];
reg [DEPTH-1:0] st; 
wire [DEPTH-1:0] sel, st_shift, nxtst;
wire full;
assign fifo_in[0] = d;
assign q = full ? fiforeg[DEPTH-1] : 0;

// status
assign st_shift = {1'b1, st[DEPTH-1:1]};
assign nxtst = en&(~full) ? st_shift : st;
assign full = &st;
assign sel = {DEPTH{en}} & ((st^st_shift) | {DEPTH{full}});
always @(posedge clk) begin
  if (!rst_n)
		st <= 0;
	else
		st <= nxtst;
end

// fifo
genvar i;
generate
	for (i = 1; i < DEPTH; i = i + 1)
		assign fifo_in[i] = full ? fiforeg[i-1] : d;
endgenerate

genvar x;
generate
for (x = 0; x < DEPTH; x = x + 1) begin
	always @(posedge clk) begin
		if (!rst_n)
			fiforeg[x] <= 0;
		else
			fiforeg[x] <= (sel[x] ? fifo_in[x] : fiforeg[x]);
	end
end	
endgenerate

endmodule // fifo
