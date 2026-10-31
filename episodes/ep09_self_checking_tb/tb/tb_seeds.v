// How lucky was seed 1?  Try 50 different seeds: how many random vectors until the bug is hit?
`timescale 1ns / 1ps
module tb_seeds;
    reg  [3:0] a, b;
    reg  [2:0] op;
    wire [3:0] yb;
    wire       zerob, carryb;
    integer s, i, seed, r, first, min = 1000000, max = 0, sum = 0, never = 0;
    alu4_bug bug (.a(a), .b(b), .op(op), .y(yb), .zero(zerob), .carry(carryb));
    function [5:0] ref_model(input [3:0] ra, input [3:0] rb, input [2:0] rop);
        integer t; reg [3:0] ry; reg rc;
        begin
            rc = 0;
            case (rop)
                0: begin t = ra + rb;            ry = t[3:0]; rc = t[4]; end
                1: begin t = ra + (15 - rb) + 1; ry = t[3:0]; rc = t[4]; end
                2: ry = ra & rb;   3: ry = ra | rb;   4: ry = ra ^ rb;
                5: ry = 15 - ra;   6: ry = (ra * 2) % 16;   7: ry = ra / 2;
            endcase
            ref_model = {rc, (ry == 0), ry};
        end
    endfunction
    initial begin
        for (s = 1; s <= 50; s = s + 1) begin
            seed = s; first = 0;
            for (i = 1; i <= 2000 && first == 0; i = i + 1) begin
                r = $random(seed); {op, b, a} = r[10:0]; #1;
                if ({carryb, zerob, yb} !== ref_model(a, b, op)) first = i;
            end
            if (first == 0) never = never + 1;
            else begin sum = sum + first; if (first < min) min = first; if (first > max) max = first; end
        end
        $display("SEEDS seeds=50 min=%0d max=%0d mean=%0d never_found=%0d", min, max, sum / 50, never);
        if (never == 0) $display("PASS: every one of 50 seeds finds the bug within 2000 random vectors");
        else $display("FAILED");
        $finish;
    end
endmodule
