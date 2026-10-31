// Silicon Simplified - FPGA Course, Episode 11
// Thermometer LED bar built with a generate-for loop: led[i] is on when level > i. N LEDs, any N.
`timescale 1ns / 1ps
module led_bar #(parameter N = 8) (
    input  wire [$clog2(N+1)-1:0] level,       // 0 .. N
    output wire [N-1:0]           leds
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_led
            assign leds[i] = (level > i);
        end
    endgenerate
endmodule
