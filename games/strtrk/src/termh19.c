/* TERMINAL dependant routines */

extern prts();
extern outchr();

static char rev = 0;

clrscr() {prts("\033E");}

cleol() {prts("\033K");}

curon() {prts("\033y5");}

curoff() {prts("\033x5");}

revv() {
	if (!rev) {
		prts("\033p");
		rev = 1;
	}
}

nrmv() {
	if (rev) {
		prts("\033q");
		rev = 0;
	}
}

static gron() { prts("\033F"); }
static groff() { prts("\033G"); }

cursor(r,c)
char r,c;
{
    outchr(27); outchr('Y');
    outchr(r+32); outchr(c+32);
}

llc() {	/* lower-left corner graphic */
	gron();
	outchr('e');
	groff();
}
lrc() {	/* lower right corner */
	gron();
	outchr('d');
	groff();
}
ulc() {	/* upper left corner */
	gron();
	outchr('f');
	groff();
}
urc() {	/* upper right corner */
	gron();
	outchr('c');
	groff();
}
horz(n,t)	/* N horiz chars, T = top */
int n;
char t;
{
	gron();
	while (n-- > 0) {
		outchr('a');
	}
	groff();
}
vl(l)	/* single vert line char, L = left */
char l;
{
	gron();
	outchr('`');
	groff();
}

/* "critical hits" bargraph, 3 ticks per char cell. */
hits(m)
char m;
{
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
putshl(r,c,a)
char r,c,a;
{
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
