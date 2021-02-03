module systolic_array
#(
   parameter BITS_AB=8,
   parameter BITS_C=16,
   parameter DIM=8
   )
  (
   input                      clk,rst_n,WrEn,en,
   input signed [BITS_AB-1:0] A [DIM-1:0],
   input signed [BITS_AB-1:0] B [DIM-1:0],
   input signed [BITS_C-1:0]  Cin [DIM-1:0],
   input [$clog2(DIM)-1:0]    Crow,
   output signed [BITS_C-1:0] Cout [DIM-1:0]
   );


wire [BITS_AB-1:0] AA [0:DIM-1][0:DIM];
wire [BITS_AB-1:0] BB [0:DIM][0:DIM-1];
wire [BITS_AB-1:0] CC [0:DIM-1][0:DIM-1];
wire [DIM-1:0] RSEL, WREN;

genvar i, j;

generate
  for (i = 0; i < DIM; i++) begin
    assign AA[i][0] = A[i];
    assign BB[0][i] = B[i];
  end
endgenerate

generate
  for (i = 0; i < DIM; i++) begin
    assign RSEL[i] = ~(|(i[$clog2(DIM)-1:0]^Crow));
    assign WREN[i] = RSEL[i] & WrEn;
    assign Cout[i] = CC[Crow][i];
  end
endgenerate

generate
  for (i = 0; i < DIM; i++) begin
    for (j = 0; j < DIM; j++) begin
      tpumac (.clk(clk), .rst_n(rst_n), .WrEn(WREN[i]), .en(en),
              .Ain(AA[i][j]), .Bin(BB[i][j]), .Cin(Cin[i]),
              .Aout(AA[i][j+1]), .Bout(BB[i+1][j]), .Cout(CC[i][j]));
    end
  end
endgenerate

endmodule

