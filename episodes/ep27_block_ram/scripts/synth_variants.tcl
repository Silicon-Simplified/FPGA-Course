# Episode 27: synthesize every variant on its own (out-of-context, PYNQ-Z2 part) and record the primitives.   vivado -mode batch -source scripts/synth_variants.tcl
file mkdir reports
read_verilog rtl/ram_variants.v
set mods {rom_bram rom_bram_oreg rom_dist ram_readfirst ram_writefirst ram_nochange ram_tdp dds}
set fh [open reports/variants.csv w]
puts $fh "module,lut,lutram,ff,ramb18,ramb36,dsp,write_mode_a,doa_reg"
foreach m $mods {
    synth_design -top $m -part xc7z020clg400-1 -mode out_of_context
    set u [report_utilization -return_string]
    foreach {v pat} {lut {Slice LUTs\*?\s*\|\s*(\d+)} lutram {LUT as Distributed RAM\s*\|\s*(\d+)} ff {Slice Registers\s*\|\s*(\d+)} b18 {RAMB18\s*\|\s*(\d+)} b36 {RAMB36/FIFO\*?\s*\|\s*(\d+)} dsp {DSPs\s*\|\s*(\d+)}} { if {![regexp $pat $u -> $v]} { set $v 0 } }
    set wm ""; set dr ""
    foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] { set wm [get_property WRITE_MODE_A $c]; set dr [get_property DOA_REG $c]; break }
    puts $fh "$m,$lut,$lutram,$ff,$b18,$b36,$dsp,$wm,$dr"
    puts "VAR $m lut=$lut lutram=$lutram ff=$ff b18=$b18 b36=$b36 write_mode=$wm doa_reg=$dr"
    close_design
}
close $fh
