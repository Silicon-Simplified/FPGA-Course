// Episode 23 - self-checking testbench with a tiny ADC model: after CS_N falls it shifts out {4'b0, 12'hA5C} MSB-first, changing SDO on each SCLK falling edge.
`timescale 1ns/1ps
module tb_spi_adc;
    reg clk = 0; always #4 clk = ~clk;
    wire cs_n, sclk; wire [3:0] led;
    reg sdo = 0;
    reg [15:0] word = {4'b0, 12'hA5C};
    integer bitn = 0;
    spi_adc dut (.clk(clk), .sdo(sdo), .cs_n(cs_n), .sclk(sclk), .led(led));
    always @(negedge cs_n) begin bitn = 0; sdo <= #5 word[15]; end         // first bit appears ~5 ns after CS_N falls
    always @(negedge sclk) if (!cs_n) begin bitn = bitn + 1; sdo <= #5 (bitn < 16) ? word[15 - bitn] : 1'b0; end
    integer k = 0;
    initial begin
        #20000;
        if (dut.data === 12'hA5C && led === 4'hA) $display("PASS: the SPI reader captured 0x%03h from the ADC model (led = %h)", dut.data, led);
        else $display("FAIL: data = 0x%03h, expected 0xA5C", dut.data);
        $finish;
    end
endmodule
