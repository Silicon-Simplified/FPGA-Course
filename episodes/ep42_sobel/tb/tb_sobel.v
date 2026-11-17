// Episode 42 - feeds frames (in.hex: one 8-bit pixel per line, frames back to back) through the Sobel pipeline with random bubbles (+gap=<percent>), then flushes it, and writes the output pixels.
// Also records the latency (clocks from the first input pixel to the first output pixel) in latency.txt.
`timescale 1ns/1ps
module tb_sobel #(parameter W = 128, parameter H = 96, parameter BUG = 0);
    reg clk = 0; always #5 clk = ~clk;
    reg rst = 1, in_valid = 0; reg [7:0] in_pix = 0; wire out_valid; wire [7:0] out_pix;
    sobel #(W, H, BUG) dut (.clk(clk), .rst(rst), .in_valid(in_valid), .in_pix(in_pix), .out_valid(out_valid), .out_pix(out_pix));
    reg [7:0] mem [0:1048575];
    integer n, gap, i, fo, fl, cycles = 0, first_in = -1, first_out = -1, nout = 0;
    initial begin
        if (!$value$plusargs("n=%d", n)) n = W * H;
        if (!$value$plusargs("gap=%d", gap)) gap = 0;
        $readmemh("in.hex", mem);
        fo = $fopen("out.txt", "w");
        repeat (4) @(negedge clk); rst = 0;
        i = 0;
        while (i < n + W + 3) begin                    // all pixels, then W + 3 flush pixels
            @(negedge clk);
            if (($urandom % 100) >= gap) begin in_valid = 1; in_pix = (i < n) ? mem[i] : 8'd0; if (first_in < 0) first_in = cycles; i = i + 1; end
            else in_valid = 0;
        end
        @(negedge clk); in_valid = 0; repeat (4) @(negedge clk);
        $fclose(fo);
        fl = $fopen("latency.txt", "w"); $fdisplay(fl, "%0d", first_out - first_in); $fclose(fl);
        $display("Sobel %0d pixels in, %0d pixels out, latency %0d clocks", n, nout, first_out - first_in);
        $finish;
    end
    always @(posedge clk) begin
        cycles = cycles + 1;
        if (out_valid && !rst) begin $fdisplay(fo, "%0d", out_pix); nout = nout + 1; if (first_out < 0) first_out = cycles; end
    end
endmodule
