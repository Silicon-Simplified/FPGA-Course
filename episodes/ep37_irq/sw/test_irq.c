/* Episode 37 - tests the driver and the ISR on the PC against a model of the peripheral and of a level-sensitive interrupt controller.
   Three trials: the correct ISR; an ISR that forgets to acknowledge (interrupt storm); an ISR that acknowledges ALL bits (a press that arrives while it runs is lost). */
#include <stdio.h>
#include <string.h>
#include "irq.h"

static uint32_t pending, enable, count, reads_of_pending;
static int inject_once;          /* a press of button 3 that arrives right after the ISR reads PENDING */
static uint32_t mrd(void *c, uint32_t off) {
    (void)c;
    switch (off) {
    case IRQ_PENDING: { uint32_t v = pending; if (inject_once) { pending |= 8; count++; inject_once = 0; } reads_of_pending++; return v; }
    case IRQ_ENABLE: return enable;
    case IRQ_COUNT: return count;
    case IRQ_ID: return IRQ_ID_VALUE;
    default: return 0;
    }
}
static void mwr(void *c, uint32_t off, uint32_t v) { (void)c; if (off == IRQ_PENDING) pending &= ~v; else if (off == IRQ_ENABLE) enable = v & 0xF; }
static void press(int b) { pending |= 1u << b; count++; }
static int level(void) { return (pending & enable) != 0; }

static int mode;   /* 0 correct, 1 forgets to acknowledge, 2 acknowledges everything */
static uint32_t bad_isr(irq_dev_t *d) {
    uint32_t p = d->rd(d->ctx, IRQ_PENDING) & 0xF;
    if (mode == 2) d->wr(d->ctx, IRQ_PENDING, 0xF);
    for (int i = 0; i < 4; i++) if (p & (1u << i)) d->presses[i]++;
    return p;
}

static int trial(const char *name, int m, int expect_ok) {
    pending = enable = count = reads_of_pending = 0; inject_once = 0; mode = m;
    irq_dev_t d = { mrd, mwr, 0, {0, 0, 0, 0} };
    int ri = irq_init(&d, 0xF);
    int calls = 0, cap = 1000;
    press(0); press(1);                                   /* two presses before the interrupt is taken */
    inject_once = 1;                                      /* and one more while the ISR is running */
    while (level() && calls < cap) { calls++; if (m == 1 || m == 2) bad_isr(&d); else irq_isr(&d); }
    uint32_t seen = d.presses[0] + d.presses[1] + d.presses[2] + d.presses[3];
    printf("IRQ driver %s: init %d, ISR called %d times, counted %u presses (3 really happened)%s\n", name, ri, calls, seen, calls >= cap ? " (interrupt storm)" : "");
    return ((seen == 3 && calls < cap) == expect_ok) && ri == 0;
}

int main(void) {
    int ok = 1;
    ok &= trial("correct ISR", 0, 1);
    ok &= trial("bug: ISR never acknowledges", 1, 0);
    ok &= trial("bug: ISR acknowledges all bits", 2, 0);
    printf("IRQ test %s\n", ok ? "PASS" : "FAIL");
    return !ok;
}
