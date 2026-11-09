# Episode 26: one flow, several floorplans.   vivado -mode batch -source scripts/fp.tcl -tclargs <tag> <rtl file> <auto|regions|tight> [incremental reference .dcp]
lassign $argv tag rtl pbmode ref
file mkdir reports build
read_verilog $rtl
read_xdc constraints/fp.xdc
synth_design -top fp_demo -part xc7z020clg400-1 -flatten_hierarchy none
if {$pbmode eq "regions"} {
    set i 0
    foreach cr {X0Y0 X1Y0 X1Y1 X1Y2} {
        create_pblock pb_l$i; add_cells_to_pblock pb_l$i [get_cells l$i]; resize_pblock pb_l$i -add CLOCKREGION_$cr; incr i
    }
}
if {$pbmode eq "tight"} {
    create_pblock pb_l0; add_cells_to_pblock pb_l0 [get_cells l0]; resize_pblock pb_l0 -add {SLICE_X0Y0:SLICE_X4Y9}      ;# 5 x 10 = 50 slices for a lane that needs more
}
if {$ref ne ""} { read_checkpoint -incremental $ref }
proc t {name body} { set t0 [clock milliseconds]; uplevel 1 $body; return [format %.1f [expr {([clock milliseconds] - $t0) / 1000.0}]] }
set t_opt [t opt {opt_design}]
set t_pl  [t place {place_design}]
set t_phy [t phys {phys_opt_design}]
set t_rt  [t route {route_design}]
write_checkpoint -force build/$tag.dcp
set rep [report_timing_summary -return_string -max_paths 1]
regexp {WNS\(ns\)[^\n]*\n[^\n]*\n\s*(-?[0-9.]+)\s+(-?[0-9.]+)\s+(\d+)\s+(\d+)\s+(-?[0-9.]+)} $rep -> wns tns nf nt whs
set fh [open reports/fp_$tag.csv w]
puts $fh "tag,mode,incremental,wns_ns,tns_ns,failing,whs_ns,t_opt,t_place,t_phys_opt,t_route,t_place_route"
puts $fh "$tag,$pbmode,[expr {$ref ne {}}],$wns,$tns,$nf,$whs,$t_opt,$t_pl,$t_phy,$t_rt,[format %.1f [expr {$t_pl + $t_phy + $t_rt}]]"
close $fh
# where did each lane end up? bounding box in slice coordinates
set fb [open reports/lanes_$tag.csv w]
puts $fb "lane,x_min,x_max,y_min,y_max,slices"
foreach l {l0 l1 l2 l3} {
    set xs {}; set ys {}; set sl {}
    foreach c [get_cells -hier -filter "NAME =~ $l/* && PRIMITIVE_LEVEL == LEAF"] {
        if {[regexp {SLICE_X(\d+)Y(\d+)} [get_property LOC $c] -> x y]} { lappend xs $x; lappend ys $y; lappend sl "$x,$y" }
    }
    puts $fb "$l,[lindex [lsort -integer $xs] 0],[lindex [lsort -integer $xs] end],[lindex [lsort -integer $ys] 0],[lindex [lsort -integer $ys] end],[llength [lsort -unique $sl]]"
}
close $fb
puts "RESULT $tag mode=$pbmode wns=$wns tns=$tns failing=$nf whs=$whs t_place=$t_pl t_route=$t_rt"
