// Silicon Simplified - FPGA Course, Episode 10
// A package: shared types for every module that talks to the ALU.
package alu_pkg;
    typedef enum logic [2:0] {ADD, SUB, AND_, OR_, XOR_, NOT_, SHL, SHR} op_t;      // same codes as Episodes 5 and 9
    typedef struct packed {
        logic       carry;
        logic       zero;
        logic [3:0] y;
    } res_t;
endpackage
