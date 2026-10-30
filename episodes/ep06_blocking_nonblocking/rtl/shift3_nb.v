// 3-stage shift register, NON-blocking (<=): a real 3-clock delay line.
// (the synchronous reset keeps Vivado from turning it into a shift-register LUT, so you can see the flip-flops)
`timescale 1ns / 1ps
module shift3_nb (
    input  wire clk, rst, d,
    output reg  q1, q2, q3
);
    always @(posedge clk) begin
        if (rst) begin
            q1 <= 1'b0; q2 <= 1'b0; q3 <= 1'b0;
        end else begin
            q1 <= d;
            q2 <= q1;
            q3 <= q2;
        end
    end
endmodule
