// Writes a pattern into all 64 words, then reads everything back (asynchronous read, so no clock needed to read).
`timescale 1ns / 1ps
module tb_dram;
    reg clk = 0, we = 0;
    reg  [5:0] wa = 0, ra = 0;
    reg  [7:0] d = 0;
    wire [7:0] q;
    integer i, errors = 0;
    wire [7:0] qs;
    dram64x8    dut  (.clk(clk), .we(we), .wa(wa), .ra(ra), .d(d), .q(q));
    wire [5:0] a_sp = we ? wa : ra;                  // one shared address: write while we=1, read otherwise
    dram64x8_sp dsp  (.clk(clk), .we(we), .a(a_sp), .d(d), .q(qs));
    always #5 clk = ~clk;
    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            @(negedge clk); we = 1; wa = i[5:0]; d = (i * 37 + 11) & 8'hFF;
        end
        @(negedge clk); we = 0;
        for (i = 0; i < 64; i = i + 1) begin
            ra = i[5:0]; #1;
            if (q  !== ((i * 37 + 11) & 8'hFF)) begin errors = errors + 1; $display("FAIL dual-port word %0d: %h", i, q); end
            if (qs !== ((i * 37 + 11) & 8'hFF)) begin errors = errors + 1; $display("FAIL single-port word %0d: %h", i, qs); end
        end
        if (errors == 0) $display("PASS: distributed RAM (dual- and single-port), 64 words"); else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
