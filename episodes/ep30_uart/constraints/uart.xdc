## PYNQ-Z2: 125 MHz clock on H16; UART on Pmod A: tx = JA1 (Y18), rx = JA2 (Y19); LEDs LD0..LD3. Pins from the official PYNQ-Z2 constraints; NOT tested on a physical board.
## (The board's USB-UART is wired to the Zynq processing system, so for the PL we use Pmod pins and an external 3.3 V USB-UART adapter.)
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 } [get_ports tx]
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports rx]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
## rx is asynchronous (an external device), tx and the LEDs have no timing requirement here
set_false_path -from [get_ports rx]
set_false_path -to [get_ports {tx led[*]}]
