/* Episode 36 - tests the DMA driver on the PC against a model of the DMA registers, the 4-sample moving average, DDR and a data cache.
   The cache model shows the two classic bugs: without a flush the DMA reads stale DDR, without an invalidate the CPU reads stale cache lines. */
#include <stdio.h>
#include <string.h>
#define DMA_MOCK
#include "dma.h"

#define WORDS 4096
static int32_t ddr[WORDS], cache[WORDS]; static char cvalid[WORDS], cdirty[WORDS];   /* word-granular model data cache */
static uint32_t regs[0x60 / 4];
static int s2mm_armed, mm2s_len, s2mm_len, order_ok, n_flush, n_inval;
static int do_flush = 1, do_inval = 1;

static void model_flush(uint32_t a, uint32_t n) { n_flush++; if (!do_flush) return; for (uint32_t i = a / 4; i < (a + n) / 4; i++) if (cdirty[i]) { ddr[i] = cache[i]; cdirty[i] = 0; } }
static void model_inval(uint32_t a, uint32_t n) { n_inval++; if (!do_inval) return; for (uint32_t i = a / 4; i < (a + n) / 4; i++) { cvalid[i] = 0; cdirty[i] = 0; } }
static void cpu_write(uint32_t w, int32_t v) { cache[w] = v; cvalid[w] = 1; cdirty[w] = 1; }
static int32_t cpu_read(uint32_t w) { if (cvalid[w]) return cache[w]; cache[w] = ddr[w]; cvalid[w] = 1; return cache[w]; }

static void run_dma(void) {                                          /* both LENGTH registers written: move the data through the accelerator */
    uint32_t sa = regs[MM2S_SA / 4] / 4, da = regs[S2MM_DA / 4] / 4; int n = mm2s_len / 4;
    int64_t h1 = 0, h2 = 0, h3 = 0;
    for (int i = 0; i < n; i++) { int64_t x = ddr[sa + i]; ddr[da + i] = (int32_t)((x + h1 + h2 + h3) >> 2); h3 = h2; h2 = h1; h1 = x; }
    regs[MM2S_DMASR / 4] |= DMASR_IOC | DMASR_IDLE; regs[S2MM_DMASR / 4] |= DMASR_IOC | DMASR_IDLE;
}
static uint32_t mrd(void *c, uint32_t off) { (void)c; if (off == MM2S_DMACR && (regs[off / 4] & DMACR_RESET)) regs[off / 4] &= ~DMACR_RESET; return regs[off / 4]; }
static void mwr(void *c, uint32_t off, uint32_t v) {
    (void)c;
    if (off == MM2S_DMASR || off == S2MM_DMASR) { regs[off / 4] &= ~(v & DMASR_IOC); return; }          /* write-1-to-clear */
    regs[off / 4] = v;
    if (off == S2MM_LEN) { s2mm_armed = 1; s2mm_len = (int)v; }
    if (off == MM2S_LEN) { mm2s_len = (int)v; if (!s2mm_armed) order_ok = 0; }
    if ((off == S2MM_LEN || off == MM2S_LEN) && s2mm_armed && mm2s_len && mm2s_len == s2mm_len) run_dma();
}

static int trial(const char *name, int flush_on, int inval_on, int expect_bad) {
    memset(ddr, 0, sizeof ddr); memset(cache, 0, sizeof cache); memset(cvalid, 0, sizeof cvalid); memset(cdirty, 0, sizeof cdirty); memset(regs, 0, sizeof regs);
    s2mm_armed = 0; mm2s_len = s2mm_len = 0; order_ok = 1; n_flush = n_inval = 0; do_flush = flush_on; do_inval = inval_on;
    const uint32_t SRC = 1024, DST = 2048, N = 256;
    for (uint32_t i = 0; i < N; i++) { ddr[DST / 4 + i] = 777; cpu_write(DST / 4 + i, 777); cdirty[DST / 4 + i] = 0; }     /* the CPU has the destination cached (old data) */
    for (uint32_t i = 0; i < N; i++) cpu_write(SRC / 4 + i, (int32_t)((i * 37) % 200) - 100);                              /* the CPU fills the source: it sits in the cache */
    dma_t d = { mrd, mwr, model_flush, model_inval, 0 };
    int ri = dma_init(&d), rt = dma_transfer(&d, SRC, DST, N * 4);
    int bad = 0; int64_t h1 = 0, h2 = 0, h3 = 0;
    for (uint32_t i = 0; i < N; i++) {
        int64_t x = (int32_t)((i * 37) % 200) - 100; int32_t want = (int32_t)((x + h1 + h2 + h3) >> 2); h3 = h2; h2 = h1; h1 = x;
        if (cpu_read(DST / 4 + i) != want) bad++;
    }
    printf("DMA %s: init %d, transfer %d, receiver armed first %s, %d of %u samples wrong\n", name, ri, rt, order_ok ? "yes" : "NO", bad, N);
    return (bad > 0) == expect_bad && ri == 0 && rt == 0;
}

int main(void) {
    int ok = 1;
    ok &= trial("with flush and invalidate", 1, 1, 0);
    ok &= trial("bug: no flush before the transfer", 0, 1, 1);
    ok &= trial("bug: no invalidate after the transfer", 1, 0, 1);
    printf("DMA test %s\n", ok ? "PASS" : "FAIL");
    return !ok;
}
