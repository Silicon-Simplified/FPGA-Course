# Episode 41: the DDC synthesized and implemented out of context for the PYNQ-Z2's xc7z020clg400-1 at a 10 ns clock (100 MHz). No board, no ADC: the input and output ports are left open.
#   vivado -mode batch -source scripts/build.tcl     (run it in a folder where nco_cos.mem, nco_sin.mem and fir_coef.mem are visible: see the Makefile)
file mkdir reports
read_verilog [list rtl/nco.v rtl/cic_decim.v rtl/fir_decim.v rtl/ddc_top.v]
synth_design -top ddc_top -part xc7z020clg400-1 -mode out_of_context
create_clock -period 10.000 -name clk [get_ports clk]
opt_design; place_design; route_design
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} brams {Block RAM Tile\s*\|\s*([\d.]+)} dsps {DSPs\s*\|\s*(\d+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "luts,ffs,bram_tiles,dsps,wns_ns,fmax_est_mhz"; puts $fh "$luts,$ffs,$brams,$dsps,$wns,[format %.0f [expr {1000.0 / (10.0 - $wns)}]]"; close $fh
puts "RESULT luts=$luts ffs=$ffs bram=$brams dsp=$dsps wns=$wns"
