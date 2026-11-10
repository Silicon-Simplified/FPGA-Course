// A fast baud rate: DUT at BAUD = 921600 with a real 921600-baud transmitter (bit time 1085.069 ns); the divider rounds 8.477 to 8.
`timescale 1ns/1ps
module tb_hi;
    reg clk = 0; always #4 clk = ~clk;
    wire t16; baud_gen #(125_000_000, 921_600) g (.clk(clk), .tick16(t16));
    reg line = 1; wire [7:0] d; wire v, fe;
    uart_rx r (.clk(clk), .tick16(t16), .rx(line), .data(d), .valid(v), .frame_err(fe));
    reg [7:0] got; always @(posedge clk) if (v) got <= d;
    integer n, bad = 0, j; reg [7:0] b; real bit_ns = 1e9 / 921600.0;
    initial begin
        repeat (20) @(negedge clk);
        for (n = 0; n < 200; n = n + 1) begin
            b = (n * 37 + 11) & 8'hFF;
            line = 0; #(bit_ns); for (j = 0; j < 8; j = j + 1) begin line = b[j]; #(bit_ns); end line = 1; #(bit_ns); #(bit_ns); repeat (4) @(negedge clk);
            if (got !== b) bad = bad + 1;
        end
        $display("HIBAUD 921600: divider=%0d actual_baud=%0d bad_bytes=%0d of 200", (125_000_000 + 921_600 * 8) / (921_600 * 16), 125_000_000 / (((125_000_000 + 921_600 * 8) / (921_600 * 16)) * 16), bad);
        $finish;
    end
endmodule
