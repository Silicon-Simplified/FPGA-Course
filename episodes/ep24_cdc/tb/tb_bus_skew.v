// Episode 24 - why a multi-bit bus cannot cross clock domains directly: model 0..2.6 ns of bit-to-bit skew (routing differences) on an 8-bit counter,
// sample it from an unrelated clock, and count samples that are NOT the counter's current or previous value. Binary vs Gray.
`timescale 1ns/1ps
module tb_bus_skew;
    reg clk_a = 0, clk_b = 0;
    always #2 clk_a = ~clk_a;               // 250 MHz source
    always #(8.3) clk_b = ~clk_b;           // ~60 MHz destination, unrelated phase
    reg [7:0] cnt = 0;
    always @(posedge clk_a) cnt <= cnt + 8'd1;
    wire [7:0] gray = cnt ^ (cnt >> 1);
    reg [7:0] bin_skew = 0, gray_skew = 0;
    genvar i;
    generate for (i = 0; i < 8; i = i + 1) begin : sk
        always @(cnt[i])  bin_skew[i]  <= #(0.3 + 0.35 * i) cnt[i];       // 0.3 .. 2.75 ns
        always @(gray[i]) gray_skew[i] <= #(0.3 + 0.35 * i) gray[i];
    end endgenerate
    reg [7:0] prev_cnt = 0, prev_gray = 0;
    always @(posedge clk_a) begin prev_cnt <= cnt; end
    integer samples = 0, bad_bin = 0, bad_gray = 0;
    reg [7:0] g2b;
    integer k;
    always @(posedge clk_b) begin
        samples = samples + 1;
        // binary: valid if equal to the current or the previous count
        if (bin_skew !== cnt && bin_skew !== prev_cnt) bad_bin = bad_bin + 1;
        // gray: convert back and apply the same rule
        g2b[7] = gray_skew[7];
        for (k = 6; k >= 0; k = k - 1) g2b[k] = g2b[k+1] ^ gray_skew[k];
        if (g2b !== cnt && g2b !== prev_cnt) bad_gray = bad_gray + 1;
        if (samples == 20000) begin
            $display("SKEW_RESULT samples=%0d bad_binary=%0d bad_gray=%0d", samples, bad_bin, bad_gray);
            $finish;
        end
    end
endmodule
