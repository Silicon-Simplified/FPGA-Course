// Exhaustive self-checking test of the SystemVerilog ALU: against an integer reference model AND against the Episode 5 Verilog ALU.
`timescale 1ns / 1ps
module tb_alu_sv;
    import alu_pkg::*;
    logic [3:0] a, b;
    op_t        op;
    res_t       res;
    logic [3:0] yv;
    logic       zv, cv;
    int errors = 0, mism_v = 0;
    alu4_sv dut (.a(a), .b(b), .op(op), .res(res));
    alu4    ref_v (.a(a), .b(b), .op(op), .y(yv), .zero(zv), .carry(cv));

    function automatic res_t ref_model(input logic [3:0] ra, rb, input op_t rop);       // integer arithmetic, written differently
        int s;
        logic [3:0] ry;
        logic rc;
        rc = 0;
        case (rop)
            ADD:  begin s = ra + rb;            ry = s[3:0]; rc = s[4]; end
            SUB:  begin s = ra + (15 - rb) + 1; ry = s[3:0]; rc = s[4]; end
            AND_: ry = ra & rb;
            OR_:  ry = ra | rb;
            XOR_: ry = ra ^ rb;
            NOT_: ry = 15 - ra;
            SHL:  ry = (ra * 2) % 16;
            SHR:  ry = ra / 2;
        endcase
        return '{carry: rc, zero: (ry == 0), y: ry};
    endfunction

    initial begin
        for (int i = 0; i < 2048; i++) begin
            {op, b, a} = i[10:0];
            #1;
            if (res !== ref_model(a, b, op)) errors++;
            if ({res.carry, res.zero, res.y} !== {cv, zv, yv}) mism_v++;
        end
        $display("ALU vectors=2048 errors_vs_reference=%0d mismatches_vs_verilog=%0d", errors, mism_v);
        if (errors == 0 && mism_v == 0) $display("PASS: the SystemVerilog ALU is exhaustively equal to the reference model and to the Verilog ALU");
        else $display("FAILED");
        $finish;
    end
endmodule
