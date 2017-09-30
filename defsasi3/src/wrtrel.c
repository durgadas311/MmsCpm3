/* Functions to write a .REL data module to be 
 * linked with the main SASI module.
 *
 * Date lasted modified 12/1/83 10:39 mjm
 *
 * "WRTREL.C"
 */

#include "defsasi.h"

#define MAXBITS 8               /* maximum bits that putbits() can handle */

/* first bit code */

#define BYTE	0               /* Next 8 bits is a byte */
#define OPCODE	1               /* Next 2 bits is a opcode */

/* 2 bit op codes or address types */

#define SPECIAL 0               /* Special link item see 4 bit op codes */
#define ABSOLUT 0               /* Absolute reference, followed by 16 bit address */
#define PROGREL 1               /* Program relative, followed by 16 bit address */
#define DATAREL 2               /* Data relative, followed by a 16 bit address */
#define COMREL	3               /* Common relative, followed by a 16 bit address */

/* 4 bit special link item op codes */

/* Followed by a 3 bit name size and a ASCII name field */
#define ENTRYSY 0               /* Entry symbol */
#define SELCOM	1               /* Select common block */
#define PROGNAM 2               /* Program name */

/* Followed by a 2 bit address type and a 16 bit address and a name field */
#define COMSIZ	5               /* Define common size */
#define CHAINEX 6               /* Chain external */
#define ENTRYPT 7               /* Define entry point */

/* Followed by a 2 bit address type and a 16 bit address */
#define EXTPLUS 9               /* External plus offset */
#define DATASIZ 10              /* Define data size */
#define SETLOC	11              /* Set location counter */
#define CHAINAD 12              /* Chain address */
#define PROGSIZ 13              /* Define program size */
#define ENDMOD	14              /* End module */
#define ENDFILE 15              /* End of file */

#define CNUML	1               /* controller number length */
#define HEADERL 0x16            /* module header length */
#define DRV0ADR 2               /* program relative address of drive 0 */
#define MODADR	0x16            /* program relative address of mode byte table */
#define CNUMADR 0               /* data relative address of controller number */
#define DPHADR	1               /* data relative address of disk parameter header */

#define DRV0SYM  "SDRV0"        /* address of drive zero */
#define CNUMSYM  "SCNUM"        /* controller number address */
#define MODESYM  "SMODTB"       /* mode byte address symbol */
#define DPBSYM	 "SDPB"         /* DPB address symbol */
#define DPHSYM	 "SDPHTB"       /* DPH address symbol */

#define DTACBSYM "@DTACB"       /* external data control block address */
#define DIRCBSYM "@DIRCB"       /* external directory control block address */
#define THRDSYM  "STHRD"        /* thread external symbol  */
#define INITSYM  "SINIT"        /* init external symbol */
#define LOGSYM	 "SLOGIN"       /* login external */
#define READSYM  "SREAD"        /* read sector external */
#define WRITSYM  "SWRIT"        /* write sector external */
#define STRSYM	 "SSTRNG"       /* string external */

#define THRDADR  0              /* thread external address */
#define INITADR  0x5            /* init external address */
#define LOGADR	 0x8            /* login external address */
#define READADR  0xB            /* read sector external address */
#define WRITADR  0xE            /* write sector external address */
#define STRADR	 0x10           /* string external address */

