# Episode 20: implement the MMCM design and read the clocks Vivado derived.   vivado -mode batch -source scripts/clk.tcl
file mkdir reports
read_verilog rtl/clk_demo.v
read_xdc constraints/pynq_z2.xdc
synth_design -top clk_demo -part xc7z020clg400-1
opt_design; place_design; route_design
report_clocks -file reports/clocks.rpt
report_timing_summary -file reports/timing_summary.rpt
report_clock_utilization -file reports/clock_utilization.rpt
report_utilization -file reports/utilization.rpt
set fh [open reports/clocks.csv w]
puts $fh "clock,period_ns,is_generated,master,wns_ns,whs_ns"
foreach c [get_clocks] {
    set per [get_property PERIOD $c]
    set gen [get_property IS_GENERATED $c]
    set mst [expr {$gen ? [get_property MASTER_CLOCK $c] : ""}]
    set sp [lindex [get_timing_paths -max_paths 1 -setup -group [get_property NAME $c]] 0]
    set hp [lindex [get_timing_paths -max_paths 1 -hold  -group [get_property NAME $c]] 0]
    set w "";  if {$sp ne ""} { set w [get_property SLACK $sp] }
    set h "";  if {$hp ne ""} { set h [get_property SLACK $hp] }
    puts $fh "[get_property NAME $c],$per,$gen,$mst,$w,$h"
}
close $fh
# the worst setup path in each derived-clock domain, with its clock uncertainty breakdown
foreach c [get_clocks] { report_timing -max_paths 1 -setup -to [get_clocks $c] -file reports/path_[get_property NAME $c].rpt }
