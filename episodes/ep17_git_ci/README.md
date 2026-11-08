# Episode 17 — Git-friendly Vivado: Tcl builds, a template repo and CI (companion code)

`template/` is a complete starter repository (8 tracked files, 7,101 bytes): `.gitignore`, `Makefile`, `rtl/blinky.v`, `tb/tb_blinky.v`, `constraints/pynq_z2.xdc`, `scripts/build.tcl`, `scripts/sim.sh`, `.github/workflows/ci.yml`.
`make lint` (Verilator), `make test` (Verilator simulation of the self-checking testbench), `make bit` (Vivado non-project build, everything under `build/`, which is git-ignored), `make sim` (Vivado simulator).
`scripts/build.tcl` stores the first 8 hex digits of the git commit in the bitstream's `USR_ACCESS` register.

`scripts/experiments.sh` produced `reports/` (Vivado 2023.2, PYNQ-Z2 part `xc7z020clg400-1`, scratch directory without spaces):

| experiment | result |
|---|---|
| project mode, built to a bitstream, then `git add -A` | 97 files, 6,015,258 bytes |
| same, with the template `.gitignore` | 6 files (`proj.xpr` is 11,431 bytes and contains an absolute path) |
| `write_project_tcl -no_copy_sources` | `recreate.tcl`: 529 lines, 25,151 bytes; the project was regenerated from it in a fresh folder |
| template repo | 8 files, 7,101 bytes |
| `git clone` the template, `make bit` in both | identical: 42 LUT, 37 FF, +1.074 ns, 4,045,666 bytes (`result_original.csv`, `result_clone.csv`) |
| the two bitstreams, byte by byte | 2 bytes differ (offsets 92–94, in the header); the commit hash is found in the file (`bitstream_check.txt`) |
| `make lint`, `make test` | both exit 0 (the simulation prints PASS) |

**Honest notes:** the GitHub Actions workflow was **not** run on GitHub — only its two commands were run locally. `make lint` / `make test` need a path without spaces (a GNU make limitation in Verilator's generated makefile).
A full Vivado build in CI needs a self-hosted runner with a Vivado install and licence. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/experiments.sh /tmp/ep17_work      # about 6 minutes
```
**Challenge:** copy `template/`, change the top module to your own, and make the CI fail on purpose with a lint error.
