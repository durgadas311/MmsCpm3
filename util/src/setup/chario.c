/* Character IO module menu functions
 *
 * Version 3.103
 *
 * Date lasted modified: 7/4/84 13:40 drm
 *
 * "CHARIO.C"
 *
 */

#include "setup30.h"
#include "display.h"
#include "term.h"
#include "tbconv.h"
#include <ctype.h>

void setchario(CHARTABL *mainchr, char *filename);
void cpychr(CHARTABL *chr1, CHARTABL *chr2);
void reinitio(CHARTABL *chrentry);
void prtchd(CHARTABL *chrentry, bool confg);
void prtcvar(CHARTABL *chrentry, bool confg);
int getfld(CHARTABL *chrentry, bool confg);
void prtcmsg(CHARTABL *chrentry, bool confg);
void inhdmsg();
void outhdmsg();
void initfld(CHARTABL *chrentry);
void baudfld(CHARTABL *chrentry);
void parfld(CHARTABL *chrentry);
void stopfld(CHARTABL *chrentry);
void wlenfld(CHARTABL *chrentry);
void sftpfld(CHARTABL *chrentry);
void inhdfld(CHARTABL *chrentry);
void outhdfld(CHARTABL *chrentry);
void prtdce(CHARTABL *chrentry);
void prtbasept(CHARTABL *chrentry);
void prtinitflg(CHARTABL *chrentry);
void prtbaudrt(CHARTABL *chrentry);
void prtparity(CHARTABL *chrentry);
void prtstop(CHARTABL *chrentry);
void prtwlen(CHARTABL *chrentry);
void prtsft(CHARTABL *chrentry);
void prtinhand(CHARTABL *chrentry);
void prtouthand(CHARTABL *chrentry);
void prtpinnum(CHARTABL *chrentry);
void prtpin(short pos, char *s);
void prtpind(short pos, char *s);
int setnode(CHARTABL *chrentry, char *filename);
void prtndhd(CHARTABL *chrentry);
void prtnd(byte ndnum);

#define  NCOL	14
#define  STCOL	24
#define  STLNE	6

/* Main entry point for character io menu */
void setchario(CHARTABL *mainchr, char *filename) {
	CHARTABL chrentry;
	short inp, i;
	bool confg;

	cpychr(chrentry, mainchr);
	if (chrentry.compart.phydevnum == NETLSTN) {
		return (setnode(chrentry, filename));
	}
	for (confg = TRUE, i = 0; i < chrentry.compart.numdev; ++i)
		if (chrentry.charpart[i].usage) {
			confg = FALSE;
		}
	initcur(STLNE, chrentry.compart.numdev, STCOL, NCOL, 2, 6, 2, 2, 2, 5, 5, 6, 5, 6, 5, 5, 5);
	prtchd(chrentry, confg);
	prtcvar(chrentry, confg);
	prtcur(filename);
	curline = curcol = 0;
	oldcol = 99;
	prtcmsg(chrentry, confg);
	if (confg) {
		bell();
	}
	do {
		inp = getfld(chrentry, confg);
		if (inp == WHITE) {
			cpychr(chrentry, mainchr);
			prtcvar(chrentry, confg);
			curline = curcol = 0;
		}
		if (inp == BLUE) {
			if (confg) {
				return;
			}
			cpychr(mainchr, chrentry);
			if (putchartbl(chrentry) == ERROR) {
				putwin(1, errmsg(errno));
				bell();
				inp = NULL;
			}
			reinitio(chrentry);
		}
	} while (inp != BLUE && inp != RED);
}

void cpychr(CHARTABL *chr1, CHARTABL *chr2) {	/* copys chr1 into chr2 */
	memcpy(chr2, chr1, sizeof * chr1);
}

void reinitio(CHARTABL *chrentry) {	/* reinitializes the character io */
					/* routines in memory when modifing */
	/* the current system and the BLUE */
	byte biospd[8]; 		/* is pressed */
	short i;

	if (bioscurflg) {
		return;
	}
	biospd[0] = 21;		    /* bios func # 21 reinit chario module */
	biospd[3] = 0;
	for (i = 0; i < chrentry->compart.numdev; ++i) {
		biospd[2] = (chrentry->compart.phydevnum - CHIONUM) + i; /* reg C */
		bdos(50, biospd);
	}
}

