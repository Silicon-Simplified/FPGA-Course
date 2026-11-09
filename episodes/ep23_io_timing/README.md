# Episode 23 — I/O timing: set_input_delay, set_output_delay, IOB packing (companion code)

`rtl/spi_adc.v`: a minimal SPI reader for a 12-bit ADC (AD7476-style frame, SCLK = clk / 16) on the PYNQ-Z2's Pmod A (`cs_n` Y18, `sdo` Y19, `sclk` Y16), `xc7z020clg400-1`, 125 MHz. `tb/tb_spi_adc.v` checks it against an ADC model (captures 0xA5C; `reports/sim_output.txt`).
`scripts/ioflow.tcl` implements it in three ways (full implementation in Vivado 2023.2): no I/O constraints (`none`), with `constraints/io_delays.xdc` and the flip-flops forced into the fabric (`fabric`), and with them forced into the I/O blocks (`iob`).
**The external delays (input 0.5 … 3.0 ns, output −1.0 … 2.0 ns) are EXAMPLE numbers for an imaginary ADC, not a datasheet.**

| experiment | result |
|---|---|
| no I/O constraints | `check_timing`: `no_input_delay` (1), `no_output_delay` (6): the pin paths are not timed |
| input path, flip-flop in the fabric | arrival 10.478 = 3.000 + IBUF 1.519 + routing 5.960; required 13.331 = 8.000 + clock latency 5.433 − 0.035 − 0.067; slack **+2.853**, hold +0.804 |
| the 5.960 ns of routing | hold fixing: with a minimum input delay of 2.5 ns the routing is 1.861 ns, slack +4.325, hold +1.203 (`paths_fabric_min2.5.csv`) |
| external delay sweep (max): 3.0 / 5.0 / 6.5 / 7.5 ns | fabric +2.853 / +0.853 / −0.647 / −1.647 (slack = 5.853 − delay); IOB +1.742 / −0.258 / −1.758 / −2.758 (slack = 4.742 − delay) |
| IOB packing | `sdo_q` in `ILOGIC_X1Y65` (routing 0), `cs_r` in `OLOGIC_X1Y66`, `sclk_r` stays in a slice; a `ZHOLD_DELAY` of 7.317 ns is inserted (also at min delay 2.5 ns); slack +1.742 |
| output path `cs_n` (max 2.0 ns vs `sys_clk`) | clock latency 5.931 + clk-to-Q 0.456 + routing 1.526 + OBUF 3.579 = 11.492 vs required 5.965: slack **−5.527** (`sclk` −5.588); hold +2.383 |

The output failure is the wrong *model*, not a design bug: a clock that leaves the chip should be constrained with a generated clock relative to the forwarded clock. That fix is described in the episode but **not demonstrated here**.
Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make sim      # in a folder whose path has no spaces
make io
make min25    # the challenge
```
**Challenge:** set the minimum input delay to 2.5 ns and see how much of the inserted hold delay disappears (fabric: the 5.960 ns detour; IOB: none).
