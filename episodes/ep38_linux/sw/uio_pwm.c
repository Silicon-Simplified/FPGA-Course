/* Episode 38 - a user-space program that starts the PWM from Linux:  ./uio_pwm /dev/uio0 [percent0 percent1 percent2 percent3] */
#include <stdio.h>
#include <stdlib.h>
#include "uio_pwm.h"

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : "/dev/uio0";
    uio_dev_t d;
    int r = uio_open(&d, path);
    if (r) { fprintf(stderr, "cannot open %s (error %d): check the device tree, the bitstream and the permissions\n", path, r); return 1; }
    uint32_t duty[4], period = 1000;
    for (int i = 0; i < 4; i++) duty[i] = period * (argc > 2 + i ? (unsigned)atoi(argv[2 + i]) : 25u * (i + 1)) / 100;
    pwm_start(&d, period, duty);
    printf("PWM running: duty %u %u %u %u of %u\n", duty[0], duty[1], duty[2], duty[3], period);
    uio_close(&d);
    return 0;
}
