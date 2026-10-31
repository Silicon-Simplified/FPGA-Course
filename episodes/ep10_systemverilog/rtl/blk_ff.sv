// Silicon Simplified - FPGA Course, Episode 10
// always_ff with BLOCKING assignments (the Episode 6 bug). The keyword says "flip-flops", so lint can flag the "=".
module blk_ff (input logic clk, input logic d, output logic q1, q2);
    always_ff @(posedge clk) begin
        q1 = d;
        q2 = q1;
    end
endmodule
