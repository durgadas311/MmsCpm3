/* Partition menu of DEFSASI program. This section displays 
 * modifies the partition parameters.
 * It takes of copy of the parstruct struct
 * from the main menu and modifies it's local copy
 * allowing the user to exit without updating
 * the main copy.  PARMENU2.C contains support functions.
 *
 * "PARMENU1.C"
 * 
 * Date last modified: 07/18/84  08:28 drm
 *
 */

#include "defsasi.h"

/* These definations are for the screen format of menu #1 */

#define VERS "00"

#define NUMW	"%-8.8d"        /* field defination for numbers */
#define NUMK	"%-dK"          /* same as above with 'K' */
#define NLNE	9               /* number of lines of data on screen */
#define ACOL	4               /* total number of accessible columns */
#define NCOL	6               /* number of columns on screen */
#define STLNE	6               /* starting line number */
#define STCOL	23              /* starting column number */
#define COLW	10              /* column width */

parmenu(mphylist, mparlist)
struct phyparm *mphylist;
struct parstruct *mparlist;
{
    struct parstruct parlist;
    int curpos[NLNE][NCOL], par, c;

    cpypar(parlist, mparlist);
    initcur(curpos, STLNE, NLNE, STCOL, NCOL, COLW);
    prtm3();
    prtphydr(mphylist, parlist);
    prtpar(parlist, curpos);
    ptcurmenu();
    c = getdata3(parlist, mparlist, mphylist, curpos);
    if (c == BLUE)
        cpypar(mparlist, parlist);
    clrscr();
}

prtm3()
{
    char *getvers();

    clrscr();
    printf("                    Partition Characteristics  v%s.%s\n\n",
           getvers(), VERS);
    puts("Physical          Partition     Total    ");
    puts("Block   Directory    File    System\n");
    puts("Drive #    Lun     Number       Size     Size");
    puts("     Entries     Space   Tracks\n\n");
}

prtpar(parlist, curpos)         /* prints the lines of partitions */
struct parstruct *parlist;      /* determined by par */
int curpos[][NCOL];
{
    int par;

    prtparlun(parlist);
    prtparnum(parlist, curpos);
    for (par = 0; par < parlist->numpar; par++)
        prtsing(parlist, par, curpos);
}


prtsing(parlist, par, curpos)
struct parstruct *parlist;
int curpos[][NCOL], par;
{
    prtparsiz(parlist, par, curpos);
    cursor(curpos[par][2]);
    printf("%dK ", parlist->blocksize[par] / 1024);
    cursor(curpos[par][3]);
    printf(NUMW, parlist->numdir[par]);
    prtact(parlist, par, curpos);
    cursor(curpos[par][5]);
    printf(NUMW, parlist->off[par]);
}

prtphydr(phylist, parlist)
struct phyparm *phylist;
struct parstruct *parlist;
{
    int dr;

    for (dr = 0; dr < parlist->numpar; dr++) {
        cursor((STLNE * getwidth() + 1) + dr * getwidth() + 1);
        if (testz67(phylist))
            printf(NUMW, (phylist->contrnum * 10) + PHYDRNUM + dr + 1);
        else
            printf(NUMW, (phylist->contrnum * 10) + PHYDRNUM + dr);
    }
}

prtparlun(parlist)
struct parstruct *parlist;
{
    int par, oldlun;

    oldlun = 5;
    for (par = 0; par < parlist->numpar; par++) {
        cursor((STLNE * getwidth() + 12) + par * getwidth() + 1);
        if (oldlun == parlist->parlun[par])
            puts("      ");
        else {
            printf(NUMW, parlist->parlun[par]);
            oldlun = parlist->parlun[par];
        }
    }
}

prtparnum(parlist, curpos)
struct parstruct *parlist;
int curpos[][NCOL];
{
    int par;
    for (par = 0; par < parlist->numpar; par++) {
        cursor(curpos[par][0]);
        printf(NUMW, parlist->parnum[par]);
    }
}

prtparsiz(parlist, par, curpos) /* print partition size before */
struct parstruct *parlist;      /* system and directory space */
int curpos[][NCOL], par;        /* is subtracted */
{
    char str[20], *trk2str();

    cursor(curpos[par][1]);
    trk2str(parlist->parsize[par], str);
    strcat(str, "K");
    printf("%-7.7s", str);
}

