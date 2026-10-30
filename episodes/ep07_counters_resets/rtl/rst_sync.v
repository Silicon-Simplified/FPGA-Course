// Silicon Simplified - FPGA Course, Episode 7
// Reset synchronizer: asserts ASYNCHRONOUSLY (immediately), releases SYNCHRONOUSLY (aligned to clk).
`timescale 1ns / 1ps
module rst_sync (
    input  wire clk,
    input  wire arst,      // asynchronous, active-high reset request (a button, a PLL "not locked", ...)
    output wire srst       // active-high reset, safe to use as a synchronous reset
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] ff = 2'b11;
    always @(posedge clk or posedge arst) begin
        if (arst) ff <= 2'b11;
        else      ff <= {ff[0], 1'b0};
    end
    assign srst = ff[1];
endmodule
