/* This source file contains the support functions for
 * PARMENU1.C like calculating the space left, track to
 * kbyte conversion, etc.
 * 
 * "PARMENU2.C"
 * 
 * Date last modified: 07/17/84 08:51 drm
 *
 *
 */

#include "defsasi.h"

/* These definations are for the screen format of partition menu */

#define NUMW	"%-8.8d"        /* field defination for numbers */
#define NUMK	"%-dK"          /* same as above with 'K' */
#define NLNE	9               /* number of lines of data on screen */
#define ACOL	4               /* total number of accessible columns */
#define NCOL	6               /* number of columns on screen */
#define STLNE	6               /* starting line number */
#define STCOL	23              /* starting column number */
#define COLW	10              /* column width */

updatnum(parlist)               /* updates the partition number from lun */
struct parstruct *parlist;
{
    int par, c, lun;

    lun = 10;
    for (par = 0, c = 0; par < MAXPAR; par++, c++) {
        if (parlist->parlun[par] != lun) {
            lun = parlist->parlun[par];
            c = 0;
        }
        parlist->parnum[par] = c;
    }
}

unsigned spleft(phylist, parlist, par)
struct phyparm *phylist;
struct parstruct *parlist;
int par;
{
    int p, lun;
    unsigned total, used, caltoltrk();

    used = 0;
    lun = parlist->parlun[par];
    for (p = 0; p < parlist->numpar; p++)
        if (lun == parlist->parlun[p])
            used += parlist->parsize[p];
    total = caltoltrk(phylist, lun);
    if (total < used)
        return (0);
    else
        return (total - used);
}

char *trk2str(trk, str)         /* Converts tracks to ASCII K value */
unsigned trk;
char *str;
{
    LONG temp1, temp2, *lmul();
    char *ltoa();

    utol(temp2, (LSIZE * LSPT) / 1024);
    utol(temp1, trk);
    return (ltoa(str, lmul(temp1, temp1, temp2)));
}

char *blk2str(blk, str, bls)    /* Converts blocks to ASCII K value */
unsigned blk, bls;
char *str;
{
    LONG temp1, temp2, *lmul();

    utol(temp1, bls / 1024);
    utol(temp2, blk);
    return (ltoa(str, lmul(temp1, temp1, temp2)));
}

unsigned str2trk(str)           /* Converts a decimal string to tracks */
char *str;
{
    LONG temp1, temp2, *ldiv();
    unsigned ltou();

    atol(temp1, str);
    utol(temp2, (LSIZE * LSPT) / 1024);
    return (ltou(ldiv(temp1, temp1, temp2)));
}

unsigned calactk(parlist, par)  /* calculates actual file space left */
struct parstruct *parlist;      /* after directory and system is out */
int par;                        /* returns number of blocks */
{
    unsigned bls, blks, dsm();

    bls = parlist->blocksize[par];
    blks =
        (dsm(parlist->parsize[par], parlist->off[par], bls) + 1) -
        dirblk(parlist->numdir[par], bls);
    return (blks);
}

unsigned caltoltrk(phylist, lun)        /* calculates total number of tracks */
int lun;
struct phyparm *phylist;
{
    unsigned ltou();
    LONG strk, numc, numh, temp1, temp2, *itol(), *lmul();

    itol(numc, phylist->numcyl[lun]);
    itol(numh, phylist->numheads[lun]);
    itol(strk, phylist->sectrk[lun]);
    lmul(temp1, strk, lmul(temp2, numc, numh));
    lmul(temp1, temp1, itol(temp2, phylist->sizesect / LSIZE));
    lsub(temp1, temp1, itol(temp2, STARTSEC));
    ldiv(temp1, temp1, itol(temp2, LSPT));
    return (ltou(temp1));
}

unsigned dsm(parsiz, offset, bls)       /* returns DSM */
int offset, bls;
unsigned parsiz;
{
    unsigned trks, blks;
    LONG temp1, temp2, *itol();

    trks = parsiz - offset;
    if (trks <= 0)
        return (0);
    itol(temp1, trks);
    lmul(temp1, temp1, itol(temp2, LSPT));
    ldiv(temp1, temp1, itol(temp2, bls / LSIZE));
    blks = ltou(temp1);
    blks = (blks == 0 ? 1 : blks);      /* need at least one block */
    return (blks - 1);
}

dirblk(dentries, bls)           /* Calculates the number of blocks */
int dentries, bls;              /* the directory uses from dentries */
{                               /* which is the number of dir entries */
    int dblk;                   /* Rounds up to the nearest block. */

    dblk = dentries / (bls / DIRBYTES);
    dblk = (dentries % (bls / DIRBYTES)) == 0 ? dblk : dblk + 1;
    return (dblk);
}

