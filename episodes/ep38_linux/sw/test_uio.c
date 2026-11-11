/* Episode 38 - tests the user-space code on the PC: a regular file stands in for /dev/uio0 (mmap works on both), a socket pair stands in for the UIO interrupt file.
   This checks OUR code (mapping, ID check, register writes, the read/write protocol). It does not test the Linux UIO kernel driver. */
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include "uio_pwm.h"

static int checks = 0, errs = 0;
static void check(const char *w, uint32_t got, uint32_t exp) { checks++; if (got != exp) { errs++; printf("FAIL %s: got %u expected %u\n", w, got, exp); } }

int main(void) {
    const char *f = "fake_uio0.bin";
    uint32_t img[UIO_MAP_BYTES / 4]; memset(img, 0, sizeof img);
    FILE *fp = fopen(f, "wb"); fwrite(img, 1, sizeof img, fp); fclose(fp);                        /* no ID yet: open must refuse */
    uio_dev_t d;
    check("wrong ID rejected", (uint32_t)uio_open(&d, f), (uint32_t)-3);
    check("missing device rejected", (uint32_t)uio_open(&d, "does_not_exist"), (uint32_t)-1);
    img[PWM_ID] = PWM_ID_VALUE;
    fp = fopen(f, "wb"); fwrite(img, 1, sizeof img, fp); fclose(fp);
    check("open ok", (uint32_t)uio_open(&d, f), 0);
    uint32_t duty[4] = {0, 250, 500, 1000};
    pwm_start(&d, 1000, duty);
    uio_close(&d);
    fp = fopen(f, "rb"); fread(img, 1, sizeof img, fp); fclose(fp);                               /* the writes went through the mapping into the "device" */
    check("CTRL enabled", img[PWM_CTRL], 1); check("PERIOD", img[PWM_PERIOD], 1000);
    check("DUTY0", img[PWM_DUTY0], 0); check("DUTY1", img[PWM_DUTY0 + 1], 250); check("DUTY2", img[PWM_DUTY0 + 2], 500); check("DUTY3", img[PWM_DUTY0 + 3], 1000);
    check("ID untouched", img[PWM_ID], PWM_ID_VALUE);
    int sv[2]; socketpair(AF_UNIX, SOCK_STREAM, 0, sv);
    uint32_t n = 7, got = 0, back = 0;
    write(sv[1], &n, sizeof n);                                                                   /* the "kernel" reports 7 interrupts */
    check("irq wait ok", (uint32_t)uio_wait_irq(sv[0], &got), 0); check("irq count", got, 7);
    read(sv[1], &back, sizeof back); check("irq re-enabled with 1", back, 1);
    remove(f);
    printf("UIO %d checks, %d errors\n", checks, errs);
    return errs != 0;
}
