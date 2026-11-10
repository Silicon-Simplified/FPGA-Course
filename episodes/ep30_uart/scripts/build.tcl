# Episode 30: the UART echo design for the PYNQ-Z2 (full flow incl. bitstream).   vivado -mode batch -source scripts/build.tcl
file mkdir reports build
read_verilog rtl/uart.v
read_xdc constraints/uart.xdc
synth_design -top uart_top -part xc7z020clg400-1
opt_design; place_design; route_design
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
report_io -file reports/io.rpt
set ok [expr {![catch {write_bitstream -force build/uart_top.bit} e]}]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)}} { if {![regexp $pat $rep -> $v]} { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "luts,ffs,wns_ns,bitstream_ok"; puts $fh "$luts,$ffs,$wns,$ok"; close $fh
puts "RESULT luts=$luts ffs=$ffs wns=$wns bitstream=$ok"
