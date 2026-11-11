# Episode 31 — SPI and I²C masters (companion code)

`rtl/spi_master.v`: a parameterised SPI master (`DIV`, `CPOL`, `CPHA`; SCLK = clk / (2·DIV)). `rtl/i2c_master.v`: a byte-level I²C master (START / WRITE / READ / STOP commands, open-drain outputs, ACK/NACK reporting, no clock stretching, single master). `rtl/comm_top.v`: both masters driven by a slow test sequencer.
PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz), Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| SPI, all 4 modes (`tb/tb_spi.v`, `sim_spi.txt`) | 256 bytes per mode, **256 ok, 0 errors** each; slave answers with the inverted byte so both directions are checked; one byte = 1632 ns; SCLK 5208 kHz |
| mutation check | master in the wrong phase: mode 1 gives **0 ok / 256 errors** (mode 0 still passes, since it is phase-insensitive in this testbench) |
| I²C (`tb/tb_i2c.v`, `sim_i2c.txt`) | write 4 bytes to a slave model (0x50): all ACKed; repeated-START read-back **11 22 33 44**; wrong address 0x51 → **NACK**; SCL 100,160 Hz; write transaction 559 µs |
| FPGA build (`build_summary.csv`) | **85 LUT, 123 FF, 11 IOBs, setup slack +2.979 ns**, bitstream written; SPI on Pmod B, I²C on Pmod A (Y16/Y17, PULLUP) |

**Honest notes:** nothing was run on a physical board, and no real SPI or I²C device was connected. The FPGA's internal pull-up is weak; real I²C buses normally need external pull-up resistors. Run the simulations in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim
make build
```
**Challenge:** add clock stretching to the master and to the slave model.
