// Episode 36 - a streaming accelerator: 4-sample moving average, y[n] = (x[n] + x[n-1] + x[n-2] + x[n-3]) / 4 on signed 32-bit samples.
// One output register, full speed (1 word per clock); the history is cleared after every packet (TLAST), so packets do not leak into each other.
// CLEAR = 0 is the bug used by the testbench (history kept across packets).
module axis_avg4 #(parameter CLEAR = 1, parameter HOLD = 1) (
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
    reg signed [31:0] h1, h2, h3;
    wire signed [33:0] sum = $signed({{2{s_axis_tdata[31]}}, s_axis_tdata}) + h1 + h2 + h3;
    assign s_axis_tready = (HOLD != 0) ? (!m_axis_tvalid || m_axis_tready) : 1'b1;
    always @(posedge aclk)
        if (!aresetn) begin m_axis_tvalid <= 0; m_axis_tdata <= 0; m_axis_tlast <= 0; h1 <= 0; h2 <= 0; h3 <= 0; end
        else if (s_axis_tready) begin
            m_axis_tvalid <= s_axis_tvalid;
            if (s_axis_tvalid) begin
                m_axis_tdata <= sum[33:2];
                m_axis_tlast <= s_axis_tlast;
                if (s_axis_tlast && CLEAR != 0) begin h1 <= 0; h2 <= 0; h3 <= 0; end
                else begin h1 <= $signed(s_axis_tdata); h2 <= h1; h3 <= h2; end
            end
        end
endmodule
