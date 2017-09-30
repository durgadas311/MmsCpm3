/* Subsystem menu of DEFSASI program. This section displays 
 * and allows the user to select the controller mfg, model
 * version, and the drive mfg and model.
 * It takes of copy of the phyparm struct
 * from the main menu and modifies it's local copy
 * allowing the user to exit without updating
 * the main parameter list in main function.
 *
 * "SUBSYS.C"
 * 
 * Date last modified: 07/18/84 08:57 drm
 *
 */

#include "defsasi.h"

/* These definations are for the screen format of menu #1 */

#define VERS "00"

#define FIELDW	12              /* Field width of input strings */
#define FWIDTH "%24.24s\n"      /* field width of headings  */
#define NUMW   "%-13.13d"       /* field defination for numbers */
#define STRW   "%-13.13s"       /* field defination for string */
#define NLNE   9                /* number of lines of data on screen */
#define NCOL   4                /* number of columns on screen */
#define STLNE  4                /* starting line number */
#define STCOL  25               /* starting column number */
#define COLW   13               /* column width */

subsys(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    struct phyparm phylist;
    int curpos[NLNE][NCOL], c, i;

    cpyphy(phylist, mainlist);
    initcur(curpos, STLNE, NLNE, STCOL, NCOL, COLW);
    ptmenu1();
    prtm1data(phylist, curpos);
    for (i = 0; i < phylist.numlun; i++)
        prtlun(phylist, curpos, i);
    ptcurmenu();
    c = getdata(phylist, mainlist, curpos);
    if (c == BLUE)
        cpyphy(mainlist, phylist);
    if ((fdatflg = dsearch(mainlist)) == FALSE) {       /* Search all luns in datfile */
        setmem(mainlist->typemed, 4, 'F');      /* re-initialized phylist */
        setmem(mainlist->numcyl, 8 * 4 * 2, 0); /* 8 fields 4 colmuns 2 bytes */
        setmem(mainlist->drivch, 4 * 3 * 2, 0);
        setmem(mainlist->assigndata, 4 * 6 * 2, 0);
        datflg = TRUE;
    }
    if (c == BLUE)
        initpar(mainlist, mparlist);    /* Do partition initialize */
    clrscr();
}

ptmenu1()
{
    char *getvers();

    clrscr();
    printf("                     Subsystem Data v%s.%s\n\n", getvers(),
           VERS);
    cursor(STLNE * getwidth() + 1);
    printf(FWIDTH, "Controller number : ");
    printf(FWIDTH, "Controller mfg : ");
    printf(FWIDTH, "Model : ");
    printf(FWIDTH, "Version : ");
    puts("\n");
    printf(FWIDTH, "Logicial unit number : ");
    printf(FWIDTH, "Drive mfg : ");
    printf(FWIDTH, "Model : ");
    printf(FWIDTH, "Physical sector size : ");
}

prtm1data(phylist, curpos)      /* Prints the controller header info */
struct phyparm *phylist;
int curpos[][NCOL];
{
    int line;

    line = 0;
    cursor(curpos[line++][0]);
    printf(NUMW, phylist->contrnum);
    cursor(curpos[line++][0]);
    printf(STRW, phylist->contrmfg);
    cursor(curpos[line++][0]);
    printf(STRW, phylist->contrmod);
    cursor(curpos[line++][0]);
    printf(STRW, phylist->contrver);
    prtphysect(phylist, curpos);
}

prtlun(phylist, curpos, lun)    /* prints the colunm of LUN's */
struct phyparm *phylist;        /* determined by lun */
int curpos[][NCOL], lun;
{
    int line;

    line = 5;
    cursor(curpos[line++][lun]);
    printf(NUMW, lun);
    cursor(curpos[line++][lun]);
    printf(STRW, phylist->drivemfg[lun]);
    cursor(curpos[line++][lun]);
    printf(STRW, phylist->drivemod[lun]);
}

prtphysect(phylist, curpos)
struct phyparm *phylist;
int curpos[][NCOL];
{
    cursor(curpos[8][0]);
    printf(NUMW, phylist->sizesect);
}

clearlun(lun, curpos)
int curpos[][NCOL], lun;
{
    int line;
    if (lun != NCOL - 1) {
        for (line = 5; line < NLNE - 1; line++) {
            cursor(curpos[line][lun + 1]);
            clreel();
        }
    }
}

