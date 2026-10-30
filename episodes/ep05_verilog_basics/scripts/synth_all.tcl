# Silicon Simplified - FPGA Course, Episode 5
# Synthesize each design for a Basys 3 device and tally what Vivado REALLY built.   vivado -mode batch -source scripts/synth_all.tcl
set part xc7a35tcpg236-1
file mkdir reports
# name, files, top
set runs {
    {alu4_comb     {adder4.v alu4.v}                    alu4}
    {alu4_reg      {adder4.v alu4.v alu4_reg.v}         alu4_reg}
    {latch_bug     {latch_bug.v}                        latch_bug}
    {latch_fixed   {latch_fixed.v}                      latch_fixed}
    {order_a       {order_a.v}                          order_a}
    {order_b       {order_b.v}                          order_b}
}
set fh [open reports/synth_summary.csv w]
puts $fh "design,slice_luts,flip_flops,latches,primitives,lut_inits"
foreach r $runs {
    lassign $r name files top
    foreach f $files { read_verilog rtl/$f }
    synth_design -top $top -part $part -mode out_of_context
    opt_design
    set tally [dict create]; set inits {}
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
        set rn [get_property REF_NAME $c]
        dict incr tally $rn
        if {[string match LUT* $rn]} { lappend inits "$rn:[get_property INIT $c]" }
    }
    set prim {}; set luts 0; set ffs 0; set lat 0
    foreach k [lsort [dict keys $tally]] {
        set n [dict get $tally $k]; lappend prim "$k x$n"
        if {[string match LUT* $k]} { incr luts $n }
        if {[string match FD* $k]}  { incr ffs $n }
        if {[string match LD* $k]}  { incr lat $n }
    }
    puts $fh "$name,$luts,$ffs,$lat,\"[join $prim {; }]\",\"[join [lsort $inits] {; }]\""
    puts "SYNTH $name : LUTs=$luts FFs=$ffs latches=$lat | [join $prim {, }]"
    close_design
}
close $fh
