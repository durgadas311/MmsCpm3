/*
 * Program to take the first 8 lines of a text file,
 * first 21 characters of line, format using 5x7 font
 * and send to SSD1306-based OLED display.
 */

#include <printf.h>
#include "oledlib.h"

static char buf[128*64/8] = { 0 };

int fngets(fp, buf, len)
int fp;
char *buf;
int len;
{
	int c;
	int x;

	--len; /* reserved for '\0' */
	x = 0;
	while ((c = getc(fp)) != -1 && c != '\n') {
		if (c == 9) { /* TAB expansion */
			while (x < len) {
				buf[x++] = ' ';
				if (!(x & 7)) break;
			}
			continue;
		}
		if (x < len) buf[x++] = c;
	}
	buf[x] = 0;
	if (!x) return c;
	return '\n';
}

char line[22];

int main(argc, argv)
int argc;
char **argv;
{
	int fp;
	int e;
	int n;

	if (argc < 2) {
		printf("Usage: oledtype <text-file>\n");
		return 1;
	}
	fp = fopen(argv[1], "r");
	if (!fp) {
		printf("%s: no file\n", argv[1]);
		return 1;
	}
	n = 0;
	while ((e = fngets(fp, line, sizeof(line))) != -1) {
		addtxt(buf, n++, line);
	}

	e = oledinit();
	if (e) {
		printf("Failed to init OLED\n");
		return 1;
	}
	e = oledbuf(buf, sizeof(buf), OLED_DAT);
	if (e) {
		printf("Failed to send data\n");
		return 1;
	}
	return 0;
}

#include "font5x7.c"

/*
 * 'txt' MUST have NUL before or at char 22
 */
int addtxt(dsp, lno, txt)
char *dsp;
int lno;
char *txt;
{
	int pg;
	int ci;
	int ch;
	int xx;

	pg = lno * 128; /* start of page/row in display memory */
	ci = 0;
	while (txt[ci]) {
		ch = (txt[ci++] - ' ') * 5; /* location in font[] for char */
		if (ch < 0 || ch > sizeof(font5x7)) continue;
		for (xx = 0; xx < 5; ++xx) {
			dsp[pg++] = font5x7[ch++];
		}
		dsp[pg++] = 0;
	}
}
