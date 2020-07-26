/*
 * Setup 3.0 header file 
 *
 * Contains global definations and variables.
 *
 * Last updated 7/12/84 15:25 drm
 *
 * "SETUP30.H"
 */

/* #include "bdscio.h" */
/* #include <stdio.h> - don't want printf... */
#include <stddef.h>
#include <cpm.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

extern char *errmsg(int err);
extern int bdos2(int fnc, int prm) __smallc;

/* These are some new data types used in this program */

#define byte char
#define word unsigned
#define bool char
#define metachar int
#define void int
#define ushort unsigned
#define short int
#define bits unsigned

#define TRUE 1		/* logical true constant */
#define FALSE 0		/* logical false constant */
#define ERROR -1	/* General "on error" return value */
#define OK 0		/* General purpose "no error" return value */

			/* GLOBAL CONSTANTS */

/* bios positions - relative to begining of mbios */

#define LOGPHYPTR 0x65		/* address of lptbl */
#define THRDSTR   0x67		/* start of thread */
#define SERDP	  0x69		/* address of ?serdp routine */
#define REDIRVEC  0x74		/* io redirection vector address */
#define DEFSRC	  0x7E		/* start of drive search order 4 bytes */
#define TMPDRV	  0x82		/* temporary drive */
#define SCRTYP	  0x83		/* search order type .com .sub */

/* System Control Block offsets */

#define SORDSCB   0x4C		/* search order */
#define TDRVSCB   0x50		/* temporary drive */
#define STYPSCB   0x18		/* file search type */
#define REDSCB	  0x22		/* redirection vectors */

/* module offsets from thread */

#define THREAD	  0
#define PHYDEVNUM 2
#define NUMDEV	  3

#define INITADR   4		/* char io modules */
#define CHRSTRADR 0x13
#define CHRTBLADR 0x15
#define XMODEADR  0x17

#define DSKSTRADR 0x10		/* disk io modules */
#define MODEADR   0x14

/* Bits positions relative to first byte of xmode byte table */

#define RLSDENBIT	0
#define RIENBIT 	1
#define DSRENBIT	2
#define CTSENBIT	3
#define USEBIT		6
#define DCEBIT		7
#define RLSDSTBIT	8
#define RISTBIT 	9
#define DSRSTBIT	10
#define CTSSTBIT	11
#define OUT2BIT 	12
#define OUT1BIT 	13
#define RTSBIT		14
#define DTRBIT		15
#define INITBIT 	16
#define STKBIT		18
#define EPSBIT		19
#define PENBIT		20
#define STBBIT		21
#define WDLNBIT1	22
#define WDLNBIT2	23

/* Bit positions in CPM3 CHRTBL */

#define PMASKBIT	4+(48)	/* protocol mask bit */
#define XONBIT		3+(48)	/* XON-XOFF protocol bit */
#define SOFTBAUDBIT	5+(48)	/* software selectable baud rate */
#define OUTDVBIT	6+(48)	/* output device bit */
#define INDVBIT 	7+(48)	/* input device bit */

/* Bit positions in floppy disk mode or mask bytes */

#define HARDBIT 	0	/* hard disk or flopply bit */
#define SIZEBIT 	16
#define DDSBIT		17
#define DDTBIT		18
#define DDDBIT		19
#define STEPBIT1	20
#define STEPBIT2	21
#define MDSBIT		25
#define MDTBIT		26
#define MDDBIT		27

/* other constants */

#define CHIONUM 200	/* start of char io phy device number */
#define NETLSTN 204	/* netlist device's physical device number */
#define UNASGN	255	/* unassign physical device number */
#define FMTBLEN 8	/* format table wide in getdp */

			/* MODULE TABLE DEFINATIONS */

#define COMTABL struct comstr
#define MAXSTRL 75

COMTABL { 		/* common section to module tables */
	char string[MAXSTRL];
	byte phydevnum;
	byte numdev;
};

#define CHARDEV struct chardev

CHARDEV {
	word chtbladdr; /* from chrtbl DR CPM3 */
	char chrstr[8]; 	/* cpm3 chrtbl string */
	char softproto;
	bool protomask; 	/* TRUE = can change  FALSE = can't change */
	ushort baudrate;
	bool baudmask;		/* TRUE = can change  FALSE = can't change */
	bool indev;		/* TRUE = input device */
	bool outdev;		/* TRUE = output device */
	word xmodeaddr; /* from xmode bytes MMS CPM3  */
	bool usage;		/* TRUE = list a chario menu  FALSE = don't */
	bool dce_dte;		/* TRUE = DCE	FALSE = DTE */
	byte baseport;
	bool initflg;		/* TRUE = yes	FALSE = NO */
	char parity;
	ushort stopbits;
	ushort wordlen;
	char hsinput[4];	/* RLSD,RI,DST,CTS  0,1,X (don't care) */
	char hsoutput[4];	/* DTR,RTS,OUT1,OUT2 0,1 */
};

