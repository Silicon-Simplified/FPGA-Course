/* Episode 38 - user-space access to a memory-mapped peripheral through the Linux UIO driver: open /dev/uioN, mmap the registers, read and write them like memory.
   The register map is the PWM peripheral of episode 35. The UIO read/write semantics used for interrupts (read blocks and returns a 32-bit count, writing 1 re-enables) are from the kernel documentation. */
#ifndef UIO_PWM_H
#define UIO_PWM_H
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define PWM_CTRL 0
#define PWM_PERIOD 1
#define PWM_DUTY0 2
#define PWM_ID 7
#define PWM_ID_VALUE 0x50574D01u
#define UIO_MAP_BYTES 4096

typedef struct { int fd; volatile uint32_t *r; } uio_dev_t;

/* path = "/dev/uio0" on the board. Returns 0 on success, negative on failure. */
static inline int uio_open(uio_dev_t *d, const char *path) {
    d->fd = open(path, O_RDWR | O_SYNC);
    if (d->fd < 0) return -1;
    void *p = mmap(0, UIO_MAP_BYTES, PROT_READ | PROT_WRITE, MAP_SHARED, d->fd, 0);   /* offset 0 = map 0 of the device */
    if (p == MAP_FAILED) { close(d->fd); return -2; }
    d->r = (volatile uint32_t *)p;
    if (d->r[PWM_ID] != PWM_ID_VALUE) { munmap((void *)d->r, UIO_MAP_BYTES); close(d->fd); return -3; }
    return 0;
}
static inline void uio_close(uio_dev_t *d) { munmap((void *)d->r, UIO_MAP_BYTES); close(d->fd); }

static inline void pwm_start(uio_dev_t *d, uint32_t period, const uint32_t duty[4]) {
    d->r[PWM_CTRL] = 0; d->r[PWM_PERIOD] = period;
    for (int i = 0; i < 4; i++) d->r[PWM_DUTY0 + i] = duty[i];
    d->r[PWM_CTRL] = 1;
}

/* Interrupts: block until the device interrupts, return the interrupt count, then re-enable the interrupt (UIO masks it after each one). */
static inline int uio_wait_irq(int fd, uint32_t *count) {
    uint32_t n;
    if (read(fd, &n, sizeof n) != (ssize_t)sizeof n) return -1;
    uint32_t one = 1;
    if (write(fd, &one, sizeof one) != (ssize_t)sizeof one) return -2;
    *count = n;
    return 0;
}
#endif
