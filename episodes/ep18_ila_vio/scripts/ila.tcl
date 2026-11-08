# Episode 18: add an ILA to a synthesized design (non-project flow) and build it.
#   vivado -mode batch -source scripts/ila.tcl -tclargs <probe_width> <depth> <tag>      (width 0 = no ILA, baseline)
lassign $argv width depth tag
set part xc7z020clg400-1
file mkdir build reports
read_verilog rtl/dbg_demo.v
read_xdc constraints/pynq_z2.xdc
synth_design -top dbg_demo -part $part
if {$width > 0} {
    create_debug_core u_ila_0 ila
    set_property C_DATA_DEPTH $depth [get_debug_cores u_ila_0]
    set_property C_TRIGIN_EN false  [get_debug_cores u_ila_0]
    set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
    set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
    set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
    set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
    set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
    set_property port_width 1 [get_debug_ports u_ila_0/clk]
    connect_debug_port u_ila_0/clk [get_nets clk_IBUF_BUFG]
    set nets {}
    for {set i 0} {$i < $width} {incr i} { lappend nets [get_nets "cnt\[$i\]"] }
    set_property port_width $width [get_debug_ports u_ila_0/probe0]
    connect_debug_port u_ila_0/probe0 $nets
    implement_debug_core
}
opt_design
place_design
route_design
report_utilization -file reports/util_$tag.rpt
report_timing_summary -file reports/timing_$tag.rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} b36 {RAMB36/FIFO\*?\s*\|\s*(\d+)} b18 {RAMB18\s*\|\s*(\d+)} tiles {Block RAM Tile\s*\|\s*([0-9.]+)}} {
    if {![regexp $pat $rep -> $v]} { set $v 0 }
}
write_bitstream -force build/dbg_$tag.bit
if {$width > 0} { write_debug_probes -force build/dbg_$tag.ltx }
set fh [open reports/ila_$tag.csv w]
puts $fh "tag,width,depth,luts,ffs,bram_tiles,wns_ns,bit_bytes"
puts $fh "$tag,$width,$depth,$luts,$ffs,$tiles,$wns,[file size build/dbg_$tag.bit]"
close $fh
puts "RESULT $tag width=$width depth=$depth luts=$luts ffs=$ffs bramtiles=$tiles wns=$wns bit=[file size build/dbg_$tag.bit]"
