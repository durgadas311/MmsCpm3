/*
; December 15, 1982  14:37  drm  "LISTREL1.ASM"
****  Program to list the contents of a ".REL" file in English. ****
**** For files created by MicroSoft's M80 or Digital Research's ****
**** RMAC.  Prints address at start of code-generating lines.	****
	    * Copyright (C) 1982 Magnolia Microsystems *
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>

// converted to C, Dec 29, 2017 drm
// Now dumps to stdout (not printer).
// Reads entire REL file into memory.

#define BYTES_PER_LINE	26

//** Address type messagess
#define ABSR	"ABSOLUTE"
#define PGMR	"PROGRAM RELATIVE ADDRESS"
#define DATR	"DATA RELATIVE ADDRESS"
#define COMR	"COMMON RELATIVE ADDRESS"

//** Special Link Item Messages
#define ENTS	"ENTRY SYMBOL"
#define COMB	"SELECT COMMON BLOCK"
#define PGMN	"PROGRAM NAME"
#define REQS	"REQUEST LIBRARY SEARCH"   // MICROSOFT ONLY
#define NOTU	"EXTENSION"
#define COMZ	"DEFINE COMMON SIZE"
#define CHNE	"CHAIN EXTERNAL"
#define DEFE	"DEFINE ENTRY POINT"
#define EXTM	"EXTERNAL MINUS OFFSET"    // MICROSOFT
#define EXTO	"EXTERNAL PLUS OFFSET"
#define DATZ	"DEFINE DATA SIZE"
#define SETL	"SET LOCATION COUNTER"
#define CHNA	"CHAIN ADDRESS"
#define PGMZ	"DEFINE PROGRAM SIZE"
#define ENDO	"END MODULE"
#define ENDF	"END FILE"

//** Message list for OP codes
char *op1[] = {
	NULL,	// OP code "00" (Special Link Item)
	PGMR,	// OP code "01" (Program relative address)
	DATR,	// OP code "10" (Data relative address)
	COMR,	// OP code "11" (Common relative address)
};

//** Message list for Special Link Items
struct {
	char *msg;
	int flags;
} op2[] = {
	{ ENTS,0 },	// Code "0000" (Entry Symbol)
	{ COMB,0 },	// Code "0001" (Select common block)
	{ PGMN,0 },	// Code "0010" (Program name)
	{ REQS,0 },	// Code "0011" (Request Library Search)
	{ NOTU,0 },	// Code "0100" (Not used)
	{ COMZ,1 },	// Code "0101" (Define Common size)
	{ CHNE,1 },	// Code "0110" (Chain external)
	{ DEFE,1 },	// Code "0111" (Define entry point)
	{ EXTM,1 },	// Code "1000" (External minus offset)
	{ EXTO,2 },	// Code "1001" (External plus offset)
	{ DATZ,2 },	// Code "1010" (Define Data size)
	{ SETL,2 },	// Code "1011" (Set location counter)
	{ CHNA,2 },	// Code "1100" (Chain address)
	{ PGMZ,2 },	// Code "1101" (Define program size)
	{ ENDO,2 },	// Code "1110" (End Module)
	{ ENDF,3 },	// Code "1111" (End File)
};
/*
** Item parameter designator:
**   0 = name field only
**   1 = value field and name field
**   2 = value field only
**   3 = no value or name field (end of file)
*/

//** Value Field Codes
char *op3[] = {
	ABSR,	// code "00" (Absolute)
	PGMR,	// code "01" (Program Relative)
	DATR,	// code "10" (Data Relative)
	COMR,	// code "11" (Common Relative)
};

char *op4[] = {
	"OPERAND",
	"BYTE",
	"WORD",
	"HIGH",
	"LOW",
	"NOT",
	"NEG",
	"ADD",
	"SUB",
	"MLT",
	"DIV",
	"MOD",
};

uint8_t *buffer;
uint8_t *bufend;
uint8_t *pointer;	// current byte in buffer
int bitter = 0;		// bits left in byte...

int *loccnt;
int absolute = 0;
int program = 0;
int data = 0;
int common = 0;

int linec = 0;

/*
** Return the number of bits specified in (C) from the REL file in
** register (A) (less than or equal to 8 bits)
*/
static int get_bits(int n) {
	int ret = 0;
	if (n > 8) n = 8;
	while (n > 0) {
		if (bitter <= 0) return -1; // try to salvage something?
		int c = ((*pointer & 0x80) != 0);
		*pointer <<= 1;
		ret = (ret << 1) | c;
		--bitter;
		--n;
		if (bitter == 0) {
			++pointer;
			if (pointer >= bufend) bitter = 0;
			else bitter = 8;
		}
	}
	return ret;
}

