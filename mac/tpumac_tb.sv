module tpumac_tb #(parameter BITS_AB=8, parameter BITS_C=16) ();

logic clk, rst_n, WrEn, en;
bit signed [BITS_AB-1:0] Ain, Bin;
bit signed [BITS_C-1:0] Cin;
wire signed [BITS_AB-1:0] Aout;
wire signed [BITS_AB-1:0] Bout;
wire signed [BITS_C-1:0] Cout;
integer a, b, c, cnt;


// DUT
tpumac tpumac0 (.clk(clk), .rst_n(rst_n), .WrEn(WrEn), .en(en),
		.Ain(Ain), .Bin(Bin), .Cin(Cin),
		.Aout(Aout), .Bout(Bout), .Cout(Cout));

// to randomly generate Ain, Bin
class stim_t;
rand bit signed [BITS_AB-1:0] vec_a;
rand bit signed [BITS_AB-1:0] vec_b;
endclass

// instantiate the random class
stim_t stim = new();

// clock
initial clk = 0;
always
  #5 clk = ~clk;

initial begin
rst_n = 0;
en = 0;
WrEn = 0;
@(posedge clk);
@(negedge clk) rst_n = 1;


// test 1
if ((Aout!=0) || (Bout!=0) || (Cout!=0)) begin
  $display("register(s) not reset properly\ntest 1 failed\n");
  $stop;
end

// test 2
Ain = 8'h7F;
Bin = 8'hFF;
Cin = 16'h0101;
WrEn = 1;
en = 1;
@(posedge clk);
#1
if ((Aout!=8'h7F) || (Bout!=8'hFF) || (Cout!=16'h0101)) begin
  $display("Incorrect values: A: %h, B: %h, C: %h\ntest 2 failed\n", Aout, Bout, Cout);
  $stop;
end

// test 3
en = 0;
WrEn = 0;
Ain = 8'h20;
Bin = 8'h21;
@(posedge clk);
#1
if ((Aout!=8'h7F) || (Bout!=8'hFF) || (Cout!=16'h0101)) begin
  $display("Incorrect values: A: %h, B: %h, C: %h\ntest 3 failed\n", Aout, Bout, Cout);
  $stop;
end

// test 4
en = 1;
Ain = 0;
Bin = 8'h21;
@(posedge clk);
#1
if ((Aout!=0) || (Bout!=8'h21) || (Cout!=16'h0101)) begin
  $display("Incorrect values: A: %h, B: %h, C: %h\ntest 4 failed\n", Aout, Bout, Cout);
  $stop;
end

Ain = 8'h20;
Bin = 0;
@(posedge clk);
#1
if ((Aout!=8'h20) || (Bout!=0) || (Cout!=16'h0101)) begin
  $display("Incorrect values: A: %h, B: %h, C: %h\ntest 4 failed\n", Aout, Bout, Cout);
  $stop;
end

// random tests
WrEn = 0;
c = Cout;
cnt = 0;
while (cnt < 100) begin
  stim.randomize();
  Ain = stim.vec_a;
  a = stim.vec_a;
  Bin = stim.vec_b;
  b = stim.vec_b;
  $display("(iter. %d) a: %d; b: %d; c: %d", cnt, a, b, c);
  c = c + a * b;
  $display("c_new: %d", c);
  if ((c>16'sh7FFF) || (c<16'sh8000)) begin
    $display("c: %h(%d) out of bound\n", c, c);
    break;
  end
  @(posedge clk);
  #1
  $display("cout: %d\n", Cout);
  if (c != Cout) begin
    $display("(iter. %d) incorrect result: DUT: %h(%d), tbsim: %h(%d)\ntest failed\n", cnt, Cout, Cout, c, c);
    $finish;
  end
  cnt = cnt + 1;
end // end while

// test passed
$display("test passed\n");
$finish;

end // end initial

endmodule

