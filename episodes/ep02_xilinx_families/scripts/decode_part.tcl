# Decode a part number with facts straight from Vivado's device database.
#   vivado -mode batch -source scripts/decode_part.tcl
file mkdir reports
set fh [open reports/part_decode.txt w]
foreach name {xc7a35tcpg236-1 xc7a35tcsg324-3 xc7a35ticsg324-1L xc7a100tcsg324-1 xc7z020clg400-1 xc7z020clg484-1 xc7s50csga324-1} {
    set p [get_parts -quiet $name]
    if {$p eq ""} {puts $fh "$name : (not found)"; continue}
    set o "$name"
    foreach n {FAMILY DEVICE PACKAGE SPEED TEMPERATURE_GRADE_LETTER MIN_OPERATING_TEMPERATURE MAX_OPERATING_TEMPERATURE AVAILABLE_IOBS IO_PIN_COUNT LUT_ELEMENTS FLIPFLOPS BLOCK_RAMS DSP MMCM SLICES} {
        if {[catch {set v [get_property $n $p]}]} {set v "?"}
        append o "\n    $n = $v"
    }
    puts $fh $o
}
puts $fh "\npackages of xc7a35t: [lsort [get_property PACKAGE [get_parts -filter {DEVICE == xc7a35t}]]]"
puts $fh "speed grades of xc7a35t: [lsort -unique [get_property SPEED [get_parts -filter {DEVICE == xc7a35t}]]]"
close $fh
