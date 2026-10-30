// Checks every operator in ops_demo for a = 4'b1011, b = 4'b0110 and prints the values used in the video.
`timescale 1ns / 1ps
module tb_ops;
    reg [3:0] a = 4'b1011, b = 4'b0110;
    wire [3:0] and_o, or_o, xor_o, not_o, add_o, shl_o, max_o, rep_o;
    wire eq_o;
    wire [7:0] cat_o;
    integer errors = 0;
    ops_demo dut (.a(a), .b(b), .and_o(and_o), .or_o(or_o), .xor_o(xor_o), .not_o(not_o), .add_o(add_o),
                  .shl_o(shl_o), .eq_o(eq_o), .max_o(max_o), .cat_o(cat_o), .rep_o(rep_o));
    initial begin
        #1;
        $display("OPS and=%b or=%b xor=%b not=%b add=%b shl=%b eq=%b max=%b cat=%b rep=%b",
                 and_o, or_o, xor_o, not_o, add_o, shl_o, eq_o, max_o, cat_o, rep_o);
        if (and_o !== 4'b0010) errors = errors + 1;
        if (or_o  !== 4'b1111) errors = errors + 1;
        if (xor_o !== 4'b1101) errors = errors + 1;
        if (not_o !== 4'b0100) errors = errors + 1;
        if (add_o !== 4'b0001) errors = errors + 1;     // 11 + 6 = 17 -> 17 mod 16 = 1
        if (shl_o !== 4'b0110) errors = errors + 1;     // 1011 << 1 = 0110 (top bit dropped)
        if (eq_o  !== 1'b0)    errors = errors + 1;
        if (max_o !== 4'b1011) errors = errors + 1;
        if (cat_o !== 8'b10110110) errors = errors + 1;
        if (rep_o !== 4'b1111) errors = errors + 1;
        if (errors == 0) $display("PASS: all operators behave as described");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
