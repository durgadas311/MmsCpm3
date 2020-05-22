/* SYSTEM dependant routines */

/* CP/M */
#include <cpm.h>

/* TODO: use real-time units. */
#define CHRTIME	1000	/* approx 1/8 "game time-unit" */
static int t = CHRTIME;

void osinit() {
	/* TODO: determine time base */
}

void osreset() {
	t = CHRTIME;
}

void outchr(char c) {
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
