// Episode 41 - 31-tap low-pass FIR with decimation by 4. The input arrives once per 50 clocks, so ONE multiplier-accumulator is shared by all taps: on every 4th input sample it runs 31 multiply-accumulates (about 33 clocks).
// Coefficients: 16-bit signed, Q15, from fir_coef.mem (tools/ddc_model.py).
module fir_decim #(parameter NT = 31, parameter DEC = 4) (input wire clk, input wire rst, input wire in_valid, input wire signed [15:0] din, output reg signed [15:0] dout, output reg dvalid);
    reg signed [15:0] h [0:NT-1];
    initial $readmemh("fir_coef.mem", h);
    reg signed [15:0] buf_ [0:NT-1];
    reg signed [31:0] prod; reg signed [47:0] acc;
    reg [2:0] dcnt; reg run, pv; reg [5:0] c; integer k;
    always @(posedge clk)
        if (rst) begin
            for (k = 0; k < NT; k = k + 1) buf_[k] <= 0;
            dcnt <= 0; run <= 0; pv <= 0; c <= 0; acc <= 0; prod <= 0; dout <= 0; dvalid <= 0;
        end else begin
            dvalid <= 0;
            if (in_valid) begin
                buf_[0] <= din; for (k = 1; k < NT; k = k + 1) buf_[k] <= buf_[k-1];
                if (dcnt == DEC - 1) begin dcnt <= 0; run <= 1; c <= 0; acc <= 0; pv <= 0; end else dcnt <= dcnt + 1;
            end
            if (run) begin
                if (c < NT) prod <= h[c] * buf_[c];
                pv <= (c < NT);
                if (pv) acc <= acc + prod;
                if (c == NT + 1) begin dout <= acc[30:15]; dvalid <= 1; run <= 0; end
                c <= c + 1;
            end
        end
endmodule
