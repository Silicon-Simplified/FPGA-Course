# AXI4-Lite PWM peripheral - Episode 35. Verilator 5 for `sim`, gcc for `driver`, Vivado 2023.2 on PATH for `build`.
.PHONY: sim driver arm build clean
sim:
	for m in 0 1 2; do verilator --binary --timing -Wno-fatal --top-module tb_axil -GMUT=$$m -Mdir obj$$m rtl/axil_pwm.v tb/tb_axil.v && ./obj$$m/Vtb_axil; done
driver:
	gcc -Wall -Wextra -O1 -o sw/test_driver sw/test_driver.c && sw/test_driver
arm:
	arm-none-eabi-gcc -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -O2 -Wall -Wextra -c sw/hello_pwm.c -o sw/hello_pwm.o && arm-none-eabi-size sw/hello_pwm.o
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf obj0 obj1 obj2 sw/test_driver sw/hello_pwm.o build *.jou *.log .Xil
