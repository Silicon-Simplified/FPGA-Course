# Button interrupt controller - Episode 37. Verilator 5 for `sim`, gcc for `driver`, arm-none-eabi-gcc for `arm`, Vivado 2023.2 on PATH for `build`.
.PHONY: sim driver arm build clean
sim:
	for m in 0 1 2; do verilator --binary --timing -Wno-fatal --top-module tb_irq -GMUT=$$m -Mdir obj$$m rtl/axil_irq.v tb/tb_irq.v && ./obj$$m/Vtb_irq; done
driver:
	gcc -Wall -Wextra -O1 -o sw/test_irq sw/test_irq.c && sw/test_irq
arm:
	arm-none-eabi-gcc -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -O2 -Wall -Wextra -c sw/hello_irq.c -o sw/hello_irq.o && arm-none-eabi-size sw/hello_irq.o
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf obj0 obj1 obj2 sw/test_irq sw/hello_irq.o build *.jou *.log .Xil
