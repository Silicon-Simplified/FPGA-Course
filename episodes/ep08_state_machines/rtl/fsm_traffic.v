// Silicon Simplified - FPGA Course, Episode 8
// Moore traffic-light controller in the classic THREE-PROCESS style:
//   1) state register   2) next-state logic   3) output logic
`timescale 1ns / 1ps
module fsm_traffic #(parameter G = 5, Y = 2) (
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,          // advance the timer once per tick
    output reg  [5:0] lights         // {ns_r, ns_y, ns_g, ew_r, ew_y, ew_g}
);
    localparam [1:0] NS_G = 2'd0, NS_Y = 2'd1, EW_G = 2'd2, EW_Y = 2'd3;
    reg [1:0] state, next;
    reg [3:0] timer;

    // 1) state register
    always @(posedge clk) begin
        if (rst) state <= NS_G;
        else     state <= next;
    end
    // timer: restarts whenever the state changes
    always @(posedge clk) begin
        if (rst || next != state) timer <= 4'd0;
        else if (tick)            timer <= timer + 4'd1;
    end
    // 2) next-state logic
    always @(*) begin
        next = state;
        case (state)
            NS_G: if (tick && timer == G - 1) next = NS_Y;
            NS_Y: if (tick && timer == Y - 1) next = EW_G;
            EW_G: if (tick && timer == G - 1) next = EW_Y;
            EW_Y: if (tick && timer == Y - 1) next = NS_G;
        endcase
    end
    // 3) output logic (Moore: depends on the state only)
    always @(*) begin
        case (state)
            NS_G:    lights = 6'b001_100;
            NS_Y:    lights = 6'b010_100;
            EW_G:    lights = 6'b100_001;
            default: lights = 6'b100_010;
        endcase
    end
endmodule
