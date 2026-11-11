/* Episode 35 - tests the driver on the PC against a software model of the register file (read-only ID, write ignored on read-only registers). */
#include <stdio.h>
#include <string.h>
#include "pwm.h"

static uint32_t mem[8];
static int errs = 0, checks = 0;
static void check(const char *what, uint32_t got, uint32_t exp) { checks++; if (got != exp) { errs++; printf("FAIL %s: got %u expected %u\n", what, got, exp); } }

int main(void) {
    pwm_t p;
    memset(mem, 0, sizeof mem);
    check("init with wrong ID fails", (uint32_t)pwm_init(&p, mem, 1000), (uint32_t)-1);
    mem[PWM_ID] = PWM_ID_VALUE;
    check("init ok", (uint32_t)pwm_init(&p, mem, 1000), 0);
    check("enabled", mem[PWM_CTRL], 1);
    check("period", mem[PWM_PERIOD], 1000);
    pwm_set_percent(&p, 0, 0);   check("0 %", mem[PWM_DUTY0], 0);
    pwm_set_percent(&p, 1, 25);  check("25 %", mem[PWM_DUTY0 + 1], 250);
    pwm_set_percent(&p, 2, 50);  check("50 %", mem[PWM_DUTY0 + 2], 500);
    pwm_set_percent(&p, 3, 100); check("100 %", mem[PWM_DUTY0 + 3], 1000);
    pwm_set_percent(&p, 3, 250); check("clamped to 100 %", mem[PWM_DUTY0 + 3], 1000);
    pwm_write(&p, PWM_PERIOD, 4000); pwm_set_percent(&p, 0, 10); check("10 % of 4000", mem[PWM_DUTY0], 400);
    printf("DRIVER %d checks, %d errors\n", checks, errs);
    return errs != 0;
}
