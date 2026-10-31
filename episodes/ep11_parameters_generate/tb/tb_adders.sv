// Exhaustive test of both 8-bit adders (65,536 input pairs each): the generate-built ripple adder and the "+" adder.
`timescale 1ns / 1ps
module tb_adders;
    logic [7:0] a, b;
    wire  [7:0] s1, s2;
    wire        c1, c2;
    int errors = 0;
    rca_gen  #(.N(8)) r (.a(a), .b(b), .sum(s1), .cout(c1));
    add_plus #(.N(8)) p (.a(a), .b(b), .sum(s2), .cout(c2));
    initial begin
        for (int i = 0; i < 65536; i++) begin
            {a, b} = i[15:0]; #1;
            if ({c1, s1} !== 9'(a + b)) errors++;
            if ({c2, s2} !== 9'(a + b)) errors++;
        end
        $display("ADDERS vectors=65536 errors=%0d", errors);
        if (errors == 0) $display("PASS: both adders are exhaustively correct");
        else $display("FAILED");
        $finish;
    end
endmodule
