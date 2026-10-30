// Silicon Simplified - FPGA Course, Episode 7
// BAD: a divided clock. A flip-flop output ("slow") is used as the clock of the LED counter.
// Same behaviour in simulation as blink_en - but a very different circuit.
`timescale 1ns / 1ps
module blink_div #(parameter N = 100_000_000) (
    input  wire       clk,
    input  wire       rst,
    output wire [3:0] led
);
    localparam HALF = N / 2;
    localparam W = $clog2(HALF);
    localparam [W-1:0] LAST = HALF[W-1:0] - 1'b1;
    reg [W-1:0] c = 0;
    reg slow = 0;
    reg [3:0] q = 0;
    always @(posedge clk) begin
        if (rst) begin c <= 0; slow <= 0; end
        else if (c == LAST) begin c <= 0; slow <= ~slow; end
        else c <= c + 1;
    end
    always @(posedge slow) q <= q + 1;      // clocked by a flip-flop output
    assign led = q;
endmodule
