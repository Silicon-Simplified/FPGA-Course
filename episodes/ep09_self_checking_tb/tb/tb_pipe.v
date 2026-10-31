// Clocked self-checking test: a 2-stage pipelined adder. Inputs change on the FALLING edge, results are checked on the
// falling edge too, so nothing ever changes at the same instant as the rising edge the DUT samples on.
// The scoreboard is two registers that delay the expected sum by the same 2 clocks.
`timescale 1ns / 1ps
module tb_pipe;
    reg clk = 0;
    reg [7:0] a = 0, b = 0;
    wire [8:0] y, yb;
    integer n = 0, err_good = 0, err_bad = 0;
    add_pipe     good (.clk(clk), .a(a), .b(b), .y(y));
    add_pipe_bad bad  (.clk(clk), .a(a), .b(b), .y(yb));
    always #5 clk = ~clk;                         // rising edges at 5, 15, 25, ...
    reg [8:0] e1 = 0, e2 = 0;                     // expected value, delayed by 1 and 2 clocks
    wire [8:0] expected = e2;
    always @(posedge clk) begin e1 <= a + b; e2 <= e1; end
    always @(negedge clk) begin
        if (n > 3) begin                          // skip the first cycles while the pipeline fills
            if (y  !== expected) err_good = err_good + 1;
            if (yb !== expected) err_bad  = err_bad + 1;
        end
        n = n + 1;
        if (n < 14) begin a <= n; b <= 8'd100; end                // readable pattern for the video
        else begin a <= $random; b <= $random; end                // then random
        if (n == 214) begin
            $display("PIPE cycles=%0d errors_2stage=%0d errors_1stage=%0d", n, err_good, err_bad);
            if (err_good == 0 && err_bad > 0) $display("PASS: the scoreboard accepts latency 2 and rejects latency 1");
            else $display("FAILED");
            $finish;
        end
    end
    initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_pipe); end
endmodule
