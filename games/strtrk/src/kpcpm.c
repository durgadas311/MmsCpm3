/* SYSTEM dependant routines */

/* CP/M */

/* TODO: use real-time units. */
#define CHRTIME	1000
static int t = CHRTIME;

osinit() {
	/* TODO: determine time base */
}

osreset() {
	t = CHRTIME;
}

outchr(c)
char c;
{
	bdos(6,c);
}

/* test if char typed */
char gc() {
	return(bdos(6,0xFF));    /* returns CHAR or 0 if not ready */
}

/* Wait for char with timeout. */
char gcto()
{
	char c;
	while((c=gc())==0) {
		if (--t == 0) {
			t = CHRTIME;
			break;
		}
	}
	return c;
}

/* wait indefinitely for char */
char inch0() {
	char c;
	while((c=gc())==0);
	return(c);
}
