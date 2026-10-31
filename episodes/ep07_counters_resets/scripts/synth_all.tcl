# Silicon Simplified - FPGA Course, Episode 7
# What does Vivado really build for each design?   vivado -mode batch -source scripts/synth_all.tcl
set part xc7z020clg400-1
file mkdir reports
set runs {cnt8_sync cnt8_async shreg_rst shreg_arst shreg_norst rst_sync tick_gen blink_en blink_div}
set fh [open reports/synth_summary.csv w]
puts $fh "design,status,luts,flip_flops,primitives,lut_inits"
foreach top $runs {
    read_verilog [glob rtl/*.v]
    if {[catch {synth_design -top $top -part $part -mode out_of_context -generic N=125000000} err]} {
        puts $fh "$top,ERROR,,,,"
        puts "SYNTH $top : ERROR (see log)"
        catch {close_design}
        continue
    }
    opt_design
    set tally [dict create]; set inits {}
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
        set rn [get_property REF_NAME $c]
        dict incr tally $rn
        if {[string match LUT* $rn]} { lappend inits "$rn:[get_property INIT $c]" }
    }
    set prim {}; set luts 0; set ffs 0
    foreach k [lsort [dict keys $tally]] {
        set n [dict get $tally $k]
        if {$k eq "GND" || $k eq "VCC"} continue
        lappend prim "$k x$n"
        if {[string match LUT* $k]} { incr luts $n }
        if {[string match FD* $k]}  { incr ffs $n }
    }
    puts $fh "$top,OK,$luts,$ffs,\"[join $prim {; }]\",\"[join [lsort $inits] {; }]\""
    puts "SYNTH $top : LUTs=$luts FFs=$ffs | [join $prim {, }] | [join [lsort $inits] {, }]"
    close_design
}
close $fh
