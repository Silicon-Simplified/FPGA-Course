// Episode 33 - a one-register AXI-Stream stage: out = in + K. A transfer happens on a clock edge where tvalid AND tready are both 1.
// HOLD = 1 (correct): the stage is ready when its output register is empty or being emptied, so it never loses a word and runs at 1 word per clock.
// HOLD = 0 (the bug we plant in the testbench): tready is always 1, so a word is overwritten when the sink is not ready.
module axis_add #(parameter K = 1, parameter HOLD = 1) (
    input  wire        aclk,
    input  wire        aresetn,
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    output reg  [31:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);
    assign s_axis_tready = (HOLD != 0) ? (!m_axis_tvalid || m_axis_tready) : 1'b1;
    always @(posedge aclk)
        if (!aresetn) begin m_axis_tvalid <= 1'b0; m_axis_tdata <= 32'd0; m_axis_tlast <= 1'b0; end
        else if (s_axis_tready) begin
            m_axis_tvalid <= s_axis_tvalid;
            if (s_axis_tvalid) begin m_axis_tdata <= s_axis_tdata + K; m_axis_tlast <= s_axis_tlast; end
        end
endmodule
