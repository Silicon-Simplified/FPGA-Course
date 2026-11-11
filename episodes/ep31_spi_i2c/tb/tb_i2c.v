// Episode 31 - the I2C master against a slave model (7-bit address 0x50, 16 byte-wide registers, auto-incrementing pointer).
`timescale 1ns/1ps
module tb_i2c;
    reg clk = 0; always #4 clk = ~clk;
    // open-drain bus: a line is low if anyone pulls it low
    wire m_scl_low, m_sda_low; reg s_sda_low = 0;
    wire scl = ~m_scl_low;
    wire sda = ~(m_sda_low | s_sda_low);
    reg cmd_valid = 0; reg [2:0] cmd = 0; reg [7:0] wdata = 0; reg nack_in = 0; wire [7:0] rdata; wire ack_out, busy, done;
    i2c_master #(312) m (.clk(clk), .cmd_valid(cmd_valid), .cmd(cmd), .wdata(wdata), .nack_in(nack_in), .rdata(rdata), .ack_out(ack_out), .busy(busy), .done(done),
                         .scl_low(m_scl_low), .sda_low(m_sda_low), .sda_in(sda));
    // ---------------- slave model ----------------
    // nclk counts SCL rising edges inside a byte (1..8 data bits, 9 = the acknowledge slot). The slave changes SDA only while SCL is low.
    reg [7:0] regs [0:15]; reg [7:0] ptr = 0, shin = 0, shout = 0;
    integer sst = 0;                    // 0 idle (ignoring), 1 address byte, 2 register pointer, 3 write data, 4 read data
    integer nclk = 0, got_start = 0, got_stop = 0; reg rw = 0, master_ack = 0, addr_ok = 0;
    initial begin : init integer i; for (i = 0; i < 16; i = i + 1) regs[i] = 8'h00; end
    always @(negedge sda) if (scl) begin sst = 1; nclk = 0; shin = 0; s_sda_low = 0; got_start = got_start + 1; end      // START (also a repeated START)
    always @(posedge sda) if (scl) begin sst = 0; s_sda_low = 0; got_stop = got_stop + 1; end                           // STOP
    always @(posedge scl) if (sst != 0) begin
        nclk = nclk + 1;
        if (nclk <= 8) begin if (sst != 4) shin = {shin[6:0], sda}; end
        else if (sst == 4) master_ack = sda == 1'b0;                                                                    // the master's ACK / NACK
    end
    always @(negedge scl) if (sst != 0) begin
        if (nclk >= 1 && nclk <= 7 && sst == 4) s_sda_low = ~shout[7 - nclk];                                           // next read bit
        else if (nclk == 8) begin
            if (sst == 4) s_sda_low = 0;                                                                                // release SDA for the master's ACK
            else begin
                case (sst)
                    1: begin addr_ok = (shin[7:1] == 7'h50); rw = shin[0]; end
                    2: begin ptr = shin; addr_ok = 1; end
                    3: begin regs[ptr[3:0]] = shin; ptr = ptr + 1; addr_ok = 1; end
                endcase
                if (addr_ok) s_sda_low = 1; else begin sst = 0; end                                                     // ACK, or ignore the rest
            end
        end else if (nclk == 9) begin
            nclk = 0; shin = 0;
            if (sst == 4) begin
                if (master_ack) begin ptr = ptr + 1; shout = regs[ptr[3:0]]; s_sda_low = ~shout[7]; end              // another byte follows
                else begin sst = 0; s_sda_low = 0; end                                                                  // NACK: the master is done
            end else begin
                s_sda_low = 0;
                if (sst == 1) begin if (rw) begin sst = 4; shout = regs[ptr[3:0]]; s_sda_low = ~shout[7]; end else sst = 2; end
                else if (sst == 2) sst = 3;
            end
        end
    end
    // ---------------- test sequence ----------------
    task run(input [2:0] c, input [7:0] w, input nk); begin @(negedge clk); cmd = c; wdata = w; nack_in = nk; cmd_valid = 1; @(negedge clk); cmd_valid = 0; wait (done); @(negedge clk); end endtask
    integer i, errs = 0, k; time t_scl0, t_scl1, t_tx0, t_tx1; integer ncl = 0; integer nack_seen = 0;
    always @(posedge scl) ncl = ncl + 1;
    initial begin
        repeat (20) @(negedge clk);
        t_tx0 = $time;
        // write 4 bytes to registers 0x04..0x07: START, 0xA0 (addr 0x50 + W), reg pointer, data x4, STOP
        run(1, 0, 0); run(2, 8'hA0, 0); if (!ack_out) errs = errs + 1;
        run(2, 8'h04, 0); if (!ack_out) errs = errs + 1;
        for (k = 0; k < 4; k = k + 1) begin run(2, 8'h11 * (k + 1), 0); if (!ack_out) errs = errs + 1; end
        run(4, 0, 0);
        t_tx1 = $time;
        // read them back: write the pointer, repeated START, address + R, read 4 bytes (NACK the last), STOP
        run(1, 0, 0); run(2, 8'hA0, 0); run(2, 8'h04, 0); run(1, 0, 0); run(2, 8'hA1, 0); if (!ack_out) errs = errs + 1;
        for (k = 0; k < 4; k = k + 1) begin run(3, 0, (k == 3)); if (rdata !== 8'h11 * (k + 1)) errs = errs + 1; $display("I2C read reg[%0d] = %h", 4 + k, rdata); end
        run(4, 0, 0);
        // wrong address: expect a NACK
        run(1, 0, 0); run(2, 8'hA2, 0); nack_seen = !ack_out; run(4, 0, 0);
        $display("I2C write 4 bytes: %0d errors (all ACKs seen); transaction took %0d us", errs, (t_tx1 - t_tx0) / 1000);
        $display("I2C readback errors in total: %0d", errs);
        $display("I2C wrong address 0x51: NACK seen = %0d", nack_seen);
        $display("I2C starts seen by the slave: %0d, stops: %0d, SCL pulses: %0d, SCL = clk / (4*312) = %0d Hz", got_start, got_stop, ncl, 125000000 / 1248);
        $finish;
    end
    initial begin #50000000; $display("I2C TIMEOUT"); $finish; end
endmodule
