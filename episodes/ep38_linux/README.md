# Episode 38 — Linux on the Zynq: device tree and UIO (companion code)

`tools/gen_dts.py`: generates device-tree fragments (a `generic-uio` node) for the peripherals of episodes 35 (PWM) and 37 (button interrupt controller) **from their Vivado address maps**, into `dts/`. `sw/uio_pwm.h`, `sw/uio_pwm.c`: a user-space program that opens `/dev/uio0`, maps the registers with `mmap` and starts the PWM (register map of episode 35). `sw/test_uio.c`: tests that code on the PC.

| experiment | result (`reports/`) |
|---|---|
| generated device tree (`dts_check.txt`, `dts/`) | `pwm@40000000`: `reg = <0x40000000 0x1000>` (from the episode 35 address map); `btn-irq@40000000` with `interrupts = <0 29 4>` (SPI 29 = GIC ID 61, level high, matching episode 37). Text checks only: braces balanced, every line ends in `;` or `{`, unit address equals the `reg` base |
| user-space test (`uio_test.txt`) | **13 checks, 0 errors**: a regular file stands in for `/dev/uio0` (a wrong ID is refused, a missing device is refused, the register writes land in the mapping: CTRL 1, PERIOD 1000, duties 0 / 250 / 500 / 1000, the ID stays untouched); a socket pair stands in for the UIO interrupt file (the count 7 is read and 1 is written back to re-enable) |

**Honest notes:** the device tree was **not compiled** with `dtc` (not installed here), so syntax and bindings were only checked as text. The UIO driver in the Linux kernel, PetaLinux, U-Boot and the PYNQ image were **not used**: the PC test checks only this repository's own user-space code against stand-ins, and `uio_pwm.c` was compiled for the PC, not for ARM Linux (no Linux cross-compiler installed). The UIO behaviour (`/dev/uioN`, `mmap`, interrupt count by `read`, re-enable by `write`) and the kernel option for `generic-uio` come from the Linux kernel documentation, not from a measurement. The interrupt number (SPI 29) comes from the Zynq-7000 reference manual. Nothing was run on a physical board.

## Run it
```bash
make dts    # regenerate the device-tree fragments from the address maps
make test   # user-space test on the PC
```
**Challenge:** write the same test for a second register block, or add a `--wait-irq` option to `uio_pwm.c` that blocks in `uio_wait_irq()` and prints the count.
