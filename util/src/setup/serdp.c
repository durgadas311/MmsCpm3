/* These functions load and call the serdp
 * routine in the bios to check if the
 * mode for the floppy disk is valid
 *
 * Version 3.102
 *
 * Date last modified: 7/4/84 10:06 drm
 *
 * "SERDP.C"
 *
 */

#include "setup30.h"

int ldserdp() {
	word serdpstr, serdpend;
	byte byt, *alloc(), *pt;

	if (bioscurflg) {	/* see if modified a bios file */
		if (getword(&serdpstr, biosstart + SERDP) == ERROR) {
			return (ERROR);    /* get start of ?serdp routine */
		}
		if (serdpstr == NULL) {
			/* if no getdp module linked in */
			serdpadr = NULL;	   /* return no error */
			return (OK);
		}
		if (getword(&serdpend, serdpstr + 1) == ERROR) {
			return (ERROR);    /* get offset to start of table */
		}
		serdpend += serdpstr;
		do {
			/* get end of ?serdp routine table */
			if (getbyte(&byt, serdpend) == ERROR) {
				return (ERROR);
			}
			serdpend += 8;
		} while (byt != 0xFF);
		pt = serdpadr = alloc(serdpend - serdpstr);	/* get some space */
		if (serdpadr == NULL) {
			return (ERROR - 5);    /* not enough memory space */
		}
		for (; serdpstr <= serdpend; ++serdpstr, ++pt)
			if (getbyte(pt, serdpstr) == ERROR) {
				return (ERROR);
			}
	} else {
		getword(&serdpadr, biosstart + SERDP); /* if mod current sys */
		if (serdpadr == biosstart) {
			serdpadr = NULL;
		}
	}
	return (OK);
}

int serdp(FLOPDEV *flpentry) {
	if (serdpadr == NULL) {	/* Return DPB not found error if no getdp */
		return (1);
	}
	setmbyt(flpentry);	     /* from tbconv */
	/* address a hl bc de */
	return (calla(serdpadr, 0, serdpadr, 0, flpentry->modebyt));
}	/* returns the A reg	*/
