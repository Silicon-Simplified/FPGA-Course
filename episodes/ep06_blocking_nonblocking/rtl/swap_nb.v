// Swap two registers each clock: only works with non-blocking assignments.
`timescale 1ns / 1ps
module swap_nb (
    input  wire       clk, load,
    input  wire [3:0] ai, bi,
    output reg  [3:0] a, b
);
    always @(posedge clk) begin
        if (load) begin a <= ai; b <= bi; end
        else      begin a <= b;  b <= a;  end      // both right-hand sides are read BEFORE either register changes
    end
endmodule
