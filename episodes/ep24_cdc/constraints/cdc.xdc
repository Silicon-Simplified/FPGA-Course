## PYNQ-Z2: 125 MHz clock on H16, LEDs LD0..LD3. Only the input clock is constrained; the two MMCM outputs are declared asynchronous to each other.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
