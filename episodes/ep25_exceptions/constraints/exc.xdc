## PYNQ-Z2: 125 MHz clock H16, BTN0 D19, LEDs; din on Pmod A pin JA1 (Y18). Pins from the official PYNQ-Z2 constraints; not tested on a physical board.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports btn]
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports din]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
## input/output delays are not the subject of this episode: keep the ports out of the way
set_false_path -from [get_ports {btn din}]
set_false_path -to [get_ports {led[*]}]
