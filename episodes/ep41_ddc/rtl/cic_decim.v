// Episode 41 - CIC decimator: 3 integrators at the input rate, decimation by 50, 3 combs at the output rate. No multipliers. Registers use wrap-around arithmetic (W = 33 bits: 16 + 3 x log2(50) rounded up; a smaller W is the planted bug of the testbench).
// Gain = 50^3 = 125000; the output keeps bits [32:17] (a gain of 0.954).
module cic_decim #(parameter W = 33) (input wire clk, input wire rst, input wire signed [15:0] din, output reg signed [15:0] dout, output reg dvalid);
    reg signed [W-1:0] i1, i2, i3, z1, z2, z3;
    reg [5:0] cnt;
    wire signed [W-1:0] c1 = i3 - z1;
    wire signed [W-1:0] c2 = c1 - z2;
    wire signed [W-1:0] c3 = c2 - z3;
    wire strobe = (cnt == 6'd49);
    always @(posedge clk)
        if (rst) begin i1 <= 0; i2 <= 0; i3 <= 0; z1 <= 0; z2 <= 0; z3 <= 0; cnt <= 0; dout <= 0; dvalid <= 0; end
        else begin
            i1 <= i1 + din;                      // sign-extended
            i2 <= i2 + i1;
            i3 <= i3 + i2;
            cnt <= strobe ? 6'd0 : cnt + 6'd1;
            dvalid <= strobe;
            if (strobe) begin z1 <= i3; z2 <= c1; z3 <= c2; dout <= c3[W-1:W-16]; end
        end
endmodule
