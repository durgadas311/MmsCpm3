/* TERMINAL dependant routines */

#include <stdio.h>	/* TODO: better way */

extern void prts(char *s);
extern void outchr(char c);

static char rev = 0;

void trmin() {
	prts("\033[1;1H\033[2J\033[1;24r");
}
void trmde() {
	prts("\033[r\033[1;1H\033[2J");
}

void clrscr() {prts("\033[2J");}

void cleol() {prts("\033[K");}

void curon() {
	prts("\033[?25h");
}

void curoff() {
	prts("\033[?25l");
}

void revv() {
	if (!rev) {
		prts("\033[7m");
		rev = 1;
	}
}

void nrmv() {
	if (rev) {
		prts("\033[0m");
		rev = 0;
	}
}

static void gron() { prts("\033(0"); }
static void groff() { prts("\033(B"); }

void cursor(char r, char c) {
    	static char buf[10];
	sprintf(buf, "\033[%d;%dH", r+1, c+1);
	prts(buf);
}

void llc() {	/* lower-left corner graphic */
	gron();
	outchr('m');
	groff();
}
void lrc() {	/* lower right corner */
	gron();
	outchr('j');
	groff();
}
void ulc() {	/* upper left corner */
	gron();
	outchr('l');
	groff();
}
void urc() {	/* upper right corner */
	gron();
	outchr('k');
	groff();
}
void horz(int n, char t) {	/* N horiz chars, T = top */
	gron();
	while (n-- > 0) {
		outchr('q');
	}
	groff();
}
void vl(char l) {	/* single vert line char, L = left */
	gron();
	outchr('x');
	groff();
}

/* "critical hits" bargraph, 3 ticks per char cell. */
void hits(char m) {
	if (m) {
		gron();
		outchr('a');
		groff();
	} else {
		revv();
		outchr(' ');
		nrmv();
	}
}
char hit0() { return('_'); }
char pos0() { gron(); outchr('`'); groff(); }
void putshl(char r, char c, char a) {
	gron();
	cursor(r,c);
	if (a) prts("lqk");
	else prts("   ");
	cursor(r+1,c+2);
	if (a) outchr('x');
	else outchr(' ');
	cursor(r+1,c);
	if (a) outchr('x');
	else outchr(' ');
	cursor(r+2,c);
	if (a) prts("mqj");
	else prts("   ");
	groff();
}
