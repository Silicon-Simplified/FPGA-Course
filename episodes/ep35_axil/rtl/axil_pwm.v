// Episode 35 - a 4-channel PWM controller with an AXI4-Lite slave interface (32-bit data, 8 registers).
//   0x00 CTRL    bit 0 = enable                     0x14 DUTY3   [15:0]
//   0x04 PERIOD  clocks per PWM period (reset 1000)  0x18 COUNT   read-only: the free-running period counter
//   0x08 DUTY0   [15:0] high time in clocks          0x1C ID      read-only: 0x50574D01
//   0x0C DUTY1   0x10 DUTY2
// STRB = 0 and CAPTURE = 0 are two bugs used only by the testbench (ignore byte strobes / use the address live instead of the captured one).
module axil_pwm #(parameter STRB = 1, parameter CAPTURE = 1) (
    input  wire        s_axi_aclk,
    input  wire        s_axi_aresetn,
    input  wire [4:0]  s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output reg         s_axi_bvalid,
    input  wire        s_axi_bready,
    input  wire [4:0]  s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready,
    output wire [3:0]  pwm
);
    reg [31:0] ctrl, period, duty0, duty1, duty2, duty3;
    reg [15:0] cnt;
    wire clk = s_axi_aclk;

    // ---- write channel: AW and W are accepted independently, in either order, then one response ----
    reg aw_got, w_got; reg [4:0] aw_q; reg [31:0] w_d; reg [3:0] w_s;
    assign s_axi_awready = !aw_got && !s_axi_bvalid;
    assign s_axi_wready  = !w_got  && !s_axi_bvalid;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_rresp   = 2'b00;
    wire do_write = aw_got && w_got;
    wire [4:0] waddr = (CAPTURE != 0) ? aw_q : s_axi_awaddr;
    wire [3:0] wst   = (STRB != 0) ? w_s : 4'hF;
    function [31:0] merge(input [31:0] old, input [31:0] nw, input [3:0] st);
        merge = {st[3] ? nw[31:24] : old[31:24], st[2] ? nw[23:16] : old[23:16], st[1] ? nw[15:8] : old[15:8], st[0] ? nw[7:0] : old[7:0]};
    endfunction
    always @(posedge clk)
        if (!s_axi_aresetn) begin
            aw_got <= 0; w_got <= 0; s_axi_bvalid <= 0; ctrl <= 0; period <= 32'd1000; duty0 <= 0; duty1 <= 0; duty2 <= 0; duty3 <= 0;
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin aw_got <= 1; aw_q <= s_axi_awaddr; end
            if (s_axi_wvalid && s_axi_wready)   begin w_got <= 1; w_d <= s_axi_wdata; w_s <= s_axi_wstrb; end
            if (do_write) begin
                aw_got <= 0; w_got <= 0; s_axi_bvalid <= 1;
                case (waddr[4:2])
                    3'd0: ctrl   <= merge(ctrl,   w_d, wst);
                    3'd1: period <= merge(period, w_d, wst);
                    3'd2: duty0  <= merge(duty0,  w_d, wst);
                    3'd3: duty1  <= merge(duty1,  w_d, wst);
                    3'd4: duty2  <= merge(duty2,  w_d, wst);
                    3'd5: duty3  <= merge(duty3,  w_d, wst);
                    default: ;                                   // COUNT and ID are read-only: the write is accepted and ignored
                endcase
            end
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 0;
        end

    // ---- read channel ----
    assign s_axi_arready = !s_axi_rvalid;
    always @(posedge clk)
        if (!s_axi_aresetn) begin s_axi_rvalid <= 0; s_axi_rdata <= 0; end
        else begin
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1;
                case (s_axi_araddr[4:2])
                    3'd0: s_axi_rdata <= ctrl;   3'd1: s_axi_rdata <= period; 3'd2: s_axi_rdata <= duty0; 3'd3: s_axi_rdata <= duty1;
                    3'd4: s_axi_rdata <= duty2;  3'd5: s_axi_rdata <= duty3;  3'd6: s_axi_rdata <= {16'd0, cnt}; default: s_axi_rdata <= 32'h50574D01;
                endcase
            end
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 0;
        end

    // ---- the PWM itself ----
    always @(posedge clk)
        if (!s_axi_aresetn || !ctrl[0]) cnt <= 0;
        else cnt <= (cnt + 16'd1 >= period[15:0]) ? 16'd0 : cnt + 16'd1;
    assign pwm = {4{ctrl[0]}} & {cnt < duty3[15:0], cnt < duty2[15:0], cnt < duty1[15:0], cnt < duty0[15:0]};
endmodule
