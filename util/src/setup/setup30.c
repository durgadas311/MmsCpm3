/* This is the main functions and menu for SETUP
 *
 * Date last modified: 7/4/84 13:02 drm
 *
 * "SETUP30.C"
 *
 */

#include "setup30.h"
#include "term.h"
#include "getdrvtb.h"
#include "serdp.h"
#include "btconv.h"
#include "biosfile.h"
#include "display.h"
#include "setlptbl.h"
#include "chario.h"
#include "diskio.h"
#include "ioredir.h"
#include "ftsord.h"

/* malloc heap... */
long heap;

#define VERS	"3.104 "
#define SELECT	14	/* select disk */
#define GETSCB	49	/* get or put system control block variables */
#define GETDSK	25	/* get currently logged on drive */
#define DRVSC	0x4C	/* drive order search position in SCB */
#define TSTMPMADR 0x57	/* MP/M test byte offset */
#define NLNE	3	/* number of fixed lines on menu */
#define MPMNLNE 1	/* number of fixed lines for MP/M xios file */
#define NCOL	1	/* number of columns in menu */
#define STLNE	3	/* starting line of menu */
#define STCOL	1	/* starting column */

void getfile(char *filename, char *drive);
void startup(char *filename);
void endset();
void mainmenu(char *filename);
void prtsignon();
void prtmfix();
void prtmvar();
void selmain();
int execmain(char *filename);
void chainfil(short altdrv, char *name, char *opt1, char *opt2);
int chkmbios();
int chkmpm();
void outerr(char *filename);
void outerr2(short er, char *filename);

CHARTABL *chrptrtbl[MAXCHR];
ushort numchario;
DISKTABL *dskptrtbl[MAXDSK];
ushort numdiskio;
word serdpadr;
DRVTABL drivtable;
byte subcom;
word redirvec[5];
word nodeadr;
byte nodenum;
byte secbuf[SECSIZ];
ushort cursec;
bool writeflg;
ushort fd;
short curline,curcol,oldcol;
ushort curpos[MAXLNE][MAXCOL];
char cntrlbuf,charbuf;
bool bioscurflg;
word biosstart; 
bool mpmfile;

int main(int argc, char **argv) {	/* main entry point from CP/M */
	char filename[20], drive[4], *cptr;
	byte temp;
	ushort vers;
	short er;

	initial();	/* initialize terminal */
	prtsignon();
	vers = bdos(12, 0);
	if ( ((vers & 0xff) < 0x30) || (vers & 0xfd00) != 0 ) {
		deinit();
		bell();
		printf("\nThis program must run on CP/M version 3.0 or greater\n");
		exit(1);
	}
	bdos(45, 0xFF);		/* set return error mode */
	if (argc > 1) {
		if ((*(argv + 1))[0] == '[') {	/* get command line arg */
			if ((*(argv + 1))[1] == 'C') {
				bioscurflg = FALSE;
				strcpy(filename, "CURRENT SYSTEM");
				startup(filename);
			} else {
				printf("\nBad command line option\n");
				return;
			}
		} else {
			bioscurflg = TRUE;
			if ((*(argv + 1))[1] == ':' && (*(argv + 1))[2] == NULL) {
				getfile(filename, argv[1]);
			} else {
				if ((*(argv + 1))[1] != ':') {
					filename[0] = bdos(25, 0) + 'A';
					filename[1] = ':';
					filename[2] = NULL;
				} else {
					filename[0] = NULL;
				}
				strcat(filename, argv[1]);
				cptr = filename;
				while (*cptr != '.') {
					if (*cptr++ == NULL) {
						strcat(filename, ".SPR");
						break;
					}
				}
				startup(filename);
			}
		}
	} else {
		bioscurflg = TRUE;
		drive[0] = bdos(25, 0) + 'A';
		drive[1] = ':';
		drive[2] = NULL;
		getfile(filename, drive);
	}
	numchario = numdiskio = 0;
	if ((er = chkmbios()) <= ERROR) {	/* Checks for a valid */
		/* system file */
		deinit();
		outerr2(er, filename);
		exit(1);
	}
	if ((er = chkmpm()) <= ERROR) {	/* Check for MP/M or CP/M 3 */
		/* type file */
		deinit();
		outerr2(er, filename);
		exit(1);
	}
	if ((er = getdrvtbl()) <= ERROR) {	/* get logical phys table,*/
		/* temp drv, drv search */
		deinit();
		outerr2(er, filename);		/* table, and redirection */
		exit(1); 			/* vectors */
	}
	if ((er = gettables()) <= ERROR) {	/* get character and disk io */
		/* information and put in */
		deinit();
		outerr2(er, filename);		/* global table */
		exit(1);
	}
	if ((er = ldserdp()) <= ERROR) {
		deinit();
		outerr2(er, filename);
		exit(1);
	}
	if (bioscurflg) {
		initlptbl(drivtable);    /* setup default entries in phy/table */
	}
	mainmenu(filename);
	endset();
	if (bioscurflg) {
		clrscr();
		if (mpmfile) {
			puts("-- REMEMBER! YOU MUST RUN \"GENSYS.COM\"\n");
		} else {
			puts("-- REMEMBER! YOU MUST RUN \"GENCPM.COM\"\n");
		}
		puts("   TO ACTIVATE ANY CHANGES MADE!\n");
	}
	return 0;
}

