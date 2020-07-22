/* Set File type search order
 *
 * Version 3.103
 *
 * Date last modified: 7/4/84 13:54 drm
 *
 * "FTSORD.C"
 *
 */

#include "setup30.h"
#include "display.h"
#include "term.h"
#include "putdrvtb.h"

int setftsord(char *filename);
void prtfthd();
void prtftyp(byte ftsord);

#define  MSTR 6

int setftsord(char *filename) {
	byte ftsord;
	short inp;

	ftsord = subcom;
	prtfthd();
	prtcur(filename);
	prtftyp(ftsord);
	do {
		inp = getchr();
		if (inp >= '1' && inp <= '3') {
			ftsord = inp - '1';
		} else if (inp != NULL) {
			bell();
		}
		prtftyp(ftsord);
		inp = getcntrl();
		if (inp == WHITE) {
			ftsord = subcom;
			prtftyp(ftsord);
		} else if (inp == BLUE) {
			subcom = ftsord;
			if (puttyps() == ERROR) {
				putwin(1, errmsg(errmsg()));
				bell();
			}
		} else if (inp == RED)
			;
		else if (inp != NULL) {
			bell();
		}
	} while (inp != RED && inp != BLUE);
	curon();
	return (TRUE);
}

void prtfthd() {
	clrscr();
	puts("File type search order");
	putwin(3, "1 = .COM files only");
	putwin(4, "2 = .COM files 1st, then .SUB");
	putwin(5, "3 = .SUB files 1st, then .COM");
}

void prtftyp(byte ftsord) {
	curoff();
	cursor(MSTR * getwidth() + 1);
	puts("Search order: ");
	switch (ftsord) {
	case 0:
		printf(".COM     ");
		break;
	case 1:
		printf(".COM,.SUB");
		break;
	case 2:
		printf(".SUB,.COM");
		break;
	}
	cursor(MSTR * getwidth() + 15);
	curon();
}

