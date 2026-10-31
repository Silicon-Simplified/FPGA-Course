// Mealy vs Moore 1011 detector (overlapping). Mealy answers in the same cycle as the last bit, Moore one clock later.
`timescale 1ns / 1ps
module tb_seq;
    reg clk = 0, rst = 1, din = 0;
    wire mealy, moore;
    integer errors = 0, n = 0, hits = 0;
    seq_mealy m (.clk(clk), .rst(rst), .din(din), .dout(mealy));
    seq_moore o (.clk(clk), .rst(rst), .din(din), .dout(moore));
    always #5 clk = ~clk;                         // rising edges at 5, 15, 25 ...
    reg [0:15] stream = 16'b0_1011_0111_0110_010;  // bit 0 is applied first
    reg [3:0] h = 0;                              // last 4 inputs sampled at rising edges
    // drive the next bit on each falling edge
    always @(negedge clk) if (!rst) begin din <= stream[n % 16]; n <= n + 1; end
    always @(posedge clk) begin
        if (!rst) begin
            if (mealy !== ({h[2:0], din} == 4'b1011)) begin errors = errors + 1; $display("FAIL mealy @%0t", $time); end
            if (moore !== (h == 4'b1011))             begin errors = errors + 1; $display("FAIL moore @%0t", $time); end
            if (mealy) hits = hits + 1;
        end
        h <= rst ? 4'b0 : {h[2:0], din};
    end
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_seq);
        #17 rst = 0;
        #(10 * 16 + 3);
        $display("SEQ hits=%0d", hits);
        if (hits < 3) begin errors = errors + 1; $display("FAIL: expected at least 3 matches"); end
        if (errors == 0) $display("PASS: Mealy matches in the same cycle, Moore one clock later (overlapping 1011)");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
