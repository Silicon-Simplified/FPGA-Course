# Program the PYNQ-Z2's PL over JTAG.   vivado -mode batch -source scripts/prog.tcl
# NOT TESTED ON HARDWARE in this course material: the boot-mode jumper must be set to JTAG first - check the PYNQ-Z2 reference manual.
open_hw_manager
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices xc7z020_1]
set_property PROGRAM.FILE out/blinky.bit [current_hw_device]
program_hw_devices [current_hw_device]
close_hw_manager
