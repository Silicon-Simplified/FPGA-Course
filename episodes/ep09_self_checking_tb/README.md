# Episode 9 — Testbenches that check themselves (companion code)

Every claim in the video is backed by a run of the Vivado simulator (`xvlog` → `xelab` → `xsim -R`, Vivado 2023.2).

| Testbench | What it shows | Result |
|---|---|---|
| `tb/tb_directed.v` | the 8 operations with a = 6, b = 3 | **0 errors for both** `alu4` and `alu4_bug` — the directed test cannot tell them apart |
| `tb/tb_random.v` | 200 random vectors, fixed seed 1 | first failure at vector **5** (8 failing vectors out of 200) |
| `tb/tb_seeds.v` | 50 different seeds | the bug is found after **2 … 60** random vectors (mean 18), never missed |
| `tb/tb_exhaustive.v` | all 2048 combinations of a, b, op | `alu4`: 0 errors · `alu4_bug`: **128** errors. First failure: `op=7 a=8 b=0 got y=12 expected y=4` |
| `tb/tb_pipe.v` | clocked testbench + 2-register scoreboard | 2-stage adder: 0 errors in 210 checks · 1-stage adder (latency bug): **210** errors in 210 checks |

`rtl/alu4_bug.v` has exactly one bug: SHR is an arithmetic shift, so it is wrong only when `a[3] = 1`.
The reference model is a Verilog function using plain integer arithmetic (written differently from the ALU), and the checker uses `!==` so X and Z count as mismatches.
Timing: each flow run takes about 12–14 s, almost all of it tool start-up (`reports/timing.txt`): xsim itself needed 8.3 s for 8 vectors and 7.8 s for 2048.

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                                       # all testbenches + reports/timing.txt + reports/wave_pipe.vcd
python3 scripts/vcd2json.py reports/wave_pipe.vcd reports/wave_pipe.json   # (used by the animation)
```
**Challenge:** the 8-bit ALU has 2^19 = 524,288 input combinations. Guess how long the simulation takes, then run it.
