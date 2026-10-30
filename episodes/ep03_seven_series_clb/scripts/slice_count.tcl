# Silicon Simplified - FPGA Course, Episode 3
# Count SLICEL and SLICEM sites straight from Vivado's device model, and cross-check against the LUT count.
#   vivado -mode batch -source scripts/slice_count.tcl
# Note: xc7a35t is a reduced version of the larger Artix-7 50T die, so its site count (8,150) is NOT 20,800 / 4.
# We therefore use devices where slices x 4 == LUT count.
file mkdir reports
set fh [open reports/slice_types.csv w]
puts $fh "part,device,slicel,slicem,total,slicem_percent,luts_in_slicem,distributed_ram_kbit,luts_db,check"
foreach part {xc7s50csga324-1 xc7a100tcsg324-1 xc7z020clg400-1} {
    read_verilog rtl/dual_lut.v
    synth_design -top dual_lut -part $part -mode out_of_context
    set l [llength [get_sites -filter {SITE_TYPE == SLICEL}]]
    set m [llength [get_sites -filter {SITE_TYPE == SLICEM}]]
    set tot [expr {$l + $m}]
    set pct [format %.1f [expr {100.0 * $m / $tot}]]
    set lutm [expr {4 * $m}]
    set kbit [expr {$lutm * 64 / 1024.0}]
    set luts_db [get_property LUT_ELEMENTS [get_parts $part]]
    set dev [get_property DEVICE [get_parts $part]]
    set chk [expr {$tot * 4 == $luts_db ? "OK" : "MISMATCH"}]
    puts $fh "$part,$dev,$l,$m,$tot,$pct,$lutm,$kbit,$luts_db,$chk"
    puts "SLICES $dev SLICEL=$l SLICEM=$m total=$tot SLICEM=${pct}% memLUTs=$lutm distRAM=${kbit}Kb  slices*4==LUTs? $chk"
    close_design
}
close $fh
