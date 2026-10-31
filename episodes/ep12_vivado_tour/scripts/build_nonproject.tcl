# Silicon Simplified - FPGA Course, Episode 12
# NON-PROJECT mode: the whole flow as a script, everything in memory.   vivado -mode batch -source scripts/build_nonproject.tcl
set t0 [clock milliseconds]
set part xc7z020clg400-1
file mkdir out_np
read_verilog [glob rtl/*.v]
read_xdc constraints/pynq_z2_blink.xdc
synth_design -top top_blink_en -part $part
opt_design
place_design
route_design
write_bitstream -force out_np/top_blink_en.bit
report_utilization -file out_np/utilization.rpt
report_timing_summary -file out_np/timing.rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set rep [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
set secs [format %.1f [expr {([clock milliseconds] - $t0) / 1000.0}]]
set fh [open out_np/result.txt w]
puts $fh "mode=non-project seconds=$secs wns=$wns luts=$luts ffs=$ffs bit_bytes=[file size out_np/top_blink_en.bit]"
close $fh
puts "RESULT mode=non-project seconds=$secs wns=$wns luts=$luts ffs=$ffs bit_bytes=[file size out_np/top_blink_en.bit]"
