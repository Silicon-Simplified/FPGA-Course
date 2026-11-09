// Episode 22 - one enable bit drives 3000 flip-flops (high fanout).
module fanout_demo (input wire clk, input wire din, output wire dout);
    reg en = 0, d2 = 0;
    always @(posedge clk) begin en <= din; d2 <= ~din; end
    (* shreg_extract = "no" *) reg [2999:0] q = 0;     // keep them as flip-flops (no shift-register LUTs)
    always @(posedge clk) if (en) q <= {q[2998:0], d2};
    reg x = 0;
    always @(posedge clk) x <= ^q[2999:2900];
    assign dout = x;
endmodule
