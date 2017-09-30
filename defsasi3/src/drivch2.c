/* Drivch2 of the DEFSASI program
 * It contains the print and screen 
 * routines for the drive chararcteristic data
 * used by a XEBEC controller and 
 * the initialize drive command used by
 * other controllers
 * 
 * "DRIVCH2.C"
 *
 * Dated last updated: 07/17/84 14:35 drm
 *
 */

#include "defsasi.h"
#define NUMW	"%-13.13d"
#define NUMH	"%02.2x"
#define FWIDTH	"%24.24s\n"
#define NLNE	13
#define STXL	9
#define MAXCOL	4

prtxmenu()
{
    printf("%-s\n", "Drive characteristic data");
    printf(FWIDTH, "Reduce write cyl. : ");
    printf(FWIDTH, "Write precomp. cyl. : ");
    printf(FWIDTH, "ECC data burst length : ");
}

initmenu()
{
    printf(FWIDTH, "Initialize     Opcode : ");
    printf(FWIDTH, "drive         Byte #1 : ");
    printf(FWIDTH, "command       Byte #2 : ");
    printf(FWIDTH, "Byte #3 : ");
    printf(FWIDTH, "Byte #4 : ");
    printf(FWIDTH, "Byte #5 : ");
}

prtxlun(phylist, curpos, lun)
struct phyparm *phylist;
int curpos[][MAXCOL], lun;
{
    int line, t;
    for (t = 0, line = STXL + 1; t < 3; t++, line++) {
        cursor(curpos[line][lun]);
        printf(NUMW, phylist->drivch[lun][t]);
    }
}

prtinitlun(phylist, curpos, lun)
struct phyparm *phylist;
int curpos[][MAXCOL], lun;
{
    int line, t;
    for (t = 0, line = STXL; t < 6; t++, line++) {
        cursor(curpos[line][lun]);
        printf(NUMH, phylist->assigndata[lun][t]);
    }
}

drivchdata(phylist, curpos, pline, plun)
struct phyparm *phylist;
int curpos[][MAXCOL], *pline, *plun;
{
    int n, lin, l, c, temp;

    *pline = STXL + 1;
    cursor(curpos[*pline][*plun]);
    winmsg("See XEBEC controller manual", 1);
    winmsg("for more information", 2);
    do {
        l = *pline;
        c = *plun;
        lin = *pline - (STXL + 1);
        temp = phylist->drivch[*plun][lin];
        cursor(curpos[*pline][*plun]);
        n = getnum(pline, plun, &temp, phylist->numlun, STXL + 4);
        if ((lin == 2 && temp > 20) || (n < CNTL && n != CRCD))
            bell();
        else
            phylist->drivch[c][lin] = temp;
        curoff();
        cursor(curpos[l][c]);
        printf(NUMW, phylist->drivch[c][lin]);
        cursor(curpos[*pline][*plun]);
        curon();
    }
    while (n != RED && n != BLUE && n != WHITE && *pline >= STXL + 1);
    clmn();
    if (n != HMCD)
        *pline = STXL - 1;
    cursor(curpos[*pline][*plun]);
    return (n);
}

initdata(phylist, curpos, pline, plun)
struct phyparm *phylist;
int curpos[][MAXCOL], *pline, *plun;
{
    int lin, n, l, c, temp;

    winmsg("See controller manual for more information", 1);
    winmsg("Note: this field is in HEX format", 3);
    do {
        l = *pline;
        c = *plun;
        lin = *pline - STXL;
        temp = phylist->assigndata[*plun][lin];
        cursor(curpos[*pline][*plun]);
        n = gethex(pline, plun, &temp, phylist->numlun, STXL + 6);
        if (temp > 255 || (n < CNTL && n != CRCD))
            bell();
        else
            phylist->assigndata[c][lin] = temp;
        curoff();
        cursor(curpos[l][c]);
        printf(NUMH, phylist->assigndata[c][lin]);
        cursor(curpos[*pline][*plun]);
        curon();
    }
    while (n != RED && n != BLUE && n != WHITE && *pline >= STXL);
    clmn();
    return (n);
}

enterhex(phylist, curpos, pline, plun, fnum, max)       /* enters a hex number into */
struct phyparm *phylist;        /* the field determined by fnum */
int curpos[][MAXCOL], *pline, *plun, fnum, max;
{
    int n, temp, l, c, maxcol, *getipt();

    do {
        l = *pline;
        c = *plun;
        temp = *getipt(phylist, fnum, *plun);
        maxcol = fnum >= 2 ? phylist->numlun : 1;
        cursor(curpos[*pline][*plun]);
        n = gethex(pline, plun, &temp, maxcol, NLNE);
        if (temp > max || (n < CNTL && n != CRCD)) {
            bell();
            *pline = l;
            *plun = c;
        } else
            *getipt(phylist, fnum, c) = temp;
        curoff();
        cursor(curpos[l][c]);
        printf(NUMH, *getipt(phylist, fnum, c));
        cursor(curpos[*pline][*plun]);
        curon();
    }
    while (n == RIGHT || n == LEFT);
    clmn();
    return (n);
}

gethex(pline pcol, pdata, maxcol, maxlne)       /* gets a hex number from the */
int *pline, *pcol, *pdata, maxcol, maxlne;      /* the screen and puts in */
{                               /* pdata if it's ok  */
    unsigned inp, pt, flag;
    char str[4];
    pt = 0;
    flag = TRUE;
    while (flag == TRUE) {
        inp = toupper(getky(pline, pcol, maxcol, maxlne));
        if (inp == BS) {
            if (pt-- <= 0)
                pt = 0;
            else {
                curoff();
                puts("\010     \010\010\010\010\010");
                curon();
            }
        } else if ((inp >= '0' && inp <= '9')
                   || (inp >= 'A' && inp <= 'F')) {
            if (pt >= 2)
                pt = 2;
            else {
                str[pt++] = inp;
                outchr(inp);
            }
        } else
            flag = FALSE;
    }
    str[pt] = NULL;
    if (pt > 0)
        sscanf(str, "%x", pdata);
    return (inp);
}

/* end of DRIVCH2.C */
