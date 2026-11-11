/* Episode 35 - "hello world" for the PWM peripheral: print the ID, then make the four LEDs breathe, each channel a quarter of a cycle apart.
   Written for a Vitis bare-metal project (standalone BSP: stdio on the PS UART). The base address is the one Vivado assigned in the block design. */
#include <stdio.h>
#include "pwm.h"

#define PWM_BASEADDR 0x40000000u

static void delay(volatile unsigned n) { while (n--) ; }

int main(void) {
    pwm_t pwm;
    if (pwm_init(&pwm, (volatile void *)PWM_BASEADDR, 1000) != 0) { printf("PWM: wrong ID, check the address and the bitstream\n"); return 1; }
    printf("PWM ready, ID = 0x%08lX\n", (unsigned long)pwm_read(&pwm, PWM_ID));
    for (;;)
        for (unsigned t = 0; t < 200; t++) {
            for (int ch = 0; ch < 4; ch++) {
                unsigned ph = (t + 50u * ch) % 200u;                    /* triangle wave, 0..100 % */
                pwm_set_percent(&pwm, ch, ph < 100 ? ph : 200 - ph);
            }
            delay(200000);
        }
}
