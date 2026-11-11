## PYNQ-Z2: 125 MHz clock H16; SPI on Pmod B (cs_n W14, mosi Y14, miso T11, sclk T10); I2C on Pmod A (scl Y16, sda Y17) with internal pull-ups; LEDs LD0..LD3.
## Pins from the official PYNQ-Z2 constraints; NOT tested on a physical board.
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 8.000 -name sys_clk [get_ports clk]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports spi_cs_n]
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports spi_mosi]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports spi_miso]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports spi_sclk]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 PULLUP true } [get_ports i2c_scl]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 PULLUP true } [get_ports i2c_sda]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
## the external devices are asynchronous to this clock for the purposes of this demo
set_false_path -from [get_ports {spi_miso i2c_sda}]
set_false_path -to [get_ports {spi_cs_n spi_mosi spi_sclk i2c_scl i2c_sda led[*]}]
