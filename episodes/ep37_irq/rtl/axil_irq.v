// Episode 37 - a button interrupt controller with an AXI4-Lite slave: 4 buttons -> synchronizer -> debounce -> press event -> pending bit -> (pending & enable) -> level interrupt.
//   0x00 RAW     [3:0] debounced button state (read-only)      0x0C COUNT   32-bit number of press events since reset (read-only)
//   0x04 PENDING [3:0] events not yet acknowledged; write 1 to a bit to clear it (W1C)    0x10 ID read-only 0x49525101
//   0x08 ENABLE  [3:0] interrupt mask
// irq is a LEVEL: it stays high while any enabled pending bit is set, until software acknowledges it.
// DEB = clocks a button must be stable (10 ms = 1,000,000 clocks at 100 MHz). NODEB = 1 and W1CALL = 1 are the two bugs used only by the testbench.
module axil_irq #(parameter DEB = 1000000, parameter NODEB = 0, parameter W1CALL = 0) (
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
    input  wire [3:0]  btn,
    output wire        irq
);
    wire clk = s_axi_aclk;
    // ---- buttons: 2-flop synchronizer, then "stable for DEB clocks" ----
    reg [3:0] s1, s2, stable, prev; reg [31:0] dcnt [0:3];
    integer k;
    always @(posedge clk)
        if (!s_axi_aresetn) begin s1 <= 0; s2 <= 0; stable <= 0; prev <= 0; for (k = 0; k < 4; k = k + 1) dcnt[k] <= 0; end
        else begin
            s1 <= btn; s2 <= s1; prev <= stable;
            for (k = 0; k < 4; k = k + 1)
                if (NODEB != 0) stable[k] <= s2[k];
                else if (s2[k] == stable[k]) dcnt[k] <= 0;
                else if (dcnt[k] == DEB - 1) begin stable[k] <= s2[k]; dcnt[k] <= 0; end
                else dcnt[k] <= dcnt[k] + 1;
        end
    wire [3:0] press = stable & ~prev;

    // ---- registers ----
    reg [3:0] pending, enable; reg [31:0] count;
    reg aw_got, w_got; reg [4:0] aw_q; reg [31:0] w_d;
    assign s_axi_awready = !aw_got && !s_axi_bvalid;
    assign s_axi_wready  = !w_got  && !s_axi_bvalid;
    assign s_axi_bresp = 2'b00;  assign s_axi_rresp = 2'b00;
    wire do_write = aw_got && w_got;
    wire [3:0] clr = (do_write && aw_q[4:2] == 3'd1) ? ((W1CALL != 0) ? 4'hF : w_d[3:0]) : 4'h0;
    always @(posedge clk)
        if (!s_axi_aresetn) begin aw_got <= 0; w_got <= 0; s_axi_bvalid <= 0; pending <= 0; enable <= 0; count <= 0; end
        else begin
            if (s_axi_awvalid && s_axi_awready) begin aw_got <= 1; aw_q <= s_axi_awaddr; end
            if (s_axi_wvalid && s_axi_wready)   begin w_got <= 1; w_d <= s_axi_wdata; end
            if (do_write) begin
                aw_got <= 0; w_got <= 0; s_axi_bvalid <= 1;
                if (aw_q[4:2] == 3'd2) enable <= w_d[3:0];
            end
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 0;
            pending <= (pending & ~clr) | press;                      // a new press wins over a simultaneous clear: no event is lost
            count   <= count + press[0] + press[1] + press[2] + press[3];
        end
    assign s_axi_arready = !s_axi_rvalid;
    always @(posedge clk)
        if (!s_axi_aresetn) begin s_axi_rvalid <= 0; s_axi_rdata <= 0; end
        else begin
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1;
                case (s_axi_araddr[4:2])
                    3'd0: s_axi_rdata <= {28'd0, stable};  3'd1: s_axi_rdata <= {28'd0, pending}; 3'd2: s_axi_rdata <= {28'd0, enable};
                    3'd3: s_axi_rdata <= count;            default: s_axi_rdata <= 32'h49525101;
                endcase
            end
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 0;
        end
    assign irq = |(pending & enable);
endmodule
