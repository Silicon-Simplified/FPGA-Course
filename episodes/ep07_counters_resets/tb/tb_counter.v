// Sync vs async reset on the same counter. Reset is asserted BETWEEN clock edges (at 42 ns) to expose the difference.
`timescale 1ns / 1ps
module tb_counter;
    reg clk = 0, rst = 0, en = 1;
    wire [7:0] qs, qa;
    integer errors = 0;
    reg [7:0] held;
    cnt8_sync  s (.clk(clk), .rst(rst), .en(en), .q(qs));
    cnt8_async a (.clk(clk), .rst(rst), .en(en), .q(qa));
    always #5 clk = ~clk;                     // rising edges at 5, 15, 25, ...
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_counter);
        #2 rst = 1; #8 rst = 0;               // initial reset 2..10 ns (async clears at 2, sync at the 5 ns edge)
        #32;                                  // 42 ns: counters have been running since the 15 ns edge
        en = 0;                               // freeze at 42 ns (before 45 ns edge)
        #0;
        // hold: after the 45 and 55 edges the value must not change
        #1; if (qs !== qa) begin errors = errors + 1; $display("FAIL: counters differ before reset"); end
        held = qs;
        #20;                                  // 64 ns: two edges (45, 55) passed with en = 0
        if (qs !== held || qa !== held) begin errors = errors + 1; $display("FAIL: enable did not hold the count"); end
        en = 1;                               // resume
        #19 rst = 1;                          // 82 ns: reset asserted BETWEEN edges (edges at 75, 85)
        #1;                                   // 83 ns
        $display("RST @83ns  async=%0d sync=%0d", qa, qs);
        if (qa !== 8'd0) begin errors = errors + 1; $display("FAIL: async reset did not clear immediately"); end
        if (qs === 8'd0) begin errors = errors + 1; $display("FAIL: sync reset cleared too early"); end
        #3;                                   // 86 ns (after the 85 ns edge)
        $display("RST @86ns  async=%0d sync=%0d", qa, qs);
        if (qs !== 8'd0) begin errors = errors + 1; $display("FAIL: sync reset did not clear at the next edge"); end
        #4 rst = 0;
        #40;
        if (errors == 0) $display("PASS: async reset clears at once, sync reset waits for the clock edge, enable holds the count");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
