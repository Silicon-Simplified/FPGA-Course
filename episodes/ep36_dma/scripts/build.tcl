# Episode 36: PS + AXI DMA + our streaming accelerator in IP Integrator.
#   memory --(HP0)--> DMA MM2S --> axis_avg4 --> DMA S2MM --(HP0)--> memory;   the processor programs the DMA over GP0 (AXI4-Lite).
#   vivado -mode batch -source scripts/build.tcl
file mkdir reports build
create_project -force zynq_dma build/proj -part xc7z020clg400-1
add_files rtl/axis_avg4.v
update_compile_order -fileset sources_1
create_bd_design sys
set ps [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7]
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100}] $ps
make_bd_intf_pins_external [get_bd_intf_pins ps7/DDR]
make_bd_intf_pins_external [get_bd_intf_pins ps7/FIXED_IO]
set dma [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 dma0]
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_length_width {23} CONFIG.c_include_mm2s {1} CONFIG.c_include_s2mm {1}] $dma
create_bd_cell -type module -reference axis_avg4 avg0
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins ps7/M_AXI_GP0_ACLK] [get_bd_pins ps7/S_AXI_HP0_ACLK]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "/ps7/FCLK_CLK0 (100 MHz)"} [get_bd_intf_pins dma0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/dma0/M_AXI_MM2S" Clk "/ps7/FCLK_CLK0 (100 MHz)"} [get_bd_intf_pins ps7/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/dma0/M_AXI_S2MM" Clk "/ps7/FCLK_CLK0 (100 MHz)"} [get_bd_intf_pins ps7/S_AXI_HP0]
connect_bd_intf_net [get_bd_intf_pins dma0/M_AXIS_MM2S] [get_bd_intf_pins avg0/s_axis]
connect_bd_intf_net [get_bd_intf_pins avg0/m_axis] [get_bd_intf_pins dma0/S_AXIS_S2MM]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins avg0/aclk]
connect_bd_net [get_bd_pins rst_ps7_100M/peripheral_aresetn] [get_bd_pins avg0/aresetn]
validate_bd_design
assign_bd_address
save_bd_design
write_bd_tcl -force reports/sys_bd.tcl
set fh [open reports/address_map.txt w]
foreach sp [get_bd_addr_spaces] { foreach s [get_bd_addr_segs -of_objects $sp] { puts $fh "[get_property PATH $s] offset=[get_property OFFSET $s] range=[get_property RANGE $s]" } }
close $fh
make_wrapper -files [get_files sys.bd] -top
add_files -norecurse [glob build/proj/zynq_dma.gen/sources_1/bd/sys/hdl/sys_wrapper.v]
set_property top sys_wrapper [current_fileset]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file reports/utilization.rpt
report_timing_summary -file reports/timing_summary.rpt
set ok [expr {[get_property PROGRESS [get_runs impl_1]] eq "100%"}]
write_hw_platform -fixed -include_bit -force build/zynq_dma.xsa
set sz [file size build/zynq_dma.xsa]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} brams {Block RAM Tile\s*\|\s*([\d.]+)} dsps {DSPs\s*\|\s*(\d+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set fh [open reports/build_summary.csv w]; puts $fh "impl_ok,xsa_bytes,luts,ffs,bram_tiles,dsps,wns_ns"; puts $fh "$ok,$sz,$luts,$ffs,$brams,$dsps,$wns"; close $fh
puts "RESULT ok=$ok xsa=$sz luts=$luts ffs=$ffs bram=$brams dsp=$dsps wns=$wns"