wrtrel(phylist, parlist, outname, inname)
struct phyparm *phylist;
struct parstruct *parlist;
char *outname, *inname;
{
    unsigned DPBadr, ALVadr, CSVadr, dtacb, dircb;

    if (openrel(outname) == ERROR)
        return (ERROR);
    if (progname(outname) == ERROR)
        return (ERROR);
    if (entrysym(5, DRV0SYM, CNUMSYM, MODESYM, DPBSYM, DPHSYM) == ERROR)
        return (ERROR);
    if (defdatsiz(caldatsiz(phylist, parlist)) == ERROR)
        return (ERROR);
    if (defprogsiz(calprogsiz(parlist)) == ERROR)
        return (ERROR);
    if (setloccnt(0) == ERROR)  /* do a "cseg" statement */
        return (ERROR);
    if (sendbytes
        (4, 0, 0, PHYDRNUM + (phylist->contrnum * 10),
         parlist->numpar) == ERROR)
        return (ERROR);
    if (sendbytes(14, 0xC3, 0, 0, 0xC3, 0, 0, 0xC3, 0, 0, 0xC3, 0, 0, 0, 0)
        == ERROR)
        return (ERROR);
    if (sendaddr(DATAREL, DPHADR) == ERROR)     /* Put dph address in header */
        return (ERROR);
    if (sendaddr(PROGREL, MODADR) == ERROR)     /* Put mode byte table addr */
        return (ERROR);
    if (sendmodbyt(phylist, parlist) == ERROR)
        return (ERROR);
    DPBadr = curlcnt();
    if (senddpb(parlist) == ERROR)
        return (ERROR);
    curloc = DATAREL;           /* do a "dseg" statement */
    if (setloccnt(0) == ERROR)
        return (ERROR);
    if (sendbytes(1, phylist->contrnum) == ERROR)
        return (ERROR);
    ALVadr = CNUML + (parlist->numpar * CPM3DPHL);
    CSVadr = CNUML + (parlist->numpar * (CPM3DPHL + CPM3ALVL));
    if (senddph(phylist, parlist, DPBadr, ALVadr, CSVadr, &dtacb, &dircb)
        == ERROR)
        return (ERROR);
    if (sendalv(parlist) == ERROR)
        return (ERROR);
    if (sendcsv(phylist, parlist) == ERROR)
        return (ERROR);

    if (defentrypt(PROGREL, DRV0ADR, DRV0SYM) == ERROR) /* define publics */
        return (ERROR);
    if (defentrypt(DATAREL, CNUMADR, CNUMSYM) == ERROR)
        return (ERROR);
    if (defentrypt(PROGREL, MODADR, MODESYM) == ERROR)
        return (ERROR);
    if (defentrypt(PROGREL, DPBadr, DPBSYM) == ERROR)
        return (ERROR);
    if (defentrypt(DATAREL, DPHADR, DPHSYM) == ERROR)
        return (ERROR);

    if (chainext(DATAREL, dtacb, DTACBSYM) == ERROR)    /* chain externals */
        return (ERROR);
    if (chainext(DATAREL, dircb, DIRCBSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, THRDADR, THRDSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, INITADR, INITSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, LOGADR, LOGSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, READADR, READSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, WRITADR, WRITSYM) == ERROR)
        return (ERROR);
    if (chainext(PROGREL, STRADR, STRSYM) == ERROR)
        return (ERROR);
    if (endmod() == ERROR)
        return (ERROR);
    if (wrtcode(inname) == ERROR)       /* Write code module to output file */
        return (ERROR);
    if (closerel() == ERROR)
        return (ERROR);
    return (OK);
}

sendmodbyt(phylist, parlist)    /* sends the mode bytes to the file */
struct phyparm *phylist;
struct parstruct *parlist;
{
    int par, mode;

    for (par = 0; par < parlist->numpar; ++par) {
        if (phylist->typemed[parlist->parlun[par]] == 'R')
            mode = 0x90;
        else
            mode = 0x80;
        if (sendbytes(1, mode + parlist->parnum[par]) == ERROR)
            return (ERROR);
        if (sendbytes(3, parlist->parlun[par] << 5, 0, 0) == ERROR)
            return (ERROR);
        if (sendbytes(4, 0xFF, 0xFF, 0xFF, 0xFF) == ERROR)
            return (ERROR);
    }
    return (OK);
}

senddpb(parlist)                /* Allocates space for the DPB's */
struct parstruct *parlist;
{
    return (setloccnt(curlcnt() + parlist->numpar * CPM3DPBL));
}

senddph(phylist, parlist, DPBadr, ALVadr, CSVadr, dtacb, dircb)
struct phyparm *phylist;
struct parstruct *parlist;
unsigned DPBadr, ALVadr, CSVadr, *dtacb, *dircb;
{
    int par;

    for (par = 0; par < parlist->numpar; ++par) {
        if (sendbytes(12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) == ERROR)
            return (ERROR);
        if (sendaddr(PROGREL, DPBadr) == ERROR)
            return (ERROR);
        DPBadr += CPM3DPBL;
        if (phylist->typemed[parlist->parlun[par]] == 'R') {
            if (sendaddr(DATAREL, CSVadr) == ERROR)
                return (ERROR);
            CSVadr += CPM3CSVL;
        } else if (sendbytes(2, 0, 0) == ERROR)
            return (ERROR);
        if (sendaddr(DATAREL, ALVadr) == ERROR)
            return (ERROR);
        ALVadr += CPM3ALVL;
        if (par == 0) {
            if (sendbytes(2, 0, 0) == ERROR)
                return (ERROR);
        } else {
            if (sendaddr(DATAREL, *dircb) == ERROR)
                return (ERROR);
        }
        *dircb = curlcnt() - 2;
        if (par == 0) {
            if (sendbytes(2, 0, 0) == ERROR)
                return (ERROR);
        } else {
            if (sendaddr(DATAREL, *dtacb) == ERROR)
                return (ERROR);
        }
        *dtacb = curlcnt() - 2;
        if (sendbytes(3, 0, 0, 0) == ERROR)
            return (ERROR);
    }
    return (OK);
}

