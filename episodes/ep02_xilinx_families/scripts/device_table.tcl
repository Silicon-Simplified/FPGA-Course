# Silicon Simplified - FPGA Course, Episode 2
# Dump one row per DEVICE (smallest package) for every installed family, straight from Vivado's device database.
#   vivado -mode batch -source scripts/device_table.tcl
file mkdir reports
set fh [open reports/device_table.csv w]
puts $fh "family,device,luts,flipflops,bram36,dsp,max_io_pins,gtp,mmcm,package_example,speed_example"
set seen [dict create]
foreach p [lsort [get_parts]] {
    set dev [get_property DEVICE $p]
    if {[dict exists $seen $dev]} continue
    dict set seen $dev 1
    set fam [get_property FAMILY $p]
    proc g {p n} { if {[catch {set v [get_property $n $p]}]} {return ""}; return $v }
    # the same device appears in several packages: report the package with the most I/O pins
    set best $p; set bestio 0
    foreach q [get_parts -filter "DEVICE == $dev"] {
        set io [g $q IO_PIN_COUNT]
        if {$io ne "" && $io > $bestio} {set bestio $io; set best $q}
    }
    puts $fh [join [list $fam $dev [g $p LUT_ELEMENTS] [g $p FLIPFLOPS] [g $p BLOCK_RAMS] [g $p DSP] $bestio \
        [g $p GTPE2_TRANSCEIVERS] [g $p MMCM] [get_property PACKAGE $best] [get_property SPEED $best]] ,]
}
close $fh
puts "DONE [dict size $seen] devices"
