#!/usr/bin/env python3
"""Episode 28: compare the FIR simulation with a numpy reference.   python3 scripts/check_fir.py <fir_in.txt> <fir_out.txt> <coeffs.txt> <summary out>"""
import sys
import numpy as np
xin, yout, ch, outp = sys.argv[1:5]
x = np.loadtxt(xin).astype(np.int64); y = np.loadtxt(yout).astype(np.int64); h = np.loadtxt(ch).astype(np.int64)
ref = np.convolve(x, h)[: len(x) + 6]
best = None
for lag in range(0, 8):
    a = y[lag:lag + len(ref) - 8]; b = ref[: len(a)]
    err = int(np.abs(a - b).max()) if len(a) else 10 ** 9
    if best is None or err < best[1]:
        best = (lag, err, len(a))
lag, err, n = best
# frequency response check: gain at DC and near Nyquist from the impulse response of the DUT is implied by the coefficients
w = np.fft.rfftfreq(256, 1.0)
H = np.abs(np.fft.rfft(h / 2 ** 15, 256))
res = dict(taps=len(h), samples_compared=n, latency_clocks=lag, max_abs_error=err, dc_gain=round(float(H[0]), 4), gain_at_0p45=round(float(H[np.argmin(abs(w - 0.45))]), 4), coeff_sum=int(h.sum()))
open(outp, "w").write("\n".join(f"{k}={v}" for k, v in res.items()) + "\n")
print(res)
