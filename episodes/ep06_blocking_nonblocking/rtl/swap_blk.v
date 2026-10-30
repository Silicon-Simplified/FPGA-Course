// The same "swap" written with blocking assignments: a = b runs first, so b = a copies the NEW a.
`timescale 1ns / 1ps
module swap_blk (
    input  wire       clk, load,
    input  wire [3:0] ai, bi,
    output reg  [3:0] a, b
);
    always @(posedge clk) begin
        if (load) begin a = ai; b = bi; end
        else      begin a = b;  b = a;  end        // after this, a and b are BOTH the old b
    end
endmodule
