/* Bios file to drive table redirection vectors
 * and seach type conversion and moving functions.
 *
 * Last updated 1/30/84 11:25 mjm
 *
 * Version 3.103
 *
 * "GETDRVTB.C"
 *
 */

#include "setup30.h"

int getdrvtbl() {
	short er;

	if ((er = getlptbl()) > ERROR)
		if (!mpmfile) {
			if ((er = getsord()) > ERROR)
				if ((er = gettdrv()) > ERROR)
					if ((er = getredir()) > ERROR) {
						er = gettyps();
					}
		}
	return (er);
}

int getlptbl() {
	word lptr, i;

	if (getlpstr(&lptr) == ERROR) {
		return (ERROR);
	}
	if (lptr == NULL) {
		return (ERROR - 7);
	}
	drivtable.logphyaddr = lptr;
	for (i = 0; i < MAXDRV; ++i, ++lptr)
		if (getbyte(&drivtable.logphytbl[i], lptr) == ERROR) {
			return (ERROR);
		}
	return (OK);
}

int getlpstr(word *dptr) {
	return (getword(dptr, biosstart + LOGPHYPTR));
}

int getsord() {
	word adr, i;
	byte scbpd[4];

	if (bioscurflg) {
		adr = biosstart + DEFSRC;
		for (i = 0; i < 4; ++i, ++adr)
			if (getbyte(&drivtable.drvsch[i], adr) == ERROR) {
				return (ERROR);
			}
	} else {
		adr = SORDSCB;
		for (i = 0; i < 4; ++i, ++adr) {
			scbpd[0] = adr;
			scbpd[1] = 0;
			drivtable.drvsch[i] = (bdos(49, scbpd) & 0xFF);
		}
	}
	return (OK);
}

int gettdrv() {
	word adr;
	byte scbpd[4];

	if (bioscurflg) {
		adr = biosstart + TMPDRV;
		if (getbyte(&drivtable.tempdrv, adr) == ERROR) {
			return (ERROR);
		}
	} else {
		scbpd[0] = TDRVSCB;
		scbpd[1] = 0;
		drivtable.tempdrv = (bdos(49, scbpd) & 0xFF);
	}
	return (OK);
}

int getredir() {
	word adr, i;
	byte scbpd[4];

	if (bioscurflg) {
		adr = biosstart + REDIRVEC;
		if (getword(&redirvec[1], adr) == ERROR) {
			return (ERROR);
		}
		if (getword(&redirvec[0], adr + 2) == ERROR) {
			return (ERROR);
		}
		if (getword(&redirvec[3], adr + 4) == ERROR) {
			return (ERROR);
		}
		if (getword(&redirvec[2], adr + 6) == ERROR) {
			return (ERROR);
		}
		if (getword(&redirvec[4], adr + 8) == ERROR) {
			return (ERROR);
		}
	} else {
		adr = REDSCB;
		for (i = 0; i < 5; ++i, adr += 2) {
			scbpd[0] = adr;
			scbpd[1] = 0;
			redirvec[i] = bdos(49, scbpd);
		}
	}
	return (OK);
}

int gettyps() {
	word adr;
	byte scbpd[4];

	if (bioscurflg) {
		adr = biosstart + SCRTYP;
		if (getbyte(&subcom, adr) == ERROR) {
			return (ERROR);
		}
	} else {
		scbpd[0] = STYPSCB;
		scbpd[1] = 0;
		subcom = (bdos(49, scbpd) & 0x18);
	}
	subcom = subcom >> 3;
	return (OK);
}
