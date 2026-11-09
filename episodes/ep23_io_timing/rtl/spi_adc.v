// Episode 23 - a minimal SPI reader for a 12-bit ADC (an AD7476-style frame: CS_N low, 16 SCLK cycles, 4 leading zeros then 12 data bits, MSB first).
// SCLK = clk / 16 (7.8 MHz at 125 MHz). The ADC changes SDO after each SCLK falling edge; we sample it just before the rising edge.
module spi_adc (input wire clk, input wire sdo, output wire cs_n, output wire sclk, output wire [3:0] led);
    reg [3:0]  div = 0;
    reg        sclk_r = 0, cs_r = 1;
    reg [5:0]  frame = 0;                 // 0..63 half-periods; the first 32 are active (16 SCLK cycles), the rest idle
    reg        sdo_q = 0;
    reg [15:0] sh = 0;
    reg [11:0] data = 0;
    always @(posedge clk) begin
        sdo_q <= sdo;                     // the input flip-flop: the first register after the pin
        div   <= div + 4'd1;
        if (div == 4'd7) begin            // a half-period of SCLK every 8 clocks
            frame <= frame + 6'd1;
            if (frame < 6'd32) begin
                cs_r   <= 1'b0;
                sclk_r <= ~sclk_r;
                if (sclk_r == 1'b0) sh <= {sh[14:0], sdo_q};   // about to rise: sample
            end else begin
                cs_r   <= 1'b1;
                sclk_r <= 1'b0;
            end
            if (frame == 6'd33) data <= sh[11:0];
        end
    end
    assign cs_n = cs_r;
    assign sclk = sclk_r;
    assign led  = data[11:8];
endmodule