void getfile(char *filename, char *drive) {	/* Setups and opens the bios file */
						/* when the file is not known */
						/* Searchs for BNKBIOS.SPR and then */
	writeflg = FALSE; 			/* BNKXIOS.SPR */
	strcpy(filename, drive);
	strcat(filename, "BNKBIOS3.SPR");
	if (openbios(filename) == ERROR) {
		strcpy(filename, drive);
		strcat(filename, "BNKXIOS.SPR");
		if (openbios(filename) == ERROR) {
			deinit();
			if (errno == 11) {
				bell();
				puts("\nBanked BIOS file not found\n");
			} else {
				outerr("");
			}
			exit(1);
		}
	}
}

void startup(char *filename) {	/* Setups and opens the bios file */
				/* when it's known (in the command */
				/* line) */
	writeflg = FALSE;
	if (openbios(filename) == ERROR) {
		deinit();
		bell();
		outerr(filename);
		exit(1);
	}
}

void endset() {
	cursor(22 * getwidth() + 1);
	deinit();
	if (closebios() == ERROR) {
		bell();
		outerr("");
		exit(1);
	}
}

void mainmenu(char *filename) {	/* Select submenu and call exec */
				/* menu routine to do it */
	short line, cond;

	cond = TRUE;
	curcol = curline = 0;
	while (TRUE) {
		if (bioscurflg) {	/* if TRUE modifing bios file */
			if (mpmfile) {
				initcur(STLNE, MPMNLNE + numchario + numdiskio + 2, STCOL, NCOL, 0);
			} else {
				initcur(STLNE, NLNE + numchario + numdiskio + 2, STCOL, NCOL, 0);
			}
		} else {
			initcur(STLNE, NLNE + numchario + numdiskio + 1, STCOL, NCOL, 0);
		}
		if (cond != ERROR) {
			prtmfix();
			prtmvar();
			prtmcur();
			prtwin(2, "Modifying %s", filename);
		}
		selmain();
		line = curline;
		cond = execmain(filename);
		curline = line + 1;
		if (cond == FALSE) {
			return;
		}
		if (cond != ERROR) {
			prtsignon();
		}
	}
}

void prtsignon() {			/* prints signon message */
	char *getterm();

	clrscr();
	printf("SETUP v%s (c) 1983,1984 Magnolia Microsystems (%s terminal)\n\n", VERS, getterm());
}

void prtmfix() {			/* prints fixed parts of main menu */
	puts(". Set logical/physical drive assignments\n");
	if (!mpmfile) {
		puts(". Set I/O redirection vectors\n");
		puts(". Set file type search order\n");
	}
}

void prtmvar() {			/* prints variable parts of menu */
	ushort i;

	for (i = 0; i < numchario; ++i) {
		printf(". %s\n", chrptrtbl[i]->compart.string);
	}
	for (i = 0; i < numdiskio; ++i) {
		printf(". %s\n", dskptrtbl[i]->compart.string);
	}
	if (bioscurflg)
		if (mpmfile) {
			puts(". Generate new MP/M system and exit\n");
		} else {
			puts(". Generate new CP/M system and exit\n");
		}
	puts(". Exit to CP/M\n");
}

void selmain() {			/* select a submenu */
	short inp, nline;

	if (mpmfile) {
		nline = MPMNLNE + numchario + numdiskio;
	} else {
		nline = NLNE + numchario + numdiskio;
	}
	if (bioscurflg) {
		++nline;
	}
	do {
		curcol = 0;
		currnt();
		inp = getkey();
		putwin(4, "");
		if (inp == DOWN) {
			if (++curline >= nline) {
				curline = nline;
			}
		} else if (inp == HMCD) {
			curline = 0;
		} else if (inp == UP) {
			if (--curline <= 0) {
				curline = 0;
			}
		} else if (inp != CRCD) {
			bell();
		}
	} while (inp != CRCD);
}

