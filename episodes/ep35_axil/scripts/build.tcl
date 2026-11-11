# Episode 35: Zynq PS + our AXI4-Lite PWM peripheral, wired in IP Integrator, implemented, bitstream, .xsa.
#   vivado -mode batch -source scripts/build.tcl
file mkdir reports build
create_project -force zynq_pwm build/proj -part xc7z020clg400-1
add_files rtl/axil_pwm.v
add_files -fileset constrs_1 constraints/pwm.xdc
update_compile_order -fileset sources_1
create_bd_design sys
set ps [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7]
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100}] $ps
make_bd_intf_pins_external [get_bd_intf_pins ps7/DDR]
make_bd_intf_pins_external [get_bd_intf_pins ps7/FIXED_IO]
create_bd_cell -type module -reference axil_pwm pwm0
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins ps7/M_AXI_GP0_ACLK]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "/ps7/FCLK_CLK0 (100 MHz)"} [get_bd_intf_pins pwm0/s_axi]
make_bd_pins_external [get_bd_pins pwm0/pwm]
set_property name led [get_bd_ports pwm_0]
validate_bd_design
assign_bd_address
save_bd_design
write_bd_tcl -force reports/sys_bd.tcl
set fh [open reports/address_map.txt w]
foreach s [get_bd_addr_segs -of_objects [get_bd_addr_spaces ps7/Data]] { puts $fh "[get_property NAME $s] offset=[get_property OFFSET $s] range=[get_property RANGE $s]" }
close $fh
make_wrapper -files [get_files sys.bd] -top
add_files -norecurse [glob build/proj/zynq_pwm.gen/sources_1/bd/sys/hdl/sys_wrapper.v]
set_property top sys_wrapper [current_fileset]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
set ok [expr {[get_property PROGRESS [get_runs impl_1]] eq "100%"}]
write_hw_platform -fixed -include_bit -force build/zynq_pwm.xsa
set sz [file size build/zynq_pwm.xsa]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "impl_ok,xsa_bytes,luts,ffs,wns_ns"; puts $fh "$ok,$sz,$luts,$ffs,$wns"; close $fh
puts "RESULT ok=$ok xsa=$sz luts=$luts ffs=$ffs wns=$wns"
