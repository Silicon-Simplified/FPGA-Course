#!/usr/bin/env python3
"""Episode 42 - test images, a bit-exact Sobel reference, an independent cross-check with scipy, and the simulation runner.
usage: python3 tools/sobel_model.py test      (needs numpy, scipy, Pillow, Verilator; writes reports/sim_sobel.txt and reports/*.png)"""
import os
import subprocess
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

HERE = os.path.dirname(os.path.abspath(__file__))
CODE = os.path.join(HERE, "..")
W, H = 128, 96


def make_image(seed):
    rng = np.random.default_rng(seed)
    yy, xx = np.mgrid[0:H, 0:W]
    img = 40 + 0.5 * xx + 0.3 * yy                                                    # a gentle gradient
    img[(xx - 40 - 10 * seed) ** 2 + (yy - 48) ** 2 < 22 ** 2] = 200                  # a bright disc
    img[20:44, 80:116] = 120 + 20 * seed                                              # a rectangle
    img[np.abs((xx - 64) - (yy - 70) * 1.2) < 1.5] = 250                              # a diagonal line
    img[60:90, 100:104] = 10                                                          # a dark bar
    img = img + rng.normal(0, 2.0, img.shape)                                         # a little sensor noise
    return np.clip(np.round(img), 0, 255).astype(np.int64)


def sobel_model(img):
    """Reference: |gx| + |gy| clamped to 255 for the interior, 0 on the border."""
    p = img
    gx = (p[:-2, 2:] + 2 * p[1:-1, 2:] + p[2:, 2:]) - (p[:-2, :-2] + 2 * p[1:-1, :-2] + p[2:, :-2])
    gy = (p[2:, :-2] + 2 * p[2:, 1:-1] + p[2:, 2:]) - (p[:-2, :-2] + 2 * p[:-2, 1:-1] + p[:-2, 2:])
    out = np.zeros_like(p)
    out[1:-1, 1:-1] = np.minimum(np.abs(gx) + np.abs(gy), 255)
    return out, np.abs(gx) + np.abs(gy)


def scipy_check(img):
    """An independent reference: scipy's Sobel filters (same kernels) give the same unclamped magnitude in the interior."""
    sx = ndimage.sobel(img, axis=1, mode="constant")
    sy = ndimage.sobel(img, axis=0, mode="constant")
    _, raw = sobel_model(img)
    return bool(np.array_equal((np.abs(sx) + np.abs(sy))[1:-1, 1:-1], raw))


def build(work):
    os.makedirs(work, exist_ok=True)
    srcs = [os.path.join(CODE, "rtl", "sobel.v"), os.path.join(CODE, "tb", "tb_sobel.v")]
    for tag, extra in (("obj", []), ("obj_b1", ["-GBUG=1"]), ("obj_b2", ["-GBUG=2"])):
        subprocess.run(["verilator", "--binary", "--timing", "-Wno-fatal", "--top-module", "tb_sobel", "-Mdir", os.path.join(work, tag), *extra, *srcs],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def run(work, frames, tag="obj", gap=0):
    flat = np.concatenate([f.ravel() for f in frames])
    open(os.path.join(work, "in.hex"), "w").write("\n".join(f"{int(v):02x}" for v in flat) + "\n")
    subprocess.run([os.path.join(work, tag, "Vtb_sobel"), f"+n={len(flat)}", f"+gap={gap}"], cwd=work, check=True, stdout=subprocess.DEVNULL)
    out = np.array([int(l) for l in open(os.path.join(work, "out.txt")).read().split()], dtype=np.int64)
    lat = int(open(os.path.join(work, "latency.txt")).read())
    return out[:len(flat)].reshape(len(frames), H, W), lat, len(out)


def main():
    work = os.environ.get("SOBEL_WORK", os.path.abspath(os.path.join(CODE, "work")))
    build(work)
    A, B = make_image(1), make_image(2)
    lines = []
    ma, ra = sobel_model(A)
    mb, rb = sobel_model(B)
    lines.append(f"Sobel reference model vs scipy.ndimage.sobel on both test images: {'identical' if scipy_check(A) and scipy_check(B) else 'DIFFERENT'} (interior, before clamping)")
    for gap in (0, 30):
        out, lat, nout = run(work, [A, B, A], gap=gap)
        bad = int((out[0] != ma).sum() + (out[1] != mb).sum() + (out[2] != ma).sum())
        lines.append(f"Sobel RTL, 3 frames of {W}x{H} back to back, {gap}% random bubbles on the input: {out.size} pixels compared, {bad} mismatches" + (f"; latency {lat} clocks (W + 3 = {W + 3}: W + 2 accepted pixels and the registered valid flag)" if gap == 0 else ""))
        if gap == 0:
            Image.fromarray(A.astype(np.uint8)).resize((W * 3, H * 3), Image.NEAREST).save(os.path.join(CODE, "reports", "image_in.png"))
            Image.fromarray(out[0].astype(np.uint8)).resize((W * 3, H * 3), Image.NEAREST).save(os.path.join(CODE, "reports", "image_sobel.png"))
            Image.fromarray(((out[0] > 80) * 255).astype(np.uint8)).resize((W * 3, H * 3), Image.NEAREST).save(os.path.join(CODE, "reports", "image_threshold.png"))
            lines.append(f"Sobel output of frame 1: {int((out[0] > 0).sum())} non-zero pixels of {W * H}; border pixels all zero: {bool((out[0][0] == 0).all() and (out[0][-1] == 0).all() and (out[0][:, 0] == 0).all() and (out[0][:, -1] == 0).all())}")
    for bug, tag, what in ((1, "obj_b1", "line buffers one pixel too short"), (2, "obj_b2", "no clamping (8-bit wrap-around)")):
        out, lat, nout = run(work, [A], tag=tag)
        bad = int((out[0] != ma).sum())
        lines.append(f"Sobel bug {bug} ({what}): {W * H} pixels compared, {bad} mismatches ({100.0 * bad / (W * H):.1f}%)")
        Image.fromarray(out[0].astype(np.uint8)).resize((W * 3, H * 3), Image.NEAREST).save(os.path.join(CODE, "reports", f"image_bug{bug}.png"))
    open(os.path.join(CODE, "reports", "sim_sobel.txt"), "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        main()
    else:
        print(__doc__)
