// Drives a and b at times that are NOT aligned with the 100 MHz clock, and dumps the waveform to wave.vcd.
`timescale 1ns / 1ps
module tb_comb_vs_seq;
    reg clk = 0, a = 0, b = 0;
    wire y_comb, y_reg;
    integer errors = 0;
    comb_vs_seq dut (.clk(clk), .a(a), .b(b), .y_comb(y_comb), .y_reg(y_reg));
    always #5 clk = ~clk;                           // 10 ns period = 100 MHz
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_comb_vs_seq);
        #12 a = 1;                                   // 12 ns
        #8  b = 1;                                   // 20 ns -> y_comb rises at once; y_reg waits for the 25 ns edge
        #13 a = 0;                                   // 33 ns -> y_comb falls at once; y_reg waits for the 35 ns edge
        #14 a = 1;                                   // 47 ns (not on a clock edge)
        #15 b = 0;                                   // 62 ns
        #30;
        if (errors == 0) $display("PASS: combinational follows inputs, register waits for the clock edge");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
    // y_comb must always equal a & b immediately; y_reg must equal the value of a & b just BEFORE each rising edge.
    always @(a or b) begin #0.1; if (y_comb !== (a & b)) begin errors = errors + 1; $display("FAIL comb @%0t", $time); end end
    reg expected = 0;
    always @(posedge clk) begin
        expected = a & b;                            // what the register must capture at THIS edge
        #0.1;
        if (y_reg !== expected) begin errors = errors + 1; $display("FAIL reg @%0t", $time); end
    end
endmodule