getdata(phylist, mainlist, curpos)      /* this function does the actual */
struct phyparm *phylist;        /* field editing of the physical */
int curpos[][NCOL];             /* parmeter structure */
struct phyparm *mainlist;
{
    int curline, curlun, n, i;
    curline = curlun = n = 0;
    cursor(curpos[0][0]);
    while (n != RED && n != BLUE) {
        switch (curline) {
        case 0:                /* controller number */
            winmsg("Maximum value: 7", 1);
            n = enternum(phylist, curpos, &curline, &curlun, 0, 7);
            break;
        case 1:                /* controller mfg  */
            n = enterfld(phylist, curpos, &curline, &curlun, 0);
            break;
        case 2:                /* controller model */
            n = enterfld(phylist, curpos, &curline, &curlun, 1);
            break;
        case 3:                /* controller vers */
            n = enterfld(phylist, curpos, &curline, &curlun, 2);
            break;
        case 4:
            if (n == UP) {
                curline--;
                curlun = 0;
            } else if (n == DOWN || n == CRCD)
                curline++;
            break;
        case 5:                /* logical unit number */
            n = lunfield(phylist, curpos, &curline, &curlun);
            break;
        case 6:                /* drive mfg */
            n = enterfld(phylist, curpos, &curline, &curlun, 3);
            break;
        case 7:                /* drive model */
            n = enterfld(phylist, curpos, &curline, &curlun, 4);
            break;
        case 8:
            winmsg("See controller manual for information", 1);
            winmsg("Valid sector sizes: 256 or 512", 2);
            curlun = 0;
            n = enternum(phylist, curpos, &curline, &curlun, 1, 9999);
            if (phylist->sizesect > 400)
                phylist->sizesect = 512;
            else
                phylist->sizesect = 256;
            prtphysect(phylist, curpos);
            break;
        default:
            break;
        }
        if (n == WHITE) {
            cpyphy(phylist, mainlist);
            prtm1data(phylist, curpos);
            curline = curlun = 0;
            for (i = 0; i < phylist->numlun; i++)
                prtlun(phylist, curpos, i);
            clearlun(phylist->numlun - 1, curpos);
        }
        cursor(curpos[curline][curlun]);
    }
    return (n);
}

lunfield(phylist, curpos, curline, curlun)      /* controls the LUN field */
struct phyparm *phylist;
int curpos[][NCOL], *curline, *curlun;
{
    int n, flag, lunmax;
    flag = TRUE;
    winmsg("<DELETE> = deletes one logical unit", 1);
    winmsg("<+>      = adds one logical unit", 2);
    if (testxebec(phylist))
        lunmax = XEBMAX;
    else
        lunmax = MAXLUN;
    while (flag == TRUE) {
        cursor(curpos[*curline][*curlun]);
        n = getky(curline, curlun, phylist->numlun, NLNE);
        cursor(curpos[*curline][*curlun]);
        switch (n) {
        case '+':
            if (++(phylist->numlun) > lunmax)
                phylist->numlun = lunmax;
            else
                prtlun(phylist, curpos, (phylist->numlun) - 1);
            break;
        case RIGHT:
            break;
        case LEFT:
            break;
        case DELETE:
            if (--(phylist->numlun) < 1)
                phylist->numlun = 1;
            else
                clearlun((phylist->numlun) - 1, curpos);
            if ((*curlun) > (phylist->numlun) - 1)
                *curlun = (phylist->numlun) - 1;
            break;
        default:
            flag = FALSE;
            if (n == LEFT || n == RIGHT || (n < CNTL && n != CRCD))
                bell();
            break;
        }
        cursor(curpos[*curline][*curlun]);
    }
    clmn();
    return (n);
}