prtact(parlist, par, curpos)    /* print actual file space */
struct parstruct *parlist;
int curpos[][NCOL], par;
{
    unsigned calactk();
    char str[20], *blk2str();

    cursor(curpos[par][4]);
    blk2str(calactk(parlist, par), str, parlist->blocksize[par]);
    strcat(str, "K");
    printf("%-7.7s", str);
}

clearpar(par)
{                               /* clears the line determined *//* by par */
    cursor((STLNE + par) * getwidth() + 1);
    clreel();
}

getdata3(parlist, mparlist, phylist, curpos)    /* this function does the actual */
struct parstruct *parlist;      /* field editing of the partition */
int curpos[][NCOL];             /* parmeter structure */
struct parstruct *mparlist;
struct phyparm *phylist;
{
    int curcol, curpar, n, lun, par;
    unsigned caltoltrk();

    curcol = curpar = n = 0;
    cursor(curpos[0][0]);
    for (lun = 0; lun < phylist->numlun; lun++) {
        if (caltoltrk(phylist, lun) <= 0) {
            prtwin(1, "Size of lun %d undefined", lun);
            winmsg("Exit to Subsystem Data menu", 2);
            bell();
            n = getky(&curpar, &curcol, ACOL, parlist->numpar);
            clmn();
            break;
        }
    }
    while (n != RED && n != BLUE) {
        cursor(curpos[curpar][curcol]);
        switch (curcol) {
        case 0:                /* partition number */
            n = parfield(parlist, phylist, curpos, &curpar, &curcol);
            break;
        case 1:                /* partition size  */
            n = parsiz(parlist, phylist, curpos, &curpar, &curcol);
            break;
        case 2:                /* block size */
            n = bls(parlist, curpos, &curpar, &curcol);
            break;
        case 3:                /* number of directory entries */
            n = dirent(parlist, phylist, curpos, &curpar, &curcol);
            break;
        default:
            break;
        }
        if (n == WHITE) {
            cpypar(parlist, mparlist);
            curoff();
            prtphydr(phylist, parlist);
            prtpar(parlist, curpos);
            for (par = parlist->numpar; par < MAXPAR; par++)
                clearpar(par);
            curon();
            curcol = curpar = 0;
        }
    }
    return (n);
}

parfield(parlist, phylist, curpos, ppar, pcol)  /* controls the partition field */
struct parstruct *parlist;
struct phyparm *phylist;
int curpos[][NCOL], *ppar, *pcol;
{
    int n, flag, parmax;

    flag = TRUE;
    winmsg("<DELETE> = deletes one partition", 1);
    winmsg("<+>      = adds one partition", 2);
    if (testz67(phylist))
        parmax = Z67MAX;
    else
        parmax = MAXPAR;
    while (flag == TRUE) {
        cursor(curpos[*ppar][*pcol]);
        n = getky(ppar, pcol, ACOL, parlist->numpar);
        cursor(curpos[*ppar][*pcol]);
        switch (n) {
        case '+':
            if (++(parlist->numpar) > parmax)
                parlist->numpar = parmax;
            else {
                if (insertpar(phylist, parlist, *ppar) == ERROR) {
                    --parlist->numpar;
                    break;
                }
                curoff();
                prtphydr(phylist, parlist);
                prtpar(parlist, curpos);
                curon();
            }
            break;
        case LEFT:
            break;
        case DOWN:
            break;
        case UP:
            break;
        case DELETE:
            if (--(parlist->numpar) < 1)
                parlist->numpar = 1;
            else {
                if (deletepar(parlist, ppar) == ERROR) {
                    ++(parlist->numpar);
                    break;
                }
                curoff();
                prtpar(parlist, curpos);
                clearpar(parlist->numpar);
                curon();
            }
            break;
        default:
            flag = FALSE;
            if (n < CNTL && n != CRCD)
                bell();
            break;
        }
        cursor(curpos[*ppar][*pcol]);
    }
    clmn();
    return (n);
}

