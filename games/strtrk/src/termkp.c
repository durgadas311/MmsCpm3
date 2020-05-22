/* TERMINAL dependant routines */

extern int prts(char *s);
extern void outchr(char c);

static char rev = 0;

void trmin() {}
void trmde() {}

void clrscr() {outchr('\032');}

void cleol() {outchr('\030');}

void curon() {prts("\033B4");}

void curoff() {prts("\033C4");}

void revv() {
	if (!rev) {
		prts("\033B0");
		rev = 1;
	}
}

void nrmv() {
	if (rev) {
		prts("\033C0");
		rev = 0;
	}
}

static void gron() {}
static void groff() {}

void cursor(char r, char c) {
    outchr(27); outchr('=');
    outchr(r+32); outchr(c+32);
}

void llc() {	/* lower-left corner graphic */
	outchr('\205');
}
void lrc() {	/* lower right corner */
	outchr('\212');
}
void ulc() {	/* upper left corner */
	outchr('\320');
}
void urc() {	/* upper right corner */
	revv();
	outchr('\337');
	nrmv();
}
void horz(int n, char t) {	/* N horiz chars, T = top */
	char c;
	c = (t ? '\260' : '\214');
	while (n-- > 0) {
		outchr(c);
	}
}
void vl(char l) {	/* single vert line char, L = left */
	if (!l) revv();
	outchr('\325');
	if (!l) nrmv();
}

/* "critical hits" bargraph, 3 ticks per char cell. */
void hits(char m) {
	if (m) outchr('\272');
	else   outchr('\277');
}
char hit0() { return '\260'; }
char pos0() { outchr('\274'); }
void putshl(char r, char c, char a) {
	cursor(r,c);
	if (a) prts("\320\260\033B0\337");
	else prts("   ");
	cursor(r+1,c+2);
	if (a) vl(0);
	else outchr(' ');
	cursor(r+1,c);
	if (a) vl(1);
	else outchr(' ');
	cursor(r+2,c);
	if (a) prts("\205\214\212");
	else prts("   ");
}
