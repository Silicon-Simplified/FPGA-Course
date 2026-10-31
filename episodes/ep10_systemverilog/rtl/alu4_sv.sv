// Silicon Simplified - FPGA Course, Episode 10
// The Episode 5 ALU in SystemVerilog: package types (enum op, packed-struct result), always_comb, unique case.
module alu4_sv import alu_pkg::*; (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  op_t        op,
    output res_t       res
);
    logic       sub;
    logic [4:0] sum;
    logic [3:0] y;
    logic       carry;
    assign sub = (op == SUB);
    assign sum = {1'b0, a} + {1'b0, b ^ {4{sub}}} + {4'b0, sub};      // one adder does ADD and SUB

    always_comb begin
        carry = 1'b0;
        unique case (op)
            ADD:  begin y = sum[3:0]; carry = sum[4]; end
            SUB:  begin y = sum[3:0]; carry = sum[4]; end
            AND_: y = a & b;
            OR_:  y = a | b;
            XOR_: y = a ^ b;
            NOT_: y = ~a;
            SHL:  y = a << 1;
            SHR:  y = a >> 1;
        endcase
        res = '{carry: carry, zero: (y == 4'd0), y: y};
    end
endmodule
