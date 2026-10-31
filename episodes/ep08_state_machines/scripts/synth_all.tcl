# Silicon Simplified - FPGA Course, Episode 8
# What does Vivado really build for each FSM?   vivado -mode batch -source scripts/synth_all.tcl
set part xc7z020clg400-1
file mkdir reports
file mkdir reports/tmp
set fh [open reports/synth_summary.csv w]
puts $fh "design,status,luts,flip_flops,primitives,logic_levels"

# (name, top, source file, generics)
set runs {}
lappend runs [list fsm_traffic fsm_traffic rtl/fsm_traffic.v {}]
lappend runs [list seq_mealy   seq_mealy   rtl/seq_mealy.v   {}]
lappend runs [list seq_moore   seq_moore   rtl/seq_moore.v   {}]
foreach enc {auto one_hot sequential gray johnson none} {
    set txt [read [open rtl/fsm8.v r]]
    set f [open reports/tmp/fsm8_$enc.v w]
    puts $f [string map [list {fsm_encoding = "auto"} "fsm_encoding = \"$enc\""] $txt]
    close $f
    lappend runs [list fsm8_$enc fsm8 reports/tmp/fsm8_$enc.v {}]
}
lappend runs [list fsm_unsafe fsm_unsafe rtl/fsm_unsafe.v {}]
lappend runs [list fsm_safe   fsm_safe   rtl/fsm_safe.v   {}]
lappend runs [list debounce   debounce   rtl/debounce.v   {-generic N=1000000}]

foreach r $runs {
    lassign $r name top src gen
    read_verilog $src
    puts "RUN $name"
    if {[catch {eval synth_design -top $top -part $part -mode out_of_context $gen} err]} {
        puts $fh "$name,ERROR,,,,"
        puts "SYNTH $name : ERROR $err"
        catch {close_design}
        continue
    }
    opt_design
    set ll {}
    if {[llength [get_ports -quiet clk]]} {
        create_clock -period 2.0 [get_ports clk]
        set tp [get_timing_paths -max_paths 1 -setup -from [all_registers] -to [all_registers]]
        if {[llength $tp]} { set ll [get_property LOGIC_LEVELS $tp] }
    }
    set tally [dict create]
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] { dict incr tally [get_property REF_NAME $c] }
    set prim {}; set luts 0; set ffs 0
    foreach k [lsort [dict keys $tally]] {
        set n [dict get $tally $k]
        if {$k eq "GND" || $k eq "VCC"} continue
        lappend prim "$k x$n"
        if {[string match LUT* $k]} { incr luts $n }
        if {[string match FD* $k]}  { incr ffs $n }
    }
    puts $fh "$name,OK,$luts,$ffs,\"[join $prim {; }]\",$ll"
    puts "SYNTH $name : LUTs=$luts FFs=$ffs levels=$ll | [join $prim {, }]"
    close_design
    remove_files [get_files *]
}
close $fh
