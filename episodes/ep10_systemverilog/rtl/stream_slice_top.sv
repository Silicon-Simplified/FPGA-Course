// Silicon Simplified - FPGA Course, Episode 10
// Flat-port wrapper so the interface version can be synthesized as a top module.
module stream_slice_top (
    input  logic       clk, rst,
    input  logic       in_valid, output logic in_ready, input logic [7:0] in_data,
    output logic       out_valid, input  logic out_ready, output logic [7:0] out_data
);
    if_stream i (), o ();
    assign i.valid = in_valid;  assign i.data = in_data;  assign in_ready = i.ready;
    assign out_valid = o.valid; assign out_data = o.data; assign o.ready = out_ready;
    stream_slice u (.clk(clk), .rst(rst), .in(i), .out(o));
endmodule
