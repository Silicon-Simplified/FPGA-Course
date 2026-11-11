/* Episode 35 - bare-metal driver for the axil_pwm peripheral. No vendor library needed: just memory-mapped registers. */
#ifndef PWM_H
#define PWM_H
#include <stdint.h>

#define PWM_CTRL    0   /* word offsets: byte address = 4 * index */
#define PWM_PERIOD  1
#define PWM_DUTY0   2   /* DUTY0..DUTY3 = 2..5 */
#define PWM_COUNT   6
#define PWM_ID      7
#define PWM_ID_VALUE 0x50574D01u

typedef struct { volatile uint32_t *r; } pwm_t;

static inline void pwm_write(pwm_t *p, int reg, uint32_t v) { p->r[reg] = v; }
static inline uint32_t pwm_read(pwm_t *p, int reg) { return p->r[reg]; }

/* Returns 0 on success, -1 if the ID register is wrong (wrong address, or the bitstream is not loaded). */
static inline int pwm_init(pwm_t *p, volatile void *base, uint32_t period) {
    p->r = (volatile uint32_t *)base;
    if (pwm_read(p, PWM_ID) != PWM_ID_VALUE) return -1;
    pwm_write(p, PWM_CTRL, 0);
    pwm_write(p, PWM_PERIOD, period);
    for (int ch = 0; ch < 4; ch++) pwm_write(p, PWM_DUTY0 + ch, 0);
    pwm_write(p, PWM_CTRL, 1);
    return 0;
}

/* duty in percent, 0..100 */
static inline void pwm_set_percent(pwm_t *p, int ch, unsigned pct) {
    if (pct > 100) pct = 100;
    pwm_write(p, PWM_DUTY0 + ch, (uint32_t)((uint64_t)pwm_read(p, PWM_PERIOD) * pct / 100));
}
#endif
