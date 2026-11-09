## EXAMPLE numbers for an imaginary ADC (use your device's datasheet): its data pin changes 0.5 .. 3.0 ns after the clock edge seen at the FPGA; the ADC needs the outputs stable 2.0 ns before / 1.0 ns after.
set_input_delay  -clock sys_clk -max 3.0  [get_ports sdo]
set_input_delay  -clock sys_clk -min 0.5  [get_ports sdo]
set_output_delay -clock sys_clk -max 2.0  [get_ports {cs_n sclk}]
set_output_delay -clock sys_clk -min -1.0 [get_ports {cs_n sclk}]
