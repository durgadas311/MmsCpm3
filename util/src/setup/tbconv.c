/* Module tables to bios file conversion and moving functions.
 *
 * Last updated 7/25/83  13:17 mjm
 *
 * Version 3.102
 *
 * "TBCONV.C"
 *
 */

#include "setup30.h"
#include "biosfile.h"
#include "btconv.h"

int putchartbl(CHARTABL *chrmod);
int putdisktbl(DISKTABL *diskmod);
void setmbyt(FLOPDEV *flpentry);
int putnode();
void tbinitflg(CHARDEV *chrentry, byte *xmodbyt);
void tbparity(CHARDEV *chrentry, byte *xmodbyt);
void tbstopbit(CHARDEV *chrentry, byte *xmodbyt);
void tbwlen(CHARDEV *chrentry, byte *xmodbyt);
void tbinhand(CHARDEV *chrentry, byte *xmodbyt);
void tbouthand(CHARDEV *chrentry, byte *xmodbyt);
void tbbaud(CHARDEV *chrentry, byte *chrtbl);
void tbsftpt(CHARDEV *chrentry, byte *chrtbl);
void tbdrvcontr(FLOPDEV *flpentry);
void tbsteprt(FLOPDEV *flpentry);
void tbmedia(FLOPDEV *flpentry);
void tbmediaft(FLOPDEV *flpentry);
void tbsides(FLOPCHAR *flpchar, byte *modebyt);
void tbtrkden(FLOPCHAR *flpchar, byte *modebyt);
void tbrecden(FLOPCHAR *flpchar, byte *modebyt);
void clearbit(byte *array, ushort bitpos);
void setbit(byte *array, ushort bitpos);

int putchartbl(CHARTABL *chrmod) {
	short i;
	byte chrtbl[8], xmode[4];

	for (i = 0; i < chrmod->compart.numdev; ++i) {
		if (getbyts(4, xmode, chrmod->charpart[i].xmodeaddr) == ERROR) {
			return (ERROR);
		}
		if (getbyts(8, chrtbl, chrmod->charpart[i].chtbladdr) == ERROR) {
			return (ERROR);
		}
		tbinitflg(&chrmod->charpart[i], xmode);
		tbparity(&chrmod->charpart[i], xmode);
		tbstopbit(&chrmod->charpart[i], xmode);
		tbwlen(&chrmod->charpart[i], xmode);
		tbinhand(&chrmod->charpart[i], xmode);
		tbouthand(&chrmod->charpart[i], xmode);
		tbbaud(&chrmod->charpart[i], chrtbl);
		tbsftpt(&chrmod->charpart[i], chrtbl);
		if (putbyts(4, xmode, chrmod->charpart[i].xmodeaddr) == ERROR) {
			return (ERROR);
		}
		if (putbyts(8, chrtbl, chrmod->charpart[i].chtbladdr) == ERROR) {
			return (ERROR);
		}
	}
	return (OK);
}

int putdisktbl(DISKTABL *diskmod) {
	short i;

	for (i = 0; i < diskmod->compart.numdev; ++i) {
		if (diskmod->floppart[i].floppy) {
			setmbyt(diskmod->floppart[i]);
			if (putbyts(8, diskmod->floppart[i].modebyt, diskmod->floppart[i].modeaddr) == ERROR) {
				return (ERROR);
			}
		}
	}
	return (OK);
}

void setmbyt(FLOPDEV *flpentry) {
	tbdrvcontr(flpentry);
	tbsteprt(flpentry);
	tbmedia(flpentry);
	tbmediaft(flpentry);
}

int putnode() {		/* put netlist node number */
	return (putbyte(&nodenum, nodeadr));
}

/* Character IO module converion routines */

void tbinitflg(CHARDEV *chrentry, byte *xmodbyt) {
	if (chrentry->initflg) {
		setbit(xmodbyt, INITBIT);
	} else {
		clearbit(xmodbyt, INITBIT);
	}
}

