/* Episode 37 - "hello world" for the button interrupt: count presses in the ISR, print them from the main loop. Written for a Vitis bare-metal project (standalone BSP).
   The GIC calls below follow the standalone BSP's XScuGic / Xil_Exception API as I remember it and were NOT compiled against the BSP headers. */
#include <stdio.h>
#include "irq.h"

#define IRQ_BASE 0x40000000u
#define PL_IRQ_ID 61u      /* IRQ_F2P[0] is interrupt ID 61 in the Zynq-7000 GIC (from the reference manual) */

#ifdef __arm__
typedef struct XScuGic_Config XScuGic_Config;
typedef struct { unsigned char opaque[256]; } XScuGic;
extern XScuGic_Config *XScuGic_LookupConfig(unsigned short id);
extern int XScuGic_CfgInitialize(XScuGic *g, XScuGic_Config *c, unsigned base);
extern int XScuGic_Connect(XScuGic *g, unsigned id, void (*handler)(void *), void *ref);
extern void XScuGic_Enable(XScuGic *g, unsigned id);
extern void XScuGic_SetPriorityTriggerType(XScuGic *g, unsigned id, unsigned char prio, unsigned char trig);
extern void Xil_ExceptionInit(void);
extern void Xil_ExceptionRegisterHandler(unsigned id, void (*h)(void *), void *data);
extern void Xil_ExceptionEnable(void);
extern void XScuGic_InterruptHandler(void *);
#endif

static uint32_t rd(void *ctx, uint32_t off) { (void)ctx; return *(volatile uint32_t *)(IRQ_BASE + off); }
static void wr(void *ctx, uint32_t off, uint32_t v) { (void)ctx; *(volatile uint32_t *)(IRQ_BASE + off) = v; }
static irq_dev_t dev = { rd, wr, 0, {0, 0, 0, 0} };
static void isr(void *ref) { (void)ref; irq_isr(&dev); }

int main(void) {
    static XScuGic gic;
    if (irq_init(&dev, 0xF) != 0) { printf("wrong ID: check the address and the bitstream\n"); return 1; }
    XScuGic_CfgInitialize(&gic, XScuGic_LookupConfig(0), 0xF8F01000u);
    XScuGic_SetPriorityTriggerType(&gic, PL_IRQ_ID, 0xA0, 0x1);       /* level-high, like our irq output */
    XScuGic_Connect(&gic, PL_IRQ_ID, isr, 0);
    XScuGic_Enable(&gic, PL_IRQ_ID);
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(5u, XScuGic_InterruptHandler, &gic);
    Xil_ExceptionEnable();
    uint32_t last[4] = {0, 0, 0, 0};
    for (;;)
        for (int i = 0; i < 4; i++)
            if (dev.presses[i] != last[i]) { last[i] = dev.presses[i]; printf("BTN%d pressed %lu times\n", i, (unsigned long)last[i]); }
}
