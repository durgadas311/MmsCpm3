
#include <printf.h>
#include "oledlib.h"

static char buf[128*64/8];
#if 0
	/* "TEST" */
	0x01,	/* 00000001 */
	0x01,	/* 00000001 */
	0x7f,	/* 01111111 */
	0x01,	/* 00000001 */
	0x01,	/* 00000001 */
	0x00,	/* 00000000 */
	0x7f,	/* 01111111 */
	0x49,	/* 01001001 */
	0x49,	/* 01001001 */
	0x49,	/* 01001001 */
	0x41,	/* 01000001 */
	0x00,	/* 00000000 */
	0x26,	/* 00100110 */
	0x49,	/* 01001001 */
	0x49,	/* 01001001 */
	0x49,	/* 01001001 */
	0x32,	/* 00110010 */
	0x00,	/* 00000000 */
	0x01,	/* 00000001 */
	0x01,	/* 00000001 */
	0x7f,	/* 01111111 */
	0x01,	/* 00000001 */
	0x01,	/* 00000001 */
	0x00,	/* 00000000 */
#endif

static char init[] = {
	0xae, 0x20,0, 0xc8, 0x40, 0x81,0x7f, 0xa1,
	0xa6, 0xa8,0x3f, 0xd3,0, 0xd5,0x80, 0xd9,0x22,
	0xda,0x12, 0xdb,0x20, 0x8d,0x14, 0xa4, 0xaf,
/* now reset address */
	0x21,0,127,0x22,0,7
};

int main(argc, argv)
int argc;
char **argv;
{
	int fp;
	int e;

	if (argc < 2) {
		printf("Usage: oledldr <oled-img-file>\n");
		return 1;
	}
	fp = fopen(argv[1], "rb");
	if (!fp) {
		printf("%s: no file\n", argv[1]);
		return 1;
	}
	e = read(fp, buf, sizeof(buf));
	fclose(fp);
	if (e != sizeof(buf)) {
		printf("%s: read error\n", argv[1]);
		return 1;
	}

	oledinit();
	e = oledbuf(init, sizeof(init), OLED_CMD);
	if (e) {
		printf("Failed to send init\n");
		return 1;
	}
	e = oledbuf(buf, sizeof(buf), OLED_DAT);
	if (e) {
		printf("Failed to send data\n");
		return 1;
	}
	return 0;
}