void tbparity(CHARDEV *chrentry, byte *xmodbyt) {
	/*    STK   EPS   PEN */
	/* N   0     0	   0  */
	/* E   0     1	   1  */
	/* O   0     0	   1  */
	switch (chrentry->parity) {
	case 'N':
		clearbit(xmodbyt, STKBIT);
		clearbit(xmodbyt, EPSBIT);
		clearbit(xmodbyt, PENBIT);
		break;
	case 'E':
		clearbit(xmodbyt, STKBIT);
		setbit(xmodbyt, EPSBIT);
		setbit(xmodbyt, PENBIT);
		break;
	case 'O':
		clearbit(xmodbyt, STKBIT);
		clearbit(xmodbyt, EPSBIT);
		setbit(xmodbyt, PENBIT);
		break;
	case '0':
		setbit(xmodbyt, STKBIT);
		setbit(xmodbyt, EPSBIT);
		setbit(xmodbyt, PENBIT);
		break;
	case '1':
		setbit(xmodbyt, STKBIT);
		clearbit(xmodbyt, EPSBIT);
		setbit(xmodbyt, PENBIT);
		break;
	default:
		break;
	}
}

void tbstopbit(CHARDEV *chrentry, byte *xmodbyt) {
	if (chrentry->stopbits == 1) {
		clearbit(xmodbyt, STBBIT);
	} else {
		setbit(xmodbyt, STBBIT);
	}
}

void tbwlen(CHARDEV *chrentry, byte *xmodbyt) {
	switch (chrentry->wordlen) {
	case 5:
		clearbit(xmodbyt, WDLNBIT1);
		clearbit(xmodbyt, WDLNBIT2);
		break;
	case 6:
		clearbit(xmodbyt, WDLNBIT1);
		setbit(xmodbyt, WDLNBIT2);
		break;
	case 7:
		setbit(xmodbyt, WDLNBIT1);
		clearbit(xmodbyt, WDLNBIT2);
		break;
	case 8:
		setbit(xmodbyt, WDLNBIT1);
		setbit(xmodbyt, WDLNBIT2);
		break;
	default:
		break;
	}
}

void tbinhand(CHARDEV *chrentry, byte *xmodbyt) {
	short bitpos, i;

	bitpos = RLSDENBIT;

	for (i = 0; i < 4; ++i, ++bitpos) {
		if (chrentry->hsinput[i] == 'X') {
			clearbit(xmodbyt, bitpos);
		} else {
			setbit(xmodbyt, bitpos);
			if (chrentry->hsinput[i] == '0') {
				clearbit(xmodbyt, bitpos + 8);
			} else {
				setbit(xmodbyt, bitpos + 8);
			}
		}
	}
}

void tbouthand(CHARDEV *chrentry, byte *xmodbyt) {
	short bitpos, i;

	bitpos = OUT2BIT;

	for (i = 3; i > -1; --i, ++bitpos) {
		if (chrentry->hsoutput[i] == '0') {
			clearbit(xmodbyt, bitpos);
		} else {
			setbit(xmodbyt, bitpos);
		}
	}
}

void tbbaud(CHARDEV *chrentry, byte *chrtbl) {
	if (chrentry->baudmask) {
		switch (chrentry->baudrate) {
		case 0:
			chrtbl[7] = 0;
			break;
		case 50:
			chrtbl[7] = 1;
			break;
		case 75:
			chrtbl[7] = 2;
			break;
		case 110:
			chrtbl[7] = 3;
			break;
		case 134:
			chrtbl[7] = 4;
			break;
		case 150:
			chrtbl[7] = 5;
			break;
		case 300:
			chrtbl[7] = 6;
			break;
		case 600:
			chrtbl[7] = 7;
			break;
		case 1200:
			chrtbl[7] = 8;
			break;
		case 1800:
			chrtbl[7] = 9;
			break;
		case 2400:
			chrtbl[7] = 10;
			break;
		case 3600:
			chrtbl[7] = 11;
			break;
		case 4800:
			chrtbl[7] = 12;
			break;
		case 7200:
			chrtbl[7] = 13;
			break;
		case 9600:
			chrtbl[7] = 14;
			break;
		case 19200:
			chrtbl[7] = 15;
			break;
		default:
			break;
		}
	}
}

