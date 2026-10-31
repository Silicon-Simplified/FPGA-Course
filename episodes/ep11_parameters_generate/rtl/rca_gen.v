// Silicon Simplified - FPGA Course, Episode 11
// A ripple-carry adder BUILT from N full-adder instances with generate-for: explicit structure.
`timescale 1ns / 1ps
module rca_gen #(parameter N = 8) (
    input  wire [N-1:0] a, b,
    output wire [N-1:0] sum,
    output wire         cout
);
    wire [N:0] c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_fa
            full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .s(sum[i]), .cout(c[i+1]));
        end
    endgenerate
    assign cout = c[N];
endmodule
