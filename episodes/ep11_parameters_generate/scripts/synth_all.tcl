# Silicon Simplified - FPGA Course, Episode 11
# What does Vivado build when the parameter changes?   vivado -mode batch -source scripts/synth_all.tcl
set part xc7a35tcpg236-1
file mkdir reports
set fh [open reports/synth_summary.csv w]
puts $fh "design,param,status,luts,flip_flops,carry4,logic_levels"
# (design, top, files, generic-name, list of values, extra generics)
set sets {
    {cnt_n    cnt_n    {rtl/cnt_n.v}                                        W {4 8 16 32 64} {}}
    {led_bar  led_bar  {rtl/led_bar.v}                                      N {8 16 32}      {}}
    {rca_gen  rca_gen  {rtl/full_adder.v rtl/rca_gen.v}                     N {8 16 32}      {}}
    {add_plus add_plus {rtl/add_plus.v}                                     N {8 16 32}      {}}
    {opt_pipe_comb opt_pipe {rtl/opt_pipe.sv}                               W {16}           {-generic PIPELINE=0}}
    {opt_pipe_reg  opt_pipe {rtl/opt_pipe.sv}                               W {16}           {-generic PIPELINE=1}}
    {opt_pipe_w1   opt_pipe {rtl/opt_pipe.sv}                               W {1}            {}}
}
foreach s $sets {
    lassign $s name top files gname values extra
    foreach v $values {
        puts "RUN $name $gname=$v"
        foreach f $files {
            if {[string match *.sv $f]} { read_verilog -sv $f } else { read_verilog $f }
        }
        if {[catch {eval synth_design -top $top -part $part -mode out_of_context -generic $gname=$v $extra} err]} {
            puts $fh "$name,$gname=$v,ERROR,,,,"
            puts "SYNTH $name $gname=$v : ERROR"
            catch {close_design}
            remove_files [get_files -quiet *]
            continue
        }
        opt_design
        set luts 0; set ffs 0; set c4 0
        foreach c [get_cells -hier -filter {IS_PRIMITIVE == 1}] {
            set rn [get_property REF_NAME $c]
            if {[string match LUT* $rn]} { incr luts }
            if {[string match FD* $rn]}  { incr ffs }
            if {$rn eq "CARRY4"} { incr c4 }
        }
        set ll {}
        if {[llength [get_ports -quiet clk]] && [llength [all_registers]]} {
            create_clock -period 10 [get_ports clk]
            set tp [get_timing_paths -max_paths 1 -setup -from [all_registers] -to [all_registers]]
        } else {
            create_clock -name vclk -period 10
            set_input_delay 0 -clock vclk [all_inputs]
            set_output_delay 0 -clock vclk [all_outputs]
            set tp [get_timing_paths -max_paths 1 -setup]
        }
        if {[llength $tp]} { set ll [get_property LOGIC_LEVELS $tp] }
        puts $fh "$name,$gname=$v,OK,$luts,$ffs,$c4,$ll"
        puts "SYNTH $name $gname=$v : LUTs=$luts FFs=$ffs CARRY4=$c4 levels=$ll"
        close_design
        remove_files [get_files -quiet *]
    }
}
close $fh
