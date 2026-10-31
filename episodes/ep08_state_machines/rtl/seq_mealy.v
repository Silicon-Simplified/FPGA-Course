// Silicon Simplified - FPGA Course, Episode 8
// Detects the bit pattern 1011 (overlapping) - MEALY: the output depends on the state AND the current input.
`timescale 1ns / 1ps
module seq_mealy (input wire clk, input wire rst, input wire din, output wire dout);
    localparam [1:0] S0 = 2'd0, S1 = 2'd1, S10 = 2'd2, S101 = 2'd3;
    reg [1:0] state, next;
    always @(posedge clk) begin
        if (rst) state <= S0; else state <= next;
    end
    always @(*) begin
        case (state)
            S0:      next = din ? S1   : S0;
            S1:      next = din ? S1   : S10;
            S10:     next = din ? S101 : S0;
            default: next = din ? S1   : S10;     // S101: a 1 completes 1011 and is also the start of a new 1
        endcase
    end
    assign dout = (state == S101) && din;
endmodule
