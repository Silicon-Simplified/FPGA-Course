// Silicon Simplified - FPGA Course, Episode 10
// The Episode 8 traffic light rewritten in SystemVerilog: enum states, always_ff / always_comb, unique case.
module fsm_traffic_sv #(parameter int G = 5, Y = 2) (
    input  logic       clk,
    input  logic       rst,
    input  logic       tick,
    output logic [5:0] lights       // {ns_r, ns_y, ns_g, ew_r, ew_y, ew_g}
);
    typedef enum logic [1:0] {NS_G, NS_Y, EW_G, EW_Y} state_t;
    state_t     state, next;
    logic [3:0] timer;

    always_ff @(posedge clk) begin
        if (rst) state <= NS_G;
        else     state <= next;
    end
    always_ff @(posedge clk) begin
        if (rst || next != state) timer <= '0;
        else if (tick)            timer <= timer + 4'd1;
    end
    always_comb begin
        next = state;
        unique case (state)
            NS_G: if (tick && timer == 4'(G - 1)) next = NS_Y;
            NS_Y: if (tick && timer == 4'(Y - 1)) next = EW_G;
            EW_G: if (tick && timer == 4'(G - 1)) next = EW_Y;
            EW_Y: if (tick && timer == 4'(Y - 1)) next = NS_G;
        endcase
    end
    always_comb begin
        unique case (state)
            NS_G: lights = 6'b001_100;
            NS_Y: lights = 6'b010_100;
            EW_G: lights = 6'b100_001;
            EW_Y: lights = 6'b100_010;
        endcase
    end
endmodule
