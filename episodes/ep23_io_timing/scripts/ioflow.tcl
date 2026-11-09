# Episode 23: implement the SPI reader and time the pins.   vivado -mode batch -source scripts/ioflow.tcl -tclargs <none|fabric|iob>
set mode [lindex $argv 0]
set minin [lindex $argv 1]                    ;# optional: override the minimum input delay (ns)
set tag $mode
if {$minin ne ""} { set tag ${mode}_min$minin }
file mkdir reports
read_verilog rtl/spi_adc.v
read_xdc constraints/pins.xdc
if {$mode ne "none"} { read_xdc constraints/io_delays.xdc }
synth_design -top spi_adc -part xc7z020clg400-1
if {$minin ne ""} { set_input_delay -clock sys_clk -min $minin [get_ports sdo] }
set regs [get_cells {sdo_q_reg cs_r_reg sclk_r_reg}]
if {$mode eq "fabric"} { set_property IOB FALSE $regs }
if {$mode eq "iob"}    { set_property IOB TRUE  $regs }
opt_design; place_design; phys_opt_design; route_design
set cf [open reports/check_timing_$tag.rpt w]; puts $cf [check_timing -return_string]; close $cf
set fh [open reports/io_$tag.csv w]
puts $fh "mode,cell,site,iob_prop"
foreach c [lsort [get_cells {sdo_q_reg cs_r_reg sclk_r_reg}]] { puts $fh "$tag,[get_property NAME $c],[get_property LOC $c],[get_property IOB $c]" }
close $fh
if {$mode eq "none"} { exit }
proc path {kind} {
    switch $kind {
        in_setup  { return [lindex [get_timing_paths -from [get_ports sdo] -delay_type max -max_paths 1] 0] }
        in_hold   { return [lindex [get_timing_paths -from [get_ports sdo] -delay_type min -max_paths 1] 0] }
        out_setup { return [lindex [get_timing_paths -to [get_ports {cs_n sclk}] -delay_type max -max_paths 1] 0] }
        out_hold  { return [lindex [get_timing_paths -to [get_ports {cs_n sclk}] -delay_type min -max_paths 1] 0] }
    }
}
set props {SLACK DATAPATH_DELAY DATAPATH_LOGIC_DELAY DATAPATH_NET_DELAY INPUT_DELAY OUTPUT_DELAY STARTPOINT_PIN ENDPOINT_PIN ARRIVAL_TIME REQUIRED_TIME}
set fh [open reports/paths_$tag.csv w]
puts $fh "mode,kind,[join $props ,]"
foreach k {in_setup in_hold out_setup out_hold} {
    set p [path $k]; set row [list $tag $k]
    foreach pr $props { lappend row [get_property $pr $p] }
    puts $fh [join $row ","]
}
close $fh
report_timing -from [get_ports sdo] -delay_type max -file reports/in_setup_$tag.rpt
report_timing -to [get_ports cs_n] -delay_type max -file reports/out_setup_$tag.rpt
# how much of the clock period is left for the FPGA's own input path? sweep the external input delay (max)
set fh [open reports/sweep_$tag.csv w]
puts $fh "mode,input_delay_max_ns,in_setup_slack_ns"
foreach d {3.0 5.0 6.5 7.5} {
    set_input_delay -clock sys_clk -max $d [get_ports sdo]
    puts $fh "$tag,$d,[get_property SLACK [path in_setup]]"
}
close $fh
