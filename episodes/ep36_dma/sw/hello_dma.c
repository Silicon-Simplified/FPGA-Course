/* Episode 36 - "hello world" for the DMA + accelerator: send 256 samples through the 4-sample moving average and check the result in software.
   Written for a Vitis bare-metal project (standalone BSP). On the Zynq, virtual and physical addresses are the same, so a pointer is the DDR address. */
#include <stdio.h>
#include "dma.h"

#define DMA_BASE 0x40400000u
#define N 256

#ifdef __arm__
extern void Xil_DCacheFlushRange(unsigned addr, unsigned len);
extern void Xil_DCacheInvalidateRange(unsigned addr, unsigned len);
static void flush(uint32_t a, uint32_t n) { Xil_DCacheFlushRange(a, n); }
static void inval(uint32_t a, uint32_t n) { Xil_DCacheInvalidateRange(a, n); }
#endif
static uint32_t rd(void *ctx, uint32_t off) { (void)ctx; return *(volatile uint32_t *)(DMA_BASE + off); }
static void wr(void *ctx, uint32_t off, uint32_t v) { (void)ctx; *(volatile uint32_t *)(DMA_BASE + off) = v; }

static int32_t src[N] __attribute__((aligned(32)));
static int32_t dst[N] __attribute__((aligned(32)));

int main(void) {
    dma_t d = { rd, wr, flush, inval, 0 };
    if (dma_init(&d) != DMA_OK) { printf("DMA reset failed\n"); return 1; }
    for (int i = 0; i < N; i++) src[i] = (i * 37 % 200) - 100;
    int r = dma_transfer(&d, (uint32_t)(uintptr_t)src, (uint32_t)(uintptr_t)dst, sizeof src);
    if (r != DMA_OK) { printf("DMA transfer failed: %d\n", r); return 1; }
    int bad = 0;
    for (int i = 0; i < N; i++) {                                       /* software model, history cleared at the start of the packet */
        int64_t s = src[i] + (i > 0 ? src[i - 1] : 0) + (i > 1 ? src[i - 2] : 0) + (i > 2 ? src[i - 3] : 0);
        if (dst[i] != (int32_t)(s >> 2)) bad++;
    }
    printf("DMA done: %d of %d samples wrong\n", bad, N);
    return bad != 0;
}
