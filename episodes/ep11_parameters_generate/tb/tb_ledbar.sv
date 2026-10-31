// Exhaustive test of the generate-for LED bar at three sizes: thermometer code for every level.
`timescale 1ns / 1ps
module tb_ledbar;
    logic [3:0] l8;   logic [4:0] l16;  logic [5:0] l32;
    logic [7:0] o8;   logic [15:0] o16; logic [31:0] o32;
    int errors = 0, vecs = 0;
    led_bar #(.N(8))  d8  (.level(l8),  .leds(o8));
    led_bar #(.N(16)) d16 (.level(l16), .leds(o16));
    led_bar #(.N(32)) d32 (.level(l32), .leds(o32));
    initial begin
        for (int k = 0; k <= 8;  k++) begin l8  = k; #1; vecs++; if (o8  !== 8'((1 << k) - 1))   errors++; end
        for (int k = 0; k <= 16; k++) begin l16 = k; #1; vecs++; if (o16 !== 16'((1 << k) - 1))  errors++; end
        for (int k = 0; k <= 32; k++) begin l32 = k; #1; vecs++; if (o32 !== 32'((64'd1 << k) - 1)) errors++; end
        $display("LEDBAR vectors=%0d errors=%0d", vecs, errors);
        if (errors == 0) $display("PASS: LED bar lights exactly `level` LEDs for N = 8, 16, 32");
        else $display("FAILED");
        $finish;
    end
endmodule
