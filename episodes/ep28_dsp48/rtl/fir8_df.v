// Episode 28 - the same filter in DIRECT form: a delay line of samples, eight multipliers, and an adder tree in the fabric (for comparison with the transposed form).
module fir8_df (input wire clk, input wire signed [15:0] x, output wire signed [34:0] y);
    reg signed [15:0] xd [0:7]; integer i;
    always @(posedge clk) begin xd[0] <= x; for (i = 1; i < 8; i = i + 1) xd[i] <= xd[i-1]; end
    reg signed [31:0] m0 = 0; always @(posedge clk) m0 <= (-236) * xd[0];
    reg signed [31:0] m1 = 0; always @(posedge clk) m1 <= (0) * xd[1];
    reg signed [31:0] m2 = 0; always @(posedge clk) m2 <= (4426) * xd[2];
    reg signed [31:0] m3 = 0; always @(posedge clk) m3 <= (12194) * xd[3];
    reg signed [31:0] m4 = 0; always @(posedge clk) m4 <= (12194) * xd[4];
    reg signed [31:0] m5 = 0; always @(posedge clk) m5 <= (4426) * xd[5];
    reg signed [31:0] m6 = 0; always @(posedge clk) m6 <= (0) * xd[6];
    reg signed [31:0] m7 = 0; always @(posedge clk) m7 <= (-236) * xd[7];
    reg signed [34:0] s0 = 0, s1 = 0, s2 = 0, s3 = 0, t0 = 0, t1 = 0, yr = 0;
    always @(posedge clk) begin s0 <= m0 + m1; s1 <= m2 + m3; s2 <= m4 + m5; s3 <= m6 + m7; t0 <= s0 + s1; t1 <= s2 + s3; yr <= t0 + t1; end
    assign y = yr;
endmodule
