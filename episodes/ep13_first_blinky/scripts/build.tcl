# Silicon Simplified - FPGA Course, Episode 13
# The whole flow for the PYNQ-Z2 as one script (non-project mode, Episode 12):   vivado -mode batch -source scripts/build.tcl
set part xc7z020clg400-1
set top  blinky
file mkdir out reports
proc stage {name body} {
    set t0 [clock milliseconds]
    uplevel 1 $body
    set s [format %.1f [expr {([clock milliseconds] - $t0) / 1000.0}]]
    puts "STAGE $name seconds=$s"
    return $s
}
read_verilog rtl/blinky.v
read_xdc constraints/pynq_z2_blinky.xdc
set t_syn  [stage synth_design { synth_design -top $top -part $part }]
set t_opt  [stage opt_design   { opt_design }]
set t_pl   [stage place_design { place_design }]
set t_rt   [stage route_design { route_design }]
report_utilization    -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
report_io             -file reports/io.rpt
report_clocks         -file reports/clocks.rpt
report_drc            -file reports/drc.rpt
set t_bit  [stage write_bitstream { write_bitstream -force out/blinky.bit }]
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
set rep [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
regexp {Bonded IOB\s*\|\s*(\d+)} $rep -> iobs
set fh [open reports/flow_summary.csv w]
puts $fh "luts,flip_flops,bonded_iobs,wns_ns,whs_ns,bit_bytes,t_synth,t_opt,t_place,t_route,t_bitstream"
puts $fh "$luts,$ffs,$iobs,$wns,$whs,[file size out/blinky.bit],$t_syn,$t_opt,$t_pl,$t_rt,$t_bit"
close $fh
puts "RESULT luts=$luts ffs=$ffs iobs=$iobs wns=$wns whs=$whs bit=[file size out/blinky.bit]"