/*
*	get an address (16 bits) from the file and display it
*	in HEX.
*/
static int addr() {
	int bl = get_bits(8);
	if (bl < 0) return -1;
	int bh = get_bits(8);
	if (bh < 0) return -1;
	printf(" %02X%02X", bh, bl);
	return (bh << 8) | bl;
}

/*
*	get 8 bits from the file and display (26 bytes per line) in HEX
*/
static void byte() {
	if (--linec <= 0) {
		printf("\n%04X: ", *loccnt);
		linec = BYTES_PER_LINE;
	}
	int b = get_bits(8);
	if (b < 0) return;	// error!
	printf("%02X ", b);
	*loccnt = *loccnt + 1;
}

static int pname() {
	int t = get_bits(3);
	if (t < 0) return -1;
	putchar('"');
	while (t > 0) {
		int c = get_bits(8);
		if (c < 0) return -1;
		putchar(c);
		--t;
	}
	putchar('"');
	return 0;
}

static int pext() {
	int c;
	int t = get_bits(3);
	if (t <= 0) return -1;
	int k = get_bits(8);
	putchar(k);
	--t;
	if (k == 'C' && t >= 3) {
		c = get_bits(8);
		--t;
		if (c < 4) {
			printf(" %s", op3[c]);
		} else {
			printf(" \\x%02X", c);
		}
		c = get_bits(8);
		--t;
		c |= get_bits(8) << 8;
		--t;
		printf(" %04X", c);
	} else if (k == 'B' && t >= 1) {
		putchar(' ');
		putchar('"');
		while (t > 0) {
			c = get_bits(8);
			--t;
		}
		putchar('"');
	} else if (k == 'A' && t >= 1) {
		c = get_bits(8);
		--t;
		if (c >= sizeof(op4) / sizeof(op4[0])) {
			printf(" \\x%02X", c);
		} else {
			printf(" %s", op4[c]);
		}
	}
	while (t > 0) {
		c = get_bits(8);
		if (c < 0) return -1;
		printf(" \\x%02X", c);
		--t;
	}
	return 0;
}

static int value(int t) {
	int a = get_bits(2);
	if (a < 0) return -1;
	printf("%s", op3[a]);
	int l = addr();
	if (l < 0) return -1;
	if (t == 0b1110 && bitter && bitter < 8) {	// end of module... end of byte
		get_bits(bitter);
	}
	return l;
}

static int naval(int t) {
	if (value(t) < 0) return -1;
	putchar(' ');
	return pname();
}

static int setloc(int p) {
	int l = value(0);
	if (l < 0) return -1;
	switch (p) {
	case 0:	loccnt = &absolute; break;
	case 1:	loccnt = &program; break;
	case 2:	loccnt = &data; break;
	case 3:	loccnt = &common; break;
	}
	*loccnt = l;
	return 0;
}

static int special() {
	int t = get_bits(4);
	if (t < 0) return -1;
	int p = op2[t].flags;
	printf("%s ", op2[t].msg);
	if (t == 0b1011) {	// set location counter
		return setloc(p);
	} else if (t == 0b0100) {	// extension
		return pext();
	} else switch (p) {
	case 0:
		return pname();
	case 1:
		return naval(t);
	case 2:
		return value(t);
	case 3:
		printf("\n");
		return -1;	// not error...
	}
	return 0;
}

static int command() {
	int t = get_bits(1);
	if (t < 0) return -1;
	if (t == 0) {
		byte();
	} else {
		linec = 1;
		putchar('\n');
		t = get_bits(2);
		if (t < 0) return -1;
		if (t == 0) { // special item...
			return special();
		} else {
			printf("%04X: %s", *loccnt, op1[t]);
			(void)addr();	// check error...
			*loccnt = *loccnt + 2;
		}
	}
	return 0;
}

int main(int argc, char **argv) {
	int x = 1;
	struct stat stb;
	// TODO: any commandline args?
	if (x >= argc) {
		fprintf(stderr, "Usage: ...\n");
		exit(1);
	}
	int fd = open(argv[x], O_RDONLY);
	if (fd < 0) {
		perror(argv[x]);
		exit(1);
	}
	fstat(fd, &stb);
	buffer = malloc(stb.st_size);
	if (buffer == NULL) {
		perror("malloc");
		exit(1);
	}
	int n = read(fd, buffer, stb.st_size);
	if (n != stb.st_size) {
		perror(argv[x]);
		exit(1);
	}
	close(fd);
	bufend = buffer + stb.st_size;
	pointer = buffer;
	bitter = 8;
	loccnt = &program;
	linec = BYTES_PER_LINE;
	while (command() >= 0);
	free(buffer);
	return 0;
}
