// Both full adders against the arithmetic truth, all 8 input combinations.
`timescale 1ns / 1ps
module tb_fa;
    reg a, b, cin;
    wire s1, c1, s2, c2;
    integer i, errors = 0;
    fa_gates g (.a(a), .b(b), .cin(cin), .sum(s1), .cout(c1));
    fa_rtl   r (.a(a), .b(b), .cin(cin), .sum(s2), .cout(c2));
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0]; #1;
            if ({c1, s1} !== (a + b + cin)) begin errors = errors + 1; $display("FAIL gates %b", {a,b,cin}); end
            if ({c2, s2} !== (a + b + cin)) begin errors = errors + 1; $display("FAIL rtl   %b", {a,b,cin}); end
            if ({c1, s1} !== {c2, s2})      begin errors = errors + 1; $display("MISMATCH %b", {a,b,cin}); end
        end
        if (errors == 0) $display("PASS: gate-level and RTL full adders match on all 8 inputs");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
