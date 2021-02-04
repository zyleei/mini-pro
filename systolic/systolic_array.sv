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
wire [BITS_C-1:0] CC [0:DIM-1][0:DIM-1];
wire [DIM-1:0] RSEL, WREN;


genvar m;
generate
  for (m = 0; m < DIM; m++) begin
    assign AA[m][0] = A[m];
    assign BB[0][m] = B[m];
  end
endgenerate


genvar n;
generate
  for (n = 0; n < DIM; n++) begin
    assign RSEL[n] = ~(|(n[$clog2(DIM)-1:0]^Crow));
    assign WREN[n] = RSEL[n] & WrEn;
    assign Cout[n] = CC[Crow][n];
  end
endgenerate


genvar i, j;
generate
  for (i = 0; i < DIM; i++) begin
    for (j = 0; j < DIM; j++) begin
      tpumac mac_x(.clk(clk), .rst_n(rst_n), .WrEn(WREN[i]), .en(en),
                   .Ain(AA[i][j]), .Bin(BB[i][j]), .Cin(Cin[i]),
                   .Aout(AA[i][j+1]), .Bout(BB[i+1][j]), .Cout(CC[i][j]));
    end
  end
endgenerate

endmodule

