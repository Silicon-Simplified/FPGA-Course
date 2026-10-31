# Episode 12 — A tour of Vivado: project vs non-project mode (companion code)

The same design (`top_blink_en`: the Episode 7 clock-enable blinker) built twice from a clean directory for the PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz):
once in **project mode** (what the GUI drives) and once in **non-project mode** (a script, everything in memory). `scripts/compare.sh` runs both and measures what each leaves behind.

| | project mode | non-project mode |
|---|---|---|
| time (this machine) | **134.3 s** | **75.5 s** |
| worst setup slack | +3.758 ns | +3.758 ns |
| LUTs / flip-flops | 10 / 31 | 10 / 31 |
| bitstream | 4,045,672 bytes | 4,045,672 bytes |
| files created | **96** in 13 folders (5.8 MB) | **8** in 2 folders (3.9 MB, mostly the .bit) |

Other measurements in `reports/`: `pm_breakdown.csv` (files per project sub-folder), `tree_np.txt` / `tree_pm_top3.txt` (what is left on disk),
`tcl_session_journal.txt` (the journal of a 6-command Tcl-console session; replayed in batch mode it gives the same result),
`vivado_modes.txt` (`vivado -help`: modes `gui`, `tcl`, `batch`).
Note: a batch run with `-source script.tcl` journals only the single `source` line; the commands inside the script appear in `vivado.log`.

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/compare.sh        # builds both ways, writes reports/mode_compare.csv   (about 4 minutes)
```
**Challenge:** run both scripts on your own design and count the files each leaves behind.

Notes on repeatability: a second run of `compare.sh` gave 76.3 s (non-project) and 139.6 s (project) with exactly the same slack, LUTs, flip-flops, file counts and sizes,
and `reports/bitstream_diff.txt` shows **0 differing bytes** between the two bitstreams after their 256-byte headers (the header holds the date and design name).
Times depend on your machine; the ratio (project mode about 1.8x slower here) is the point. The video quotes the first run.
