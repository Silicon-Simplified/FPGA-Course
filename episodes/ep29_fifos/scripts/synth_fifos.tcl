# Episode 29: synthesize the FIFO variants (out-of-context, PYNQ-Z2 part).   vivado -mode batch -source scripts/synth_fifos.tcl
file mkdir reports
read_verilog -sv rtl/fifo_lib.v
auto_detect_xpm
proc one {tag top generics} {
    synth_design -top $top -part xc7z020clg400-1 -mode out_of_context {*}$generics
    set u [report_utilization -return_string]
    foreach {v pat} {lut {Slice LUTs\*?\s*\|\s*(\d+)} lutram {LUT as Distributed RAM\s*\|\s*(\d+)} ff {Slice Registers\s*\|\s*(\d+)} b18 {RAMB18\s*\|\s*(\d+)} b36 {RAMB36/FIFO\*?\s*\|\s*(\d+)}} { if {![regexp $pat $u -> $v]} { set $v 0 } }
    puts "FIFO $tag lut=$lut lutram=$lutram ff=$ff ramb18=$b18 ramb36=$b36"
    return "$tag,$lut,$lutram,$ff,$b18,$b36"
}
set rows {}
lappend rows [one mine_std_16   sync_fifo_std  {-generic AW=4}]
lappend rows [one mine_std_1024 sync_fifo_std  {-generic AW=10}]
lappend rows [one mine_fwft_16   sync_fifo_fwft {-generic AW=4}]
lappend rows [one mine_fwft_1024 sync_fifo_fwft {-generic AW=10}]
lappend rows [one xpm_auto_16    xs {-generic DEPTH=16 -generic MEM=auto}]
lappend rows [one xpm_auto_1024  xs {-generic DEPTH=1024 -generic MEM=auto}]
lappend rows [one xpm_block_16   xs {-generic DEPTH=16 -generic MEM=block}]
lappend rows [one xpm_dist_1024  xs {-generic DEPTH=1024 -generic MEM=distributed}]
lappend rows [one xpm_fwft_1024  xs {-generic DEPTH=1024 -generic MEM=auto -generic MODE=fwft}]
lappend rows [one xpm_async_1024 xa {-generic DEPTH=1024}]
set fh [open reports/fifo_resources.csv w]
puts $fh "variant,lut,lutram,ff,ramb18,ramb36"
foreach r $rows { puts $fh $r }
close $fh
