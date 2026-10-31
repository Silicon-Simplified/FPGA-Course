// Silicon Simplified - FPGA Course, Episode 10
`timescale 1ns / 1ps
// An interface: the valid / ready / data bundle in ONE named port, with modports giving each side's directions.
interface if_stream #(parameter int W = 8);
    logic         valid;
    logic         ready;
    logic [W-1:0] data;
    modport src (output valid, data, input  ready);
    modport snk (input  valid, data, output ready);
endinterface
