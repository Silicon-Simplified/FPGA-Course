// The same function with the logic cut in two by a pipeline register: each half is shorter, so the clock can go faster.
`timescale 1ns / 1ps
module path_demo_piped (
    input  wire        clk,
    input  wire [31:0] d,
    output reg         q
);
    reg [31:0] r;
    reg  [7:0] s;
    reg  [7:0] x;
    reg  [7:0] t;
    always @(posedge clk) begin
        r <= d;
        s <= r[7:0] + r[15:8];                       // stage 1: add
        x <= r[23:16];
        t <= r[31:24];
        q <= ((s ^ x) < t);                          // stage 2: xor + compare
    end
endmodule
