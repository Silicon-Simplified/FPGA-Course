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

# --- the PYNQ-Z2's device, xc7z020: what does the database say about packages, speed grades and temperature?
set fh [open reports/part_decode_z020.txt w]
set parts [get_parts -filter {DEVICE == xc7z020}]
puts $fh "parts named xc7z020: [llength $parts]"
puts $fh "packages: [lsort -unique [get_property PACKAGE $parts]]"
puts $fh "speed grades: [lsort -unique [get_property SPEED $parts]]"
foreach p $parts {
    puts $fh "[get_property NAME $p]  pkg=[get_property PACKAGE $p] speed=[get_property SPEED $p] temp=[get_property TEMPERATURE_GRADE_LETTER $p] [get_property MIN_OPERATING_TEMPERATURE $p]..[get_property MAX_OPERATING_TEMPERATURE $p]C iobs=[get_property AVAILABLE_IOBS $p]"
}
set pi [get_parts -quiet -filter {DEVICE == xc7z020i}]
puts $fh "xc7z020i parts: [llength $pi]"
foreach p $pi { puts $fh "[get_property NAME $p]  speed=[get_property SPEED $p] temp=[get_property TEMPERATURE_GRADE_LETTER $p] [get_property MIN_OPERATING_TEMPERATURE $p]..[get_property MAX_OPERATING_TEMPERATURE $p]C" }
close $fh
