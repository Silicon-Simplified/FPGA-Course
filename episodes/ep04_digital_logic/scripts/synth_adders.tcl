# Silicon Simplified - FPGA Course, Episode 4
# Gate-level vs RTL full adder: what does Vivado build for each?   vivado -mode batch -source scripts/synth_adders.tcl
set part xc7a35tcpg236-1
file mkdir reports
set fh [open reports/adders.csv w]
puts $fh "design,slice_luts,primitives,luts_detail"
foreach {name file top} {fa_gates fa_gates.v fa_gates  fa_rtl fa_rtl.v fa_rtl} {
    read_verilog rtl/$file
    synth_design -top $top -part $part -mode out_of_context
    opt_design
    set tally [dict create]
    set luts {}
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
        set r [get_property REF_NAME $c]
        dict incr tally $r
        if {[string match LUT* $r]} { lappend luts "$r INIT=[get_property INIT $c]" }
    }
    set prim {}
    foreach k [lsort [dict keys $tally]] { lappend prim "$k x[dict get $tally $k]" }
    set n 0; foreach k [dict keys $tally] { if {[string match LUT* $k]} { incr n [dict get $tally $k] } }
    puts $fh "$name,$n,\"[join $prim {; }]\",\"[join [lsort $luts] {; }]\""
    puts "ADDER $name : $n LUT(s) | [join $prim {, }] | [join [lsort $luts] {, }]"
    close_design
}
close $fh
