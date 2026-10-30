// Exhaustive self-checking testbench: all 2^11 = 2048 combinations of a, b and op, against a reference model
// written differently (integer arithmetic in a function). Also prints the example table used in the video.
`timescale 1ns / 1ps
module tb_alu4;
    reg  [3:0] a, b;
    reg  [2:0] op;
    wire [3:0] y;
    wire       zero, carry;
    integer i, errors = 0;
    alu4 dut (.a(a), .b(b), .op(op), .y(y), .zero(zero), .carry(carry));

    function [5:0] ref_model(input [3:0] ra, input [3:0] rb, input [2:0] rop);   // {carry, zero, y}
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
            if ({carry, zero, y} !== ref_model(a, b, op)) begin
                errors = errors + 1;
                if (errors < 5) $display("FAIL op=%0d a=%0d b=%0d got y=%0d z=%b c=%b", op, a, b, y, zero, carry);
            end
        end
        // the table shown in the video: a = 6, b = 3, every operation
        a = 4'd6; b = 4'd3;
        for (i = 0; i < 8; i = i + 1) begin
            op = i[2:0]; #1;
            $display("ROW %b %b %b %b %b %b", op, a, b, y, zero, carry);
        end
        if (errors == 0) $display("PASS: alu4, all 2048 combinations");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