#define CHARTABL struct charstr
#define MAXCHR 6
#define MAXCDEV 6

CHARTABL {		/* char io module table structure */
	COMTABL compart;
	CHARDEV charpart[MAXCDEV];
};

extern CHARTABL *chrptrtbl[MAXCHR];	/* table of pointers - data in free memory */
					/* allocated at run time by alloc() */

extern ushort numchario;	/* number of char io modules in table */

#define FLOPCHAR struct flopchar

FLOPCHAR {
	bool numsides;	/* TRUE = side sided  FALSE = double sided */
	bool sidemask;	/* TRUE = can change  FALSE = can't change */
	bool trkden;	/* TRUE = 48 tpi      FALSE = 96 tpi */
	bool trkmask;
	bool recden;	/* TRUE = single density FALSE = double density */
	bool recmask;
};

#define FLOPDEV struct flopdev

FLOPDEV {
	bool floppy;	/* TRUE = floppy disk FALSE = hard disk and ednore */
	word modeaddr;					       /* mode bytes*/ 
	byte modebyt[8];	/* Actual mode bytes used by serdp */
	bool disksize;		/* TRUE = 8"  FALSE = 5.25" */
	FLOPCHAR drive_contr;
	ushort steprate;
	bool stepmask;
	FLOPCHAR media;
	ushort medforcd;	/* bit position code in mode byte */
	byte medmask[2];	/* actual mode masks */
};

#define DISKTABL struct diskstr
#define MAXFDEV 9
#define MAXDSK 8

DISKTABL {
	COMTABL compart;
	FLOPDEV floppart[MAXFDEV];
};
extern DISKTABL *dskptrtbl[MAXDSK];	/* a table of pointers - data in free memory */
					/* allocated by the alloc() function */

extern ushort numdiskio;     /* number of disk io modules in table */
extern word serdpadr;	      /* address of ?serdp routine used to check mode bytes */


			/* OTHER GLOBAL VARIABLES */

/* Logical physical table and other related data */

#define MAXDRV 16
#define DRVTABL struct drvtabl
DRVTABL {
	byte logphytbl[MAXDRV];
	word logphyaddr;    /* address in bios of lptbl */
	byte drvsch[4];     /* drive search path array	drive number 0-16 */
			    /* drvsch[0] = 1st drv, drvsch[1] = 2nd drv, etc */
	byte tempdrv;	    /* temporary drive - drive number 0-16 */
};			    /* zero = default drive */

extern DRVTABL drivtable;

/* SUB, COM search order code */

extern byte subcom;	/* 0 = .COM only  1 = .COM,.SUB  2 = .SUB,.COM */


/* redirection vectors */

extern word redirvec[5];	 /* MSB = phy device # 200, etc */

	   /* [0] = conin, [1] = conout, [2] = auxin [3] = auxout [4] = lst */


/* netlist device node number and address of node number */

extern word nodeadr;
extern byte nodenum;


/* Sector read and write globals */

#define SECSIZ 128
#define NUMSEC	1
#define FILEOFF 0x100		/* offset of an spr file */
extern byte secbuf[SECSIZ];
extern ushort cursec;
extern bool writeflg;
extern ushort fd;

/* Cursor positioning globals */

#define MAXLNE	17
#define MAXCOL	15
extern short curline,curcol,oldcol;
extern ushort curpos[MAXLNE][MAXCOL];
extern int cntrlbuf,charbuf;

/* general globals */

extern bool bioscurflg;	/* TRUE = bios file  FALSE = current image in memory */
extern word biosstart; 	/* 0000 if changeing bios file else start of bios in */
			/* memory location 0001h */

extern bool mpmfile;	/* TRUE = bios file is MP/M (BNKXIOS.SPR) */
			/* FALSE = bios file is CP/M 3 (BNKBIOS.SPR) */

#include "terminal.h"

#define STMNLNE 17	/* starting line of window */
#define STMNCOL 46	/* starting column of window */

/* end of SETUP30.H */
