# Episode 27 — Block RAM and distributed RAM (companion code)

`rtl/ram_variants.v`: the same memory written in different ways (sine ROM `rtl/sine1024.hex`, 1024 x 12, synchronous / with output register / asynchronous; 1024 x 8 RAMs with three read-during-write behaviours; a true dual-port RAM; a DDS).
Vivado 2023.2, PYNQ-Z2 part `xc7z020clg400-1`, out-of-context.

| experiment | result (`reports/`) |
|---|---|
| `rom_bram` (clocked read, `$readmemh`) | **1 RAMB18**, 0 LUT, 0 FF |
| `rom_bram_oreg` (extra output register) | 1 RAMB18 with `DOA_REG = 1`, 0 FF: the register is inside the block RAM |
| `rom_dist` (`ram_style = "distributed"`, asynchronous read) | **151 LUT**, 0 block RAM |
| `ram_tdp` (true dual-port 1024 x 8) | 1 RAMB18 |
| `ram_readfirst / writefirst / nochange` | `WRITE_MODE_A` = READ_FIRST / WRITE_FIRST / NO_CHANGE (`variants.csv`) |
| read-during-write (simulation, `sim_rw.txt`): write 0xAA over 0x11 | read-first **0x11**, write-first **0xAA**, no-change **0x77** (the last read) |
| latency (simulation) | data after **1** clock edge; with the output register after **2** |
| BRAM-start timing path at a 3.0 ns clock (`bram_paths.csv`) | without output register 3.270 ns, slack **−0.435**; with it 1.852 ns, slack **+1.006** |
| `dds` | 1 RAMB18, 64 LUT, 44 FF |
| DDS, K = 34,359,738 (`dds_1mhz_summary.txt`) | expected 999,999.989 Hz, **measured 1,000,000.0 Hz** (20,000 samples at 125 MHz), amplitude ±2047 |
| DDS spectrum, 16,384 samples, 127 cycles (`dds_coherent_*`) | SFDR **60.14 dBc** (worst spur at bin 1151); about 6.02 dB per address bit × 10 bits |

Notes: the timing paths start at the block RAM only (`-from` the RAMB18 cell); the whole top-level design had other, unrelated critical paths at 3 ns. Run the simulations in a folder whose path has no spaces (Verilator's makefile cannot handle spaces). Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make synth
make bramtiming
make sim
```
**Challenge:** store only a quarter wave (256 entries) and rebuild the full sine with address and sign tricks. How much SFDR do you keep?
