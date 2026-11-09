// Episode 24 - two classic mistakes. clk_a = 250 MHz, clk_b = 62.5 MHz (both from one MMCM, declared asynchronous).
module cdc_bad (input wire clk, output wire [3:0] led);
    wire clk_a, clk_b;
    clk_gen g (.clk(clk), .clk_a(clk_a), .clk_b(clk_b));
    reg [7:0] cnt_a = 0;
    always @(posedge clk_a) cnt_a <= cnt_a + 8'd1;
    wire flag_a = cnt_a[7];                     // a 1-bit signal ...
    reg  flag_b = 0;
    always @(posedge clk_b) flag_b <= flag_a;   // ... crossing with ONE flip-flop: mistake 1
    reg [7:0] bus_b = 0;
    always @(posedge clk_b) bus_b <= cnt_a;     // an 8-bit bus crossing with no protection: mistake 2
    assign led = {flag_b, bus_b[7], bus_b[1], bus_b[0]};
endmodule
