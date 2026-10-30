// Silicon Simplified - FPGA Course, Episode 7
// GOOD: one clock domain. A 4-bit LED counter advances once per tick, using the flip-flops' CE pins.
`timescale 1ns / 1ps
module blink_en #(parameter N = 100_000_000) (
    input  wire       clk,
    input  wire       rst,
    output wire [3:0] led
);
    wire tick;
    reg [3:0] c = 0;
    tick_gen #(.N(N)) tg (.clk(clk), .rst(rst), .tick(tick));
    always @(posedge clk) begin
        if (rst)       c <= 0;
        else if (tick) c <= c + 1;
    end
    assign led = c;
endmodule
