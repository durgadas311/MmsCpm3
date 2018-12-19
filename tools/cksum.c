// Compute ROM checksum as required for MMS 444-84B, et al.
// ROM bytes sent to stdin, e.g.
// dd if=2732a_444_84b_mms.bin bs=1 count=4092 | cksum

#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
	int c = 0;
	int n = 0;
	int cs = 0;
	while (read(0, &c, 1) == 1) {
		cs += (c & 0xff);
		++n;
	}
	printf("Checksummed %d bytes = %04x\n", n, cs & 0xffff);
}
