# Silicon Simplified - FPGA Course, Episode 7
# Full implementation of the two blinkers for the PYNQ-Z2, then the reports used in the video.
#   vivado -mode batch -source scripts/impl_blink.tcl
set part xc7z020clg400-1
file mkdir reports
set fh [open reports/impl_summary.csv w]
puts $fh "design,luts,flip_flops,bufg,clock_nets_with_no_clock,wns_ns,tns_ns,failing_endpoints"
foreach top {top_blink_en top_blink_div} {
    read_verilog [glob rtl/*.v]
    read_xdc constraints/pynq_z2_blink.xdc
    synth_design -top $top -part $part
    opt_design
    check_timing -file reports/${top}_check_timing.rpt
    place_design
    route_design
    report_clock_networks -file reports/${top}_clock_networks.rpt
    report_clocks -file reports/${top}_clocks.rpt
    report_timing_summary -file reports/${top}_timing.rpt
    report_methodology -file reports/${top}_methodology.rpt
    report_utilization -file reports/${top}_utilization.rpt
    report_cdc -file reports/${top}_cdc.rpt
    set luts 0; set ffs 0; set bufg 0
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
        set rn [get_property REF_NAME $c]
        if {[string match LUT* $rn]} { incr luts }
        if {[string match FD* $rn]}  { incr ffs }
        if {[string match BUFG* $rn]} { incr bufg }
    }
    set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
    puts "IMPL $top luts=$luts ffs=$ffs bufg=$bufg wns=$wns"
    puts $fh "$top,$luts,$ffs,$bufg,,$wns,,"
    close_design
}
close $fh
