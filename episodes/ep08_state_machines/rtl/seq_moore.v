// Silicon Simplified - FPGA Course, Episode 8
// The same detector as a MOORE machine: the output depends on the state only, so it needs one more state and answers one clock later.
`timescale 1ns / 1ps
module seq_moore (input wire clk, input wire rst, input wire din, output wire dout);
    localparam [2:0] S0 = 3'd0, S1 = 3'd1, S10 = 3'd2, S101 = 3'd3, S1011 = 3'd4;
    reg [2:0] state, next;
    always @(posedge clk) begin
        if (rst) state <= S0; else state <= next;
    end
    always @(*) begin
        case (state)
            S0:      next = din ? S1    : S0;
            S1:      next = din ? S1    : S10;
            S10:     next = din ? S101  : S0;
            S101:    next = din ? S1011 : S10;
            default: next = din ? S1    : S10;    // S1011
        endcase
    end
    assign dout = (state == S1011);
endmodule
