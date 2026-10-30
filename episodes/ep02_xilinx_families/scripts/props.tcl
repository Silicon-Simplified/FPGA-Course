# list the properties Vivado exposes for a part
set p [get_parts xc7a35tcpg236-1]
puts "PROPS: [lsort [list_property $p]]"
foreach n {FAMILY ARCHITECTURE DEVICE SPEED TEMPERATURE_GRADE_LETTER PACKAGE LUT_ELEMENTS FLIPFLOPS BLOCK_RAMS DSP IO_PIN_COUNT GTP_TRANSCEIVERS PART_FAMILY_NAME} {
    catch {puts "  $n = [get_property $n $p]"}
}