sendalv(parlist)                /* Allocates space for the ALV's */
struct parstruct *parlist;
{
    return (setloccnt(curlcnt() + parlist->numpar * CPM3ALVL));
}

sendcsv(phylist, parlist)       /* Allocates space for the CSV's */
struct phyparm *phylist;
struct parstruct *parlist;
{
    int remov;

    remov = calremov(phylist, parlist);
    if (remov != 0)
        return (setloccnt(curlcnt() + (remov * CPM3CSVL)));
    return (OK);
}

calprogsiz(parlist)             /* Calculates total program seg size */
struct parstruct *parlist;
{
    return (HEADERL + parlist->numpar * (CPM3MODL + CPM3DPBL));
}

caldatsiz(phylist, parlist)     /* Calculates total data seg size */
struct phyparm *phylist;
struct parstruct *parlist;
{
    return (CNUML + parlist->numpar * (CPM3DPHL + CPM3ALVL) +
            calremov(phylist, parlist) * CPM3CSVL);
}

calremov(phylist, parlist)      /* Calculates the number of removable partitions */
struct phyparm *phylist;
struct parstruct *parlist;
{
    int i, remov;

    for (i = 0, remov = 0; i < parlist->numpar; ++i)
        if (phylist->typemed[parlist->parlun[i]] == 'R')
            ++remov;
    return (remov);
}

curlcnt()
{                               /* returns the current location counter value */
    return (loccnt[curloc]);
}

openrel(filename)               /* opens the file and initializes the global */
char *filename;
{
    bitsused = outbits = 0;
    bitsleft = MAXBITS;
    curloc = PROGREL;
    loccnt[0] = loccnt[1] = loccnt[2] = loccnt[3] = 0;
    return (fcreat(filename, riobuf));
}

progname(name)                  /* Sends a program name to the file */
char *name;
{
    if (sendspec(PROGNAM) == ERROR)
        return (ERROR);
    return (sendname(name));
}

entrysym(num, symbol)           /* Sends symbol entries to the file */
int num;
char *symbol;
{
    int i;
    char **cptr;

    cptr = &symbol;
    for (i = 0; i < num; ++i, ++cptr) {
        if (sendspec(ENTRYSY) == ERROR)
            return (ERROR);
        if (sendname(*cptr) == ERROR)
            return (ERROR);
    }
    return (OK);
}

defdatsiz(size)                 /* Defines the data relative size */
unsigned size;
{
    if (sendspec(DATASIZ) == ERROR)
        return (ERROR);
    return (sendvalue(ABSOLUT, size));
}

defprogsiz(size)                /* Defines the program relative size */
unsigned size;
{
    if (sendspec(PROGSIZ) == ERROR)
        return (ERROR);
    return (sendvalue(PROGREL, size));
}

setloccnt(address)              /* Sets the current location counter */
unsigned address;
{
    if (sendspec(SETLOC) == ERROR)
        return (ERROR);
    if (sendvalue(curloc, address) == ERROR)
        return (ERROR);
    loccnt[curloc] = address;
    return (OK);
}

sendaddr(type, address)         /* Makes a address program or data relative */
unsigned type, address;
{
    if (putbits(OPCODE, 1) == ERROR)
        return (ERROR);
    if (sendvalue(type, address) == ERROR)
        return (ERROR);
    loccnt[curloc] += 2;
    return (OK);
}

defentrypt(type, address, name) /* Define entry point for public symbol */
unsigned type, address;
char *name;
{
    if (sendspec(ENTRYPT) == ERROR)
        return (ERROR);
    if (sendvalue(type, address) == ERROR)
        return (ERROR);
    return (sendname(name));
}

chainext(type, address, name)   /* Ends external chain and defines the sym */
unsigned type, address;
char *name;
{
    if (sendspec(CHAINEX) == ERROR)
        return (ERROR);
    if (sendvalue(type, address) == ERROR)
        return (ERROR);
    return (sendname(name));
}

