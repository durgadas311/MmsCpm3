/*
 * Setup30 display handling routines
 *
 * Version 3.103
 *
 * Date last modified: 7/18/84 09:19 drm
 *
 * "DISPLAY.C"
 */

#include "setup30.h"
#include "term.h"
#include <ctype.h>

extern void outchr(char c);
extern void _spr(void **fmt, void (*outp)(char c));

int getnum(short fldsiz, short *pdata);
int getstr(short fldsiz, char *pdata);
ushort getchr();
ushort getcntrl();
void movcur(char c, short maxcol, short maxlne);
void initcur(ushort stline, int nline, int stcol, int ncol, int colwids, ...);
void prtpos(ushort line, ushort col, char *format, ...);
void prtcnt(char *format, ...);
void currnt();
int prtmcur();
int prtcur(char *f);
void clmn();
void putwin(ushort linenum, char *strpt);
void prtwin(ushort linenum, char *format, ...);

/* Keyboard routines */

int getnum(short fldsiz, short *pdata) {	/* gets a number from the */
						/* the screen and puts in */
	/* pdata if it's ok  */
	short i, inp, pt, flag;
	char str[8];

	pt = 0;
	flag = TRUE;
	while (flag == TRUE) {
		inp = getchr();
		if (inp == BS) {
			if (pt-- <= 0) {
				pt = 0;
			} else {
				outchr(BS);
				outchr(' ');
				outchr(BS);
			}
		} else if (inp >= '0' && inp <= '9') {
			if (pt == 0) {
				for (i = 0; i < fldsiz; ++i) {
					outchr(' ');
				}
				currnt();
			}
			str[pt] = inp;
			outchr(inp);
			if (++pt >= fldsiz) {
				flag = FALSE;
			}
		} else if (inp == NULL) {
			flag = FALSE;
		} else {
			bell();
		}
	}
	str[pt] = NULL;
	if (pt == 0) {	/* return null if no char were entered */
		return (NULL);
	}
	*pdata = atoi(str);
	return (!NULL);
}

int getstr(short fldsiz, char *pdata) {	/* input a string on the screen */
	short i, inp, pt, flag;

	pt = 0;
	flag = TRUE;
	while (flag == TRUE) {
		inp = toupper(getchr());
		if (inp == BS) {
			if (pt-- <= 0) {
				pt = 0;
			} else {
				outchr(BS);
				outchr(' ');
				outchr(BS);
			}
		} else  if ((inp >= 'A' && inp <= 'Z') || (inp >= '0' && inp <= '9')) {
			if (pt == 0) {
				for (i = 0; i < fldsiz && pt == 0; ++i) {
					outchr(' ');
				}
				currnt();
			}
			pdata[pt] = inp;
			outchr(inp);
			if (++pt >= fldsiz) {
				flag = FALSE;
			}
		} else  if (inp == NULL) {
			flag = FALSE;
		} else {
			bell();
		}
	}
	if (pt == 0) {
		return (NULL);    /* if no char were entered return null */
	}
	pdata[pt] = NULL;
	return (!NULL);
}

ushort getchr() {
	ushort c;

	if (charbuf == NULL) {
		c = getkey();
		if ((c & CNTL) || c == CRCD) {
			cntrlbuf = c;
			return (NULL);
		}
	} else {
		c = charbuf;
		charbuf = NULL;
	}
	return (c);
}

ushort getcntrl() {
	ushort c;

	if (cntrlbuf == NULL) {
		c = getkey();
		if (c < CNTL && c != CRCD) {
			charbuf = c;
			return (NULL);
		}
	} else {
		c = cntrlbuf;
		cntrlbuf = NULL;
	}
	return (c);
}

void movcur(char c, short maxcol, short maxlne) {
 	/* moves cursor according to c which is */
	/* a cursor control char */
	switch (c) {
	case DOWN:			/* down arrow */
	case CRCD:
		if (++curline > maxlne - 1) {
			curline = maxlne - 1;
		}
		break;
	case UP:			/* up arrow */
		if (--curline <= 0) {
			curline = 0;
		}
		break;
	case RIGHT:			/* right arrow */
		if (++curcol >= maxcol) {
			curcol = maxcol - 1;
		}
		break;
	case LEFT:			/* left arrow */
		if (--curcol <= 0) {
			curcol = 0;
		}
		break;
	case HMCD:			/* home key */
		curline = curcol = 0;
		break;
	default:
		break;
	}
}

/* Screen routines */

/* initializes the cursor
 * stline = starting line of screen
 * nline = number of lines on screen
 * stcol = starting column of screen
 * ncol = number of columns and colwids
 * colwids = first column width
 */
{
void initcur(ushort stline, int nline, int stcol, int ncol, int colwids, ...) {
	ushort *cptr, lpos, cpos, col, ln;

	for (lpos = ((stline - 1) * getwidth()) + stcol, ln = 0;
			ln < nline; lpos += getwidth(), ln++) {
		cptr = (ushort *)&colwids;
		for (cpos = lpos, col = 0; col < ncol; cpos += *cptr++, col++) {
			curpos[ln][col] = cpos;
		}
	}
}

void prtpos(ushort line, ushort col, char *format, ...) {
 	/* print formated data at line and col */

	cursor(curpos[line][col]);
	_spr(&format, outchr);	      /* formated output libaray function */
}

void prtcnt(char *format, ...) {
	currnt();
	_spr(&format, outchr);
}

void currnt() {	/* move cursor to current position */
	cursor(curpos[curline][curcol]);
}

int prtmcur() {
	cursor((STMNLNE + 2)*getwidth() + 1);
	puts("ENTER  = Execute functions\n");
	puts("<UP>   = Move up a line\n");
	puts("<DOWN> = Move down a line\n");
	puts("<HOME> = Jump to top line");
	return (0);
}

int prtcur(char *f) {
	cursor((STMNLNE + 2)*getwidth() + 1);
	printf( "%-11.11s = End and update %s\n", termctrl.f6name, f);
	printf( "%-11.11s = Quit (No update)\n", termctrl.f7name);
	printf( "%-11.11s = Restart with original data\n", termctrl.f8name);
	puts("ARROWS      = Move to next field\n");
	puts("HOME        = Jump to top line");
	return (0);
}

void clmn() {		/* clears window on screen */
	ushort i;

	curoff();
	for (i = 0; i < (getlength() - (STMNLNE + 1)); ++i) {
		cursor(((i + STMNLNE)*getwidth()) + STMNCOL);
		clreel();
	}
	curon();
}

void putwin(ushort linenum, char *strpt) {	/* prints a unformated message in the window */
	curoff();
	cursor(((linenum - 1 + STMNLNE)*getwidth()) + STMNCOL);
	clreel();
	puts(strpt);
	curon();
}

void prtwin(ushort linenum, char *format, ...) {
	/* prints a formated message in the window */
	cursor(((linenum - 1 + STMNLNE) * getwidth()) + STMNCOL);
	clreel();
	_spr(&format, outchr);	/* formated output libaray function */
}

/* end of DISPLAY */
