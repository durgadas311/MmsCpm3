/*
 * Program to send a 1024-byte binary bitmap image to
 * an SSD1306-based OLED display.
 */

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

	e = oledinit();
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
