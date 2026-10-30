# Silicon Simplified - FPGA Course, Episode 1
# Non-project synthesis for a Basys 3 (Artix-7 xc7a35tcpg236-1).
# Run from the code/ folder:   vivado -mode batch -source scripts/synth.tcl
set part xc7a35tcpg236-1
file mkdir reports

foreach top {any_function six_input_function} {
    read_verilog rtl/$top.v
    synth_design -top $top -part $part
    report_utilization -file reports/${top}_utilization.rpt
    puts "RESULT $top : [llength [get_cells -hier -filter {PRIMITIVE_GROUP == LUT}]] LUT(s),\
          primitive = [get_property REF_NAME [get_cells -hier -filter {PRIMITIVE_GROUP == LUT}]]"
    close_project
}
