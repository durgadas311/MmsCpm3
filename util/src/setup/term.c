/* July 18, 1984  09:28  drm  "TERM.C" */
/* terminal control module - for BDS "C" */

/* This modules reads a file "TERMINAL.SYS" from drive A: and uses
 * it to control the console. The format of the file is indicated by
 * the structure "tcb".
 *
 */

/* CP/M specific */

#include "setup30.h"
# from stdio.h:
extern int vsnprintf(char *str, size_t n,const char *fmt,void *ap);

extern void _spr(void **fmt, void (*outp)(char c));
extern void termload();

int initial();
int deinit();
int getkey();
int inchar();
void puts(char *buf);
void outchr(char c);
int printf(char *format, ...);
void putctl(char *buf);
void putnul(char c);
void cursor(int position);
int getwidth();
int getlength();
char *getterm();
void clrscr();
void curhome();
void curleft();
void curright();
void curup();
void curdown();
void clreel();
void clreop();
void curoff();
void curon();
void invon();
void invoff();
void bell();

#define TWIDTH 80
#define TLENGTH 24

int initial() {
	termload();
	putctl(termctrl.tinit);
	return (0);
}

int deinit() {
	int x;
	putctl(termctrl.tdeinit);
	return (0);
}

int getkey() {
	char c[4], cd, *ktbl;
	int p, pp, qq;
	ktbl = termctrl.khome;
	p = 0;
	cd = HMCD;
	c[0] = inchar();
	while (p < 68 && *(ktbl + p) != c[0]) {
		p += 4;
		++cd;
	}
	if (p >= 68) {
		return (c[0]);
	}
	qq = 0;
	for (pp = 1; pp < 4; ++pp) {
		if (*(ktbl + p + pp) == 0) {
			return (cd);
		}
		if (pp > qq) {
			c[pp] = inchar();
			qq = pp;
		}
		if (*(ktbl + p + pp) != c[pp]) {
			p += 4;
			++cd;
			while (p < 68 && *(ktbl + p) != c[0]) {
				p += 4;
				++cd;
			}
			pp = 0;
		}
		if (p >= 68) {
			return (c[qq]);
		}
	}
	return (cd);
}

int inchar() {
	char c;
	while ((c = bdos(6, 0xFF)) == NULL) ;
	return (c);
}

static char buf[128];
void _spr(void **fmt, void (*outp)(char c)) {
	vsnprintf(buf, sizeof(buf), *fmt, &fmt[1]);
	puts(buf);
}

void puts(char *buf) {
	char c;
	while (*buf != 0) {
		outchr(*buf++);
	}
}

void outchr(char c) {
	if (c == '\n') {
		bdos(6, '\r');
	}
	bdos(6, c);
}

int printf(char *format, ...) {
	return _spr(&format, outchr);
}

void putctl(char *buf) {	/* for outputing screen control sequences only ! */
				/* this routine does not change '\n' into '\r','\n' */
	char c;
	while ((c = *buf++) != 0) {
		if (c & 0x80) {
			putnul(c);
		} else {
			bdos(6, c);
		}
	}
}

void putnul(char c) {
	c &= 0x7F;
	while (c-- > 0) {
		bdos(6, 0);
	}
}

void cursor(int position) {
	char line, col;
	char c;
	int p;
	line = --position / TWIDTH;
	col = position % TWIDTH;
	for (p = 0; p < 12; ++p) {
		c = termctrl.cpos[p];
		if (c == 0) {
			break;
		}
		if (c < 0x80) {
			bdos(6, c);
			continue;
		}
		if (c == 0x80) {
			c = line;
		} else if (c == 0x81) {
			c = col;
		} else {
			putnul(c);
			continue;
		}
		++p;
		if (termctrl.cpos[p] == 0xFF) {
			printf("%d", c + 1);
		} else {
			bdos(6, c + termctrl.cpos[p]);
		}
	}
}

int getwidth() {
	return (TWIDTH);
}

int getlength() {
	return (TLENGTH);
}

char *getterm() {
	return (termctrl.name);
}

void clrscr() {
	putctl(termctrl.cls);
}

void curhome() {
	putctl(termctrl.home);
}

void curleft() {
	putctl(termctrl.cleft);
}

void curright() {
	putctl(termctrl.cright);
}

void curup() {
	putctl(termctrl.cup);
}

void curdown() {
	putctl(termctrl.cdown);
}

void clreel() {
	putctl(termctrl.ceol);
}

void clreop() {
	putctl(termctrl.ceop);
}

void curoff() {
	putctl(termctrl.coff);
}

void curon() {
	putctl(termctrl.con);
}

void invon() {
	putctl(termctrl.revvid);
}

void invoff() {
	putctl(termctrl.nrmvid);
}

void bell() {
	bdos(6, 0x07);
}

/* end of TERMSYS */
