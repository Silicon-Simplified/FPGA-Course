// Load a = 1, b = 2, then clock once with load = 0.
`timescale 1ns / 1ps
module tb_swap;
    reg clk = 0, load = 1;
    reg [3:0] ai = 4'd1, bi = 4'd2;
    wire [3:0] na, nb_, ba, bb;
    integer errors = 0;
    swap_nb  s1 (.clk(clk), .load(load), .ai(ai), .bi(bi), .a(na), .b(nb_));
    swap_blk s2 (.clk(clk), .load(load), .ai(ai), .bi(bi), .a(ba), .b(bb));
    always #5 clk = ~clk;
    initial begin
        @(posedge clk); #1;                        // loaded
        $display("SWAP loaded  nb=(%0d,%0d) blk=(%0d,%0d)", na, nb_, ba, bb);
        load = 0;
        @(posedge clk); #1;                        // one swap step
        $display("SWAP after1  nb=(%0d,%0d) blk=(%0d,%0d)", na, nb_, ba, bb);
        if ({na, nb_} !== {4'd2, 4'd1}) errors = errors + 1;
        if ({ba, bb}  !== {4'd2, 4'd2}) errors = errors + 1;
        @(posedge clk); #1;
        $display("SWAP after2  nb=(%0d,%0d) blk=(%0d,%0d)", na, nb_, ba, bb);
        if ({na, nb_} !== {4'd1, 4'd2}) errors = errors + 1;
        if ({ba, bb}  !== {4'd2, 4'd2}) errors = errors + 1;
        if (errors == 0) $display("PASS: non-blocking swaps, blocking copies");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