void prtchd(CHARTABL *chrentry, bool confg) { /* print char io headings */
	clrscr();
	printf(chrentry->compart.string);
	if (confg) {
		cursor(6 * getwidth() + 24);
		printf("Module not user configurable");
		return;
	}
	cursor(((STLNE - 4)*getwidth()) + 38);
	printf("************** Handshaking ****************");
	cursor(((STLNE - 3)*getwidth()) + 26);
	printf("Baud    S W   -------Inputs------- ------Outputs-------");
	cursor(((STLNE - 2)*getwidth()) + 1);
	printf("Type Port    Name      ");
	printf("I Rate  P B L S RLSD RI   DSR   CTS  DTR   RTS  OUT1 OUT2");
}

void prtcvar(CHARTABL *chrentry, bool confg) {  /* print all the fields */
	if (confg) {
		return;
	}
	curoff();
	for (curline = 0; curline < chrentry->compart.numdev; ++curline) {
		prtdce(chrentry);
		prtbasept(chrentry);
		prtinitflg(chrentry);
		prtbaudrt(chrentry);
		prtparity(chrentry);
		prtstop(chrentry);
		prtwlen(chrentry);
		prtsft(chrentry);
		prtinhand(chrentry);
		prtouthand(chrentry);
		prtpinnum(chrentry);
	}
	curon();
}

int getfld(CHARTABL *chrentry, bool confg) {	/* Move cursor to a field and */
						/* call the field's subroutine */
						/* if a non-control character */
						/* is entered */
	short inp;

	if (confg) {
		return (getcntrl());
	}
	curon();
	do {
		currnt();
		inp = getcntrl();
		if (inp == BLUE || inp == RED || inp == WHITE) {
			return (inp);
		}
		movcur(inp, NCOL, chrentry->compart.numdev);
		prtcmsg(chrentry, confg);
	} while (inp != NULL);
	currnt();
	if (chrentry->charpart[curline].usage) {
		switch (curcol) {
		case 0:
			initfld(chrentry);
			break;
		case 1:
			baudfld(chrentry);
			break;
		case 2:
			parfld(chrentry);
			break;
		case 3:
			stopfld(chrentry);
			break;
		case 4:
			wlenfld(chrentry);
			break;
		case 5:
			sftpfld(chrentry);
			break;
		case 6:
		case 7:
		case 8:
		case 9:
			inhdfld(chrentry);
			break;
		case 10:
		case 11:
		case 12:
		case 13:
			outhdfld(chrentry);
			break;
		default:
			break;
		}
	} else {
		bell();
	}
	curon();
	return (NULL);
}

