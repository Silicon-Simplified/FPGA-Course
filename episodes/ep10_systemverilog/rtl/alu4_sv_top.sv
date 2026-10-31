// Silicon Simplified - FPGA Course, Episode 10
// Flat-port wrapper for synthesizing alu4_sv.
module alu4_sv_top (input logic [3:0] a, b, input logic [2:0] op, output logic [5:0] res);
    alu_pkg::res_t r;
    alu4_sv u (.a(a), .b(b), .op(alu_pkg::op_t'(op)), .res(r));
    assign res = r;
endmodule
