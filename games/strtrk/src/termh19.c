/* TERMINAL dependant routines */

extern void prts(char *s);
extern void outchr(char c);

static char rev = 0;

void clrscr() {prts("\033E");}

void cleol() {prts("\033K");}

void curon() {prts("\033y5");}

void curoff() {prts("\033x5");}

void revv() {
	if (!rev) {
		prts("\033p");
		rev = 1;
	}
}

void nrmv() {
	if (rev) {
		prts("\033q");
		rev = 0;
	}
}

static gron() { prts("\033F"); }
static groff() { prts("\033G"); }

void cursor(char r, char c) {
    outchr(27); outchr('Y');
    outchr(r+32); outchr(c+32);
}

void llc() {	/* lower-left corner graphic */
	gron();
	outchr('e');
	groff();
}
void lrc() {	/* lower right corner */
	gron();
	outchr('d');
	groff();
}
void ulc() {	/* upper left corner */
	gron();
	outchr('f');
	groff();
}
void urc() {	/* upper right corner */
	gron();
	outchr('c');
	groff();
}
void horz(int n, char t) {	/* N horiz chars, T = top */
	gron();
	while (n-- > 0) {
		outchr('a');
	}
	groff();
}
void vl(char l) {	/* single vert line char, L = left */
	gron();
	outchr('`');
	groff();
}

/* "critical hits" bargraph, 3 ticks per char cell. */
void hits(char m) {
	revv();
	if (m) {
		gron();
		outchr('q');
		groff();
	} else outchr(' ');
	nrmv();
}
char hit0() { return('_'); }
char pos0() { gron(); outchr('^'); groff(); }
void putshl(char r, char c, char a) {
	gron();
	cursor(r,c);
	if (a) prts("fac");
	else prts("   ");
	cursor(r+1,c+2);
	if (a) outchr('`');
	else outchr(' ');
	cursor(r+1,c);
	if (a) outchr('`');
	else outchr(' ');
	cursor(r+2,c);
	if (a) prts("ead");
	else prts("   ");
	groff();
}
