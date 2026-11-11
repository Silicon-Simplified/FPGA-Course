# Episode 31: SPI + I2C masters on the PYNQ-Z2 (full flow incl. bitstream).   vivado -mode batch -source scripts/build.tcl
file mkdir reports build
read_verilog [list rtl/spi_master.v rtl/i2c_master.v rtl/comm_top.v]
read_xdc constraints/comm.xdc
synth_design -top comm_top -part xc7z020clg400-1
opt_design; place_design; route_design
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
report_io -file reports/io.rpt
set ok [expr {![catch {write_bitstream -force build/comm_top.bit} e]}]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} iobs {Bonded IOB\s*\|\s*(\d+)}} { if {![regexp $pat $rep -> $v]} { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "luts,ffs,iobs,wns_ns,bitstream_ok"; puts $fh "$luts,$ffs,$iobs,$wns,$ok"; close $fh
puts "RESULT luts=$luts ffs=$ffs iobs=$iobs wns=$wns bitstream=$ok"
