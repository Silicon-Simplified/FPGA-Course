# Template build: sources + constraints in, bitstream + reports out, everything under build/ (git-ignored).
#   vivado -mode batch -source scripts/build.tcl -tclargs <top> <part>
set top  [expr {[llength $argv] > 0 ? [lindex $argv 0] : "blinky"}]
set part [expr {[llength $argv] > 1 ? [lindex $argv 1] : "xc7z020clg400-1"}]
set out build
file mkdir $out
# the git commit goes into the bitstream's USR_ACCESS register (first 8 hex digits of the hash)
set rev "00000000"
catch { set rev [string range [exec git rev-parse HEAD] 0 7] }
read_verilog [glob rtl/*.v]
read_xdc [glob constraints/*.xdc]
synth_design -top $top -part $part
opt_design
place_design
route_design
set_property BITSTREAM.CONFIG.USR_ACCESS 0x$rev [current_design]
report_utilization    -file $out/utilization.rpt
report_timing_summary -file $out/timing_summary.rpt
write_bitstream -force $out/$top.bit
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set rep [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
set fh [open $out/result.csv w]; puts $fh "rev,luts,ffs,wns_ns,bit_bytes"; puts $fh "$rev,$luts,$ffs,$wns,[file size $out/$top.bit]"; close $fh
puts "RESULT rev=$rev luts=$luts ffs=$ffs wns=$wns bit=[file size $out/$top.bit]"
