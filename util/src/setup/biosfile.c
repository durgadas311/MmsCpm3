/* Bios file handling functions for SETUP30
 * Open, close, get a byte, change a byte
 * in BNKBIOS3.SPR or current image in memory.
 *
 * Last updated: 7/05/83  8:06 mjm
 *
 * Version 3.102
 *
 * "BIOSFILE.C"
 *
 */

#include "setup30.h"

int getbyts(int n, byte *array, word adr) {	/* get an array of n bytes from bios */
	ushort i;

	for (i = 0; i < n; ++i)
		if (getbyte(array++, adr++) == ERROR) {
			return (ERROR);
		}
	return (OK);
}

int putbyts(int n, byte *array, word adr) {	/* puts an array of n bytes in bios */
	ushort i;

	for (i = 0; i < n; ++i)
		if (putbyte(array++, adr++) == ERROR) {
			return (ERROR);
		}
	return (OK);
}

int getword(word *dptr, word address) {
	word temp1, temp2;

	if (getbyte(&temp1, address++) == ERROR) {	/* high order byte */
		return (ERROR);
	}
	if (getbyte(&temp2, address) == ERROR) {	/* low order byte */
		return (ERROR);
	}
	*dptr = temp2 << 8 | (temp1 & 0xFF);
	return (OK);
}

int putword(word *dptr, word address) {
	byte temp;

	temp = *dptr & 0xFF;
	if (putbyte(&temp, address++) == ERROR) {
		return (ERROR);
	}
	temp = *dptr >> 8;
	if (putbyte(&temp, address) == ERROR) {
		return (ERROR);
	}
	return (OK);
}

int getbyte(byte *dptr, word address) {
	short sec;
	byte *ptr;

	if (bioscurflg) {
		sec = adrsec(address);
		if (readwrite(sec) == ERROR) {
			return (ERROR);
		}
		ptr = secbuf + adroff(address);
	} else {
		ptr = address;
	}
	*dptr = *ptr;
	return (OK);
}

int putbyte(byte *dptr, word address) {
	short sec;
	byte *ptr;

	if (bioscurflg) {
		sec = adrsec(address);
		if (readwrite(sec) == ERROR) {
			return (ERROR);
		}
		ptr = secbuf + adroff(address);
		writeflg = TRUE;
	} else {
		ptr = address;
	}
	*ptr = *dptr;
	return (OK);
}

int readwrite(short sec) {
	if (sec != cursec) {
		if (writeflg) {
			writeflg = FALSE;
			if (writebios(cursec) == ERROR) {
				return (ERROR);
			}
		}
		if (readbios(sec) == ERROR) {
			return (ERROR);
		}
	}
	return (OK);
}

int adrsec(word address) {
	return ((address + FILEOFF) / SECSIZE);
}

int adroff(word address) {
	return ((address + FILEOFF) % SECSIZE);
}

int openbios(char *filename) {
	byte *ptr;

	if (bioscurflg) {
		fd = open(filename, 2);
		if (fd == ERROR) {
			return (ERROR);
		}
		if (readbios(2) == ERROR) {
			return (ERROR);
		}
		biosstart = 0000;
	} else {
		ptr = 2;
		biosstart = *ptr << 8;
	}
	return (OK);
}

int closebios() {
	short er;

	if (bioscurflg) {
		if (writeflg) {
			er = writebios(cursec);
		}
		if (close(fd) == ERROR) {
			return (ERROR);
		}
		if (er == ERROR) {
			return (ERROR);
		}
	}
	return (OK);
}

int readbios(short sector) {
	short er;

	if (seek(fd, sector, 0) == ERROR) {
		return (ERROR);
	}
	er = read(fd, secbuf, NUMSEC);
	if (er != NUMSEC) {
		return (ERROR);
	}
	cursec = sector;
	return (OK);
}

int writebios(short sector) {
	short er;

	if (seek(fd, sector, 0) == ERROR) {
		return (ERROR);
	}
	er = write(fd, secbuf, NUMSEC);
	if (er != NUMSEC) {
		return (ERROR);
	}
	cursec = sector;
	return (OK);
}
