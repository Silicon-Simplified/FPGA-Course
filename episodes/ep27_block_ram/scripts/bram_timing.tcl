# Episode 27: BRAM output register, timing.   vivado -mode batch -source scripts/bram_timing.tcl   (clock 3.0 ns = 333 MHz)
file mkdir reports
read_verilog [list rtl/ram_variants.v rtl/bram_timing.v]
set fh [open reports/bram_timing.csv w]
puts $fh "top,wns_ns,start_to_end,datapath_ns,logic_levels,ff,ramb18"
foreach top {t_plain t_oreg} {
    synth_design -top $top -part xc7z020clg400-1 -mode out_of_context
    create_clock -period 3.000 -name clk [get_ports clk]
    opt_design; place_design; route_design
    set p [lindex [get_timing_paths -max_paths 1 -setup] 0]
    set u [report_utilization -return_string]
    regexp {Slice Registers\s*\|\s*(\d+)} $u -> ff
    regexp {RAMB18\s*\|\s*(\d+)} $u -> b18
    puts $fh "$top,[get_property SLACK $p],[get_property STARTPOINT_PIN $p]->[get_property ENDPOINT_PIN $p],[get_property DATAPATH_DELAY $p],[get_property LOGIC_LEVELS $p],$ff,$b18"
    report_timing -max_paths 1 -setup -file reports/bram_path_$top.rpt
    close_design
}
close $fh
