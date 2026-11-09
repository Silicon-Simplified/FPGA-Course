# Episode 25: implement exc_demo with NO exceptions, then apply exceptions one by one (timing analysis only) and record what each one does.   vivado -mode batch -source scripts/exc.tcl
file mkdir reports
read_verilog [list rtl/clk_gen.v rtl/cdc_lib.v rtl/exc_demo.v]
read_xdc constraints/exc.xdc
synth_design -top exc_demo -part xc7z020clg400-1
opt_design; place_design; phys_opt_design; route_design
puts "CLOCKS [get_clocks]"
set ca [get_clocks -filter {PERIOD == 4.000}]
set cb [get_clocks -filter {PERIOD == 16.000}]
proc slk {args} {      ;# worst slack of the paths given, or NONE
    set p [lindex [get_timing_paths -max_paths 1 {*}$args] 0]
    if {$p eq ""} { return NONE }
    return [get_property SLACK $p]
}
proc summary {} {
    set rep [report_timing_summary -return_string -max_paths 1]
    if {[regexp {WNS\(ns\)[^\n]*\n[^\n]*\n\s*(-?[0-9.]+|NA)\s+(-?[0-9.]+|NA)\s+(\d+)\s+(\d+)\s+(-?[0-9.]+|NA)} $rep -> wns tns nf nt whs]} { return [list $wns $tns $nf $nt $whs] }
    return [list NA NA NA NA NA]
}
set fh [open reports/exceptions.csv w]
puts $fh "step,wns_ns,tns_ns,failing,endpoints,whs_ns,p1_setup,p2_setup,p2_hold,x_setup,gray_setup"
proc rec {fh step} {
    lassign [summary] wns tns nf nt whs
    set p1 [slk -setup -from [get_cells p1_cfg_reg*] -to [get_cells p1_dst_reg*]]
    set p1b [slk -setup -from [get_cells sh_reg*] -to [get_cells p1_dst_reg*]]
    set p2 [slk -setup -from [get_cells p2_src_reg*] -to [get_cells p2_dst_reg*]]
    set p2h [slk -hold -from [get_cells p2_src_reg*] -to [get_cells p2_dst_reg*]]
    set x [slk -setup -from [get_cells x_cnt_reg*] -to [get_cells x_dst_reg*]]
    set g [slk -setup -from [get_cells g_gray_reg*] -to [get_cells {gs[*].s/s1_reg}]]
    puts $fh "$step,$wns,$tns,$nf,$nt,$whs,$p1,$p2,$p2h,$x,$g"
    puts "STEP $step wns=$wns tns=$tns nf=$nf/$nt whs=$whs p1=$p1 p1_from_sh=$p1b p2=$p2 p2hold=$p2h x=$x gray=$g"
}
rec $fh 0_no_exceptions
# --- E1: the configuration register is static: false path from it
set_false_path -from [get_cells p1_cfg_reg*]
rec $fh 1_false_path_cfg
# --- E2: multicycle 2 for the half-rate datapath: first setup only, then setup + hold
set_multicycle_path 2 -setup -from [get_cells p2_src_reg*] -to [get_cells p2_dst_reg*]
rec $fh 2a_multicycle_setup_only
set_multicycle_path 1 -hold -from [get_cells p2_src_reg*] -to [get_cells p2_dst_reg*]
rec $fh 2b_multicycle_setup_and_hold
# --- E3: bound the Gray crossing instead of ignoring it: set_max_delay -datapath_only (4.0 ns, then a too-tight 1.0 ns)
set gp [list -from [get_cells g_gray_reg*] -to [get_cells {gs[*].s/s1_reg}]]
set_max_delay -datapath_only 4.0 {*}$gp   ;# a later set_max_delay on the same from/to replaces the earlier one
rec $fh 3a_max_delay_datapath_only_4.0
set_max_delay -datapath_only 1.0 {*}$gp
rec $fh 3b_max_delay_datapath_only_1.0
set_max_delay -datapath_only 4.0 {*}$gp   ;# a later set_max_delay on the same from/to replaces the earlier one
# --- E4: asynchronous clock groups for the two MMCM clocks (they are really related, and this also overrides the max_delay above)
set_clock_groups -asynchronous -group $ca -group $cb
rec $fh 4_clock_groups_async
report_exceptions -file reports/report_exceptions.rpt
# --- E5: the abuse: a false path from the clock to itself
set_false_path -from [get_clocks sys_clk] -to [get_clocks sys_clk]
rec $fh 5_ABUSE_false_path_sysclk_to_sysclk
close $fh