void prtcmsg(CHARTABL *chrentry, bool confg) {	/* prints window help menus */
	bool useflg;

	if (confg) {
		return;
	}
	useflg = chrentry->charpart[curline].usage;
	if (oldcol == curcol && useflg) {
		return;
	}
	oldcol = curcol;
	putwin(2, "");
	switch (curcol) {
	case 0:
		putwin(1, "Initialization");
		if (useflg) {
			putwin(3, "Y = perform I/O port");
			putwin(4, "       initialization");
			putwin(5, "N = do not perform I/O port");
			putwin(6, "       initialization");
			putwin(7, "");
		}
		break;
	case 1:
		if (useflg) {
			if (chrentry->charpart[curline].baudmask) {
				putwin(1, "Valid Baud Rates");
				putwin(3, "19200       2400        150");
				putwin(4, "9600        1800        134.5");
				putwin(5, "7200        1200        110");
				putwin(6, "4800        600         75");
				putwin(7, "3600        300         50");
			} else {
				clmn();
				putwin(1, "Baud rate not selectable");
			}
		} else {
			putwin(1, "Baud Rate");
		}
		break;
	case 2:
		putwin(1, "Parity");
		if (useflg) {
			putwin(3, "N = None");
			putwin(4, "E = Even");
			putwin(5, "O = Odd");
			putwin(6, "1 = Stuck at 1");
			putwin(7, "0 = Stuck at 0");
		}
		break;
	case 3:
		putwin(1, "Stop Bits");
		if (useflg) {
			putwin(3, "1 = one bit");
			putwin(4, "2 = two bits");
			putwin(5, "");
			putwin(6, "");
			putwin(7, "");
		}
		break;
	case 4:
		putwin(1, "Word length");
		if (useflg) {
			putwin(3, "5 = Five bits");
			putwin(4, "6 = Six bits");
			putwin(5, "7 = Seven bits");
			putwin(6, "8 = Eight bits");
			putwin(7, "");
		}
		break;
	case 5:
		if (useflg) {
			if (chrentry->charpart[curline].protomask) {
				putwin(1, "Software Protocol");
				putwin(3, "N = None");
				putwin(4, "X = XON/XOFF");
			} else {
				putwin(1, "Soft Protocol not supported");
				putwin(3, "");
				putwin(4, "");
			}
			putwin(5, "");
			putwin(6, "");
			putwin(7, "");
		} else {
			putwin(1, "Software Protocol");
		}
		break;
	case 6:
		putwin(1, "Received Line Signal Detect");
		if (useflg) {
			inhdmsg();
		}
		break;
	case 7:
		putwin(1, "Ring Indicator");
		if (useflg) {
			inhdmsg();
		}
		break;
	case 8:
		putwin(1, "Data Set Ready");
		if (useflg) {
			inhdmsg();
		}
		break;
	case 9:
		putwin(1, "Clear to Send");
		if (useflg) {
			inhdmsg();
		}
		break;
	case 10:
		putwin(1, "Data Terminal Ready");
		if (useflg) {
			outhdmsg();
		}
		break;
	case 11:
		putwin(1, "Request to Send");
		if (useflg) {
			outhdmsg();
		}
		break;
	case 12:
		putwin(1, "Output 1");
		if (useflg) {
			outhdmsg();
		}
		break;
	case 13:
		putwin(1, "Output 2");
		if (useflg) {
			outhdmsg();
		}
		break;
	default:
		break;
	}
	if (!useflg) {
		putwin(3, "Characteristics not accessible");
		putwin(4, "");
		putwin(5, "");
		putwin(6, "");
		putwin(7, "");
		oldcol = 99;
	}
}

void inhdmsg() {
	putwin(3, "1 = require a high level");
	putwin(4, "0 = require a low level");
	putwin(5, "X = ignore signal");
	putwin(6, "[ ] RS-232 connector pin number");
	putwin(7, "");
}

void outhdmsg() {
	putwin(3, "1 = output a high level");
	putwin(4, "0 = output a low level");
	putwin(5, "");
	putwin(6, "[ ] RS-232 connector pin number");
	putwin(7, "");
}

void initfld(CHARTABL *chrentry) {	/* initialization flag field */
	short inp;

	if ((inp = toupper(getchr())) != NULL) {
		if (inp == 'Y') {
			chrentry->charpart[curline].initflg = TRUE;
		} else if (inp == 'N') {
			chrentry->charpart[curline].initflg = FALSE;
		} else {
			bell();
		}
	}
	prtinitflg(chrentry);
}

void baudfld(CHARTABL *chrentry) {	/* change baud rate routine */
	short inp;
	ushort temp;

	if ((inp = getnum(5, &temp)) != NULL) {
		if (chrentry->charpart[curline].baudmask) {
			if (temp == 0) {
				temp = 0;
			} else if (temp < 60) {
				temp = 50;
			} else if (temp < 90) {
				temp = 75;
			} else if (temp < 120) {
				temp = 110;
			} else if (temp < 140) {
				temp = 134;
			} else if (temp < 200) {
				temp = 150;
			} else if (temp < 400) {
				temp = 300;
			} else if (temp < 800) {
				temp = 600;
			} else if (temp < 1500) {
				temp = 1200;
			} else if (temp < 2000) {
				temp = 1800;
			} else if (temp < 2800) {
				temp = 2400;
			} else if (temp < 4000) {
				temp = 3600;
			} else if (temp < 6000) {
				temp = 4800;
			} else if (temp < 8000) {
				temp = 7200;
			} else if (temp < 10000) {
				temp = 9600;
			} else {
				temp = 19200;
			}
			chrentry->charpart[curline].baudrate = temp;
		}
	}
	curoff();
	prtbaudrt(chrentry);
}