insertpar(phylist, parlist, par)        /* Inserts a minimum size partition */
struct parstruct *parlist;      /* at the end of the current lun. */
struct phyparm *phylist;
int par;                        /* Parlist->numpar must have */
{                               /* already been incremented */
    int i, lun, endpar, newpar, firstpar;
    unsigned spleft(), minsize();

    lun = parlist->parlun[par];
    endpar = parlist->numpar - 1;

    newpar = par;               /* find insert position */
    while (parlist->parlun[newpar] == lun && newpar < endpar)
        ++newpar;
    parlist->numpar = endpar;   /* make to old # of par */
    if (spleft(phylist, parlist, par) < DEFTRK) {
        firstpar = 0;           /* find first partition of lun */
        while (parlist->parlun[firstpar] != lun)
            ++firstpar;
        i = newpar - 1;         /* Subtract new space from existing */
        while (parlist->parsize[i] - DEFTRK < minsize(parlist, i)) {
            if (i < firstpar)
                return (ERROR); /*error if not enough room for */
            else                /* new partition */
                --i;
        }
        parlist->parsize[i] -= DEFTRK;
    }
    parlist->numpar = endpar + 1;       /* restore to new # of partitions */
    while (newpar < endpar) {   /* move data down */
        parlist->parlun[endpar] = parlist->parlun[endpar - 1];
        parlist->parsize[endpar] = parlist->parsize[endpar - 1];
        parlist->blocksize[endpar] = parlist->blocksize[endpar - 1];
        parlist->numdir[endpar] = parlist->numdir[endpar - 1];
        parlist->off[endpar] = parlist->off[endpar - 1];
        --endpar;
    }
    parlist->parlun[newpar] = lun;
    updatnum(parlist);
    parlist->parsize[newpar] = DEFTRK;  /* use default values for new par */
    parlist->blocksize[newpar] = DEFBLS;
    parlist->numdir[newpar] = DEFDIR;
    parlist->off[newpar] = DEFOFF;
}

deletepar(parlist, ppar)        /* Deletes the last partition on the */
struct parstruct *parlist;      /* current lun.Parlist->numpar must */
int *ppar;                      /* have already been decremented */
{
    int lun, endpar, delpar, firstpar;

    lun = parlist->parlun[*ppar];
    endpar = parlist->numpar;   /* Last partition plus one */
    firstpar = 0;               /* Find first partition of lun */
    while (parlist->parlun[firstpar] != lun)
        ++firstpar;
    delpar = *ppar;
    while (parlist->parlun[delpar] == lun && delpar <= endpar)
        ++delpar;               /* find delete position */
    if (firstpar >= delpar - 1) /* error if last partition on lun */
        return (ERROR);
    if (*ppar >= delpar - 1)    /* move cursor back if needed */
        *ppar = delpar - 2;
    while (delpar <= endpar) {  /* move data up */
        parlist->parlun[delpar - 1] = parlist->parlun[delpar];
        parlist->parsize[delpar - 1] = parlist->parsize[delpar];
        parlist->blocksize[delpar - 1] = parlist->blocksize[delpar];
        parlist->numdir[delpar - 1] = parlist->numdir[delpar];
        parlist->off[delpar - 1] = parlist->off[delpar];
        ++delpar;
    }
    updatnum(parlist);
    return (OK);
}

parsiz(parlist, phylist, curpos, ppar, pcol)    /* enters the partition size */
struct parstruct *parlist;      /* in kbytes and converts it */
struct phyparm *phylist;        /* to tracks */
int curpos[][NCOL], *ppar, *pcol;
{
    int n, p, c, errflg;
    unsigned str2trk(), trks;
    char str[20];

    do {
        errflg = OK;
        p = *ppar;
        c = *pcol;
        prtleft(phylist, parlist, p);
        trk2str(parlist->parsize[p], str);
        cursor(curpos[*ppar][*pcol]);
        n = getdstr(ppar, pcol, str, ACOL, parlist->numpar);
        trks = str2trk(str);
        winmsg("", 5);
        winmsg("", 6);
        if (n < CNTL && n != CRCD)
            errflg = ERROR;
        else if (trks != parlist->parsize[p])
            errflg = updatpars(parlist, phylist, p, trks);
        if (errflg == ERROR) {
            bell();
            *ppar = p;
            *pcol = c;
            n = CRCD;
        }
        curoff();
        prtact(parlist, p, curpos);
        prtparsiz(parlist, p, curpos);
        cursor(curpos[*ppar][*pcol]);
        curon();
    }
    while (n == UP || n == DOWN || n == CRCD);
    clmn();
    return (n);
}

