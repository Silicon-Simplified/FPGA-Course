# Episode 29: what does report_cdc say about the XPM asynchronous FIFO?   vivado -mode batch -source scripts/xpm_cdc.tcl
file mkdir reports
read_verilog -sv rtl/fifo_lib.v
auto_detect_xpm
synth_design -top xa -part xc7z020clg400-1 -mode out_of_context -generic DEPTH=1024
create_clock -period 5.0  -name wclk [get_ports wclk]
create_clock -period 13.0 -name rclk [get_ports rclk]
set_clock_groups -asynchronous -group [get_clocks wclk] -group [get_clocks rclk]
report_cdc -summary -file reports/xpm_cdc_summary.rpt
report_cdc -details -file reports/xpm_cdc_details.rpt
