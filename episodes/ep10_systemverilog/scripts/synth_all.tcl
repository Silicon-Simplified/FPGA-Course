# Silicon Simplified - FPGA Course, Episode 10
# Does SystemVerilog build the same hardware as Verilog, and what do the "intent" keywords catch?
#   vivado -mode batch -source scripts/synth_all.tcl
set part xc7a35tcpg236-1
file mkdir reports
set fh [open reports/synth_summary.csv w]
puts $fh "design,status,luts,flip_flops,primitives"
# (name, top, files)
set runs {
    {fsm_traffic     fsm_traffic     {rtl/fsm_traffic.v}}
    {fsm_traffic_sv  fsm_traffic_sv  {rtl/fsm_traffic_sv.sv}}
    {alu4            alu4            {rtl/adder4.v rtl/alu4.v}}
    {alu4_sv_top     alu4_sv_top     {rtl/alu_pkg.sv rtl/alu4_sv.sv rtl/alu4_sv_top.sv}}
    {stream_slice_top stream_slice_top {rtl/if_stream.sv rtl/stream_slice.sv rtl/stream_slice_top.sv}}
    {latch_comb      latch_comb      {rtl/latch_comb.sv}}
    {blk_ff          blk_ff          {rtl/blk_ff.sv}}
    {multi_drv       multi_drv       {rtl/multi_drv.sv}}
}
foreach r $runs {
    lassign $r name top files
    puts "RUN $name"
    foreach f $files {
        if {[string match *.sv $f]} { read_verilog -sv $f } else { read_verilog $f }
    }
    if {[catch {synth_design -top $top -part $part -mode out_of_context} err]} {
        puts $fh "$name,ERROR,,,"
        puts "SYNTH $name : ERROR"
        catch {close_design}
        remove_files [get_files -quiet *]
        continue
    }
    if {[catch {opt_design} err2]} {
        puts $fh "$name,ERROR_DRC,,,"
        puts "SYNTH $name : DRC ERROR in opt_design"
        catch {close_design}
        remove_files [get_files -quiet *]
        continue
    }
    set tally [dict create]
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] { dict incr tally [get_property REF_NAME $c] }
    set prim {}; set luts 0; set ffs 0
    foreach k [lsort [dict keys $tally]] {
        set n [dict get $tally $k]
        if {$k eq "GND" || $k eq "VCC"} continue
        lappend prim "$k x$n"
        if {[string match LUT* $k]} { incr luts $n }
        if {[string match FD* $k] || [string match LD* $k]}  { incr ffs $n }
    }
    puts $fh "$name,OK,$luts,$ffs,\"[join $prim {; }]\""
    puts "SYNTH $name : LUTs=$luts FFs=$ffs | [join $prim {, }]"
    close_design
    remove_files [get_files -quiet *]
}
close $fh
