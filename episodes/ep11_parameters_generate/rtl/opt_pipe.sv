// Silicon Simplified - FPGA Course, Episode 11
// generate-if: the PIPELINE option adds an output register only when asked. W < 2 is rejected at ELABORATION time.
`timescale 1ns / 1ps
module opt_pipe #(parameter int W = 16, parameter bit PIPELINE = 1) (
    input  logic         clk,
    input  logic [W-1:0] a, b,
    output logic [W-1:0] y
);
    if (W < 2) begin : g_bad_width
        $error("opt_pipe: W must be at least 2, got %0d", W);
    end
    logic [W-1:0] s;
    assign s = a + b;
    if (PIPELINE) begin : g_reg
        always_ff @(posedge clk) y <= s;
    end else begin : g_comb
        assign y = s;
    end
endmodule
