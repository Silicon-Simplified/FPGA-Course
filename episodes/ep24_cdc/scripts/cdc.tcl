# Episode 24: implement a CDC design and run report_cdc.   vivado -mode batch -source scripts/cdc.tcl -tclargs <cdc_bad|cdc_good>
set top [lindex $argv 0]
file mkdir reports
read_verilog [list rtl/cdc_lib.v rtl/clk_gen.v rtl/$top.v]
read_xdc constraints/cdc.xdc
synth_design -top $top -part xc7z020clg400-1
opt_design; place_design; route_design
# the two MMCM outputs (250 MHz, 62.5 MHz) are treated as asynchronous to each other
set ca [get_clocks -filter {PERIOD == 4.000}]
set cb [get_clocks -filter {PERIOD == 16.000}]
puts "CLOCKS a=$ca b=$cb"
set_clock_groups -asynchronous -group $ca -group $cb
report_cdc -summary -file reports/cdc_summary_$top.rpt
report_cdc -details -file reports/cdc_details_$top.rpt
report_utilization -file reports/util_$top.rpt
puts "RESULT $top done"
