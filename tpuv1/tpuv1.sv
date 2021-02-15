module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
    )
   (
    input clk, rst_n, r_w,
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
   );

localparam DIM_LOG = $clog2(DIM);
reg [$clog2(4*DIM):0] cnt_comp;
logic signed [BITS_AB-1:0] Aout [DIM-1:0];
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic signed [BITS_AB-1:0] Bout [DIM-1:0];
logic signed [BITS_AB-1:0] in_AB [DIM-1:0];
logic signed [BITS_C-1:0] in_C [DIM/2-1:0];
logic signed [BITS_C-1:0] Cin_lo [DIM/2-1:0];
logic signed [BITS_C-1:0] Cin_hi [DIM/2-1:0];
logic signed [BITS_C-1:0] Cin [DIM-1:0];
logic [BITS_C-1:0] Cout [DIM-1:0];
logic [BITS_C-1:0] Cout_lo [DIM/2-1:0];
logic [BITS_C-1:0] Cout_hi [DIM/2-1:0];
wire [$clog2(DIM)-1:0] Arow, Crow;
wire enA, enB, enC;
wire WrEn_A, WrEn_C;
wire in_prog;
wire hi;


assign Cin_hi = in_C;
assign Cin[DIM-1:DIM/2] = Cin_hi;
assign Cin[DIM/2-1:0] = Cin_lo;
assign hi = addr[$clog2(DIM)];
assign in_prog = |cnt_comp;
assign Arow = addr[DIM_LOG+2:DIM_LOG];
assign Crow = addr[DIM_LOG+3:DIM_LOG+1];
assign WrEn_A = r_w & (addr[ADDRW-1:ADDRW/2] == 8'h01);
assign WrEn_C = r_w & (addr[ADDRW-1:ADDRW/2] == 8'h03) & hi;
assign enA = in_prog;
assign enB = in_prog | (r_w & (addr[ADDRW-1:ADDRW/2] == 8'h02));
assign enC = in_prog;
assign Cout_lo[DIM/2-1:0] = Cout[DIM/2-1:0];
assign Cout_hi[DIM/2-1:0] = Cout[DIM-1:DIM/2];
assign Bin = r_w ? in_AB : {>>{0}};
assign {>>{in_AB}} = dataIn;
assign {>>{in_C}} = dataIn;
assign dataOut = hi ? {>>{Cout_hi}} : {>>{Cout_lo}};

memA #(.BITS_AB(BITS_AB), .DIM(DIM))
memA_x(.clk(clk), .rst_n(rst_n), .en(enA), .WrEn(WrEn_A),
       .Ain(in_AB), .Arow(Arow), .Aout(Aout));

memB #(.BITS_AB(BITS_AB), .DIM(DIM))
memB_x(.clk(clk), .rst_n(rst_n), .en(enB), .Bin(Bin), .Bout(Bout));

systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM))
sys_arr_0 (.clk(clk), .rst_n(rst_n), .WrEn(WrEn_C), .en(enC),
           .A(Aout), .B(Bout), .Cin(Cin), .Crow(Crow), .Cout(Cout));

always @(posedge clk) begin
  if (!rst_n)
    Cin_lo <= {>>{0}};
  else if (r_w & (~hi))
    Cin_lo <= in_C;
end

// computation counter
always @(posedge clk) begin
 if (!rst_n)
  cnt_comp <= 0;
 else if (cnt_comp == 0) begin
  if (r_w & (addr==16'h0400)) cnt_comp <= 1;
  else cnt_comp <= 0;
 end
 else if (cnt_comp == 3*DIM) 
  cnt_comp <= 0;
 else
  cnt_comp <= cnt_comp + 1;
end


endmodule
