# Episode 28: implement the two FIR forms at 250 MHz (4 ns, ports 0 ns against the clock) and record resources, DSP cascade use, and the worst path.
file mkdir reports
read_verilog [list rtl/fir8.v rtl/fir8_df.v]
set fh [open reports/fir_impl.csv w]
puts $fh "top,dsp,lut,ff,pcin_connected,wns_ns,worst_datapath_ns,logic_levels"
foreach top {fir8 fir8_df} {
    synth_design -top $top -part xc7z020clg400-1 -mode out_of_context
    create_clock -period 4.000 -name clk [get_ports clk]
    set_input_delay -clock clk 0 [get_ports -filter {NAME != clk && DIRECTION == IN}]
    set_output_delay -clock clk 0 [all_outputs]
    opt_design; place_design; phys_opt_design; route_design
    set u [report_utilization -return_string]
    foreach {v pat} {dsp {DSPs\s*\|\s*(\d+)} lut {Slice LUTs\*?\s*\|\s*(\d+)} ff {Slice Registers\s*\|\s*(\d+)}} { if {![regexp $pat $u -> $v]} { set $v 0 } }
    set pc 0
    foreach c [get_cells -hier -filter {REF_NAME =~ DSP48E1}] {
        set n [get_nets -quiet -of_objects [get_pins -quiet $c/PCIN[0]]]
        if {$n ne "" && [get_property TYPE $n] ne "GROUND"} { incr pc }
    }
    set p [lindex [get_timing_paths -max_paths 1 -setup] 0]
    puts $fh "$top,$dsp,$lut,$ff,$pc,[get_property SLACK $p],[get_property DATAPATH_DELAY $p],[get_property LOGIC_LEVELS $p]"
    puts "FIR $top dsp=$dsp lut=$lut ff=$ff pcin=$pc wns=[get_property SLACK $p]"
    report_timing -max_paths 1 -file reports/fir_path_$top.rpt
    close_design
}
close $fh
