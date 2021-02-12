module tpumac
 #(parameter BITS_AB=8,
   parameter BITS_C=16)
  (
   input clk, rst_n, WrEn, en,
   input signed [BITS_AB-1:0] Ain,
   input signed [BITS_AB-1:0] Bin,
   input signed [BITS_C-1:0] Cin,
   output reg signed [BITS_AB-1:0] Aout,
   output reg signed [BITS_AB-1:0] Bout,
   output reg signed [BITS_C-1:0] Cout
  );

wire signed [15:0] sum, cnxt;

// direct outputs
always @(posedge clk) begin
  if (!rst_n) begin
    Aout <= 0;
    Bout <= 0;
  end
  else if (en) begin
    Aout <= Ain;
    Bout <= Bin;
  end
end

assign sum = Ain * Bin + Cout;
assign cnxt = WrEn ? Cin : sum;

// reg C
always @(posedge clk) begin
  if (!rst_n)
    Cout <= 0;
  else if (en|WrEn)
    Cout <= cnxt;
end

endmodule
