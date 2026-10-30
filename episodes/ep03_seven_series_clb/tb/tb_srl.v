// Checks that srl_delay (DEPTH=32) delays a random bit stream by exactly 32 enabled clocks,
// and that srl_var returns the bit from the selected tap.
`timescale 1ns / 1ps
module tb_srl;
    reg clk = 0, ce = 1, d = 0;
    reg [4:0] tap = 0;
    wire q, qv;
    reg [31:0] hist = 0;           // reference model: what d looked like 1..32 clocks ago
    integer i, errors = 0;
    srl_delay #(.DEPTH(32)) dut (.clk(clk), .ce(ce), .d(d), .q(q));
    srl_var                 dv  (.clk(clk), .ce(ce), .d(d), .tap(tap), .q(qv));
    always #5 clk = ~clk;
    initial begin
        for (i = 0; i < 400; i = i + 1) begin
            @(negedge clk);
            d   = $random;
            tap = $random;
            ce  = ($random % 8) != 0;    // enable most cycles, pause some
            @(posedge clk);              // DUT samples d here
            #1;
            if (ce) hist = {hist[30:0], d};
            if (i > 40) begin
                if (q  !== hist[31])  begin errors = errors + 1; $display("FAIL q  @%0d", i); end
                if (qv !== hist[tap]) begin errors = errors + 1; $display("FAIL qv @%0d tap=%0d", i, tap); end
            end
        end
        if (errors == 0) $display("PASS: SRL delay and variable tap"); else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
