# Episode 39: four experiments, each variant synthesized out of context, placed and routed against a 2.000 ns clock (500 MHz, deliberately too fast),
# so the worst slack tells the achievable clock:  Fmax = 1 / (2.000 ns - WNS).   vivado -mode batch -source scripts/run.tcl
file mkdir reports
read_verilog [list rtl/tree.v rtl/fan.v rtl/dly.v rtl/cs.v]
set part xc7z020clg400-1
set fh [open reports/results.csv w]
puts $fh "experiment,variant,wns_ns,fmax_mhz,luts,ffs,slices,lut_as_srl,lut_as_ram,bram_tiles,control_sets"
proc run {exp var top generics} {
    global fh part
    catch {close_design}
    set args [list -top $top -part $part -mode out_of_context]
    foreach g $generics { lappend args -generic $g }
    synth_design {*}$args
    create_clock -period 2.000 -name clk [get_ports clk]
    opt_design; place_design; route_design
    set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
    set rep [report_utilization -return_string]
    foreach {k pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} slices {\| Slice\s*\|\s*(\d+)} srl {LUT as Shift Register\s*\|\s*(\d+)} ram {LUT as Distributed RAM\s*\|\s*(\d+)} bram {Block RAM Tile\s*\|\s*([\d.]+)}} {
        if {[regexp $pat $rep m v]} { set $k $v } else { set $k 0 } }
    set cs [report_control_sets -verbose -return_string]
    if {![regexp {Total control sets\s*\|\s*(\d+)} $cs m csets]} { set csets 0 }
    set fmax [format %.0f [expr {1000.0 / (2.0 - $wns)}]]
    puts $fh "$exp,$var,$wns,$fmax,$luts,$ffs,$slices,$srl,$ram,$bram,$csets"; flush $fh
    puts "RESULT $exp $var wns=$wns fmax=$fmax luts=$luts ffs=$ffs slices=$slices srl=$srl ram=$ram bram=$bram csets=$csets"
}
run pipelining comb       tree {STG=0}
run pipelining every_level tree {STG=1}
run pipelining every_2nd   tree {STG=2}
run fanout     plain      fan_plain {}
run fanout     max_fanout_50 fan_mf {}
run delay_line ff_with_reset dly {MODE=0}
run delay_line srl_no_reset  dly {MODE=1}
run delay_line ff_chain      dly {MODE=3}
run delay_line block_ram     dly {MODE=2}
run control_sets one_ce      cs {MODE=0}
run control_sets 256_ces     cs {MODE=1}
close $fh
