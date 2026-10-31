# Silicon Simplified - FPGA Course, Episode 5
# Full flow for the PYNQ-Z2 (non-project mode): synth -> place -> route -> bitstream.   vivado -mode batch -source scripts/build_top.tcl
set part xc7z020clg400-1
file mkdir reports build
foreach f {adder4.v alu4.v alu_top.v} { read_verilog rtl/$f }
read_xdc constraints/pynq_z2.xdc
synth_design -top alu_top -part $part
opt_design; place_design; route_design
report_utilization -file reports/alu_top_utilization.rpt
report_io          -file reports/alu_top_io.rpt
report_drc         -file reports/alu_top_drc.rpt
write_bitstream -force build/alu_top.bit
set rep [report_utilization -return_string]
regexp {Slice LUTs\*?\s*\|\s*(\d+)} $rep -> luts
regexp {Slice Registers\s*\|\s*(\d+)} $rep -> ffs
regexp {Bonded IOB\s*\|\s*(\d+)} $rep -> iobs
set fh [open reports/alu_top_summary.csv w]
puts $fh "luts,flip_flops,bonded_iobs,bit_bytes"
puts $fh "$luts,$ffs,$iobs,[file size build/alu_top.bit]"
close $fh
puts "TOP luts=$luts ffs=$ffs iobs=$iobs bitfile=[file size build/alu_top.bit] bytes"