enterfld(phylist, curpos, pline, plun, fnum)    /* enter data into field */
struct phyparm *phylist;        /* determined by fnum code */
int curpos[][NCOL], *pline, *plun, fnum;
{
    int n, ln, c, i, arrend, lnum, maxcol, maxlne;
    do {
        lnum = 0;
        ln = *pline;
        c = *plun;
        arrend = listfile(phylist, *plun, fnum);
        maxcol = fnum >= 3 ? phylist->numlun : 1;
        maxlne = *plun == 0 ? NLNE : NLNE - 1;
        cursor(curpos[*pline][*plun]);
        n = getky(pline, plun, maxcol, maxlne);
        if (n >= CNTL || n == CRCD)
            break;
        if (isdigit(n))
            lnum = n - '0';
        else if (toupper(n) >= 'A' && toupper(n) <= 'Z')
            lnum = (toupper(n) - 'A') + 10;
        else
            lnum = NULL;
        if (lnum <= arrend + 1 && lnum != NULL) {
            if (lnum != arrend + 1)
                cpyfld(phylist, *plun, lnum, fnum);
            else {
                clmn();
                winmsg("Enter data", 1);
                cursor(curpos[*pline][*plun]);
                n = getstr(pline, plun, getppt(phylist, fnum, *plun),
                           phylist->numlun, maxlne);
                clmn();
            }
            if (testxebec(phylist)) {
                for (i = 0; i < XEBMAX; i++) {  /*if xebec make all lun same */
                    strcpy(getppt(phylist, fnum, i),
                           getppt(phylist, fnum, c));
                    datsearch(phylist, i);
                }
                curoff();
                for (i = 0; i < (fnum >= 3 ? phylist->numlun : 1); i++) {
                    cursor(curpos[ln][i]);
                    printf(STRW, getppt(phylist, fnum, i));
                }
            } else {
                datsearch(phylist, *plun);
                curoff();
                cursor(curpos[ln][c]);
                printf(STRW, getppt(phylist, fnum, c));
            }
            prtphysect(phylist, curpos);
        } else
            bell();
        cursor(curpos[*pline][*plun]);
        curon();
    }
    while ((n < CNTL && n != CRCD) || n == LEFT || n == RIGHT);
    clmn();
    return (n);
}

char *getppt(phypt, fnum, lun)  /* gets a pointer to a field */
struct phyparm *phypt;          /* in a phyparm  struct */
int fnum;                       /* determined by fnum */
{
    switch (fnum) {
    case 0:
        return (phypt->contrmfg);
    case 1:
        return (phypt->contrmod);
    case 2:
        return (phypt->contrver);
    case 3:
        return (phypt->drivemfg[lun]);
    case 4:
        return (phypt->drivemod[lun]);
    default:
        return (phypt->contrmfg);
    }
}

enternum(phylist, curpos, pline, plun, fnum, max)       /* enters the a number into */
struct phyparm *phylist;        /* the field determined by fnum */
int curpos[][NCOL], *pline, *plun, fnum, max;
{
    int n, temp, l, c, maxcol, *getipt();

    do {
        l = *pline;
        c = *plun;
        temp = *getipt(phylist, fnum, *plun);
        maxcol = fnum >= 3 ? phylist->numlun : 1;
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
    while (n == LEFT || n == RIGHT || (n < CNTL && n != CRCD));
    clmn();
    return (n);
}

int *getipt(phypt, fnum, lun)   /* get a pointer to a field */
struct phyparm *phypt;
int fnum, lun;
{
    switch (fnum) {
    case 0:
        return (&phypt->contrnum);
    case 1:
        return (&phypt->sizesect);
    default:
        return (&phypt->contrnum);
    }
}

getstr(pline, pcol, pdata, maxcol, maxlne)      /* get a string from the screen */
int *pline, *pcol, maxcol, maxlne;
char *pdata;
{
    unsigned inp, pt, flag, t;
    char str[FIELDW + 2];

    pt = 0;
    flag = TRUE;
    strcpy(str, pdata);
    while (flag == TRUE) {
        inp = getky(pline, pcol, maxcol, maxlne);
        if (inp == BS) {
            if (pt-- <= 0)
                pt = 0;
            else
                outchr(BS);
            for (t = 0; t < FIELDW - pt; t++)
                outchr(' ');
            for (t = 0; t < FIELDW - pt; t++)
                outchr(BS);
        } else {
            if (inp >= ' ' && inp <= 'z' && inp != ';') {
                if (pt >= FIELDW)
                    pt = FIELDW;
                else {
                    str[pt++] = inp;
                    outchr(inp);
                }
            } else
                flag = FALSE;
        }
    }
    if (pt != 0)
        str[pt] = NULL;
    if (inp < CNTL && inp != CRCD)
        bell();
    else
        strcpy(pdata, str);
    return (inp);
}
