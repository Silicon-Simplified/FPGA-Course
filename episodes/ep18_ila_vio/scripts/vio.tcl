# Episode 18: what does a VIO core cost?  4 probe inputs (watch) + 4 probe outputs (drive from the host)
#   run from a scratch directory:  vivado -mode batch -source <path>/scripts/vio.tcl -tclargs <output_report_dir>
set repdir [lindex $argv 0]
create_project -in_memory -part xc7z020clg400-1
create_ip -name vio -vendor xilinx.com -library ip -module_name vio_0
set_property -dict [list CONFIG.C_NUM_PROBE_IN {4} CONFIG.C_NUM_PROBE_OUT {4} CONFIG.C_PROBE_IN0_WIDTH {4} CONFIG.C_PROBE_OUT0_WIDTH {2}] [get_ips vio_0]
generate_target all [get_ips vio_0]
synth_ip [get_ips vio_0]
open_checkpoint [get_property IP_OUTPUT_DIR [get_ips vio_0]]/vio_0.dcp
set rep [report_utilization -return_string]
foreach {v pat} {luts {Slice LUTs\*?\s*\|\s*(\d+)} ffs {Slice Registers\s*\|\s*(\d+)} tiles {Block RAM Tile\s*\|\s*([0-9.]+)}} { if {![regexp $pat $rep -> $v]} { set $v 0 } }
set fh [open $repdir/vio.csv w]; puts $fh "core,probe_in,probe_out,luts,ffs,bram_tiles"; puts $fh "vio,4,4,$luts,$ffs,$tiles"; close $fh
puts "RESULT vio luts=$luts ffs=$ffs tiles=$tiles"
