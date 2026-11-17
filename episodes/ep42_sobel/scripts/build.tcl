# Episode 42: the Sobel pipeline for a 640 x 480 frame (VGA size), synthesized and implemented out of context for the PYNQ-Z2's xc7z020clg400-1 at a 10 ns clock. No board, no camera.
#   vivado -mode batch -source scripts/build.tcl
file mkdir reports
read_verilog rtl/sobel.v
synth_design -top sobel -part xc7z020clg400-1 -mode out_of_context -generic W=640 -generic H=480
create_clock -period 10.000 -name clk [get_ports clk]
opt_design; place_design; route_design
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} lutram {LUT as Distributed RAM\s*\|\s*(\d+)} brams {Block RAM Tile\s*\|\s*([\d.]+)} dsps {DSPs\s*\|\s*(\d+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "luts,ffs,lut_as_ram,bram_tiles,dsps,wns_ns"; puts $fh "$luts,$ffs,$lutram,$brams,$dsps,$wns"; close $fh
puts "RESULT luts=$luts ffs=$ffs lutram=$lutram bram=$brams dsp=$dsps wns=$wns"
