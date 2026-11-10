// Episode 30 - a UART from scratch: 8 data bits, no parity, 1 stop bit (8N1).

// A tick 16 times per bit: one pulse every round(CLK_HZ / (BAUD * 16)) clocks.
module baud_gen #(parameter CLK_HZ = 125_000_000, BAUD = 115_200) (input wire clk, output reg tick16 = 0);
    localparam DIV = (CLK_HZ + (BAUD * 8)) / (BAUD * 16);          // rounded to the nearest integer
    reg [15:0] cnt = 0;
    always @(posedge clk) begin
        if (cnt == DIV - 1) begin cnt <= 0; tick16 <= 1; end
        else begin cnt <= cnt + 1; tick16 <= 0; end
    end
endmodule

module uart_tx (input wire clk, input wire tick16, input wire start, input wire [7:0] data, output reg tx = 1, output wire busy);
    reg [3:0] sub = 0; reg [3:0] bitn = 0; reg [9:0] sh = 10'h3FF; reg active = 0;
    assign busy = active;
    always @(posedge clk) begin
        if (!active) begin
            if (start) begin sh <= {1'b1, data, 1'b0}; active <= 1; sub <= 0; bitn <= 0; end     // stop, data (LSB first), start
        end else if (tick16) begin
            if (sub == 4'd0) begin tx <= sh[0]; sh <= {1'b1, sh[9:1]}; end
            sub <= sub + 1'b1;
            if (sub == 4'd15) begin
                bitn <= bitn + 1'b1;
                if (bitn == 4'd9) begin active <= 0; tx <= 1; end
            end
        end
    end
endmodule

// 16x oversampling receiver: find the falling edge of the start bit, wait half a bit, then sample every 16 ticks.
module uart_rx (input wire clk, input wire tick16, input wire rx, output reg [7:0] data = 0, output reg valid = 0, output reg frame_err = 0);
    (* ASYNC_REG = "TRUE" *) reg r1 = 1, r2 = 1;
    always @(posedge clk) begin r1 <= rx; r2 <= r1; end
    reg [3:0] sub = 0; reg [3:0] bitn = 0; reg [7:0] sh = 0; reg busy = 0;
    always @(posedge clk) begin
        valid <= 0;
        if (!busy) begin
            if (!r2) begin busy <= 1; sub <= 0; bitn <= 0; end                           // start bit seen (the edge, not yet verified at its middle)
        end else if (tick16) begin
            sub <= sub + 1'b1;
            if (bitn == 0 && sub == 4'd7) begin
                if (r2) busy <= 0;                                                       // glitch: start bit is gone at its middle
                else begin sub <= 0; bitn <= 1; end                                      // re-align on the middle of the start bit
            end else if (bitn != 0 && sub == 4'd15) begin
                if (bitn <= 8) begin sh <= {r2, sh[7:1]}; bitn <= bitn + 1'b1; end
                else begin data <= sh; valid <= 1; frame_err <= !r2; busy <= 0; end      // stop bit: must be high
            end
        end
    end
endmodule

module uart_top #(parameter CLK_HZ = 125_000_000, BAUD = 115_200) (input wire clk, input wire rx, output wire tx, output wire [3:0] led);
    wire t16; baud_gen #(CLK_HZ, BAUD) g (.clk(clk), .tick16(t16));
    wire [7:0] rdata; wire rvalid, ferr;
    uart_rx r (.clk(clk), .tick16(t16), .rx(rx), .data(rdata), .valid(rvalid), .frame_err(ferr));
    // echo: every received byte is sent back (and the low bits are shown on the LEDs)
    reg start = 0; reg [7:0] txd = 0; wire busy;
    always @(posedge clk) begin start <= 0; if (rvalid && !busy) begin txd <= rdata; start <= 1; end end
    uart_tx t (.clk(clk), .tick16(t16), .start(start), .data(txd), .tx(tx), .busy(busy));
    assign led = rdata[3:0];
endmodule