void tbsftpt(CHARDEV *chrentry, byte *chrtbl) {
	if (chrentry->protomask) {
		if (chrentry->softproto == 'X') {
			setbit(chrtbl, XONBIT);
		} else {
			clearbit(chrtbl, XONBIT);
		}
	}
}

/* Floppy disk io converion routines */

void tbdrvcontr(FLOPDEV *flpentry) {
	tbsides(&flpentry->drive_contr, flpentry->modebyt);
	tbtrkden(&flpentry->drive_contr, flpentry->modebyt);
	tbrecden(&flpentry->drive_contr, flpentry->modebyt);
}

void tbsteprt(FLOPDEV *flpentry) {
	short temp;

	if (flpentry->stepmask) {
		if (flpentry->disksize == FALSE) {
			temp = flpentry->steprate / 2;    /* 5.25" */
		} else {
			temp = flpentry->steprate;    /* 8" */
		}
		switch (temp) {
		case 3:
			clearbit(flpentry->modebyt, STEPBIT1);
			clearbit(flpentry->modebyt, STEPBIT2);
			break;
		case 6:
			clearbit(flpentry->modebyt, STEPBIT1);
			setbit(flpentry->modebyt, STEPBIT2);
			break;
		case 10:
			setbit(flpentry->modebyt, STEPBIT1);
			clearbit(flpentry->modebyt, STEPBIT2);
			break;
		case 15:
			setbit(flpentry->modebyt, STEPBIT1);
			setbit(flpentry->modebyt, STEPBIT2);
			break;
		default:
			break;
		}
	}
}

void tbmedia(FLOPDEV *flpentry) {
	tbsides(&flpentry->media, flpentry->modebyt + 1);
	tbtrkden(&flpentry->media, flpentry->modebyt + 1);
	tbrecden(&flpentry->media, flpentry->modebyt + 1);
}

void tbmediaft(FLOPDEV *flpentry) {
	bits fmt;
	ushort count;

	count = flpentry->medforcd;
	for (fmt = 0x8000; count > 0; --count) {
		fmt = fmt >> 1;
	}
	if (testbit(&flpentry->medmask, flpentry->medforcd) == 0) {
		flpentry->modebyt[0] = fmt >> 8;
		flpentry->modebyt[1] = fmt;
	}
}

void tbsides(FLOPCHAR *flpchar, byte *modebyt) {
	if (flpchar->sidemask) {
		if (flpchar->numsides) {
			clearbit(modebyt, DDSBIT);
		} else {
			setbit(modebyt, DDSBIT);
		}
	}
}

void tbtrkden(FLOPCHAR *flpchar, byte *modebyt) {
	if (flpchar->trkmask) {
		if (flpchar->trkden) {
			clearbit(modebyt, DDTBIT);
		} else {
			setbit(modebyt, DDTBIT);
		}
	}
}

void tbrecden(FLOPCHAR *flpchar, byte *modebyt) {
	if (flpchar->recmask) {
		if (flpchar->recden) {
			clearbit(modebyt, DDDBIT);
		} else {
			setbit(modebyt, DDDBIT);
		}
	}
}

void clearbit(byte *array, ushort bitpos) {
	byte mask;

	mask = ~(0x80 >> (bitpos % 8));
	array[bitpos / 8] = array[bitpos / 8] & mask;
}

void setbit(byte *array, ushort bitpos) {
	byte mask;

	mask = 0x80 >> (bitpos % 8);
	array[bitpos / 8] = array[bitpos / 8] | mask;
}
