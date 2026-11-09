# Episode 22: implement one variant at the PYNQ-Z2's 125 MHz clock and append a result row.
#   vivado -mode batch -source scripts/fix.tcl -tclargs <top> <tag> [retiming] [directives]
lassign $argv top tag opt1 opt2 xdc
if {$xdc eq ""} { set xdc clk.xdc }
file mkdir reports
read_verilog rtl/$top.v
set sargs {}
if {$opt1 eq "retiming"} { lappend sargs -global_retiming on }
read_xdc -mode out_of_context constraints/$xdc      ;# the clock must exist BEFORE synthesis: timing-driven synthesis and retiming need it
synth_design -top $top -part xc7z020clg400-1 -mode out_of_context {*}$sargs
if {$opt1 eq "directives" || $opt2 eq "directives"} {
    opt_design -directive Explore
    place_design -directive ExtraTimingOpt
    phys_opt_design -directive AggressiveExplore
    route_design -directive Explore
    phys_opt_design -directive AggressiveExplore
} else {
    opt_design; place_design; phys_opt_design; route_design
}
set rep [report_timing_summary -return_string -max_paths 1]
regexp {WNS\(ns\)[^\n]*\n[^\n]*\n\s*(-?[0-9.]+)\s+(-?[0-9.]+)\s+(\d+)\s+(\d+)\s+(-?[0-9.]+)} $rep -> wns tns nf nt whs
set u [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $u -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $u -> ffs
set p [lindex [get_timing_paths -max_paths 1 -setup] 0]
set lv [get_property LOGIC_LEVELS $p]
set dp [get_property DATAPATH_DELAY $p]
set fh [open reports/fix_$tag.csv w]
puts $fh "tag,luts,ffs,wns_ns,tns_ns,failing,total_endpoints,whs_ns,worst_logic_levels,worst_datapath_ns"
puts $fh "$tag,$luts,$ffs,$wns,$tns,$nf,$nt,$whs,$lv,$dp"
close $fh
puts "RESULT $tag luts=$luts ffs=$ffs wns=$wns tns=$tns failing=$nf/$nt whs=$whs levels=$lv dp=$dp"
