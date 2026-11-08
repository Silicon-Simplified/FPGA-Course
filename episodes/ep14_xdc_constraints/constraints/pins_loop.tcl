## The same pins as base.xdc, written with Tcl loops. read_xdc does NOT allow "for" (see reports/x_for.txt), so this is a .tcl file: use `source`.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports btn]
set sw_pins  {M20 M19}
set led_pins {R14 P14 N16 M14}
for {set i 0} {$i < 2} {incr i} { set_property -dict "PACKAGE_PIN [lindex $sw_pins $i] IOSTANDARD LVCMOS33" [get_ports "sw\[$i\]"] }
for {set i 0} {$i < 4} {incr i} { set_property -dict "PACKAGE_PIN [lindex $led_pins $i] IOSTANDARD LVCMOS33" [get_ports "led\[$i\]"] }
