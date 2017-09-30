/* DEFSASI header 
 *  Contains global definations and varaibles
 *  to be used by all modules in the config
 *  program.
 *  Each module must have this line:
 *	       #include "DEFSASI.H"
 *
 * Date last modified: 07/16/84 15:25 drm
 *
 */

#include "bdscio.h"

#define RVERS	"3.01"          /* Root version number */
/* If this is changed, all the ovl*.c files have to be re-compiled */

#define STRSIZE 30              /* size of string fields */

#define INITFLD "............"  /* initial value of string fields */
#define DEFTRK	4               /* default values for tracks,bls,etc */
#define DEFBLS	4096
#define DEFDIR	512
#define DEFOFF	2

#define ERR1 ERROR-1            /* error codes from read module functions */
#define HEOF ERR1-1
#define ERR2 HEOF-1
#define ERR3 ERR2-1

struct phyparm {
    int contrnum;
    char contrmfg[STRSIZE];
    char contrmod[STRSIZE];
    char contrver[STRSIZE];
    int sizesect;

    char drivemfg[4][STRSIZE];
    char drivemod[4][STRSIZE];
    char typemed[4];
    unsigned numcyl[4];
    int numheads[4];
    int sectrk[4];
    int contbyte[4];
    int drivcont[4];
    int ileavfac[4];
    int exfort[4];
    int exdtest[4];
    int drivch[4][3];           /* drive characteristic data used by XEBEC */
    int assigndata[4][6];       /* assign drive data used by DP-900 */
    int numlun;
};

/* data file format strings  */

#define VERDAT	"%d.%03.3d\n"   /* Version number field defination */
#define RVERDAT "%d.%s\n"       /* Read dat file version field defination */
#define CFTDAT	"%s;%s;%s;%d\n"
#define DFTDAT	"%s;%s;%c\n"
#define NFTDAT	"%d;%d;%d;%d;%d;%d;%d;%d\n"
#define A1FTDAT "%d;%d;%d\n"
#define A2FTDAT "%d;%d;%d;%d;%d;%d\n"
#define MAXREC	100

/* data file structure */

struct datfile {
    char dcontrmfg[STRSIZE];    /*  CFTDAT  */
    char dcontrmod[STRSIZE];
    char dcontrver[STRSIZE];
    int dsizesect;

    char ddrivemfg[STRSIZE];    /*  DFTDAT  */
    char ddrivemod[STRSIZE];
    char dtypemed;

    unsigned dnumcyl;           /*  NFTDAT  */
    int dnumheads;
    int dsectrk;
    int dcontbyte;
    int ddrivcont;
    int dileavfac;
    int dexfort;
    int dexdtest;

    int ddrivch[3];             /*  A1FTDAT */

    int dassigndata[6];         /*  A2FTDAT */
};

#define MAXPAR	9               /* maximum number of partitions */
#define Z67MAX	8               /* maximun for Z67 module */

struct parstruct {
    int parlun[MAXPAR];
    int parnum[MAXPAR];
    unsigned parsize[MAXPAR];
    int blocksize[MAXPAR];
    int numdir[MAXPAR];
    int off[MAXPAR];
    int numpar;
};

/* globals for defsasi2.c */

int gcurovl;                    /* current overlay in memory */
int fdatflg;                    /* TRUE if found data in dat file */

/*  globals for whole program */

#define PHYDRNUM 50             /* Starting physical drive number */
#define MAXLUN	 4              /* Maximun number of logical units */
#define XEBMAX	 2              /* Maximun number of lun if XEBEC  */

#define DIRBYTES 32             /* Number of bytes per directory entry */
#define MAXTRK	 1024           /* Maximum number of tracks CP/M 2.24 allows */
                                /* per partition. */
#define ALEN	 256            /* CP/M 2.24 allocation buffer length. */
                                /*  1 bit per block - 8 blocks per byte */
#define CSLEN	 128            /* CP/M 2.24 Check sum vector buffer length */
                                /* for removable media. */

#define CPM3ALVL 512            /* CP/M 3 allocation buffer length */
                                /*  2 bits per block - 4 blocks per byte */
#define CPM3CSVL 256            /* CP/M 3 checksum vector buffer length */
#define CPM3DPBL 17             /* CP/M 3 disk parameter block length */
#define CPM3MODL 8              /* CP/M 3 mode byte length */
#define CPM3DPHL 25             /* CP/M 3 disk parameter header length */
#define CPM3DIR  896            /* Maximun number CP/M 3 directory entries */

#define MAXDIRBLK 16            /* Maximum number of directory blocks CP/M */
                                /* allows (because of the 16 bit ALV0,ALV1). */
#define MINDIRENT 64            /* Minimum number of directory entries. */

#define HSTBUF	512             /* Size of regular host buffer in module. */
#define Z67HST	256             /* Size of Z67 module host buffer */
#define Z67FLOP 64+62           /* Size of CVS & ALV buffers for floppy disk */
#define CKBUF	0xF000          /* Starting address of check sum, alloc and host buffers in module. */
#define LSIZE	128             /* logical sector size */
#define LSPT	64              /* logical sectors per track */
#define STARTSEC 12             /* starting logical sector */

#define  GETVERS 12             /* get CP/M version number */
#define  GETDSK  25             /* get currently logged on drive */
#define  GETSCB  49             /* get system control block */
#define  DRVSC	 0x4C           /* drive search order start */

int cpm3flg;                    /* if = 0 (FALSE) then running 2.24 CP/M */
                                /* else  running 3.0 CP/M */

/* global for write dat */

int datflg;                     /* if = TRUE then the drive data has been */
                                /* changed and the version number of the */
                                /* DAT file will change otherwise the version */
                                /* will not change */

/* global for read dat */

int initflg;                    /* if = TRUE then a default drive has been */
                                /* put in DEFSASI3.DAT (bit 8 of controller */
                                /* mfg is set */

int dispflg;                    /* if = TRUE put "Write 'DEFSASI3.DAT' after */
                                /* Subsystem data in main menu */

/*  global for initfun */

int fmtflg;                     /* if = 0 (FALSE) disk has not been formated */

/*  global variables for data functions  */

struct datfile *datarray[MAXREC];       /* array of pointers to datfile  */
int _endarr;                    /* structures in memory.         */
                                        /* alloc/free functions are used */
struct datfile *listarr[MAXREC];        /* to put the data from          */
                                        /* "DRIVES.DAT" into memory.     */

int datvers1, datvers2;         /* Version number of dat file */
                                       /* #1 is kept fixed and #2 is uped */
                                       /* every time the file is written out */

/*  globals for modfunc  */

int gdata[17];
int gccnt;
unsigned gcaddr;

/*  globals for wrtrel */

char riobuf[BUFSIZ];            /* data buffer */
unsigned bitsused, bitsleft;    /* number of bits used and left */
char outbits;                   /* current bits waiting to be written */

unsigned loccnt[4];             /* data and program location counters */
unsigned curloc;                /* current location counter */
                                        /* 1 = program  2 = data */

/*  globals defination for longs */

struct lg {
    char l[4];
};

#define LONG struct lg
#define GREATER  1
#define LESS	 -1
#define EQUAL	 0

#include "terminal.h"

char linpos, colpos;

/* end of DEFSASI.H */
