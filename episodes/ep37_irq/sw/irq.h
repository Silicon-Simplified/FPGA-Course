/* Episode 37 - driver and interrupt service routine for the button interrupt controller (axil_irq). Registers are accessed through two hooks so the same code runs on the PC test and on the Zynq. */
#ifndef IRQ_H
#define IRQ_H
#include <stdint.h>

#define IRQ_RAW     0x00
#define IRQ_PENDING 0x04   /* write 1 to clear */
#define IRQ_ENABLE  0x08
#define IRQ_COUNT   0x0C
#define IRQ_ID      0x10
#define IRQ_ID_VALUE 0x49525101u

typedef struct {
    uint32_t (*rd)(void *ctx, uint32_t off);
    void     (*wr)(void *ctx, uint32_t off, uint32_t v);
    void     *ctx;
    volatile uint32_t presses[4];     /* filled by the ISR, read by the main loop */
} irq_dev_t;

static inline int irq_init(irq_dev_t *d, uint32_t enable_mask) {
    if (d->rd(d->ctx, IRQ_ID) != IRQ_ID_VALUE) return -1;
    for (int i = 0; i < 4; i++) d->presses[i] = 0;
    d->wr(d->ctx, IRQ_PENDING, 0xF);          /* start clean */
    d->wr(d->ctx, IRQ_ENABLE, enable_mask);
    return 0;
}

/* The interrupt service routine: keep it short. Read what is pending, ACKNOWLEDGE exactly those bits, record them.
   Acknowledging only what was read means a press that arrives while we run is not lost: it stays pending and raises the interrupt again. */
static inline uint32_t irq_isr(irq_dev_t *d) {
    uint32_t p = d->rd(d->ctx, IRQ_PENDING) & 0xFu;
    d->wr(d->ctx, IRQ_PENDING, p);
    for (int i = 0; i < 4; i++) if (p & (1u << i)) d->presses[i]++;
    return p;
}
#endif
