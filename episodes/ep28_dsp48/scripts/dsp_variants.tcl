# Episode 28: implement every variant out-of-context at a 5 ns clock (ports timed against the clock with 0 delay) and record DSP use and the worst path.
file mkdir reports
read_verilog rtl/dsp_variants.v
set mods {m0 m1 m2 m3 mac preadd m3_lut}
set fh [open reports/dsp_variants.csv w]
puts $fh "module,dsp,lut,ff,areg,breg,mreg,preg,use_dport,wns_ns,worst_datapath_ns,logic_levels"
foreach m $mods {
    synth_design -top $m -part xc7z020clg400-1 -mode out_of_context
    create_clock -period 5.000 -name clk [get_ports clk]
    set_input_delay -clock clk 0 [get_ports -filter {NAME != clk && DIRECTION == IN}]
    set_output_delay -clock clk 0 [all_outputs]
    opt_design; place_design; route_design
    set u [report_utilization -return_string]
    foreach {v pat} {dsp {DSPs\s*\|\s*(\d+)} lut {Slice LUTs\*?\s*\|\s*(\d+)} ff {Slice Registers\s*\|\s*(\d+)}} { if {![regexp $pat $u -> $v]} { set $v 0 } }
    set ar ""; set br ""; set mr ""; set pr ""; set dp ""
    foreach c [get_cells -hier -filter {REF_NAME =~ DSP48E1}] { set ar [get_property AREG $c]; set br [get_property BREG $c]; set mr [get_property MREG $c]; set pr [get_property PREG $c]; set dp [get_property USE_DPORT $c]; break }
    set p [lindex [get_timing_paths -max_paths 1 -setup] 0]
    puts $fh "$m,$dsp,$lut,$ff,$ar,$br,$mr,$pr,$dp,[get_property SLACK $p],[get_property DATAPATH_DELAY $p],[get_property LOGIC_LEVELS $p]"
    puts "VAR $m dsp=$dsp lut=$lut ff=$ff AREG=$ar BREG=$br MREG=$mr PREG=$pr DPORT=$dp wns=[get_property SLACK $p] dp=[get_property DATAPATH_DELAY $p]"
    close_design
}
close $fh