updatpars(parlist, phylist, par, newtrk)
struct parstruct *parlist;
struct phyparm *phylist;
unsigned newtrk;
int par;
{
    int lun;
    unsigned dsm(), spleft(), minsize(), blktrk();

    lun = parlist->parlun[par];
    if (newtrk > spleft(phylist, parlist, par) + parlist->parsize[par]) {
        winmsg("Not enough space left on drive", 6);
        return (ERROR);
    }
    if (newtrk > blktrk(CPM3ALVL * 4, parlist->blocksize[par])) {
        winmsg("Partition too large for CP/M 3.1", 5);
        prtwin(6, "   with a %dK block size",
               parlist->blocksize[par] / 1024);
        return (ERROR);
    }
    if (newtrk < minsize(parlist, par)) {
        winmsg("Too small to cover system overhead", 6);
        return (ERROR);
    }
    if (parlist->blocksize[par] == 1024) {
        if (dsm(newtrk, parlist->off[par], 1024) > 255) {
            winmsg("Too large for a 1K block size", 6);
            return (ERROR);
        }
    }
    if (newtrk > MAXTRK) {
        winmsg("WARNING - Too large for CP/M 2.2", 6);
        parlist->parsize[par] = newtrk;
        curoff();
        return (ERROR);
    }
    if (newtrk > blktrk(ALEN * 8, parlist->blocksize[par])) {
        winmsg("WARNING - Too large for CP/M 2.2", 5);
        prtwin(6, "     with a %dK block size",
               parlist->blocksize[par] / 1024);
        parlist->parsize[par] = newtrk;
        curoff();
        return (ERROR);
    }
    parlist->parsize[par] = newtrk;
    return (OK);
}

prtleft(phylist, parlist, par)
struct phyparm *phylist;
struct parstruct *parlist;
int par;
{
    unsigned maxsize(), maxsize3(), minsize(), spleft();
    char str1[20], str2[20], str3[20], *trk2str();

    curoff();
    trk2str(spleft(phylist, parlist, par), str1);
    prtwin(1, "Space left on lun %d: %sK     ", parlist->parlun[par],
           str1);
    trk2str(minsize(parlist, par), str1);
    trk2str(maxsize(phylist, parlist, par), str2);
    trk2str(maxsize3(phylist, parlist, par), str3);
    prtwin(2, "Minimum size: %sK     ", str1);
    prtwin(3, "Maximum CP/M 2.2 size: %sK     ", str2);
    prtwin(4, "Max CP/M 3.1: %sK if %dK blocks", str3,
           parlist->blocksize[par] / 1024);
    clreel();
    curon();
}

bls(parlist, curpos, ppar, pcol)        /* enters the block size  */
struct parstruct *parlist;      /* in the field from the screen */
int curpos[][NCOL], *ppar, *pcol;
{
    int n, temp, p, c, errflg;
    unsigned dsm();

    n = CRCD;
    winmsg("Valid block sizes: 1k 2k 4k 8k 16k", 1);
    while (n == UP || n == DOWN || n == CRCD) {
        errflg = OK;
        p = *ppar;
        c = *pcol;
        temp = parlist->blocksize[p] / 1024;
        cursor(curpos[*ppar][*pcol]);
        n = getnum(ppar, pcol, &temp, ACOL, parlist->numpar);
        winmsg("", 3);
        winmsg("", 4);
        if (n < LEFT)
            errflg = ERROR;
        else if (temp != parlist->blocksize[p] / 1024) {
            if (temp <= 1)
                temp = 1024;
            else if (temp <= 3)
                temp = 2048;
            else if (temp <= 6)
                temp = 4096;
            else if (temp <= 9)
                temp = 8192;
            else
                temp = 16384;
            if (temp == 1024
                && dsm(parlist->parsize[p], parlist->off[p], 1024) > 255) {
                winmsg("1K blocks too small for partition", 3);
                errflg = ERROR;
            } else if (dirblk(parlist->numdir[p], temp) > MAXDIRBLK) {
                prtwin(3, "%dK blocks too small for directory",
                       temp / 1024);
                errflg = ERROR;
            } else if (dsm(parlist->parsize[p], parlist->off[p], temp) +
                       1 > CPM3ALVL * 4) {
                prtwin(3, "%dK blocks too small", temp / 1024);
                prtwin(4, "for CP/M 3.1 partition");

                errflg = ERROR;
            } else if (parlist->parsize[p] <
                       minsize2(temp, parlist->numdir[p], parlist->off[p]))
            {
                prtwin(3, "%dK blocks too large for partition",
                       temp / 1024);
                errflg = ERROR;
            } else {
                parlist->blocksize[p] = temp;
                if (dsm(parlist->parsize[p], parlist->off[p], temp) + 1 >
                    ALEN * 8) {
                    prtwin(3, "WARNING - %dK blocks too small for",
                           temp / 1024);
                    prtwin(4, "    CP/M 2.2 partition");
                    errflg = ERROR;
                }
            }
            curoff();
            prtact(parlist, p, curpos);
        }
        if (errflg == ERROR) {
            bell();
            n = CRCD;
            *ppar = p;
            *pcol = c;
        }
        curoff();
        cursor(curpos[p][c]);
        printf("%-dK ", parlist->blocksize[p] / 1024);
        cursor(curpos[*ppar][*pcol]);
        curon();
    }
    clmn();
    return (n);
}

