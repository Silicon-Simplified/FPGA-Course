// Episode 39 - experiment 1: pipelining. Sum of 16 signed 32-bit numbers with an adder tree (4 levels), inputs and output registered.
// STG = 0: the 4 levels are one combinational path; STG = 1: a register after every level; STG = 2: a register after every second level.
module tree #(parameter STG = 0) (input wire clk, input wire [511:0] x, output reg [35:0] y);
    reg [511:0] xr; always @(posedge clk) xr <= x;
    wire signed [35:0] l0 [0:15]; genvar i;
    generate for (i = 0; i < 16; i = i + 1) begin : g0 assign l0[i] = {{4{xr[32*i+31]}}, xr[32*i +: 32]}; end endgenerate
    // level 1
    wire signed [35:0] a1 [0:7]; reg signed [35:0] r1 [0:7];
    generate for (i = 0; i < 8; i = i + 1) begin : g1 assign a1[i] = l0[2*i] + l0[2*i+1]; always @(posedge clk) r1[i] <= a1[i]; end endgenerate
    wire signed [35:0] b1 [0:7]; generate for (i = 0; i < 8; i = i + 1) begin : g1b assign b1[i] = (STG == 1) ? r1[i] : a1[i]; end endgenerate
    // level 2
    wire signed [35:0] a2 [0:3]; reg signed [35:0] r2 [0:3];
    generate for (i = 0; i < 4; i = i + 1) begin : g2 assign a2[i] = b1[2*i] + b1[2*i+1]; always @(posedge clk) r2[i] <= a2[i]; end endgenerate
    wire signed [35:0] b2 [0:3]; generate for (i = 0; i < 4; i = i + 1) begin : g2b assign b2[i] = (STG != 0) ? r2[i] : a2[i]; end endgenerate
    // level 3
    wire signed [35:0] a3 [0:1]; reg signed [35:0] r3 [0:1];
    generate for (i = 0; i < 2; i = i + 1) begin : g3 assign a3[i] = b2[2*i] + b2[2*i+1]; always @(posedge clk) r3[i] <= a3[i]; end endgenerate
    wire signed [35:0] b3 [0:1]; generate for (i = 0; i < 2; i = i + 1) begin : g3b assign b3[i] = (STG == 1) ? r3[i] : a3[i]; end endgenerate
    // level 4
    always @(posedge clk) y <= b3[0] + b3[1];
endmodule
