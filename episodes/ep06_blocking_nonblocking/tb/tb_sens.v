// Simulation: change only b and see whether the output follows.
`timescale 1ns / 1ps
module tb_sens;
    reg a = 0, b = 0;
    wire y_bad, y_good;
    integer errors = 0;
    sens_bad  u1 (.a(a), .b(b), .y(y_bad));
    sens_good u2 (.a(a), .b(b), .y(y_good));
    initial begin
        #5 a = 1;                                   // a rises: both evaluate (b = 0 -> y = 0)
        #5 b = 1;                                   // only b changes: y_good must rise, y_bad does not re-evaluate
        #1 $display("SENS a=%b b=%b  bad=%b good=%b", a, b, y_bad, y_good);
        if (y_good !== 1'b1) errors = errors + 1;
        if (y_bad  !== 1'b0) errors = errors + 1;   // the stale value: this IS the bug
        #5 a = 0; #1 a = 1; #1;                     // wiggle a: bad finally catches up
        $display("SENS (a wiggled) bad=%b good=%b", y_bad, y_good);
        if (y_bad !== 1'b1) errors = errors + 1;
        if (errors == 0) $display("PASS: incomplete sensitivity list gives a stale output in simulation");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