unsigned blktrk(blk, bls)       /* Block to track conversion. */
unsigned blk, bls;              /* If less than one track if returns */
{                               /* one track. */
    LONG trk, temp1, temp2, temp3, *itol();

    lmul(temp1, itol(temp2, bls), itol(temp3, blk));
    itol(temp2, LSPT * LSIZE);
    ldiv(trk, temp1, temp2);
    lmod(temp3, temp1, temp2);  /* round up if remindar == zero */
    if (lcomp(temp3, itol(temp1, 0)) == 0)
        return (ltou(trk));
    else
        return (ltou(trk) + 1);
}

unsigned minsize(parlist, par)  /* calculates the minimun number */
struct parstruct *parlist;      /* of tracks a partition can have */
int par;
{
    return (minsize2
            (parlist->blocksize[par], parlist->numdir[par],
             parlist->off[par]));
}

minsize2(bls, dir, off)
unsigned bls, dir, off;
{
    return (off + blktrk(dirblk(dir, bls), bls));
}

unsigned maxsize(phylist, parlist, par) /* calculates the maximum number */
struct parstruct *parlist;      /* tracks a partition can have */
struct phyparm *phylist;        /* for CP/M 2.2 */
int par;
{
    unsigned maxtrks, splmax, spleft();

    maxtrks = blktrk(ALEN * 8, parlist->blocksize[par]);
    maxtrks =
        parlist->blocksize[par] == 1024 ? blktrk(256, 1024) : maxtrks;
    maxtrks = MAXTRK < maxtrks ? MAXTRK : maxtrks;
    splmax = spleft(phylist, parlist, par) + parlist->parsize[par];
    if (splmax < maxtrks)
        maxtrks = splmax;
    return (maxtrks);
}

unsigned maxsize3(phylist, parlist, par)        /* calculates the maximum number */
struct parstruct *parlist;      /* tracks a partition can have */
struct phyparm *phylist;        /* for CP/M 3.1 */
int par;
{
    unsigned maxtrks, splmax, spleft();

    maxtrks = blktrk(CPM3ALVL * 4, parlist->blocksize[par]);
    maxtrks =
        parlist->blocksize[par] == 1024 ? blktrk(256, 1024) : maxtrks;
    splmax = spleft(phylist, parlist, par) + parlist->parsize[par];
    if (splmax < maxtrks)
        maxtrks = splmax;
    return (maxtrks);
}

initpar(phylist, parlist)       /* initialize the partitions to */
struct phyparm *phylist;        /* as many 8 mbyte as the drive */
struct parstruct *parlist;      /* can hold */
{
    int lun, par, i;
    unsigned toltrk, caltoltrk();

    initw(parlist->parsize, "4,4,4,4,4,4,4,4,4");
    initw(parlist->blocksize,
          "4096,4096,4096,4096,4096,4096,4096,4096,4096");
    initw(parlist->numdir, "512,512,512,512,512,512,512,512,512");
    initw(parlist->off, "2,2,2,2,2,2,2,2,2");
    parlist->numpar = 8;
    for (lun = par = 0; lun < phylist->numlun && par < MAXPAR; ++lun) {
        toltrk = caltoltrk(phylist, lun);
        while (toltrk > 0 && par < MAXPAR) {
            parlist->parlun[par] = lun;
            if (toltrk >= MAXTRK) {
                parlist->parsize[par] = MAXTRK;
                toltrk -= MAXTRK;
            } else {
                parlist->parsize[par] = toltrk;
                toltrk = 0;
            }
            parlist->numpar = ++par;
        }
    }
    updatnum(parlist);
}

cpypar(parlist1, parlist2)      /* copy parstruct */
struct parstruct *parlist1;     /* parlist1=parlist2 */
struct parstruct *parlist2;
{
    movmem(parlist2, parlist1, sizeof *parlist1);
}

getdstr(pline pcol, pdata, maxcol, maxlne)      /* gets a number from the */
int *pline, *pcol, maxcol, maxlne;      /* the screen in string */
char *pdata;                    /* form and puts it in pdata */
{                               /* if correct */
    unsigned inp, pt, flag, i;
    char str[8];

    pt = 0;
    flag = TRUE;
    while (flag == TRUE) {
        inp = getky(pline, pcol, maxcol, maxlne);
        if (inp == BS) {
            if (pt-- <= 0)
                pt = 0;
            else {
                curoff();
                outchr(BS);
                for (i = 0; i + pt <= 7; ++i) {
                    outchr(' ');
                }
                for (i = 0; i + pt <= 7; ++i) {
                    outchr(BS);
                }
                curon();
            }
        } else if (inp >= '0' && inp <= '9') {
            if (pt >= 6)
                pt = 6;
            else {
                str[pt++] = inp;
                outchr(inp);
            }
        } else
            flag = FALSE;
    }
    str[pt] = NULL;
    if (pt > 0)
        strcpy(pdata, str);
    return (inp);
}

/* end of PARMENU2.C */
