/* Drivch1 of DEFSASI program. This section displays 
 * modifies the physical parameters of the drives.
 * It takes of copy of the phyparm struct
 * from the main menu and modifies it's local copy
 * allowing the user to exit without updating
 * the main list.
 *
 * "DRIVCH1.C"
 * 
 * Date last modified: 07/18/84 08:27 drm
 *
 */

#include "defsasi.h"

/* These definations are for the screen format of menu #1 */

#define VERS "00"

#define FWIDTH "%24.24s\n"      /* field width of headings  */
#define NUMW   "%-13.13d"       /* field defination for numbers */
#define NUMH   "%02.2x"         /* field defination for hex numbers */
#define STRW   "%-13.13s"       /* field defination for string */
#define NLNE   15               /* number of lines of data on screen */
#define NCOL   4                /* number of columns on screen */
#define STLNE  2                /* starting line number */
#define STCOL  25               /* starting column number */
#define COLW   13               /* column width */
#define MAXCOL NCOL

drivch1(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    struct phyparm phylist;
    int curpos[NLNE][MAXCOL], lun, c;

    cpyphy(phylist, mainlist);
    initcur(curpos, STLNE, NLNE, STCOL, NCOL, COLW);
    ptdrmenu(phylist);
    for (lun = 0; lun < phylist.numlun; lun++) {
        phylist.assigndata[lun][1] |= lun << 5;
        ptlun(phylist, curpos, lun);
    }
    ptcurmenu();
    c = getdata2(phylist, mainlist, curpos);
    if (testxebec(phylist))
        setmem(&phylist.assigndata, 4 * 6 * 2, 0);
    else
        setmem(&phylist.drivch, 4 * 3 * 2, 0);
    if (c == BLUE) {
        cpyphy(mainlist, phylist);
        initpar(mainlist, mparlist);
        datflg = TRUE;
    }
    clrscr();
}


ptdrmenu(phylist)
struct phyparm *phylist;
{
    char *getvers();

    clrscr();
    printf("                     Drive Characteristics  v%s.%s\n\n",
           getvers(), VERS);
    cursor(STLNE * getwidth() + 1);
    printf(FWIDTH, "Logicial unit number : ");
    printf(FWIDTH, "Type of media : ");
    printf(FWIDTH, "Number of cylinders : ");
    printf(FWIDTH, "Number of heads : ");
    printf(FWIDTH, "Sectors per track : ");
    printf(FWIDTH, "Control byte : ");
    printf(FWIDTH, "Interleave factor : ");
    printf(FWIDTH, "Expected format time : ");
    printf(FWIDTH, "Exp. disk test time : ");
    if (testxebec(phylist))
        prtxmenu();
    else
        initmenu();
}

