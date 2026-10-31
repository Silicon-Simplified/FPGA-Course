// Silicon Simplified - FPGA Course, Episode 8
// An 8-state controller used to compare state ENCODINGS. scripts/synth_all.tcl rewrites the fsm_encoding value
// ("auto" -> one_hot / sequential / gray / johnson / none) and reports what Vivado builds.
`timescale 1ns / 1ps
module fsm8 (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] x,
    output reg  [2:0] y
);
    localparam [2:0] A = 3'd0, B = 3'd1, C = 3'd2, D = 3'd3, E = 3'd4, F = 3'd5, G = 3'd6, H = 3'd7;
    (* fsm_encoding = "auto" *) reg [2:0] state;
    always @(posedge clk) begin
        if (rst) state <= A;
        else case (state)
            A: state <= x[0] ? B : x[1] ? C : A;
            B: state <= x[1] ? D : A;
            C: state <= x[0] ? E : F;
            D: state <= x[0] ? G : B;
            E: state <= x[1] ? H : C;
            F: state <= x[0] ? A : G;
            G: state <= x[1] ? H : D;
            H: state <= x[0] ? A : E;
        endcase
    end
    // Moore outputs: an arbitrary code per state (NOT equal to the state number, so the outputs need real decode logic)
    always @(*) begin
        case (state)
            A: y = 3'd0;  B: y = 3'd5;  C: y = 3'd3;  D: y = 3'd6;
            E: y = 3'd1;  F: y = 3'd7;  G: y = 3'd2;  default: y = 3'd4;
        endcase
    end
endmodule
