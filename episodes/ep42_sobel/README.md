# Episode 42 — Capstone 2: a streaming Sobel edge detector (companion code)

`rtl/sobel.v`: 8-bit grayscale pixels, one per accepted clock (`in_valid`); two line buffers (`W` pixels each, distributed RAM), a 3×3 register window, `|gx| + |gy|` clamped to 255, border pixels forced to 0 so the output frame has the same size and order as the input; the pipeline only moves when a pixel is accepted. `BUG = 1` (line buffers one pixel too short) and `BUG = 2` (no clamping) are used only by the test.
`tb/tb_sobel.v` feeds frames through it (optionally with random bubbles) and flushes it; `tools/sobel_model.py` makes the synthetic test images, a reference model, an independent cross-check with `scipy.ndimage.sobel`, runs the simulations and writes `reports/`. `scripts/build.tcl`: out-of-context Vivado flow for a 640 × 480 frame on the PYNQ-Z2's `xc7z020clg400-1` at 10 ns.

| experiment | result (`reports/`) |
|---|---|
| reference vs SciPy (`sim_sobel.txt`) | the model equals `scipy.ndimage.sobel` (|gx| + |gy|, before clamping) in the interior of both test images |
| RTL vs the model, 3 frames of 128 × 96 back to back | **36,864 pixels, 0 mismatches** with no gaps, and **0 mismatches with 30% random bubbles** on the input; latency **131 clocks** (W + 3: W + 2 accepted pixels and the registered valid flag); all border pixels 0 |
| planted bug 1: line buffers one pixel too short | **10,231 of 12,288 pixels wrong (83.3%)**, the picture is sheared (`image_bug1.png`) |
| planted bug 2: no clamping | **838 pixels wrong (6.8%)**, the strongest edges wrap around and turn dark (`image_bug2.png`) |
| Vivado, 640 × 480, out of context (`build_summary.csv`) | **348 LUT** (160 as distributed RAM = the line buffers), **114 FF, 0 block RAM, 0 DSP**, setup slack **+4.008 ns** at 100 MHz |

`image_in.png`, `image_sobel.png` (the RTL's output) and `image_threshold.png` are the pictures shown in the video.

**Honest notes:** the test images are synthetic (a gradient, a disc, a rectangle, a diagonal line, a bar and a little noise), not camera images; there is no camera and nothing was run on a physical board. The threshold picture (`> 80`) only serves the video; its threshold was chosen by eye. The output is `|gx| + |gy|`, not the square root of the sum of squares. The design assumes the frame size is fixed at synthesis (`W`, `H`) and frames follow each other without a sync signal.

## Run it
```bash
make test     # Verilator simulations, comparison and pictures (about a minute)
make build    # Vivado, 640 x 480, out of context
```
**Challenge:** use the square root of the sum of squares (or a threshold output) instead of `|gx| + |gy|`, and keep the model and the testbench in step.
