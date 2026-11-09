# Episode 19: implement a tiny design once, then read its timing paths and re-time it at different clock periods.   vivado -mode batch -source scripts/sta.tcl
file mkdir reports
read_verilog rtl/sta_demo.v
synth_design -top sta_demo -part xc7z020clg400-1 -mode out_of_context
create_clock -period 5.0 -name clk [get_ports clk]
opt_design; place_design; route_design
set props {STARTPOINT_PIN ENDPOINT_PIN STARTPOINT_CLOCK_EDGE ENDPOINT_CLOCK_EDGE STARTPOINT_CLOCK_DELAY ENDPOINT_CLOCK_DELAY DATAPATH_DELAY DATAPATH_LOGIC_DELAY DATAPATH_NET_DELAY ARRIVAL_TIME REQUIRED_TIME REQUIREMENT UNCERTAINTY CLOCK_PESSIMISM SKEW SLACK LOGIC_LEVELS}
proc dump {fh tag p props} {
    set row $tag
    foreach pr $props { lappend row [get_property $pr $p] }
    puts $fh [join $row ","]
}
set fh [open reports/paths.csv w]
puts $fh "tag,[join $props ,]"
foreach per {5.0 3.0 2.2 2.0} {
    create_clock -period $per -name clk [get_ports clk]
    set ps [lindex [get_timing_paths -max_paths 1 -from [get_cells a_r_reg*] -to [get_cells s_r_reg*] -delay_type max] 0]
    set ph [lindex [get_timing_paths -max_paths 1 -from [get_cells sh1_reg] -to [get_cells sh2_reg] -delay_type min] 0]
    dump $fh "setup_$per" $ps $props
    dump $fh "hold_$per" $ph $props
    if {$per == 5.0} {
        report_timing -from [get_cells a_r_reg*] -to [get_cells s_r_reg*] -delay_type max -file reports/setup_path.rpt
        report_timing -from [get_cells sh1_reg] -to [get_cells sh2_reg] -delay_type min -file reports/hold_path.rpt
    }
}
close $fh
