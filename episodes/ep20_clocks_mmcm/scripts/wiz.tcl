# the Clocking Wizard IP for the same job: 125 MHz in, 250 MHz + 62.5 MHz out.  vivado -mode batch -source scripts/wiz.tcl -tclargs <report dir>
set repdir [lindex $argv 0]
create_project -in_memory -part xc7z020clg400-1
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0
set_property -dict [list CONFIG.PRIM_IN_FREQ {125.000} CONFIG.CLKOUT1_USED {true} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {250.000} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {62.500} CONFIG.USE_RESET {false}] [get_ips clk_wiz_0]
set fh [open $repdir/wizard.csv w]
puts $fh "key,value"
foreach p {PRIMITIVE CLKOUT1_REQUESTED_OUT_FREQ CLKOUT2_REQUESTED_OUT_FREQ MMCM_DIVCLK_DIVIDE MMCM_CLKFBOUT_MULT_F MMCM_CLKOUT0_DIVIDE_F MMCM_CLKOUT1_DIVIDE} {
    catch { puts $fh "$p,[get_property CONFIG.$p [get_ips clk_wiz_0]]" }
}
close $fh
generate_target all [get_ips clk_wiz_0]
synth_ip [get_ips clk_wiz_0]
open_checkpoint [get_property IP_OUTPUT_DIR [get_ips clk_wiz_0]]/clk_wiz_0.dcp
set fh [open $repdir/wizard_cells.txt w]
foreach c [get_cells -hier -filter {PRIMITIVE_LEVEL==LEAF}] { puts $fh [get_property REF_NAME $c] }
close $fh
