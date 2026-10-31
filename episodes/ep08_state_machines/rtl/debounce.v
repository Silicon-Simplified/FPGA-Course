// Silicon Simplified - FPGA Course, Episode 8
// Push-button debouncer as an FSM: 2-flip-flop synchronizer, then a state must stay stable for N clocks before it counts.
// press = one clock pulse per real button press; level = debounced button state.
`timescale 1ns / 1ps
module debounce #(parameter N = 1_000_000) (
    input  wire clk,
    input  wire rst,
    input  wire btn,        // raw, asynchronous, bouncy
    output wire press,
    output wire level
);
    localparam W = $clog2(N);
    localparam [W-1:0] LAST = N[W-1:0] - 1'b1;
    localparam [1:0] IDLE = 2'd0, CHK_P = 2'd1, HELD = 2'd2, CHK_R = 2'd3;
    (* ASYNC_REG = "TRUE" *) reg s1 = 0, s2 = 0;
    always @(posedge clk) begin s1 <= btn; s2 <= s1; end

    reg [1:0] state = IDLE;
    reg [W-1:0] cnt = 0;
    always @(posedge clk) begin
        if (rst) begin state <= IDLE; cnt <= 0; end
        else case (state)
            IDLE:  if (s2) begin state <= CHK_P; cnt <= 0; end
            CHK_P: if (!s2) state <= IDLE;
                   else if (cnt == LAST) state <= HELD;
                   else cnt <= cnt + 1'b1;
            HELD:  if (!s2) begin state <= CHK_R; cnt <= 0; end
            CHK_R: if (s2) state <= HELD;
                   else if (cnt == LAST) state <= IDLE;
                   else cnt <= cnt + 1'b1;
        endcase
    end
    assign press = (state == CHK_P) && s2 && (cnt == LAST);
    assign level = (state == HELD) || (state == CHK_R);
endmodule