ptlun(phylist, curpos, lun)     /* prints the colunm of LUN's */
struct phyparm *phylist;        /* determined by lun */
int curpos[][MAXCOL], lun;
{
    int line;

    line = 0;
    cursor(curpos[line++][lun]);
    printf(NUMW, lun);
    pttypmed(phylist, curpos, lun, line++);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->numcyl[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->numheads[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->sectrk[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMH, phylist->contbyte[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->ileavfac[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->exfort[lun]);
    cursor(curpos[line++][lun]);
    printf(NUMW, phylist->exdtest[lun]);
    if (testxebec(phylist))
        prtxlun(phylist, curpos, lun);
    else
        prtinitlun(phylist, curpos, lun);
}

pttypmed(phylist, curpos, lun, line)    /* print the type of media field */
struct phyparm *phylist;
int curpos[][MAXCOL], lun, line;
{
    cursor(curpos[line][lun]);
    switch (phylist->typemed[lun]) {
    case 'F':
        puts("Fixed    ");
        break;
    case 'R':
        puts("Removable");
        break;
    default:
        break;
    }
}

getdata2(phylist, mainlist, curpos)     /* this function does the actual */
struct phyparm *phylist;        /* field editing of the physical */
int curpos[][MAXCOL];           /* parmeter structure */
struct phyparm *mainlist;
{
    int curline, curlun, n, l;
    curline = 1;
    curlun = n = 0;
    cursor(curpos[1][0]);
    while (n != RED && n != BLUE) {
        switch (curline) {
        case 0:
            curline = 1;
            break;
        case 1:                /* type of media field */
            n = tmed(phylist, curpos, &curline, &curlun);
            break;
        case 2:                /* number of cylinders field */
            winmsg("See drive manual for more information", 1);
            n = enternum(phylist, curpos, &curline, &curlun, 2, 9999);
            break;
        case 3:                /* number of heads */
            winmsg("Maximun number of heads is 16", 1);
            winmsg("See drive manual for more information", 2);
            n = enternum(phylist, curpos, &curline, &curlun, 3, 16);
            break;
        case 4:                /* physical sectors per track */
            winmsg("Maximum number of sector per track: 64", 1);
            winmsg("See drive or controller manual", 2);
            winmsg("for more information", 3);
            n = enternum(phylist, curpos, &curline, &curlun, 4, 64);
            break;
        case 5:                /* control byte */
            winmsg("Last byte of controller command", 1);
            winmsg("See controller manual for more information", 2);
            winmsg("Note: this field is HEX format", 4);
            n = enterhex(phylist, curpos, &curline, &curlun, 5, 255);
            break;
        case 6:
            curoff();
            prtwin(1, "Maximum interleave factor: %d",
                   phylist->sectrk[curlun]);
            curon();
            n = enternum(phylist, curpos, &curline, &curlun, 7,
                         phylist->sectrk[curlun]);
            break;
        case 7:
            winmsg("Highest expected format time: 255", 1);
            winmsg("Determined by doing a trial disk format", 2);
            n = enternum(phylist, curpos, &curline, &curlun, 8, 255);
            break;
        case 8:
            winmsg("Highest expected disk test time: 255", 1);
            winmsg("Determined by doing a trial disk test", 2);
            n = enternum(phylist, curpos, &curline, &curlun, 9, 255);
            break;
        case 9:
        case 10:               /* drive characteristic data */
        case 11:               /* if XEBEC controller  else */
        case 12:               /* initialize drive command  */
        case 13:
        case 14:
            if (testxebec(phylist))
                n = drivchdata(phylist, curpos, &curline, &curlun);
            else
                n = initdata(phylist, curpos, &curline, &curlun);
        default:
            break;
        }
        if (n == WHITE) {
            cpyphy(phylist, mainlist);
            for (l = 0; l < phylist->numlun; l++)
                ptlun(phylist, curpos, l);
            curline = 1;
            curlun = 0;
        }
        cursor(curpos[curline][curlun]);
    }
    return (n);
}

tmed(phylist, curpos, curline, curlun)  /* controls type of media field */
struct phyparm *phylist;
int curpos[][MAXCOL], *curline, *curlun;
{
    int n, flag, l;
    flag = TRUE;
    winmsg("F = Fixed hard disk", 1);
    winmsg("R = Removable hard disk", 2);
    while (flag == TRUE) {
        l = *curline;
        cursor(curpos[*curline][*curlun]);
        n = getky(curline, curlun, phylist->numlun, NLNE);
        cursor(curpos[*curline][*curlun]);
        switch (n) {
        case RIGHT:
        case LEFT:
            break;
        case 'r':
        case 'R':
            phylist->typemed[*curlun] = 'R';
            break;
        case 'f':
        case 'F':
            phylist->typemed[*curlun] = 'F';
            break;
        default:
            flag = FALSE;
            if (n < CNTL && n != CRCD)
                bell();
            break;
        }
        curoff();
        pttypmed(phylist, curpos, *curlun, l);
        cursor(curpos[*curline][*curlun]);
        curon();
    }
    clmn();
    return (n);
}

enternum(phylist, curpos, pline, plun, fnum, max)       /* enters a number into */
struct phyparm *phylist;        /* the field determined by fnum */
int curpos[][MAXCOL], *pline, *plun, fnum, max;
{
    int n, temp, l, c, maxcol, *getipt();
    do {
        l = *pline;
        c = *plun;
        temp = *getipt(phylist, fnum, *plun);
        maxcol = (fnum >= 2 ? phylist->numlun : 1);
        cursor(curpos[*pline][*plun]);
        n = getnum(pline, plun, &temp, maxcol, NLNE);
        if (temp > max || (n < CNTL && n != CRCD)) {
            bell();
            *pline = l;
            *plun = c;
        } else
            *getipt(phylist, fnum, c) = temp;
        curoff();
        cursor(curpos[l][c]);
        printf(NUMW, *getipt(phylist, fnum, c));
        cursor(curpos[*pline][*plun]);
        curon();
    }
    while (n == RIGHT || n == LEFT || (n < CNTL && n != CRCD));
    clmn();
    return (n);
}

int *getipt(phypt, fnum, lun)
struct phyparm *phypt;
int fnum, lun;
{
    switch (fnum) {
    case 0:
        return (&phypt->contrnum);
    case 1:
        return (&phypt->sizesect);
    case 2:
        return (&phypt->numcyl[lun]);
    case 3:
        return (&phypt->numheads[lun]);
    case 4:
        return (&phypt->sectrk[lun]);
    case 5:
        return (&phypt->contbyte[lun]);
    case 6:
        return (&phypt->drivcont[lun]);
    case 7:
        return (&phypt->ileavfac[lun]);
    case 8:
        return (&phypt->exfort[lun]);
    case 9:
        return (&phypt->exdtest[lun]);
    default:
        return (&phypt->contrnum);
    }
}

/* end of DRIVCH1.C */
