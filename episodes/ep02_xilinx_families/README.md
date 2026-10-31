# Episode 2 — Xilinx/AMD families (companion code)

Everything on screen about device sizes was read from **Vivado 2023.2's own device database**. These Tcl scripts
reproduce it on your machine, for whatever devices your Vivado install includes.

| File | What it does |
|---|---|
| `scripts/device_table.tcl` | one row per device (LUTs, flip-flops, block RAMs, DSP slices, max I/O pins, MMCMs) for every installed family |
| `scripts/decode_part.tcl` | decodes part numbers: family, device, package, speed grade, usable I/O, temperature range |
| `scripts/props.tcl` | lists every property Vivado exposes for a part |
| `reports/device_table.csv` | output of `device_table.tcl` (Vivado 2023.2) |
| `reports/part_decode.txt` | output of `decode_part.tcl` (Vivado 2023.2) |

## Run it
```bash
source <vivado install>/settings64.sh
vivado -mode batch -source scripts/device_table.tcl     # -> reports/device_table.csv
vivado -mode batch -source scripts/decode_part.tcl      # -> reports/part_decode.txt
```

## Reading a part number
```
xc7a35t cpg236 -1
|   |   |      |
|   |   |      speed grade (-1 slowest ... -3 fastest; -2L = low power)
|   |   package + ball count  (same die: cpg236 -> 106 usable I/O, csg324 -> 210)
|   size  (bigger number = bigger device)
xc7a = Xilinx, 7 series, Artix   (s Spartan, k Kintex, v Virtex, z Zynq)
```

**Challenge:** put the part number from *your* board into `decode_part.tcl` and run it.

`reports/part_decode_z020.txt` (from the second half of `decode_part.tcl`) lists every `xc7z020` part in the database: packages `clg400` (125 usable I/O, the PYNQ-Z2) and `clg484` (200), speed grades -1/-2/-3, and the industrial `xc7z020i` in -1L (-40 to 100 C).
