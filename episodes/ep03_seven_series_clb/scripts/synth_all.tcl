# Silicon Simplified - FPGA Course, Episode 3
# Synthesize + place every design for the PYNQ-Z2 device (xc7z020) (out-of-context, so no I/O buffers are added) and
# tally the REAL primitives Vivado used.   vivado -mode batch -source scripts/synth_all.tcl
set part xc7z020clg400-1
file mkdir reports
# name  file  top  generics
set runs {
    {dual_lut     dual_lut.v     dual_lut     {}}
    {wide7        wide7.v        wide7        {}}
    {wide8        wide8.v        wide8        {}}
    {dual_lut_prim dual_lut_prim.v dual_lut_prim {}}
    {adder8       adder.v        adder        {W=8}}
    {adder8_carryout adder_co.v  adder_co     {W=8}}
    {adder32      adder.v        adder        {W=32}}
    {srl32        srl_delay.v    srl_delay    {DEPTH=32}}
    {srl32_reset  srl_delay_ff.v srl_delay_ff {DEPTH=32}}
    {srl_var      srl_var.v      srl_var      {}}
    {srl64        srl_delay.v    srl_delay    {DEPTH=64}}
    {srl128       srl_delay.v    srl_delay    {DEPTH=128}}
    {dram64x8_dual dram64x8.v    dram64x8     {}}
    {dram64x8_single dram64x8_sp.v dram64x8_sp {}}
}
set fh [open reports/primitives.csv w]
puts $fh "design,slice_luts_after_place,lut_as_logic,lut_as_memory,ffs,primitives"
foreach r $runs {
    lassign $r name file top gen
    read_verilog rtl/$file
    set args [list -top $top -part $part -mode out_of_context]
    foreach g $gen { lappend args -generic $g }
    synth_design {*}$args
    opt_design
    place_design
    # tally leaf primitives
    set tally [dict create]
    foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
        dict incr tally [get_property REF_NAME $c]
    }
    set prim {}
    foreach k [lsort [dict keys $tally]] { lappend prim "$k x[dict get $tally $k]" }
    # physical utilisation after placement
    set rep [report_utilization -return_string]
    set lut_total "?"; set lut_logic "?"; set lut_mem "?"; set ffs "?"
    regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> lut_total
    regexp {LUT as Logic\s*\|\s*(\d+)} $rep -> lut_logic
    regexp {LUT as Memory\s*\|\s*(\d+)} $rep -> lut_mem
    regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
    puts $fh "$name,$lut_total,$lut_logic,$lut_mem,$ffs,\"[join $prim {; }]\""
    puts "RESULT $name | slice LUTs $lut_total (logic $lut_logic, memory $lut_mem), FFs $ffs | [join $prim {, }]"
    report_utilization -file reports/${name}_utilization.rpt
    close_design
}
close $fh
