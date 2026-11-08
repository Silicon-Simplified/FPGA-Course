# Episode 16: run the implementation steps one at a time and record timing + cost after each.
#   vivado -mode batch -source scripts/stages.tcl -tclargs <period_ns>
set period [lindex $argv 0]
if {$period eq ""} { set period 4.0 }
set part xc7z020clg400-1
file mkdir reports
read_verilog rtl/impl_demo.v
proc wns_now {} {
    set rep [report_timing_summary -return_string -max_paths 1]
    # the design-timing-summary table: WNS TNS TNS-failing-endpoints ... WHS ...
    if {[regexp {WNS\(ns\)[^\n]*\n[^\n]*\n\s*(-?[0-9.]+)\s+(-?[0-9.]+)\s+(\d+)\s+(\d+)} $rep -> w t f n]} { return [list $w $t $f $n] }
    return [list NA NA NA NA]
}
set fh [open reports/stages_$period.csv w]
puts $fh "stage,seconds,wns_ns,tns_ns,failing_endpoints,total_endpoints"
proc rec {fh name t0} {
    set s [format %.1f [expr {([clock milliseconds] - $t0) / 1000.0}]]
    lassign [wns_now] w t f n
    puts $fh "$name,$s,$w,$t,$f,$n"; flush $fh
    puts "STAGE $name sec=$s wns=$w tns=$t fail=$f of=$n"
}
set t0 [clock milliseconds]
synth_design -top impl_demo -part $part -mode out_of_context
create_clock -period $period -name clk [get_ports clk]
rec $fh synth_design $t0
set t0 [clock milliseconds]; opt_design;                     rec $fh opt_design $t0
set t0 [clock milliseconds]; place_design;                   rec $fh place_design $t0
write_checkpoint -force reports/placed_$period.dcp
# where did the placer put things? (slice column / row of every cell)
set ph [open reports/placement_$period.csv w]; puts $ph "x,y,type"
foreach c [get_cells -hier -filter {PRIMITIVE_LEVEL==LEAF}] {
    set loc [get_property LOC $c]
    if {[regexp {SLICE_X(\d+)Y(\d+)} $loc -> x y]} { puts $ph "$x,$y,[get_property REF_NAME $c]" }
}
close $ph
set t0 [clock milliseconds]; phys_opt_design;                rec $fh phys_opt_design $t0
set t0 [clock milliseconds]; route_design;                   rec $fh route_design $t0
set t0 [clock milliseconds]; phys_opt_design;                rec $fh post_route_phys_opt $t0
close $fh
set rs [report_route_status -return_string]
set f2 [open reports/route_status_$period.txt w]; puts $f2 $rs; close $f2
report_utilization -file reports/utilization_$period.rpt
report_timing -max_paths 1 -file reports/worst_path_$period.rpt
