/* Set logical physical table menu
 *
 * Version 3.103
 *
 * Date last modified: 7/4/84 13:53 drm
 *
 * "SETLPTBL.C"
 *
 */

#include "setup30.h"

#define STLNE	2
#define NLNE	17
#define STCOL	2
#define NCOL	5
#define ECOL	3
#define STRFLD	"%-47.47s"

int setlptbl(char *filename) {
	DRVTABL drvtbl;
	short inp;

	clrscr();
	initcur(STLNE, NLNE, STCOL, NCOL, 3, 12, 4, 51);
	cpydrv(drvtbl, drivtable);
	prtlhd();
	prtlptbl(drvtbl);
	prtcur(filename);
	curline = 1;
	curcol = 2;
	oldcol = 99;
	do {
		inp = getlfld(drvtbl);
		if (inp == WHITE) {
			cpydrv(drvtbl, drivtable);
			prtlptbl(drvtbl);
			curline = 1;
			curcol = 2;
			oldcol = 99;
		}
		if (inp == BLUE) {
			cpydrv(drivtable, drvtbl);
			if (putdrvtbl() == ERROR) {
				putwin(1, errmsg(errmsg()));
				bell();
				inp = NULL;
			}
		}
	} while (inp != BLUE && inp != RED);
	curon();
	return (OK);
}

void cpydrv(DRVTABL *drv1, DRVTABL *drv2) {
	movmem(drv2, drv1, sizeof * drv1);
}

void initlptbl(DRVTABL *drvtbl) {	/* Set default entries in the log/phy table */
	short i, j, pdrv, ldrv;

	for (i = 0; i < MAXDRV; ++i)
		if (drvtbl->logphytbl[i] != UNASGN) {
			return;
		}
	for (i = ldrv = 0; i < numdiskio && ldrv < MAXDRV; ++i) {
		pdrv = dskptrtbl[i]->compart.phydevnum;
		for (j = 0; j < dskptrtbl[i]->compart.numdev && ldrv < MAXDRV; ++j, ++pdrv, ++ldrv) {
			drvtbl->logphytbl[ldrv] = pdrv;
		}
	}
}


void prtlhd() {
	if (mpmfile) {
		puts("        ");
	} else {
		puts("TFD DSO ");
	}
	puts("Logical PDN           Module Description\n");
}

void prtdrlet() {		/* print drive letter */
	short i;

	cursor((STLNE - 1)*getwidth() + 9);
	if (!mpmfile) {
		puts("Default     Currently logged-in drive");
	}
	for (i = 0; i < MAXDRV; ++i) {
		cursor((STLNE + i)*getwidth() + 11);
		printf("%c:\n", i + 'A');
	}
}

void prtlptbl(DRVTABL *drvtbl) {	/* print all variable portitions of menu */
	curoff();
	if (!mpmfile) {
		prttdrv(drvtbl->tempdrv);
		prtsord(drvtbl->drvsch);
	}
	prtdrlet();
	for (curline = 1; curline < MAXDRV + 1; ++curline) {
		prtpnum(drvtbl->logphytbl);
		if (prtstr(drvtbl->logphytbl) == ERROR) {
			prtpos(curline, 3, " ! Module not supported !");
		}
	}
	prtdup(drvtbl->logphytbl);
	curon();
}

int getlfld(DRVTABL *drvtbl) {	/* move cursor to a field and if a non cntrl */
				/* type character is entered goto the field */
				/* curcol is pointing to */
	short inp;

	curon();
	do {
		prtlmsg();
		currnt();
		inp = getcntrl();
		putwin(7, "");
		if (inp == BLUE || inp == RED || inp == WHITE) {
			return (inp);
		}
		movcur(inp, ECOL, NLNE);
		if (mpmfile) {
			curcol = 2;
		}
		if (curcol == 2 && curline == 0) {
			curline = 1;
		}
	} while (inp != NULL);
	currnt();
	switch (curcol) {
	case 0:
		tempfld(drvtbl);
		break;
	case 1:
		schfld(drvtbl);
		break;
	case 2:
		phyfld(drvtbl);
		break;
	}
	return (NULL);
}

void prtlmsg() {			/* print window help messages */
	if (oldcol == curcol) {
		return;
	}
	oldcol = curcol;
	switch (curcol) {
	case 0:
		putwin(3, "Temporary File Drive");
		putwin(5, "T = drive used for temporary files");
		putwin(6, "");
		break;
	case 1:
		putwin(3, "Drive Search Order");
		putwin(5, "1 = First     3 = Third");
		putwin(6, "2 = Second    4 = Fourth");
		break;
	case 2:
		putwin(3, "Physical Drive Number");
		putwin(5, "DELETE  = Set drv \"Not assigned\"");
		putwin(6, "");
		break;
	}
}

void tempfld(DRVTABL *drvtbl) {		/* Change temporary drive field */
	short inp;

	inp = toupper(getchr());
	if (inp == 'T') {
		if (curline != 0 && drvtbl->logphytbl[curline - 1] == UNASGN) {
			putwin(7, "Logical drive not assigned");
			bell();
		} else {
			drvtbl->tempdrv = curline;
		}
	} else if (inp == NULL) {
		return;
	} else {
		bell();
	}
	curoff();
	prttdrv(drvtbl->tempdrv);
}