int execmain(char *filename) {		/* Execute a submenu */
	if (mpmfile) {
		/* If MP/M file */
		if (curline == 0) {
			setlptbl(filename);
		} else if (curline - MPMNLNE < numchario) {
			setchario(chrptrtbl[curline - MPMNLNE], filename);
		} else if (curline - (MPMNLNE + numchario) < numdiskio) {
			setdiskio(dskptrtbl[(curline - MPMNLNE) - numchario], filename);
		} else if (curline - (MPMNLNE + numchario + numdiskio) < 1 && bioscurflg) {
			endset();
			chainfil(filename[0] - 'A', "GENSYS.COM", "$AR", 0);
			startup(filename);
			return (ERROR);
		} else {
			return (FALSE);
		}
	} else {
		/* If CP/M file */
		if (curline == 0) {
			setlptbl(filename);
		} else if (curline == 1) {
			setiored(filename);
		} else if (curline == 2) {
			setftsord(filename);
		} else if (curline - NLNE < numchario) {
			setchario(chrptrtbl[curline - NLNE], filename);
		} else if (curline - (NLNE + numchario) < numdiskio) {
			setdiskio(dskptrtbl[(curline - NLNE) - numchario], filename);
		} else if (curline - (NLNE + numchario + numdiskio) < 1 && bioscurflg) {
			endset();
			chainfil(filename[0] - 'A', "GENCPM.COM", "A", "D");
			startup(filename);
			return (ERROR);
		} else {
			return (FALSE);
		}
	}
	return (TRUE);
}

void execl(char *name, char *opt1, char *opt2) {
	char *buf;
	buf = (char *)0x0080;
	strcpy(buf, name);
	if (opt1) {
		strcat(buf, " ");
		strcat(buf, opt1);
	}
	if (opt2) {
		strcat(buf, " ");
		strcat(buf, opt2);
	}
	bdos(47, 0xff); /* does not return */
	/* NOTREACHED */
}

void chainfil(short altdrv, char *name, char *opt1, char *opt2) {
/* name,opt1,opt2 = command to chain to */
/* altdrv = drive in bios file name */
	short drv, logdrv;
	ushort adr;
	char filename[20];
	byte scbpd[4];

	logdrv = bdos(GETDSK, 0);
	if (altdrv != logdrv) {
		bdos(SELECT, altdrv);
		execl(name, opt1, opt2);
	}
	for (adr = DRVSC; adr <= DRVSC + 3; ++adr) {
		scbpd[0] = adr;
		scbpd[1] = 0;
		drv = bdos(GETSCB, scbpd) & 0xFF;
		if (drv == 0xFF) {
			break;
		}
		if (drv == 0) {
			drv = logdrv;
		} else {
			--drv;
		}
		filename[0] = drv + 'A';
		filename[1] = ':';
		filename[2] = NULL;
		strcat(filename, name);
		execl(filename, opt1, opt2);
	}
	bell();
	prtwin(4, "%s not found", name);
	bdos(SELECT, logdrv);
}

int chkmbios() {		/* checks if system is valid by checking for */
				/* 16 JMP's in a row */
	byte jump;
	short i, retcode;

	retcode = OK;
	for (i = 0; i < (16 * 3); i += 3) {
		if (getbyte(&jump, i + biosstart) == ERROR) {
			retcode = ERROR;
			break;
		}
		if (jump != 0xC3) {
			retcode = ERROR - 8;
			break;
		}
	}
	return (retcode);
}

int chkmpm() {
	byte testbyte;
	short retcode;

	if (getbyte(&testbyte, biosstart + TSTMPMADR) == ERROR) {
		retcode = ERROR;
	} else {
		if (testbyte == 0xC3) {
			mpmfile = FALSE;
			retcode = OK;
		} else {
			if (testbyte == 0) {
				mpmfile = TRUE;
				retcode = OK;
			} else {
				retcode = ERROR - 8;
			}
		}
	}
	return (retcode);
}

void outerr(char *filename) {
	short er;

	if ((er = errno) == 11) {
		printf("\n%s not found\n", filename);
	} else {
		printf("\n%s\n", errmsg(er));
	}
}

void outerr2(short er, char *filename) {
	bell();
	switch (er) {
	case ERROR:
		outerr(filename);
		break;
	case ERROR-1:
		printf("\nToo many character I/O modules linked in system\n");
		break;
	case ERROR-2:
		printf("\nToo many disk I/O modules linked in system\n");
		break;
	case ERROR-3:
		printf("\nToo many character I/O devices in a module\n");
		break;
	case ERROR-4:
		printf("\nToo many disk I/O devices in a module\n");
		break;
	case ERROR-5:
		printf("\nNot enough TPA\n");
		break;
	case ERROR-6:
		printf("\nModule string over %d characters\n", MAXSTRL);
		break;
	case ERROR-7:
		printf("\nLPTBL.REL not linked into system\n");
		break;
	case ERROR-8:
		printf("\n%s corrupt (MBIOS3.REL not present)\n", filename);
		break;
	}
}

