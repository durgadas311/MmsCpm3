/* Pads file to 128 bytes, using 0x1a (Ctrl-Z, CP/M EOF) */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char **argv) {
	int x;
	struct stat stb;
	int err = 0;
	char buf[128];
	memset(buf, 0x1a, sizeof(buf));
	for (x = 1; x < argc; ++x) {
		int fd = open(argv[x], O_RDWR);
		if (fd < 0) {
			perror(argv[x]);
			++err;
			continue;
		}
		fstat(fd, &stb);
		if ((stb.st_size & 0x7f) == 0) {
			printf("No change: %s\n", argv[x]);
			close(fd);
			continue;
		}
		lseek(fd, 0, SEEK_END);
		int n = 128 - (stb.st_size & 0x7f);
		if (write(fd, buf, n) != n) {
			perror(argv[x]);
			++err;
		}
		if (close(fd) != 0) {
			perror(argv[x]);
			++err;
		}
	}
	return err;
}
