# Silicon Simplified - FPGA Course, Episode 4
# Real static-timing numbers for a reg -> logic -> reg path on a Basys 3 device (xc7a35t, speed grade -1).
#   vivado -mode batch -source scripts/timing_demo.tcl
set part xc7a35tcpg236-1
file mkdir reports
set fh [open reports/timing.csv w]
puts $fh "design,period_ns,slack_ns,fmax_est_mhz,clk_to_q_ns,logic_ns,route_ns,datapath_ns,setup_ns,logic_levels,logic_cells"
foreach {name file top} {path_demo path_demo.v path_demo  path_demo_piped path_demo_piped.v path_demo_piped} {
    foreach period {10.0 4.0 2.5} {
        read_verilog rtl/$file
        synth_design -top $top -part $part -mode out_of_context
        create_clock -name clk -period $period [get_ports clk]
        opt_design; place_design; route_design
        set p [lindex [get_timing_paths -max_paths 1 -setup] 0]
        set slack [get_property SLACK $p]
        set dp    [get_property DATAPATH_DELAY $p]
        set logic [get_property DATAPATH_LOGIC_DELAY $p]
        set route [get_property DATAPATH_NET_DELAY $p]
        set levels [get_property LOGIC_LEVELS $p]
        set txt [report_timing -setup -max_paths 1 -return_string]
        set tcq "?"; set setup "?"
        regexp {Prop_fdre_C_Q\)\s+([0-9.]+)} $txt -> tcq
        regexp {Setup_fdre_C_D\)\s+(-?[0-9.]+)} $txt -> setup
        set cells {}
        foreach c [get_cells -of_objects $p -filter {IS_PRIMITIVE==1}] { lappend cells [get_property REF_NAME $c] }
        set fmax [format %.0f [expr {1000.0 / ($period - $slack)}]]
        puts $fh "$name,$period,$slack,$fmax,$tcq,$logic,$route,$dp,$setup,$levels,\"[join $cells { }]\""
        puts "TIMING $name period=$period slack=$slack fmax_est=${fmax}MHz clk2q=$tcq logic=$logic route=$route datapath=$dp setup=$setup levels=$levels cells=[join $cells {,}]"
        if {$period == 10.0} {
            set f [open reports/${name}_path_10ns.rpt w]; puts $f $txt; close $f
        }
        close_design
    }
}
close $fh
