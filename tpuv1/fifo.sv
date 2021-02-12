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

    logic [BITS-1:0] arr [DEPTH-1:0];

    always @(posedge clk) begin
        if(!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                arr[i] <= '0;
        end
        else begin
            if (en) begin
                for(int i = DEPTH - 1; i > 0; i--)
                    arr[i] <= arr[i-1];
                arr[0] <= d;
            end
        end
    end

    assign q = arr[DEPTH-1];

endmodule // fifo
