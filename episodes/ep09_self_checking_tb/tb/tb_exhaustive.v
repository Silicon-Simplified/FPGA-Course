// EXHAUSTIVE self-checking test: all 2^11 = 2048 combinations of a, b and op, against the reference model.
`timescale 1ns / 1ps
module tb_exhaustive;
    reg  [3:0] a, b;
    reg  [2:0] op;
    wire [3:0] y, yb;
    wire       zero, carry, zerob, carryb;
    integer i, err_good = 0, err_bug = 0;
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
    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            {op, b, a} = i[10:0];
            #1;
            if ({carry, zero, y} !== ref_model(a, b, op)) err_good = err_good + 1;
            if ({carryb, zerob, yb} !== ref_model(a, b, op)) begin
                err_bug = err_bug + 1;
                if (err_bug == 1) $display("FIRST FAIL op=%0d a=%0d b=%0d got y=%0d expected y=%0d", op, a, b, yb, ref_model(a, b, op) & 6'h0F);
            end
        end
        $display("EXHAUSTIVE vectors=2048 errors_alu4=%0d errors_alu4_bug=%0d", err_good, err_bug);
        if (err_good == 0 && err_bug > 0) $display("PASS: exhaustive test passes the good ALU and catches the buggy one");
        else $display("FAILED");
        $finish;
    end
endmodule
