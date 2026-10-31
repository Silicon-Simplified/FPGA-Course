## PYNQ-Z2 pins for alu_top. Names and pins are copied from the official PYNQ-Z2 constraints
## (Xilinx/PYNQ, boards/Pynq-Z2/base/vivado/constraints/base.xdc, tag v2.7.0); Vivado checks that each pin exists in the package.
## Inputs come from Pmod A / Pmod B; weak pull-downs make unconnected pins read 0.
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {a[0]}]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {a[1]}]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {a[2]}]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {a[3]}]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {b[0]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {b[1]}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {b[2]}]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {b[3]}]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {op[0]}]
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {op[1]}]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {op[2]}]
## LEDs LD0-LD3
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
## RGB LEDs: LD4 green = zero flag, LD5 green = carry
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports led_zero]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports led_carry]
## A purely combinational design has no clock, so there is nothing to time: tell Vivado that is intentional.
set_false_path -from [get_ports {a[*] b[*] op[*]}] -to [get_ports {led[*] led_zero led_carry}]
