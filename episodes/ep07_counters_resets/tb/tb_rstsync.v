// Reset synchronizer: assert is immediate, release is aligned to the clock (2 edges after the request ends).
`timescale 1ns / 1ps
module tb_rstsync;
    reg clk = 0, arst = 0;
    wire srst;
    integer errors = 0;
    rst_sync dut (.clk(clk), .arst(arst), .srst(srst));
    always #5 clk = ~clk;
    // srst may only fall just after a rising clock edge
    always @(negedge srst) begin
        if (($time % 10) != 5 && $time > 0) begin errors = errors + 1; $display("FAIL: srst released off-clock at %0t", $time); end
    end
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_rstsync);
        #1 arst = 1;                         // power-up reset request at 1 ns
        #36 arst = 0;                        // request ends at 37 ns (between edges) -> srst should fall at 55 ns
        #31 arst = 1;                        // new request at 68 ns, between edges
        #1 if (srst !== 1'b1) begin errors = errors + 1; $display("FAIL: assert not immediate"); end
        #13 arst = 0;                        // request ends at 82 ns (edges at 75, 85)
        #3  if (srst !== 1'b1) begin errors = errors + 1; $display("FAIL: released early"); end
        #50;
        if (srst !== 1'b0) begin errors = errors + 1; $display("FAIL: never released"); end
        if (errors == 0) $display("PASS: reset asserts immediately and releases only on a clock edge");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
