// Silicon Simplified - FPGA Course, Episode 13
// First hardware: a blinky for the PYNQ-Z2 (125 MHz clock).
//   BTN0       = reset (synchronized)
//   SW1:SW0    = speed: 00 -> 1 step/s, 01 -> 2, 10 -> 4, 11 -> 8
//   LD0..LD3   = a 4-bit counter that steps once per "tick"
`timescale 1ns / 1ps
module blinky #(parameter CLK_HZ = 125_000_000) (
    input  wire       clk,
    input  wire       btn,
    input  wire [1:0] sw,
    output wire [3:0] led
);
    // 1) bring the asynchronous button and switches into the clock domain (2 flip-flops each)
    (* ASYNC_REG = "TRUE" *) reg [2:0] s1 = 0, s2 = 0;
    always @(posedge clk) begin
        s1 <= {sw, btn};
        s2 <= s1;
    end
    wire       rst = s2[0];
    wire [1:0] spd = s2[2:1];

    // 2) one tick every (CLK_HZ >> spd) clock cycles
    wire [26:0] limit = (CLK_HZ >> spd) - 1;
    reg  [26:0] cnt = 0;
    wire        tick = (cnt >= limit);
    always @(posedge clk) begin
        if (rst || tick) cnt <= 27'd0;
        else             cnt <= cnt + 27'd1;
    end

    // 3) the LED counter advances on every tick (clock enable, not a divided clock: Episode 7)
    reg [3:0] c = 0;
    always @(posedge clk) begin
        if (rst)       c <= 4'd0;
        else if (tick) c <= c + 4'd1;
    end
    assign led = c;
endmodule
