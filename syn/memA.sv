module memA
  #(
    parameter BITS_AB=8,
    parameter DIM=8
    )
   (
    input                        clk,rst_n,en,WrEn,
    input  signed [BITS_AB-1:0]  Ain [DIM-1:0],
    input  [$clog2(DIM)-1:0]     Arow,
    output signed [BITS_AB-1:0]  Aout [DIM-1:0]
   );

// decode row number
wire [DIM-1:0] Arow_dec;
genvar x;
generate
 for (x = 0; x < DIM; x++)
  assign Arow_dec[x] = (x[$clog2(DIM)-1:0] == Arow);
endgenerate

// instantiate fifos
genvar i;
generate
 for (i = 0; i < DIM; i++)
  fifoTr #(.DEPTH(DIM), .BITS(BITS_AB), .DELAY(i))
  fifoTr_x (.clk(clk), .rst_n(rst_n),
            .ctl({en,WrEn&Arow_dec[i]}),
            .in(Ain[DIM-1:0]), .out(Aout[i]));
endgenerate

endmodule
