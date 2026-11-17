// Episode 41 - feeds in.hex (12-bit samples, one per clock) into the DDC and writes the I and Q outputs to out_i.txt / out_q.txt. +n=<samples>
`timescale 1ns/1ps
module tb_ddc #(parameter CICW = 33);
    reg clk = 0; always #5 clk = ~clk;
    reg rst = 1; reg signed [11:0] x = 0; wire signed [15:0] oi, oq; wire ov;
    reg [11:0] mem [0:1048575];
    integer n, i, fi, fq, cnt = 0;
    ddc_top #(CICW) dut (.clk(clk), .rst(rst), .x(x), .inc(32'd459561501), .out_i(oi), .out_q(oq), .out_valid(ov));
    initial begin
        if (!$value$plusargs("n=%d", n)) n = 409600;
        $readmemh("in.hex", mem);
        fi = $fopen("out_i.txt", "w"); fq = $fopen("out_q.txt", "w");
        repeat (4) @(negedge clk); rst = 0;
        for (i = 0; i < n; i = i + 1) begin x = mem[i]; @(negedge clk); end
        $fclose(fi); $fclose(fq);
        $display("DDC simulated %0d input samples, %0d output samples", n, cnt);
        $finish;
    end
    always @(posedge clk) if (ov && !rst) begin $fdisplay(fi, "%0d", oi); $fdisplay(fq, "%0d", oq); cnt = cnt + 1; end
endmodule
