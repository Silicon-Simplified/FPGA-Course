// Silicon Simplified - FPGA Course, Episode 7
// Clock-enable tick generator: one clock-wide pulse every N clock cycles.
`timescale 1ns / 1ps
module tick_gen #(parameter N = 100_000_000) (
    input  wire clk,
    input  wire rst,
    output wire tick
);
    reg [$clog2(N)-1:0] c = 0;
    assign tick = (c == N - 1);
    always @(posedge clk) begin
        if (rst || tick) c <= 0;
        else             c <= c + 1;
    end
endmodule
