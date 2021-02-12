
module memA_tb();

localparam BITS_AB=8;
localparam DIM=8;
localparam ROWBITS=$clog2(DIM);

logic clk, rst_n;
logic en, WrEn;
logic signed [BITS_AB-1:0]  Ain [DIM-1:0];
logic [$clog2(DIM)-1:0]     Arow;
wire signed [BITS_AB-1:0]   Aout [DIM-1:0];


memA #(.BITS_AB(BITS_AB), .DIM(DIM))
memA_x (.clk(clk), .rst_n(rst_n),
        .en(en), .WrEn(WrEn),
        .Ain(Ain), .Arow(Arow), .Aout(Aout));

always #5 clk = ~clk; 

initial begin

clk = 1'b0;
rst_n = 1'b0;
en = 1'b0;
WrEn = 1'b0;

@(posedge clk);

rst_n = 1;
WrEn = 1;
for (int i = 0; i < DIM; i++) begin
 Ain[i] = i+1;
end
for (int i = 0; i < DIM; i++) begin
 Arow[ROWBITS-1:0] = i;
 @(posedge clk);
end // end for

WrEn = 0;
en = 1;

$display("Aout: \n");
for (int i = 0; i < 2 * DIM; i++) begin
 @(posedge clk);
 for (int j = 0; j < DIM; j++) begin
  $display("%d", Aout[j]);
 end
 $display("\n");
end

$stop;
end // end initial


endmodule

