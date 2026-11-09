// Episode 22 - pipelining must not change the answer, only delay it: sum of pipe_N == sum of pipe_0, N cycles later.
`timescale 1ns/1ps
module tb_pipe;
    reg clk = 0, din = 0;
    always #4 clk = ~clk;
    wire d0, d1, d2, d3, d4;
    pipe_0 u0 (.clk(clk), .din(din), .dout(d0));
    pipe_1 u1 (.clk(clk), .din(din), .dout(d1));
    pipe_2 u2 (.clk(clk), .din(din), .dout(d2));
    pipe_3 u3 (.clk(clk), .din(din), .dout(d3));
    pipe_4 u4 (.clk(clk), .din(din), .dout(d4));
    reg [36:0] h0 [0:7];
    integer i, errors = 0, checked = 0;
    reg [31:0] lfsr = 32'hACE1_2345;
    always @(posedge clk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        din  <= lfsr[0];
        for (i = 7; i > 0; i = i - 1) h0[i] <= h0[i-1];
        h0[0] <= u0.sum;
    end
    // compare after the shift register has filled (>= 800 cycles)
    integer t = 0;
    always @(negedge clk) begin
        t = t + 1;
        if (t > 900) begin
            // u0.sum is registered once; u_k.sum is registered k more times: u_k.sum(t) == u0.sum(t-k)
            checked = checked + 4;
            if (u1.sum !== h0[0] ) begin errors = errors + 1; end
            if (u2.sum !== h0[1] ) begin errors = errors + 1; end
            if (u3.sum !== h0[2] ) begin errors = errors + 1; end
            if (u4.sum !== h0[3] ) begin errors = errors + 1; end
        end
        if (t == 2000) begin
            if (errors == 0) $display("PASS: pipe_1..4 sums equal pipe_0 sum delayed by 1..4 cycles (%0d comparisons)", checked);
            else $display("FAIL: %0d mismatches", errors);
            $finish;
        end
    end
endmodule
