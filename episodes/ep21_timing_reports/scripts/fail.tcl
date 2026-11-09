# Episode 21: implement the failing design at the PYNQ-Z2's 125 MHz clock and write the reports we read in the video.   vivado -mode batch -source scripts/fail.tcl
file mkdir reports
read_verilog rtl/fail_demo.v
synth_design -top fail_demo -part xc7z020clg400-1 -mode out_of_context
create_clock -period 8.000 -name clk [get_ports clk]
opt_design; place_design; phys_opt_design; route_design
report_timing_summary -file reports/timing_summary.rpt
report_timing -max_paths 1 -setup -file reports/worst_setup.rpt
report_timing -max_paths 1 -hold -file reports/worst_hold.rpt
report_utilization -file reports/utilization.rpt
report_design_analysis -logic_level_distribution -file reports/design_analysis.rpt
report_high_fanout_nets -max_nets 5 -file reports/high_fanout.rpt
set cf [open reports/check_timing.rpt w]; puts $cf [check_timing -return_string]; close $cf
# the slack of every failing endpoint (worst path to each)
set fh [open reports/failing_endpoints.csv w]
puts $fh "endpoint,slack_ns,logic_levels"
foreach p [get_timing_paths -max_paths 60 -nworst 1 -unique_pins -setup] {
    if {[get_property SLACK $p] < 0} { puts $fh "[get_property ENDPOINT_PIN $p],[get_property SLACK $p],[get_property LOGIC_LEVELS $p]" }
}
close $fh