void parfld(CHARTABL *chrentry) {	/* change parity field */
	short inp;

	if ((inp = toupper(getchr())) != NULL) {
		switch (inp) {
		case 'N':
			chrentry->charpart[curline].parity = 'N';
			break;
		case 'E':
			chrentry->charpart[curline].parity = 'E';
			break;
		case 'O':
			chrentry->charpart[curline].parity = 'O';
			break;
		case '1':
			chrentry->charpart[curline].parity = '1';
			break;
		case '0':
			chrentry->charpart[curline].parity = '0';
			break;
		default:
			bell();
			break;
		}
	}
	prtparity(chrentry);
}

void stopfld(CHARTABL *chrentry) {	/* change stop bits field */
	short inp;
	ushort temp;

	if ((inp = getnum(1, &temp)) != NULL) {
		if (temp < 1 || temp > 2) {
			bell();
		} else {
			chrentry->charpart[curline].stopbits = temp;
		}
	}
	prtstop(chrentry);
}

void wlenfld(CHARTABL *chrentry) {	/* change word length */
	short inp;
	ushort temp;

	if ((inp = getnum(1, &temp)) != NULL) {
		if (temp < 5 || temp > 8) {
			bell();
		} else {
			chrentry->charpart[curline].wordlen = temp;
		}
	}
	prtwlen(chrentry);
}

void sftpfld(CHARTABL *chrentry) {	/* change software protocol */
	short inp;

	if ((inp = toupper(getchr())) != NULL) {
		if (chrentry->charpart[curline].protomask) {
			if (inp == 'N') {
				chrentry->charpart[curline].softproto = 'N';
			} else if (inp == 'X') {
				chrentry->charpart[curline].softproto = 'X';
			} else {
				bell();
			}
		} else {
			bell();
		}
	}
	prtsft(chrentry);
}

void inhdfld(CHARTABL *chrentry) {      /* change one of the input handshaking fields */
	short inp, fld;

	fld = curcol - 6;
	if ((inp = toupper(getchr())) != NULL) {
		if (inp == 'X') {
			chrentry->charpart[curline].hsinput[fld] = 'X';
		} else if (inp == '0') {
			chrentry->charpart[curline].hsinput[fld] = '0';
		} else if (inp == '1') {
			chrentry->charpart[curline].hsinput[fld] = '1';
		} else {
			bell();
		}
	}
	curoff();
	prtinhand(chrentry);
}

void outhdfld(CHARTABL *chrentry) {  /* change one of the output handshaking fields */
	short inp, fld;

	fld = curcol - 10;
	if ((inp = toupper(getchr())) != NULL) {
		if (inp == '0') {
			chrentry->charpart[curline].hsoutput[fld] = '0';
		} else if (inp == '1') {
			chrentry->charpart[curline].hsoutput[fld] = '1';
		} else {
			bell();
		}
	}
	curoff();
	prtouthand(chrentry);
}

void prtdce(CHARTABL *chrentry) {	/* print DCE or DTE device type */
	cursor(((curline + STLNE - 1)*getwidth()) + 1);
	if (chrentry->charpart[curline].dce_dte) {
		puts("DCE");
	} else {
		puts("DTE");
	}
}

void prtbasept(CHARTABL *chrentry) {	/* print base port address in hex and octal */
					/* print description from base port addr. */
	ushort bp;

	bp = chrentry->charpart[curline].baseport;
	cursor(((curline + STLNE - 1)*getwidth()) + 5);
	if (bp != 0) {
		printf("(%3.3o/%02.2x) ", bp, bp);
	}
	switch (bp) {
	case 0xE8:
		printf("%10.10s", "Console : ");
		break;
	case 0xD0:
		printf("%10.10s", "Aux : ");
		break;
	case 0xE0:
		printf("%10.10s", "Printer : ");
		break;
	case 0xD8:
		printf("%10.10s", "Modem : ");
		break;
	default:
		printf(" %6.6s : ", chrentry->charpart[curline].chrstr);
		break;
	}
}

void prtinitflg(CHARTABL *chrentry) {	/* print initialization flag */
	if (chrentry->charpart[curline].initflg) {
		prtpos(curline, 0, "Y");
	} else {
		prtpos(curline, 0, "N");
	}
}

