// One data pulse (high for exactly one clock edge) through both shift registers; dumps the waveform to wave.vcd.
`timescale 1ns / 1ps
module tb_shift;
    reg clk = 0, rst = 1, d = 0;
    wire n1, n2, n3, b1, b2, b3;
    integer errors = 0;
    shift3_nb  nb  (.clk(clk), .rst(rst), .d(d), .q1(n1), .q2(n2), .q3(n3));
    shift3_blk blk (.clk(clk), .rst(rst), .d(d), .q1(b1), .q2(b2), .q3(b3));
    always #5 clk = ~clk;                          // 10 ns period, rising edges at 5, 15, 25, ...
    // reference: remember d as sampled at each rising edge
    reg [3:0] h = 0;                               // h[0] = d sampled at the latest edge
    always @(posedge clk) begin
        if (rst) h <= 0; else h <= {h[2:0], d};
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_shift);
        #12 rst = 0;
        #5  d = 1;                                 // 17 ns: sampled at the 25 ns edge
        #10 d = 0;                                 // 27 ns: gone before the 35 ns edge
        #60;
        if (errors == 0) $display("PASS: non-blocking delays by 3 clocks, blocking collapses to no delay");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
    // after every edge: non-blocking = true delay line; blocking = no delay (all three follow d at once)
    always @(posedge clk) begin
        #1;
        if (!rst) begin
            if ({n1, n2, n3} !== {h[0], h[1], h[2]}) begin errors = errors + 1; $display("FAIL nb @%0t", $time); end
            if ({b1, b2, b3} !== {3{h[0]}})          begin errors = errors + 1; $display("FAIL blk @%0t", $time); end
        end
    end
endmodule
