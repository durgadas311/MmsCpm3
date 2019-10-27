/* TERMINAL dependant routines */

extern prts();
extern outchr();

static char rev = 0;

clrscr() {outchr('\032');}

cleol() {outchr('\030');}

curon() {prts("\033B4");}

curoff() {prts("\033C4");}

revv() {
	if (!rev) {
		prts("\033B0");
		rev = 1;
	}
}

nrmv() {
	if (rev) {
		prts("\033C0");
		rev = 0;
	}
}

cursor(r,c)
char r,c;
{
    outchr(27); outchr('=');
    outchr(r+32); outchr(c+32);
}

llc() {	/* lower-left corner graphic */
	outchr('\205');
}
lrc() {	/* lower right corner */
	outchr('\212');
}
ulc() {	/* upper left corner */
	outchr('\320');
}
urc() {	/* upper right corner */
	revv();
	outchr('\337');
	nrmv();
}
horz(n,t)	/* N horiz chars, T = top */
int n;
char t;
{
	char c;
	c = (t ? '\260' : '\214');
	while (n-- > 0) {
		outchr(c);
	}
}
vl(l)	/* single vert line char, L = left */
char l;
{
	if (!l) revv();
	outchr('\325');
	if (!l) nrmv();
}

/* "critical hits" bargraph, 3 ticks per char cell. */
hits(m)
char m;
{
	if (m) outchr('\272');
	else   outchr('\277');
}
char hit0() { return '\260'; }
char pos0() { outchr('\274'); }
putshl(r,c,a)
char r,c,a;
{
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
