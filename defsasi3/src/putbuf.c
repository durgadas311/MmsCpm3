/*
 * These routines build the magic sector
 *  buffer for initsasi()
 *
 *  Date last modified: 12/1/83 10:25 mjm
 *
 * "PUTBUF.C"
 *
 */

#include "defsasi.h"

#define BUFADR	8
#define CHSUMCD 0x0FF0          /* code to indicate that the check sum is good */
#define STPARTBL 20             /* start of partition address table in BUFFER */
#define STDPB	47              /* start of dpb in BUFFER */

putbuf(phylist, parlist, lun)
struct phyparm *phylist;
struct parstruct *parlist;
int lun;
{
    char *bufpt, *initsasi();
    int i;

    bufpt = initsasi(BUFADR);
    setmem(bufpt, 1024, 0);
    *(bufpt++) = 0xC3;          /* jump to boot loader */
    *(bufpt++) = 0x80;
    *(bufpt++) = 0x24;
    if (testxebec(phylist))     /* drive / controller code */
        *(bufpt++) = 0x00;
    else
        *(bufpt++) = 0xFF;
    *(bufpt++) = phylist->contbyte[lun];
    *(bufpt++) = phylist->numcyl[lun] / 256;
    *(bufpt++) = phylist->numcyl[lun];
    *(bufpt++) = phylist->numheads[lun];

    *(bufpt++) = phylist->drivch[lun][0] / 256;
    *(bufpt++) = phylist->drivch[lun][0];
    *(bufpt++) = phylist->drivch[lun][1] / 256;
    *(bufpt++) = phylist->drivch[lun][1];
    *(bufpt++) = phylist->drivch[lun][2];

    for (i = 0; i < 6; i++)
        *(bufpt++) = phylist->assigndata[lun][i];
    *(bufpt++) = getlunpar(parlist, lun);
    putpartbl(parlist, lun);
    putdpb(phylist, parlist, lun);
    checksum();
}

getlunpar(parlist, lun)
struct parstruct *parlist;
int lun;
{
    int i, count;
    for (i = 0, count = 0; i < parlist->numpar; i++)
        if (lun == parlist->parlun[i])
            ++count;
    return (count);
}

putpartbl(parlist, lun)         /* calculates # of sectors and */
struct parstruct *parlist;      /* address for each partition */
int lun;
{
    LONG paradd, temp, temp2;
    char *bufpt, *initsasi();
    int i;

    bufpt = initsasi(BUFADR) + STPARTBL;
    itol(paradd, STARTSEC);
    for (i = 0; i < parlist->numpar; i++) {
        if (lun == parlist->parlun[i]) {
            *(bufpt++) = paradd.l[1];
            *(bufpt++) = paradd.l[2];
            *(bufpt++) = paradd.l[3];
            itol(temp, parlist->parsize[i]);
            itol(temp2, LSPT);
            lmul(temp, temp, temp2);
            ladd(paradd, paradd, temp);
        }
    }
}

putdpb(phylist, parlist, lun)
struct phyparm *phylist;
struct parstruct *parlist;
int lun;
{
    int i;
    char *bufpt, *initsasi();
    unsigned bits, cksize, getalv(), dsm();

    bufpt = initsasi(BUFADR) + STDPB;
    for (i = 0; i < parlist->numpar; i++) {
        if (lun == parlist->parlun[i]) {
            *(bufpt++) = LSPT;  /* SPT */
            *(bufpt++) = LSPT / 256;
            *(bufpt++) = getbsh(parlist, i);    /* BSH */
            *(bufpt++) = (parlist->blocksize[i] / LSIZE) - 1;
            if (dsm(parlist, i) < 256)  /* EXT */
                *(bufpt++) = (parlist->blocksize[i] / 1024) - 1;
            else
                *(bufpt++) = (parlist->blocksize[i] / 2048) - 1;
            *(bufpt++) = dsm(parlist, i);       /* DSM */
            *(bufpt++) = dsm(parlist, i) / 256;
            *(bufpt++) = parlist->numdir[i] - 1;        /* DRM */
            *(bufpt++) = (parlist->numdir[i] - 1) / 256;
            bits = getalv(parlist, i);  /* ALV0 ALV1 */
            *(bufpt++) = bits >> 8;
            *(bufpt++) = bits;
            if (phylist->typemed[lun] == 'F') { /* CKS */
                *(bufpt++) = 0;
                *(bufpt++) = 0;
            } else {
                cksize = parlist->numdir[i] / 4;
                cksize =
                    (parlist->numdir[i] % 4) == 0 ? cksize : cksize + 1;
                *(bufpt++) = cksize;
                *(bufpt++) = cksize / 256;
            }
            *(bufpt++) = parlist->off[i];       /* OFF */
            *(bufpt++) = parlist->off[i] / 256;
            if (phylist->sizesect == 512)       /* mode bytes */
                *(bufpt++) = 0x02;
            else
                *(bufpt++) = 0x01;
            *(bufpt++) = 0x80;
            *(bufpt++) = 0;
            *(bufpt++) = 0xFF;  /* mask bytes */
            *(bufpt++) = 0xFF;
            *(bufpt++) = 0xFF;
        }
    }
}

getbsh(parlist, par)            /* calculates bsh */
struct parstruct *parlist;
int par;
{
    switch (parlist->blocksize[par]) {
    case 1024:
        return (3);
    case 2048:
        return (4);
    case 4096:
        return (5);
    case 8192:
        return (6);
    case 16384:
    default:
        return (7);
    }
}

unsigned dsm(parlist, par)      /* returns DSM */
struct parstruct *parlist;
int par;
{
    unsigned trks, blks;
    LONG temp1, temp2;

    trks = parlist->parsize[par] - parlist->off[par];
    if (trks <= 0)
        return (0);
    itol(temp1, trks);
    lmul(temp1, temp1, itol(temp2, LSPT));
    ldiv(temp1, temp1, itol(temp2, parlist->blocksize[par] / LSIZE));
    blks = ltou(temp1);
    blks = (blks == 0 ? 1 : blks);
    return (blks - 1);
}

unsigned getalv(parlist, par)   /* calculates alv0 and alv1 */
struct parstruct *parlist;
int par;
{
    unsigned bits, temp, alv, mask;

    alv = 0x8000;               /* Allocate at least one block */
    mask = 0x8000;
    bits = dirblk(parlist, par);
    while (bits > 0) {
        alv = alv | mask;
        mask /= 2;
        --bits;
    }
    return (alv);
}

unsigned dirblk(parlist, par)   /* Calculates the number of blocks */
struct parstruct *parlist;      /* the directory uses from dentries */
int par;                        /* which is the number of dir entries */
{                               /* Rounds up to the nearest block. */
    unsigned dblk, dentries, bls;

    dentries = parlist->numdir[par];
    bls = parlist->blocksize[par];
    dblk = dentries / (bls / DIRBYTES);
    dblk = (dentries % (bls / DIRBYTES)) == 0 ? dblk : dblk + 1;
    return (dblk);
}

checksum()
{
    char *bytpt, *initsasi();
    int i, *wdpt;
    unsigned sum;
    sum = 0;

    wdpt = bytpt = initsasi(BUFADR);
    *(wdpt + 126) = CHSUMCD;
    for (i = 0; i < 254; i++)
        sum += *(bytpt++);
    *(wdpt + 127) = sum;
}
