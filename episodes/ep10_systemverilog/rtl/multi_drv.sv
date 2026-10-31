// Silicon Simplified - FPGA Course, Episode 10
// Two always_ff blocks driving the same variable. always_ff / always_comb promise ONE driver per variable.
module multi_drv (input logic clk, input logic a, b, output logic q);
    always_ff @(posedge clk) q <= a;
    always_ff @(posedge clk) q <= b;
endmodule
