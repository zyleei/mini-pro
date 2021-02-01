module tpumac_tb
 #(parameter BITS_AB=8,
   parameter BITS_C=16) ();

logic clk, rst_n, WrEn, en;
bit signed [BITS_AB-1:0] Ain, Bin;
bit signed [BITS_C-1:0] Cin;
wire signed [BITS_AB-1:0] Aout;
wire signed [BITS_AB-1:0] Bout;
wire signed [BITS_C-1:0] Cout;

// DUT
tpumac tpumac0 (.clk(clk), .rst_n(rst_n), .WrEn(WrEn), .en(en),
		.Ain(Ain), .Bin(Bin), .Cin(Cin),
		.Aout(Aout), .Bout(Bout), .Cout(Cout));

// clock
initial clk = 0;
always
  #5 clk = ~clk;

class stim_t
rand bit signed [BITS_AB-1:0] vec_a;
rand bit signed [BITS_AB-1:0] vec_b
endclass


initial begin
rst_n = 0;
en = 0;
WrEn = 0;
@(posedge clk);
@(negedge clk) rst_n = 1;


// test 1
if ((Aout!=0) || (Bout!=0) || (Cout!=0)) begin
  $display("register(s) not reset properly\n");
  $stop; 
end

// test 2
Ain = 8'h7F;
Bin = 8'hFF;
Cin = 16'h0101;
WrEn = 1;
en = 1;
@(posedge clk);
if ((Aout!=8'h7F) || (Bout!=8'hFF) || (Cout!=16'h0101)) begin
  $display("Incorrect values: A: %h, B: %h, C: %h\n", Aout, Bout, Cout);
  $stop;
end

// random tests
WrEn = 0;
Integer c = Cout;
Integer a, b;
Integer cnt = 0;
stim_t stim = new();
while (cnt < 1000) begin : loop
  stim.randomize();
  Ain = stim.vec_a;
  a = Ain;
  Bin = stim.vec_b;
  b = Bin;
  c = c + a * b;
  if ((c>16'sh7FFF) || (c<16'shFFFF)) begin
    $display("c: %h(%d) out of bound\n", c, c);
    disable loop;
  end
  @(posedge);
  if (c != Cout) begin
    $display("(iter. %d) incorrect result: DUT: %h(%d), tbsim: %h(%d)\n", cnt, Cout, Cout, c, c);
    $stop;
  end
  cnt = cnt + 1;
end

// test passed
$display("test passed\n");
$finish;

end // end initial


endmodule

