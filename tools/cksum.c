// Compute ROM checksum as required for MMS 444-84B, et al.
// ROM bytes sent to stdin, e.g.
// dd if=2732a_444_84b_mms.bin bs=1 count=4092 | cksum

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

static int filter = 0;
static int wide = 0;
static int limit = 0;
static int len = 0;

static int wrcksum(long cs) {
	int c;
	int n = 0;
	c = (cs & 0xff);
	write(1, &c, 1);
	++n;
	c = ((cs >> 8) & 0xff);
	write(1, &c, 1);
	++n;
	if (wide) {
		c = ((cs >> 16) & 0xff);
		write(1, &c, 1);
		++n;
		c = ((cs >> 24) & 0xff);
		write(1, &c, 1);
		++n;
	}
	return n;
}

int main(int argc, char **argv) {
	int c = 0;
	int n = 0;
	int t = 0;
	long cs = 0;
	int x;
	extern char *optarg;
	while ((x = getopt(argc, argv, "fl:w")) != EOF) {
		switch (x) {
		case 'f':
			++filter;
			break;
		case 'l':
			len = strtoul(optarg, NULL, 0);
			break;
		case 'w':
			++wide;
			break;
		}
	}
	if (len) {
		limit = len - (wide ? 4 : 2);
	}
	while (read(0, &c, 1) == 1) {
		cs += (c & 0xff);
		++n;
		if (filter) {
			write(1, &c, 1);
			++t;
		}
	}
	if (filter && len) {
		// only matters if len/limit set
		if (n >= limit) {
			fprintf(stderr, "ROM overflow (%d bytes)\n", n);
			return 1;
		}
		c = 0xff;	// *EPROM pad character
		while (t < limit) {
			cs += (c & 0xff);
			++n;
			write(1, &c, 1);
			++t;
		}
		// output checksum little-endian...
		t += wrcksum(cs);
	}
	if (wide) {
		fprintf(stderr, "Checksummed %d bytes = %08lx\n", n, cs & 0xffffffff);
	} else {
		fprintf(stderr, "Checksummed %d bytes = %04lx\n", n, cs & 0xffff);
	}
}
