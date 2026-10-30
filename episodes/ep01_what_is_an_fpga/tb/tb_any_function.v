// Exhaustive self-checking testbench: tries all 16 input combinations.
`timescale 1ns / 1ps
module tb_any_function;
    reg  a, b, c, d;
    wire y;
    integer i, errors = 0;

    any_function dut (.a(a), .b(b), .c(c), .d(d), .y(y));

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            {a, b, c, d} = i[3:0];
            #10;
            if (y !== ((a & b) | (c ^ d))) begin
                $display("FAIL: a=%b b=%b c=%b d=%b -> y=%b", a, b, c, d, y);
                errors = errors + 1;
            end
        end
        if (errors == 0) $display("PASS: all 16 combinations correct");
        else             $display("FAILED with %0d errors", errors);
        $finish;
    end
endmodule
