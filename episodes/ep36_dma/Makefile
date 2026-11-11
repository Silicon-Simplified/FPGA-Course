# AXI DMA + accelerator - Episode 36. Verilator 5 for `sim`, gcc for `driver`, arm-none-eabi-gcc for `arm`, Vivado 2023.2 on PATH for `build`.
.PHONY: sim driver arm build clean
sim:
	verilator --binary --timing -Wno-fatal --top-module tb_avg4 rtl/axis_avg4.v tb/tb_avg4.v && ./obj_dir/Vtb_avg4
driver:
	gcc -Wall -Wextra -O1 -o sw/test_dma sw/test_dma.c && sw/test_dma
arm:
	arm-none-eabi-gcc -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -O2 -Wall -Wextra -c sw/hello_dma.c -o sw/hello_dma.o && arm-none-eabi-size sw/hello_dma.o
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf obj_dir sw/test_dma sw/hello_dma.o build *.jou *.log .Xil
