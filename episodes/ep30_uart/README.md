# Episode 30 — UART from scratch (companion code)

`rtl/uart.v`: `baud_gen` (a tick 16 times per bit, divider = round(clk / (baud × 16))), `uart_tx` (8N1 shift register), `uart_rx` (16× oversampling: start-edge detect, half-bit check, mid-bit sampling, stop-bit / framing-error check) and `uart_top` (an echo design with the low 4 received bits on the LEDs).
PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz), Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| divider arithmetic (`baud_table.csv`) | 9600 → 814 (−0.02%); 115200 → 68 (114,889.7 baud, **−0.27%**); 230400 → 34; 460800 → 17; **921600 → 8 (976,562.5 baud, +5.96%)**; 1,000,000 → 8 (−2.34%) |
| loopback (`tb/tb_uart.v`, `sim_uart.txt`) | all 256 byte values TX → RX: 256 sent, 256 received, **0 errors** |
| receiver tolerance, 40 bytes per step | **0 bad bytes from −5% to +5%** bit-time error; −6%: 14, −7%: 30; +6%: 11, +7%: 27 (theory: 0.5 bit / 9.5 bits = 5.3%) |
| break (line low for a whole frame) | framing error flagged |
| 921600 baud with a real transmitter (`tb/tb_hi.v`) | divider 8 (+5.96%): **49 of 200** bytes wrong |
| FPGA build (`build_summary.csv`) | **33 LUT, 77 FF, setup slack +3.985 ns**, bitstream written; `tx` = Pmod A JA1 (Y18), `rx` = JA2 (Y19) |

**Honest notes:** nothing was run on a physical board. The PYNQ-Z2's on-board USB-UART is wired to the Zynq processing system, so the PL UART needs an external 3.3 V USB-UART adapter on the Pmod pins. Run the simulations in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim
make build
```
**Challenge:** add an even-parity bit (8E1) and rerun the tolerance sweep: how does the window change?
