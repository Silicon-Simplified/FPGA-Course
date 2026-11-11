/* Episode 36 - a tiny register-level driver for the AXI DMA in simple (direct register) mode, one MM2S + one S2MM transfer at a time.
   Register offsets and bits are taken from the AXI DMA product guide (PG021), not measured here.
   The cache operations are hooks: on the Zynq they are Xil_DCacheFlushRange / Xil_DCacheInvalidateRange; in the PC test they are model functions. */
#ifndef DMA_H
#define DMA_H
#include <stdint.h>

#define MM2S_DMACR 0x00
#define MM2S_DMASR 0x04
#define MM2S_SA    0x18
#define MM2S_LEN   0x28
#define S2MM_DMACR 0x30
#define S2MM_DMASR 0x34
#define S2MM_DA    0x48
#define S2MM_LEN   0x58
#define DMACR_RS     (1u << 0)
#define DMACR_RESET  (1u << 2)
#define DMASR_HALTED (1u << 0)
#define DMASR_IDLE   (1u << 1)
#define DMASR_ERR    ((1u << 4) | (1u << 5) | (1u << 6))   /* DMAIntErr, DMASlvErr, DMADecErr */
#define DMASR_IOC    (1u << 12)

typedef struct {
    uint32_t (*rd)(void *ctx, uint32_t off);
    void     (*wr)(void *ctx, uint32_t off, uint32_t v);
    void     (*flush)(uint32_t addr, uint32_t len);   /* write dirty cache lines back to DDR   */
    void     (*inval)(uint32_t addr, uint32_t len);   /* drop cache lines so the CPU re-reads DDR */
    void     *ctx;
} dma_t;

enum { DMA_OK = 0, DMA_ERR_RESET = -1, DMA_ERR_HW = -2, DMA_ERR_TIMEOUT = -3 };

static inline int dma_init(dma_t *d) {
    d->wr(d->ctx, MM2S_DMACR, DMACR_RESET);
    for (int i = 0; i < 1000; i++) if (!(d->rd(d->ctx, MM2S_DMACR) & DMACR_RESET)) return DMA_OK;
    return DMA_ERR_RESET;
}

/* Send nbytes from src through the PL accelerator and receive them at dst (both are DDR addresses, 4-byte aligned). */
static inline int dma_transfer(dma_t *d, uint32_t src, uint32_t dst, uint32_t nbytes) {
    d->flush(src, nbytes);                          /* the DMA reads DDR: make sure the data we wrote is really there   */
    d->inval(dst, nbytes);                          /* the DMA writes DDR: drop stale cache lines before and after      */
    d->wr(d->ctx, S2MM_DMACR, DMACR_RS);
    d->wr(d->ctx, MM2S_DMACR, DMACR_RS);
    d->wr(d->ctx, S2MM_DA, dst);  d->wr(d->ctx, S2MM_LEN, nbytes);   /* arm the receiver first ...          */
    d->wr(d->ctx, MM2S_SA, src);  d->wr(d->ctx, MM2S_LEN, nbytes);   /* ... writing LENGTH starts the transfer */
    for (int i = 0; i < 100000; i++) {
        uint32_t a = d->rd(d->ctx, MM2S_DMASR), b = d->rd(d->ctx, S2MM_DMASR);
        if ((a | b) & DMASR_ERR) return DMA_ERR_HW;
        if ((a & DMASR_IOC) && (b & DMASR_IOC)) {
            d->wr(d->ctx, MM2S_DMASR, DMASR_IOC); d->wr(d->ctx, S2MM_DMASR, DMASR_IOC);   /* write 1 to clear */
            d->inval(dst, nbytes);                  /* the data landed in DDR behind the cache's back */
            return DMA_OK;
        }
    }
    return DMA_ERR_TIMEOUT;
}
#endif
