# Linux user-space code and device-tree fragments - Episode 38. Needs only python3 and gcc on the PC.
.PHONY: dts test clean
dts:
	python3 tools/gen_dts.py
test:
	gcc -Wall -Wextra -O1 -o sw/test_uio sw/test_uio.c && cd sw && ./test_uio
	gcc -Wall -Wextra -O2 -o sw/uio_pwm sw/uio_pwm.c
clean:
	rm -f sw/test_uio sw/uio_pwm sw/fake_uio0.bin
