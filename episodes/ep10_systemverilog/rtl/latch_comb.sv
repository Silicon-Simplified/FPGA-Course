// Silicon Simplified - FPGA Course, Episode 10
// always_comb with an incomplete assignment: q is not assigned when en = 0, so a latch would be needed.
// SystemVerilog tools are required to complain; plain Verilog "always @(*)" stays silent.
module latch_comb (input logic en, input logic [3:0] d, output logic [3:0] q);
    always_comb begin
        if (en) q = d;
    end
endmodule
