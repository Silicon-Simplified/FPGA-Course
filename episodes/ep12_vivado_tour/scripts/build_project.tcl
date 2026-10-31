# Silicon Simplified - FPGA Course, Episode 12
# PROJECT mode: the same design, driven through a project (what the GUI does).   vivado -mode batch -source scripts/build_project.tcl
set t0 [clock milliseconds]
set part xc7z020clg400-1
create_project -force proj_pm proj_pm -part $part
add_files [glob rtl/*.v]
add_files -fileset constrs_1 constraints/pynq_z2_blink.xdc
set_property top top_blink_en [current_fileset]
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 2
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
open_run impl_1
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set rep [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
set bit [glob proj_pm/proj_pm.runs/impl_1/*.bit]
set secs [format %.1f [expr {([clock milliseconds] - $t0) / 1000.0}]]
puts "RESULT mode=project seconds=$secs wns=$wns luts=$luts ffs=$ffs bit_bytes=[file size $bit]"
close_project
