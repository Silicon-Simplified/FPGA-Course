# Episode 33: an AXI-Stream pipeline in IP Integrator = our axis_add (module reference) + the AXI4-Stream Data FIFO from the IP catalog.
# vivado -mode batch -source scripts/bd.tcl      (project is created in ./build; nothing here needs a board)
file mkdir reports
create_project -force axis_pipe build -part xc7z020clg400-1
add_files rtl/axis_add.v
update_compile_order -fileset sources_1
create_bd_design axis_pipe
set add [create_bd_cell -type module -reference axis_add add0]
set fifo [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 fifo0]
set_property -dict [list CONFIG.FIFO_DEPTH {512}] $fifo
set sp [create_bd_intf_port -mode Slave  -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS]
set mp [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS]
set_property -dict [list CONFIG.FREQ_HZ {125000000} CONFIG.HAS_TLAST {1} CONFIG.HAS_TREADY {1} CONFIG.TDATA_NUM_BYTES {4}] $sp
create_bd_port -dir I -type clk -freq_hz 125000000 aclk
create_bd_port -dir I -type rst aresetn
connect_bd_intf_net [get_bd_intf_ports S_AXIS] [get_bd_intf_pins add0/s_axis]
connect_bd_intf_net [get_bd_intf_pins add0/m_axis] [get_bd_intf_pins fifo0/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins fifo0/M_AXIS] [get_bd_intf_ports M_AXIS]
connect_bd_net [get_bd_ports aclk] [get_bd_pins add0/aclk] [get_bd_pins fifo0/s_axis_aclk]
connect_bd_net [get_bd_ports aresetn] [get_bd_pins add0/aresetn] [get_bd_pins fifo0/s_axis_aresetn]
set_property CONFIG.ASSOCIATED_BUSIF {S_AXIS:M_AXIS} [get_bd_ports aclk]
validate_bd_design
save_bd_design
write_bd_tcl -force reports/axis_pipe_bd.tcl
make_wrapper -files [get_files axis_pipe.bd] -top
add_files -norecurse [glob build/axis_pipe.gen/sources_1/bd/axis_pipe/hdl/axis_pipe_wrapper.v]
set_property top axis_pipe_wrapper [current_fileset]
set fx [open build/axis.xdc w]; puts $fx "create_clock -period 8.000 -name aclk \[get_ports aclk\]"; close $fx
add_files -fileset constrs_1 build/axis.xdc
generate_target all [get_files axis_pipe.bd]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1
report_utilization -file reports/utilization.rpt
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} brams {Block RAM Tile\s*\|\s*([\d.]+)}} { if {[regexp $pat $rep m val]} { set $v $val } else { set $v 0 } }
puts "RESULT luts=$luts ffs=$ffs brams=$brams"
set fh [open reports/build_summary.csv w]; puts $fh "luts,ffs,bram_tiles,bd_cells,wns_ns"
set wns n/a
catch { set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]] }
puts $fh "$luts,$ffs,$brams,[llength [get_bd_cells]],$wns"; close $fh