void prtbaudrt(CHARTABL *chrentry) {	/* print baud rate field */
	ushort br;

	br = chrentry->charpart[curline].baudrate;
	if (br == 0) {
		prtpos(curline, 1, "None");
	} else {
		prtpos(curline, 1, "%-5.5d", br);
	}
}

void prtparity(CHARTABL *chrentry) {	/* print parity field */
	prtpos(curline, 2, "%c", chrentry->charpart[curline].parity);
}

void prtstop(CHARTABL *chrentry) {	/* print stop bits field */
	prtpos(curline, 3, "%1.1u", chrentry->charpart[curline].stopbits);
}

void prtwlen(CHARTABL *chrentry) {	/* print word length field */
	prtpos(curline, 4, "%1.1u", chrentry->charpart[curline].wordlen);
}

void prtsft(CHARTABL *chrentry) {	/* print software protocol field */
	prtpos(curline, 5, "%c", chrentry->charpart[curline].softproto);
}

void prtinhand(CHARTABL *chrentry) {     /* print all input handshaking fields */
	short i;

	for (i = 0; i < 4; ++i) {
		prtpos(curline, 6 + i, "%c", chrentry->charpart[curline].hsinput[i]);
	}
}

void prtouthand(CHARTABL *chrentry) {    /* print all output handshaking fields */
	short i;

	for (i = 0; i < 4; ++i) {
		prtpos(curline, 10 + i, "%c", chrentry->charpart[curline].hsoutput[i]);
	}
}

void prtpinnum(CHARTABL *chrentry) {	/* print pin numbers for a DTE or DCE */
					/*	device */
	if (chrentry->charpart[curline].dce_dte) {
		prtpin(0, "[-]");	/* RLSD */
		prtpin(1, "[-]");	/* RI */
		prtpind(2, "[20]");	/* DSR */
		prtpin(3, "[4]");	/* CTS */
		prtpind(4, "[ 6]");	/* DTR */
		prtpin(5, "[5]");	/* RTS */
		prtpin(6, "[-]");	/* OUT1 */
		prtpin(7, "[8]");	/* OUT2 */
	} else {
		prtpin(0, "[8]");	/* RLSD */
		prtpin(1, "[-]");	/* RI */
		prtpind(2, "[ 6]");	/* DSR */
		prtpin(3, "[5]");	/* CTS */
		prtpind(4, "[20]");	/* DTR */
		prtpin(5, "[4]");	/* RTS */
		prtpin(6, "[-]");	/* OUT1 */
		prtpin(7, "[-]");	/* OUT2 */
	}
}

void prtpin(short pos, char *s) {
	cursor(curpos[curline][pos + 6] - 3);
	puts(s);
}

void prtpind(short pos, char *s) {
	cursor(curpos[curline][pos + 6] - 4);
	puts(s);
}


/* Set netlist device's node number (physical device number #204) */

#define  MSTR 6

int setnode(CHARTABL *chrentry, char *filename) {
	byte ndnum, temp;
	short inp;

	ndnum = nodenum;
	prtndhd(chrentry);
	prtcur(filename);
	prtnd(ndnum);
	do {
		inp = getnum(2, &temp);
		if (inp != NULL) {
			if (temp <= 63) {
				ndnum = temp;
			} else {
				bell();
			}
		}
		prtnd(ndnum);
		inp = getcntrl();
		if (inp == WHITE) {
			ndnum = nodenum;
			prtnd(ndnum);
		} else if (inp == BLUE) {
			nodenum = ndnum;
			if (putnode() == ERROR) {
				putwin(1, errmsg(errmsg()));
				bell();
			}
		} else if (inp == RED)
			;
		else if (inp == CRCD)
			;
		else if (inp != NULL) {
			bell();
		}
	} while (inp != RED && inp != BLUE);
	curon();
	return (TRUE);
}

void prtndhd(CHARTABL *chrentry) {
	clrscr();
	printf(chrentry->compart.string);
	putwin(3, "Valid node numbers: 0 thru 63");
}

void prtnd(byte ndnum) {
	curoff();
	cursor(MSTR * getwidth() + 1);
	puts("Network node number: ");
	printf("%-2.2d", ndnum);
	cursor(MSTR * getwidth() + 22);
	curon();
}

