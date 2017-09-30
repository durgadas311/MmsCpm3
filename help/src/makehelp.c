#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>

struct helptoc {
	char topic[12];
	uint16_t recoff;
	uint8_t bytoff;
	uint8_t level;
} __attribute__((packed));

// input file must have already been converted LF => CR,LF.
// Typically, a concatination of all help files.
int main(int argc, char **argv) {
	struct stat stb;
	char *buf = NULL;
	size_t buflen = 0;
	struct helptoc toc;
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <help-file>\n", argv[0]);
		exit(1);
	}
	int x;
	int fd = open(argv[1], O_RDONLY);
	if (fd < 0) {
		perror(argv[1]);
		exit(1);
	}
	fstat(fd, &stb);
	buflen = stb.st_size;
	buf = malloc(stb.st_size + 1);
	if (buf == NULL) {
		perror("malloc");
		exit(1);
	}
	int rc = read(fd, buf, stb.st_size);
	if (rc < 0) {
		perror(argv[1]);
		exit(1);
	}
	close(fd);
	buf[stb.st_size] = 0;

	// Line endings MUST be CR-LF... always...
	// CR-LF are considered the START of the text...
	char *s = buf;
	x = 0;
	while ((s = strstr(s, "///")) != NULL) {
		++x;
		while (*s && *s != '\r') ++s;
	}
	// compute size of TOC... base of all offsets...
	int ntoc = ((x + 3) & ~3);
	if (ntoc == x) {
		ntoc += 4;
	}
	int toclen = ntoc * sizeof(struct helptoc);
	// Now go through text again, building TOC (on stdout)...
	int t = 0;
	s = buf;
	while ((s = strstr(s, "///")) != NULL) {
		s += 3;
		toc.level = *s++ - '0';
		x = 0;
		while (x < sizeof(toc.topic) && *s && *s != '\r') {
			toc.topic[x++] = toupper(*s++);
		}
		while (x < sizeof(toc.topic)) {
			toc.topic[x++] = ' ';
		}
		while (*s && *s != '\r') ++s;
		int off = ((s - buf) + toclen);
		toc.recoff = off >> 7;
		toc.bytoff = off & 0x7f;
		write(1, &toc, sizeof(toc));
		++t;
	}
	memset(toc.topic, ' ', sizeof(toc.topic));
	toc.topic[0] = '$';
	toc.level = 0;
	toc.recoff = 0;
	toc.bytoff = 0;
	while (t < ntoc) {
		write(1, &toc, sizeof(toc));
		++t;
	}
	// now dump the help text...
	write(1, buf, buflen);
	return 0;
}
