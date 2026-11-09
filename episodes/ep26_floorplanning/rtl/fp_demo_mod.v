// Episode 26 - four identical processing lanes that share nothing but the clock and the input bit. Good material for floorplanning.
// Each lane: a 256-bit shift register of input words, an 8-word adder tree in two pipeline stages, an output register.
module lane #(parameter SEED = 0) (input wire clk, input wire din, output wire dout);
    reg [255:0] sh = 0;
    always @(posedge clk) sh <= {sh[254:0], din ^ SEED[0]};
    reg [34:0] s1_0 = 0, s1_1 = 0, s1_2 = 0, s1_3 = 0;
    always @(posedge clk) begin
        s1_0 <= sh[31:0]    + sh[63:32];
        s1_1 <= sh[95:64]   + sh[127:96];
        s1_2 <= sh[159:128] + sh[191:160];
        s1_3 <= sh[223:192] + sh[255:224];
    end
    reg [37:0] s2 = 0;
    always @(posedge clk) s2 <= s1_0 + s1_1 + s1_2 + s1_3;
    reg x = 0;
    always @(posedge clk) x <= ^s2;
    assign dout = x;
endmodule

module fp_demo (input wire clk, input wire din, output wire [3:0] led);
    wire [3:0] o;
    lane #(0) l0 (.clk(clk), .din(din), .dout(o[0]));
    lane #(1) l1 (.clk(clk), .din(din), .dout(o[1]));
    lane #(2) l2 (.clk(clk), .din(din), .dout(o[2]));
    lane #(2) l3 (.clk(clk), .din(din), .dout(o[3]));
    assign led = o;
endmodule
