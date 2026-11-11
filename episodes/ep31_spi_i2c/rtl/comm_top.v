// Episode 31 - both masters on the PYNQ-Z2: every ~0.1 s an SPI byte is sent and an I2C write (device 0x50, register 0) is made. The I2C pins are open-drain (tri-state buffers).
module comm_top (input wire clk, output wire spi_cs_n, output wire spi_sclk, output wire spi_mosi, input wire spi_miso, inout wire i2c_scl, inout wire i2c_sda, output wire [3:0] led);
    // slow tick: about 10 per second
    reg [23:0] tcnt = 0; wire tick = (tcnt == 24'd12_499_999);
    always @(posedge clk) tcnt <= tick ? 24'd0 : tcnt + 1'b1;
    reg [7:0] counter = 0; always @(posedge clk) if (tick) counter <= counter + 1'b1;
    // SPI (mode 0, SCLK = 125 MHz / 24 = 5.2 MHz)
    wire [7:0] spi_rx; wire spi_busy, spi_done;
    spi_master #(12, 0, 0) spi (.clk(clk), .start(tick), .tx(counter), .rx(spi_rx), .busy(spi_busy), .done(spi_done), .sclk(spi_sclk), .mosi(spi_mosi), .miso(spi_miso), .cs_n(spi_cs_n));
    // I2C write: START, 0xA0, 0x00, counter, STOP
    wire scl_low, sda_low, i2c_busy, i2c_done, i2c_ack; wire [7:0] i2c_rd;
    reg cv = 0; reg [2:0] cmd = 0; reg [7:0] wd = 0; reg [2:0] step = 0; reg run = 0;
    i2c_master #(312) i2c (.clk(clk), .cmd_valid(cv), .cmd(cmd), .wdata(wd), .nack_in(1'b0), .rdata(i2c_rd), .ack_out(i2c_ack), .busy(i2c_busy), .done(i2c_done), .scl_low(scl_low), .sda_low(sda_low), .sda_in(i2c_sda));
    reg last_ack = 0;
    always @(posedge clk) begin
        cv <= 0;
        if (tick) begin run <= 1; step <= 0; end
        else if (run && !i2c_busy && !cv) begin
            case (step)
                0: begin cmd <= 3'd1; cv <= 1; step <= 1; end
                1: begin cmd <= 3'd2; wd <= 8'hA0; cv <= 1; step <= 2; end
                2: begin cmd <= 3'd2; wd <= 8'h00; cv <= 1; step <= 3; end
                3: begin cmd <= 3'd2; wd <= counter; cv <= 1; step <= 4; end
                4: begin cmd <= 3'd4; cv <= 1; step <= 5; end
                default: run <= 0;
            endcase
        end
        if (i2c_done) last_ack <= i2c_ack;
    end
    assign i2c_scl = scl_low ? 1'b0 : 1'bz;
    assign i2c_sda = sda_low ? 1'b0 : 1'bz;
    assign led = {last_ack, spi_busy, i2c_busy, spi_rx[0]};
endmodule
