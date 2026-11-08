## PYNQ-Z2 pins for the blinky.
## LEDs, button and switches are copied from the official PYNQ-Z2 constraints (Xilinx/PYNQ, boards/Pynq-Z2/base/vivado/constraints/base.xdc, tag v2.7.0).
## The 125 MHz PL system clock is on pin H16 (PYNQ-Z2 reference manual). Vivado checks every pin against the package; not tested on a physical board.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]          ;# 125 MHz = 8 ns
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports btn]        ;# BTN0
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]    ;# SW0
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]    ;# SW1
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]   ;# LD0
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]   ;# LD1
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]   ;# LD2
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]   ;# LD3
