// reg -> logic -> reg. The logic in the middle is what limits how fast you can clock the design.
`timescale 1ns / 1ps
module path_demo (
    input  wire        clk,
    input  wire [31:0] d,
    output reg         q
);
    reg [31:0] r;
    always @(posedge clk) r <= d;
    wire [7:0] s = r[7:0] + r[15:8];                 // 8-bit add (carry chain)
    wire       lt = (s ^ r[23:16]) < r[31:24];       // XOR then compare
    always @(posedge clk) q <= lt;
endmodule
