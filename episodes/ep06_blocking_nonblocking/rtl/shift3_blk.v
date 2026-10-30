// THE BUG: the same shift register written with BLOCKING (=) assignments inside a clocked block.
// q1 = d runs first, then q2 = q1 sees the NEW q1, then q3 = q2 sees the new q2: there is no delay at all.
`timescale 1ns / 1ps
module shift3_blk (
    input  wire clk, rst, d,
    output reg  q1, q2, q3
);
    always @(posedge clk) begin
        if (rst) begin
            q1 = 1'b0; q2 = 1'b0; q3 = 1'b0;
        end else begin
            q1 = d;
            q2 = q1;
            q3 = q2;
        end
    end
endmodule
