# Episode 39 — High-Fmax design techniques, measured (companion code)

Four small experiments, each variant synthesized out of context for the PYNQ-Z2's `xc7z020clg400-1` (speed grade −1), placed and routed against a deliberately too-fast **2.000 ns** clock. The worst setup slack gives an estimate of the maximum frequency: **Fmax ≈ 1 / (2.000 ns − WNS)**. `scripts/run.tcl` runs all of them and writes `reports/results.csv`.

| experiment (`rtl/`) | variant | slack (ns) | est. Fmax (MHz) | LUT | FF | slices | notes |
|---|---|---|---|---|---|---|---|
| 1 pipelining (`tree.v`: sum of 16 × 32-bit) | one combinational tree | −7.315 | **107** | 309 | 548 | 162 | |
| | register every 2nd level | −2.060 | **246** | 490 | 684 | 171 | |
| | register every level | −1.010 | **332** | 508 | 1028 | 194 | 3.1× the frequency for 1.9× the flip-flops |
| 2 fanout (`fan.v`: 1 enable → 2000 FFs) | plain | +0.295 | 587* | 0 | 4013 | 710 | 14 control sets |
| | `MAX_FANOUT = 50` | +0.422 | 634* | 0 | 4040 | 795 | 41 control sets; +127 ps for +12% slices |
| 3 delay line 64 × 32 (`dly.v`) | with synchronous reset | +0.328 | 598* | 80 | 127 | 45 | 64 SRL + 80 LUT + 127 FF (unexpected: extra logic around SRLs, not examined) |
| | no reset (SRL) | +0.365 | 612* | 64 | 64 | 34 | 64 SRLs |
| | forced flip-flop chain | +0.548 | 689* | 0 | 2048 | 335 | `shreg_extract = no`; 10× the slices |
| | block RAM circular buffer | +0.275 | 580* | 4 | 6 | 2 | 0.5 block RAM tile |
| 4 control sets (`cs.v`: 1024 FFs) | one shared enable | +0.361 | 610* | 0 | 2055 | 362 | 8 control sets |
| | 256 different enables | +0.561 | 695* | 0 | 2304 | 699 | 257 control sets; 1.9× the slices, timing not worse |

\* the variant meets 2 ns, so this number is only a rough estimate of the achievable frequency, not a proven limit.

**Honest notes:** these are small out-of-context experiments, with one placement per variant, on one device and speed grade, without I/O timing, so they show the direction and size of each effect, not a guarantee for other designs. Flip-flop counts include the input/output registers of each test module. The unexpected result in the delay-line experiment (a reset version that still maps to SRLs) was not investigated. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make run
```
**Challenge:** add a variant of the adder tree that uses the DSP48 slices with a register after every level, and compare slack and area.
