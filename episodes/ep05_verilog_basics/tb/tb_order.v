// order_a and order_b must behave identically for all 16 inputs.
`timescale 1ns / 1ps
module tb_order;
    reg a, b, c, d;
    wire ya, yb;
    integer i, errors = 0;
    order_a ua (.a(a), .b(b), .c(c), .d(d), .y(ya));
    order_b ub (.a(a), .b(b), .c(c), .d(d), .y(yb));
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            {a, b, c, d} = i[3:0]; #1;
            if (ya !== yb || ya !== ((a & b) | (c ^ d))) errors = errors + 1;
        end
        if (errors == 0) $display("PASS: statement order does not matter for assigns");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