void schfld(DRVTABL *drvtbl) {	/* change drive search field */
	short inp, i, j;

	inp = getchr();
	if (inp >= '1' && inp <= '4') {
		inp = inp - '1';
		if (curline != 0 && drvtbl->logphytbl[curline - 1] == UNASGN) {
			putwin(7, "Logical drive not assigned");
			bell();
		} else {
			for (j = 0; j < 4; ++j) /* get end of drv search table */
				if (drvtbl->drvsch[j] == 0xFF && inp >= j) {
					inp = j;
					break;
				}
			drvtbl->drvsch[inp] = curline;
			for (j = 0; j < 4; ++j) { /* delete dup drives if any */
				if (j != inp && drvtbl->drvsch[j] == drvtbl->drvsch[inp]) {
					for (i = j; i < 4; ++i) {
						drvtbl->drvsch[i] = drvtbl->drvsch[i + 1];
					}
					drvtbl->drvsch[3] = 0xFF;
				}
			}
		}
	} else if (inp == NULL) {
		return;
	} else {
		bell();
	}
	curoff();
	prtsord(drvtbl->drvsch);
}

void phyfld(DRVTABL *drvtbl) {
	short inp, i, j;
	word temp1, temp2;

	if ((inp = getchr()) == DELETE) {	/* see if a delete character was hit */
		drvtbl->logphytbl[curline - 1] = UNASGN;
		curoff();
		chkdrvtbl(drvtbl);	/* check and see if the deleted  */
		curon();		/* drive had temp or search order */
	}			/* assigned to it */
	else if (inp >= '0' && inp <= '9') {
		charbuf = inp;		/* push back character for getnum */
		temp1 = temp2 = drvtbl->logphytbl[curline - 1];
		inp = getnum(2, &temp1);
		drvtbl->logphytbl[curline - 1] = temp1;
	} else {
		bell();
		return;
	}
	if (bioscurflg == FALSE && bdos(25, 0) == curline - 1) { /* func 25 gets */
		/* current drive */
		bell();
		putwin(7, "Can not change current drive");
		drvtbl->logphytbl[curline - 1] = temp2;
		cntrlbuf = NULL;
	} else if (prtstr(drvtbl->logphytbl) == ERROR) {
		bell();
		prtwin(7, "Drive %d not supported", temp1);
		drvtbl->logphytbl[curline - 1] = temp2;
		cntrlbuf = NULL;
	}
	curoff();
	prtpnum(drvtbl->logphytbl);
	prtdup(drvtbl->logphytbl);
}

void chkdrvtbl(DRVTABL *drvtbl) {	/* checks temporary and file search */
					/* order fields to if one is assigned*/
					/* to an deleted drive. */
	short i, j;

	if (drvtbl->tempdrv == curline) {
		drvtbl->tempdrv = 0;
		prttdrv(drvtbl->tempdrv);
	}
	for (j = 0; j < 4; ++j) {
		if (drvtbl->drvsch[j] == curline) {
			if (j == 0 && drvtbl->drvsch[j + 1] == 0xFF) {
				drvtbl->drvsch[j] = 0;
				prtsord(drvtbl->drvsch);
				break;
			}
			for (i = j; i < 4; ++i) {
				drvtbl->drvsch[i] = drvtbl->drvsch[i + 1];
			}
			drvtbl->drvsch[3] = 0xFF;
			prtsord(drvtbl->drvsch);
			break;
		}
	}
}

void prtsord(byte *drvs) {	/* print drive search order field */
	char *sordstr();
	short i, j;

	for (i = 0; i < MAXDRV + 1; ++i) {
		prtpos(i, 1, "   ");
		for (j = 0; j < 4; ++j)
			if (drvs[j] == i) {
				prtpos(i, 1, "%s", sordstr(j));
			}
	}
}

char *sordstr(short scrnum) {
	switch (scrnum) {
	case 0:
		return ("1st");
	case 1:
		return ("2nd");
	case 2:
		return ("3rd");
	case 3:
		return ("4th");
	default:
		return ("   ");
	}
}

void prttdrv(byte tdrv) {	/* print temporary drive field */
	short i;

	for (i = 0; i < MAXDRV + 1; ++i) {
		if (tdrv == i) {
			prtpos(i, 0, "T");
		} else {
			prtpos(i, 0, " ");
		}
	}
}

void prtpnum(byte *lptbl) {	/* print physical drive number */
	if (lptbl[curline - 1] == UNASGN) {
		prtpos(curline, 2, "--");
	} else {
		prtpos(curline, 2, "%2.2d", lptbl[curline - 1]);
	}
}

int prtstr(byte *lptbl) {	/* print module text string */
	ushort phynum, i;

	phynum = lptbl[curline - 1];
	if (phynum >= UNASGN) {
		prtpos(curline, 3, "..Not assigned...");
		clreel();
		return (OK);
	}
	if ((i = searchdisk(phynum)) == ERROR) {
		return (ERROR);
	} else {
		prtpos(curline, 3, STRFLD, dskptrtbl[i]->compart.string);
	}
	clreel();
	return (OK);
}

void prtdup(byte *lptbl) {	/* print or clear duplicate msg */
	short i, j;
	byte duparr[MAXDRV];

	setmem(duparr, MAXDRV, FALSE);
	for (j = 0; j < MAXDRV; ++j) {
		for (i = 0; i < MAXDRV; ++i) {
			if (i != j && lptbl[i] != UNASGN && lptbl[i] == lptbl[j]) {
				duparr[i] = TRUE;
			}
		}
	}
	for (j = 0; j < MAXDRV; ++j) {
		if (duparr[j]) {
			prtpos(j + 1, 4, "Duplicate");
		} else {
			prtpos(j + 1, 4, "         ");
		}
	}
}

int searchdisk(ushort phydev) {
	ushort i, phyb, numd;

	for (i = 0; i < numdiskio; ++i) {
		phyb = dskptrtbl[i]->compart.phydevnum;
		numd = dskptrtbl[i]->compart.numdev;
		if (phydev >= phyb && phydev < phyb + numd) {
			return (i);
		}
	}
	return (ERROR);
}

