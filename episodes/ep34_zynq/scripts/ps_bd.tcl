# Episode 34: the smallest Zynq design = the processing system alone. Builds the block design, lists its PS-PL interfaces,
# implements it, writes the bitstream and exports the hardware platform (.xsa) that Vitis would start from.
#   vivado -mode batch -source scripts/ps_bd.tcl
file mkdir reports build
create_project -force zynq_ps build/proj -part xc7z020clg400-1
create_bd_design ps
set ps [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
# GP0 = the processor talks to PL, HP0 = PL talks to DDR memory; two PL clocks
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_EN_CLK1_PORT {1}] $ps
make_bd_intf_pins_external [get_bd_intf_pins processing_system7_0/DDR]
make_bd_intf_pins_external [get_bd_intf_pins processing_system7_0/FIXED_IO]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]
validate_bd_design
save_bd_design
write_bd_tcl -force reports/ps_bd.tcl
# interface inventory
set fh [open reports/ps_interfaces.txt w]
foreach p [lsort [get_bd_intf_pins processing_system7_0/*]] { puts $fh "intf [get_property NAME $p] [get_property MODE $p] [get_property VLNV $p]" }
foreach p [lsort [get_bd_pins processing_system7_0/FCLK_CLK*]] { puts $fh "clock [get_property NAME $p] [expr {[get_property CONFIG.FREQ_HZ $p] / 1000000}] MHz" }
close $fh
make_wrapper -files [get_files ps.bd] -top
add_files -norecurse [glob build/proj/zynq_ps.gen/sources_1/bd/ps/hdl/ps_wrapper.v]
set_property top ps_wrapper [current_fileset]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file reports/utilization.rpt
set ok [expr {[get_property PROGRESS [get_runs impl_1]] eq "100%"}]
write_hw_platform -fixed -include_bit -force build/zynq_ps.xsa
set sz [file size build/zynq_ps.xsa]
set bsz [file size [glob build/proj/zynq_ps.runs/impl_1/*.bit]]
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} luts_avail {Slice LUTs\*?\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*(\d+)} brams {Block RAM Tile\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*(\d+)} dsps {DSPs\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*\d+\s*\|\s*(\d+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
set fh [open reports/build_summary.csv w]; puts $fh "impl_ok,xsa_bytes,bit_bytes,luts_used,luts_avail,bram_tiles_avail,dsp_avail"; puts $fh "$ok,$sz,$bsz,$luts,$luts_avail,$brams,$dsps"; close $fh
puts "RESULT ok=$ok xsa=$sz bit=$bsz luts=$luts/$luts_avail bram=$brams dsp=$dsps"
