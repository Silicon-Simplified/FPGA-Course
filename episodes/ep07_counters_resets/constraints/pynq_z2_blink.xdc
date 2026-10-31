## PYNQ-Z2 pins. LEDs and button copied from the official PYNQ-Z2 constraints (Xilinx/PYNQ, boards/Pynq-Z2/base/vivado/constraints/base.xdc, tag v2.7.0);
## the 125 MHz PL system clock is on pin H16 (PYNQ-Z2 reference manual). Vivado checks that every pin exists in the package; not tested on a board.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports btn]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
