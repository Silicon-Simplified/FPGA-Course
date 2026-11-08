# Episode 15: synthesize every block of rtl/zoo.v on its own (out-of-context) and record what Vivado built.   vivado -mode batch -source scripts/zoo.tcl
set part xc7z020clg400-1
file mkdir reports
read_verilog rtl/zoo.v
set mods {add16 mux4_8 rom32x8 ram1k_bram ram1k_dist mult18_dsp mult18_lut shreg32 latch_bug trim_demo}
set fh [open reports/zoo.csv w]
puts $fh "module,lut,lutram,srl,ff,latch,carry4,bram18,bram36,dsp"
foreach m $mods {
    synth_design -top $m -part $part -mode out_of_context -flatten_hierarchy none
    set rep [report_utilization -return_string]
    set cells $rep
    proc num {rep pat} { if {[regexp $pat $rep -> v]} { return $v } else { return 0 } }
    set lut   [num $rep {Slice LUTs\*?\s*\|\s*(\d+)}]
    set lram  [num $rep {LUT as Distributed RAM\s*\|\s*(\d+)}]
    set srl   [num $rep {LUT as Shift Register\s*\|\s*(\d+)}]
    set ff    [num $rep {Slice Registers\s*\|\s*(\d+)}]
    set lat   [num $rep {Register as Latch\s*\|\s*(\d+)}]
    set cy    [num $cells {CARRY4\s*\|\s*(\d+)}]
    set b18   [num $rep {RAMB18\s*\|\s*(\d+)}]
    set b36   [num $rep {RAMB36/FIFO\*?\s*\|\s*(\d+)}]
    set dsp   [num $rep {DSPs\s*\|\s*(\d+)}]
    puts $fh "$m,$lut,$lram,$srl,$ff,$lat,$cy,$b18,$b36,$dsp"
    puts "ZOO $m lut=$lut lutram=$lram srl=$srl ff=$ff latch=$lat carry4=$cy bram18=$b18 bram36=$b36 dsp=$dsp"
    if {$m eq "ram1k_bram"} { report_utilization -file reports/util_ram1k_bram.rpt }
    if {$m eq "latch_bug"}  { report_utilization -file reports/util_latch_bug.rpt }
    close_design
}
close $fh
