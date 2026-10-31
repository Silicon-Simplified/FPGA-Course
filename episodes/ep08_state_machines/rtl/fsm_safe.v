// Silicon Simplified - FPGA Course, Episode 8
// The same ring with a SAFE default: any illegal state returns to S0 on the next clock.
`timescale 1ns / 1ps
module fsm_safe (input wire clk, input wire rst, input wire go, output wire busy);
    localparam [2:0] S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
    (* fsm_encoding = "none" *) reg [2:0] state;
    always @(posedge clk) begin
        if (rst) state <= S0;
        else case (state)
            S0: if (go) state <= S1;
            S1: state <= S2;
            S2: state <= S3;
            S3: state <= S4;
            S4: state <= S0;
            default: state <= S0;               // recover from illegal states
        endcase
    end
    assign busy = (state != S0);
endmodule
