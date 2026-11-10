// Episode 27 - run the DDS and write its output samples to a file (analysed by scripts/analyze_dds.py).   plusargs: +K=<decimal tuning word> +N=<samples> +OUT=<file>
`timescale 1ns/1ps
module tb_dds;
    reg clk = 0; always #4 clk = ~clk;              // 125 MHz
    reg [31:0] k = 0;
    wire signed [11:0] s;
    dds d (.clk(clk), .k(k), .sine(s));
    integer n = 16384, fd, i, kk;
    reg [1023:0] fname;
    initial begin
        if (!$value$plusargs("K=%d", kk)) kk = 33292288;
        if (!$value$plusargs("N=%d", n)) n = 16384;
        if (!$value$plusargs("OUT=%s", fname)) fname = "dds_samples.txt";
        k = kk;
        fd = $fopen(fname, "w");
        repeat (8) @(posedge clk);                    // let the pipeline fill
        for (i = 0; i < n; i = i + 1) begin @(posedge clk); $fdisplay(fd, "%0d", $signed(s)); end
        $fclose(fd);
        $finish;
    end
endmodule
