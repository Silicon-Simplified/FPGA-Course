# Episode 8 — Finite state machines (companion code)

Every claim in the video is backed by a run: the Vivado simulator (`xsim`) and Vivado 2023.2 synthesis (out-of-context) for the PYNQ-Z2 part (`xc7z020clg400-1`).

| Design | What it shows | Result |
|---|---|---|
| `rtl/fsm_traffic.v` | Moore traffic light, three-process style | green 5 ticks, yellow 2 ticks, greens never overlap (testbench). Vivado: FSM extracted, **6 flip-flops** (2 state + 4 timer) |
| `rtl/seq_mealy.v` / `seq_moore.v` | overlapping `1011` detector | Mealy answers in the same cycle (55 ns), Moore one clock later (65 ns). Mealy: 4 states, **2 FF, 3 LUT**. Moore: 5 states, **5 FF, 5 LUT** (Vivado chose one-hot) |
| `rtl/fsm8.v` | 8-state machine, five encodings (`scripts/synth_all.tcl` rewrites `fsm_encoding`) | auto → one-hot **8 FF / 12 LUT**; sequential **3 / 6**; gray **3 / 6**; johnson **4 / 7**; extraction off **3 / 5**; every variant has **1 logic level** |
| `rtl/fsm_unsafe.v` / `fsm_safe.v` | injected illegal state 6 | unsafe stays in 6 forever; safe returns to 0 at the next edge; both **4 LUT, 3 FF** |
| `rtl/debounce.v` | synchronizer + 4-state debouncer | bouncy button pressed twice: naive edge counter **10**, debouncer **2 presses**. N = 1,000,000 (10 ms at 100 MHz) → **24 flip-flops** |

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                                   # testbenches + reports/wave_*.vcd
python3 scripts/vcd2json.py reports/wave_seq.vcd reports/wave_seq.json   # (used by the animation)
vivado -mode batch -source scripts/synth_all.tcl          # -> reports/synth_summary.csv
```
**Challenge:** stretch the debouncer to 20 ms at 100 MHz (`N = 2_000_000`). Guess how many flip-flops it needs, then check in Vivado.
