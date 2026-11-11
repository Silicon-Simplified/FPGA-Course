// Episode 31 - a byte-level I2C master (7-bit addressing, no clock stretching). Commands: 1 START (also repeated start), 2 WRITE a byte (ack_out = 1 if the slave acknowledged),
// 3 READ a byte (nack_in = 1 sends a NACK, i.e. "last byte"), 4 STOP. SCL = clk / (4 * Q). The pins are open-drain: *_low = 1 pulls the line low, 0 releases it.
module i2c_master #(parameter Q = 312) (
    input wire clk, input wire cmd_valid, input wire [2:0] cmd, input wire [7:0] wdata, input wire nack_in,
    output reg [7:0] rdata = 0, output reg ack_out = 0, output wire busy, output reg done = 0,
    output wire scl_low, output wire sda_low, input wire sda_in);
    localparam IDLE = 0, START = 1, WR = 2, WRACK = 3, RD = 4, RDACK = 5, STOP = 6;
    reg [2:0] st = IDLE; reg [1:0] ph = 0; reg [3:0] bn = 0; reg [15:0] qc = 0; reg [7:0] sh = 0; reg scl_r = 1, sda_r = 1, nack_r = 0;
    assign busy = (st != IDLE);
    assign scl_low = ~scl_r;
    assign sda_low = ~sda_r;
    always @(posedge clk) begin
        done <= 0;
        if (st == IDLE) begin
            qc <= 0; ph <= 0; bn <= 0;
            if (cmd_valid) begin
                sh <= wdata; nack_r <= nack_in;
                case (cmd) 3'd1: st <= START; 3'd2: st <= WR; 3'd3: st <= RD; 3'd4: st <= STOP; default: st <= IDLE; endcase
            end
        end else if (qc != Q - 1) qc <= qc + 1'b1;
        else begin
            qc <= 0; ph <= ph + 1'b1;
            case (st)
                START: case (ph) 0: begin scl_r <= 0; sda_r <= 1; end 1: scl_r <= 1; 2: sda_r <= 0; 3: begin scl_r <= 0; st <= IDLE; done <= 1; end endcase
                WR:    case (ph) 0: begin scl_r <= 0; sda_r <= sh[7]; end 1: scl_r <= 1; 2: ; 3: begin scl_r <= 0; sh <= {sh[6:0], 1'b0}; bn <= bn + 1'b1; if (bn == 4'd7) begin st <= WRACK; end end endcase
                WRACK: case (ph) 0: begin scl_r <= 0; sda_r <= 1; end 1: scl_r <= 1; 2: ack_out <= ~sda_in; 3: begin scl_r <= 0; st <= IDLE; done <= 1; end endcase
                RD:    case (ph) 0: begin scl_r <= 0; sda_r <= 1; end 1: scl_r <= 1; 2: sh <= {sh[6:0], sda_in}; 3: begin scl_r <= 0; bn <= bn + 1'b1; if (bn == 4'd7) st <= RDACK; end endcase
                RDACK: case (ph) 0: begin scl_r <= 0; sda_r <= nack_r; end 1: scl_r <= 1; 2: ; 3: begin scl_r <= 0; sda_r <= 1; rdata <= sh; st <= IDLE; done <= 1; end endcase
                STOP:  case (ph) 0: begin scl_r <= 0; sda_r <= 0; end 1: scl_r <= 1; 2: sda_r <= 1; 3: begin st <= IDLE; done <= 1; end endcase
                default: st <= IDLE;
            endcase
        end
    end
endmodule
