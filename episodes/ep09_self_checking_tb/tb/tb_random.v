// RANDOM test with a fixed seed: reproducible. Counts how many random vectors it takes to hit the bug.
`timescale 1ns / 1ps
module tb_random;
    reg  [3:0] a, b;
    reg  [2:0] op;
    wire [3:0] y, yb;
    wire       zero, carry, zerob, carryb;
    integer i, seed = 1, r, err_good = 0, err_bug = 0, first = -1;
    alu4     good (.a(a), .b(b), .op(op), .y(y),  .zero(zero),  .carry(carry));
    alu4_bug bug  (.a(a), .b(b), .op(op), .y(yb), .zero(zerob), .carry(carryb));
    function [5:0] ref_model(input [3:0] ra, input [3:0] rb, input [2:0] rop);   // {carry, zero, y}: written with integer arithmetic, NOT like the DUT
        integer s;
        reg [3:0] ry; reg rc;
        begin
            rc = 0;
            case (rop)
                0: begin s = ra + rb;             ry = s[3:0]; rc = s[4]; end
                1: begin s = ra + (15 - rb) + 1;  ry = s[3:0]; rc = s[4]; end
                2: ry = ra & rb;
                3: ry = ra | rb;
                4: ry = ra ^ rb;
                5: ry = 15 - ra;
                6: ry = (ra * 2) % 16;
                7: ry = ra / 2;
            endcase
            ref_model = {rc, (ry == 0), ry};
        end
    endfunction
    localparam N = 200;
    initial begin
        for (i = 1; i <= N; i = i + 1) begin
            r = $random(seed);
            {op, b, a} = r[10:0];
            #1;
            if ({carry,  zero,  y}  !== ref_model(a, b, op)) err_good = err_good + 1;
            if ({carryb, zerob, yb} !== ref_model(a, b, op)) begin
                err_bug = err_bug + 1;
                if (first < 0) first = i;
            end
        end
        $display("RANDOM seed=1 vectors=%0d first_failure_at_vector=%0d failing_vectors=%0d errors_alu4=%0d", N, first, err_bug, err_good);
        if (err_good == 0 && err_bug > 0) $display("PASS: random testing with a fixed seed finds the bug, and the good ALU is clean");
        else $display("FAILED");
        $finish;
    end
endmodule
