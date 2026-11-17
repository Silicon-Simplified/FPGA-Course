# Episode 40: power estimates from Vivado's report_power (a MODEL, not a measurement on silicon). xc7z020clg400-1, out of context, placed and routed, then analysed with stated switching activity.
#   vivado -mode batch -source scripts/run.tcl
file mkdir reports
read_verilog [list rtl/pw.v rtl/mul.v rtl/dly.v]
set part xc7z020clg400-1
set fh [open reports/results.csv w]
puts $fh "experiment,variant,setting,total_w,dynamic_w,static_w,clocks_w,logic_w,signals_w,bram_w,dsp_w,confidence,luts,dsp48_cells"
proc pow {exp var setting} {
    global fh
    set r [report_power -return_string]
    set rep_util [report_utilization -return_string]
    foreach {k pat} {dspn {DSPs\s*\|\s*(\d+)} lutn {Slice LUTs\*?\s*\|\s*(\d+)}} { if {[regexp $pat $rep_util m v]} { set $k $v } else { set $k 0 } }
    foreach {k pat} {total {Total On-Chip Power \(W\)\s*\|\s*([<\d.]+)} dyn {Dynamic \(W\)\s*\|\s*([<\d.]+)} stat {Device Static \(W\)\s*\|\s*([<\d.]+)} clk {\| Clocks\s*\|\s*([<\d.]+)} logic {\| Slice Logic\s*\|\s*([<\d.]+)} sig {\| Signals\s*\|\s*([<\d.]+)} bram {\| Block RAM\s*\|\s*([<\d.]+)} dsp {\| DSPs\s*\|\s*([<\d.]+)} conf {Confidence Level\s*\|\s*(\w+)}} {
        if {[regexp $pat $r m v]} { set $k $v } else { set $k n/a } }
    puts $fh "$exp,$var,\"$setting\",$total,$dyn,$stat,$clk,$logic,$sig,$bram,$dsp,$conf,$lutn,$dspn"; flush $fh
    puts "RESULT $exp $var $setting total=$total dyn=$dyn static=$stat clk=$clk logic=$logic sig=$sig bram=$bram dsp=$dsp conf=$conf"
}
proc impl {top generics} {
    global part
    catch {close_design}
    set a [list -top $top -part $part -mode out_of_context]
    foreach g $generics { lappend a -generic $g }
    synth_design {*}$a
    create_clock -period 10.000 -name clk [get_ports clk]
    opt_design; place_design; route_design
}
# post-implementation functional simulation with random data, SAIF recorded by xsim, read back into the power analysis
proc saif_run {var defs} {
    file mkdir sim
    write_verilog -mode funcsim -force sim/$var.v
    set glbl [file join $::env(XILINX_VIVADO) data verilog src glbl.v]
    exec xvlog -work work_$var sim/$var.v $glbl tb/tb_power.v {*}$defs 2>@1
    exec xelab -L unisims_ver -debug typical work_$var.tb work_$var.glbl -s snap_$var 2>@1
    set tcl [open sim/$var.tcl w]
    puts $tcl "open_saif sim/$var.saif\nlog_saif \[get_objects -r /tb/dut/*\]\nrun all\nclose_saif\nquit"
    close $tcl
    exec xsim snap_$var -tclbatch sim/$var.tcl 2>@1
    reset_switching_activity -all
    read_saif -strip_path tb/dut sim/$var.saif
}

# 1) clock frequency: vectorless (default activity), one implementation of the free-running accumulators
impl pw_free {}
foreach p {20.000 10.000 5.000} {                       ;# 50, 100, 200 MHz
    create_clock -period $p -name clk [get_ports clk]
    reset_switching_activity -all
    pow clock_frequency pw_free "[expr {round(1000/$p)}] MHz, default (vectorless) activity"
}
create_clock -period 10.000 -name clk [get_ports clk]
# 2) enable gating: free-running, flip-flop CE, BUFGCE; enable duty 100% and 10%; random data every clock
foreach {var top} {free pw_free ce pw_ce bufgce pw_gate} {
    impl $top {}
    foreach duty {100 10} {
        saif_run ${var}_$duty [list -d PW=$top -d DUTYV=$duty]
        pow enable_gating $var "100 MHz, random data, enable duty $duty% (simulated activity)"
    }
}
# 3) multipliers in DSP48 or LUTs
foreach {var top} {dsp48 mul_dsp luts mul_lut} {
    impl $top {}
    saif_run mul_$var [list -d MUL=$top]
    pow multiplier $var "100 MHz, random inputs (simulated activity)"
}
# 4) delay line: SRL, flip-flop chain, block RAM
foreach {var mode} {srl 1 ff_chain 3 block_ram 2} {
    impl dly [list MODE=$mode]
    saif_run dly_$var [list -d DLY=1]
    pow delay_line $var "100 MHz, random data (simulated activity)"
}
close $fh