endmod()
{                               /* End of module - forces byte boundary */
    if (sendspec(ENDMOD) == ERROR)
        return (ERROR);
    if (sendvalue(ABSOLUT, 0) == ERROR)
        return (ERROR);
    if (bitsused > 0) {
        if (putc(outbits, riobuf) == ERROR)
            return (ERROR);
        outbits = bitsused = 0;
        bitsleft = MAXBITS;
    }
    return (OK);
}

endfile()
{
    return (sendspec(ENDFILE));
}

sendbytes(num, bytes)           /* sends bytes out to REL file - inr loccnt */
unsigned num;
char bytes;
{
    int i;
    unsigned *wptr;             /* characters on the stack are extended to word length */

    for (wptr = &bytes, i = 0; i < num; ++i, ++wptr) {
        if (putbits(BYTE, 1) == ERROR)
            return (ERROR);
        if (putbits(*wptr, 8) == ERROR)
            return (ERROR);
    }
    loccnt[curloc] += num;
    return (OK);
}

sendspec(code)                  /* Sends a special link item command to file */
unsigned code;
{
    if (putbits(OPCODE, 1) == ERROR)
        return (ERROR);
    if (putbits(SPECIAL, 2) == ERROR)
        return (ERROR);
    return (putbits(code, 4));
}

sendvalue(type, address)        /* Sends a address to the file */
unsigned type, address;
{
    if (putbits(type, 2) == ERROR)
        return (ERROR);
    if (putbits(address, 8) == ERROR)
        return (ERROR);
    return (putbits(address >> 8, 8));
}

sendname(name)                  /* Sends a ASCII name to the file */
char *name;
{
    unsigned i, len;

    len = strlen(name);
    len = len > 6 ? 6 : len;
    if (putbits(len, 3) == ERROR)
        return (ERROR);
    for (i = 0; i < len; ++i, ++name)
        if (putbits(*name, 8) == ERROR)
            return (ERROR);
    return (OK);
}

putbits(data, nbits)            /* Does the bit manipulations */
unsigned nbits;
char data;
{
    if (nbits == bitsleft) {
        outbits |= data;
        if (putc(outbits, riobuf) == ERROR)
            return (ERROR);
        outbits = bitsused = 0;
    } else if (nbits < bitsleft) {
        outbits |= data << (bitsleft - nbits);
        bitsused += nbits;
    } else {                    /* nbits > bitsleft */
        outbits |= data >> (nbits - bitsleft);
        if (putc(outbits, riobuf) == ERROR)
            return (ERROR);
        outbits = data << ((MAXBITS + bitsleft) - nbits);
        bitsused = nbits - bitsleft;
    }
    bitsleft = MAXBITS - bitsused;
}

wrtcode(inname)
char *inname;
{
    int c;
    char iobuf[BUFSIZ];

    if (fopens(inname, iobuf) == ERROR)
        return (ERROR);
    while ((c = getc(iobuf)) != ERROR)
        if (putc(c, riobuf) == ERROR)
            return (ERROR);
    return (OK);
}

closerel()
{
    if (bitsused > 0)
        if (putc(outbits, riobuf) == ERROR)
            return (ERROR);
    return (fclose(riobuf));
}



/* This is a sample assemble of the code WRTREL produces:
 *
 *	   extrn @dtacb,@dircb,sthrd,sinit,slogin,sread,swrit,sstrng
 *	   public sdrv0,scnum,smodtb,sdpb,sdphtb
 *
 *	   cseg
 *	
 *	   dw	   sthrd
 * sdrv0   db	   50,2
 *	   jmp	   sinit
 *	   jmp	   slogin
 *	   jmp	   sread
 *	   jmp	   swrit
 *	   dw	   sstrng
 *	   dw	   sdphtb,smodtb
 *
 * smodtb  db	   1000$0000b,000$00000b,00000000b,00000000b
 *	   db	   1111$1111b,111$11111b,11111111b,11111111b
 *
 *	   db	   1001$0000b,001$00000b,00000000b,00000000b
 *	   db	   1111$1111b,111$11111b,11111111b,11111111b
 *
 * sdpb    ds	   2*17
 *
 *	   dseg
 *
 * scnum   db	   0
 *
 * sdphtb  dw	   0,0,0,0,0,0,sdpb,0,alv,@dircb,@dtacb,0
 *	   db	   0
 *	   dw	   0,0,0,0,0,0,sdpb+17,csv,alv+512,@dircb,@dtacb,0
 *	   db	   0
 *
 * alv	   ds	   2*512
 *
 * csv	   ds	   256
 *
 */