dirent(parlist, phylist, curpos, ppar, pcol)    /* enters the number of directory */
struct phyparm *phylist;
struct parstruct *parlist;      /* entries from the screen */
int curpos[][NCOL], *ppar, *pcol;
{
    int n, temp, p, c, maxent, errflg;

    n = CRCD;
    while (n == UP || n == DOWN || n == CRCD || n == RIGHT) {
        errflg = OK;
        p = *ppar;
        c = *pcol;
        temp = parlist->numdir[p];
        prtdir(parlist, phylist, p);
        cursor(curpos[*ppar][*pcol]);
        n = getnum(ppar, pcol, &temp, ACOL, parlist->numpar);
        winmsg("", 5);
        winmsg("", 6);
        if (n < CNTL && n != CRCD)
            errflg = ERROR;
        else if (temp != parlist->numdir[p]) {
            if (dirblk(temp, parlist->blocksize[p]) > MAXDIRBLK) {
                prtwin(5, "Too large for a %dK block size",
                       parlist->blocksize[p] / 1024);
                errflg = ERROR;
            } else if (phylist->typemed[parlist->parlun[p]] == 'R'
                       && temp > CPM3CSVL * 4) {
                winmsg("Directory too large for CPM 3.1", 5);
                winmsg("     with removable media", 6);
                errflg = ERROR;
            } else if (temp < MINDIRENT) {
                winmsg("Number below minimum", 5);
                errflg = ERROR;
            } else if (parlist->parsize[p] <
                       minsize2(parlist->blocksize[p], temp,
                                parlist->off[p])) {
                winmsg("Too large for partition", 5);
                errflg = ERROR;
            } else {
                parlist->numdir[p] = temp;
                if (phylist->typemed[parlist->parlun[p]] == 'R'
                    && temp > CSLEN * 4) {
                    winmsg("WARNING - Too large for CPM 2.2", 5);
                    winmsg("     with removable media", 6);
                    errflg = ERROR;
                }
                if (temp > CPM3DIR) {
                    winmsg("WARNING - Too large for CP/M 3.1", 5);
                    winmsg("Hash buffers are too small", 6);
                    errflg = ERROR;
                }
            }
            curoff();
            prtact(parlist, p, curpos);
        }
        if (errflg == ERROR) {
            bell();
            n = CRCD;
            *ppar = p;
            *pcol = c;
        }
        curoff();
        cursor(curpos[p][c]);
        printf(NUMW, parlist->numdir[p]);
        cursor(curpos[*ppar][*pcol]);
        curon();
    }
    clmn();
    return (n);
}

prtdir(parlist, phylist, par)   /* Prints min. and max directory entries */
struct parstruct *parlist;
struct phyparm *phylist;
int par;
{
    int maxent, maxent3;

    maxent3 = maxent = (parlist->blocksize[par] / DIRBYTES) * MAXDIRBLK;
    maxent =
        phylist->typemed[parlist->parlun[par]] == 'R' ? CSLEN * 4 : maxent;

    maxent3 = CPM3DIR <= maxent3 ? CPM3DIR : maxent3;
    maxent3 = phylist->typemed[parlist->parlun[par]] == 'R'
        && maxent3 > CPM3CSVL * 4 ? CPM3CSVL * 4 : maxent3;
    curoff();
    prtwin(1, "Minimum value: %d    ", MINDIRENT);
    prtwin(2, "Maximum CP/M 2.2 value: %d    ", maxent);
    prtwin(3, "Maximum CP/M 3.1 value: %d    ", maxent3);
    curon();
}

/* end of PARMENU1.C */
