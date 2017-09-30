/*
 * DEFSASI program common functions - must be in root segment
 * 
 * Date last modified: 07/18/84 08:25 drm
 *
 */

#include "defsasi.h"
#define STMN0 (18*getwidth()+1) /* start of menus in col 0 */
#define STMN (STMN0+42)         /* start of submenu window */

testxebec(phylist)
struct phyparm *phylist;
{
    return (cmpstr(phylist->contrmfg, "XEBEC"));
}

testz67(phylist)
struct phyparm *phylist;
{
    return (cmpstr(phylist->contrmfg, "DTC(Z67)"));
}

cmpstr(s1, s2)
char *s1, *s2;
{
    while (*s2) {
        while (*s1 == ' ')
            ++s1;
        if (toupper(*s1) != *s2)
            return (FALSE);
        ++s1;
        ++s2;
    }
    return (TRUE);
}

getnum(pline pcol, pdata, maxcol, maxlne)       /* gets a number from the */
int *pline, *pcol, *pdata, maxcol, maxlne;      /* the screen and puts in */
{                               /* pdata if it's ok  */
    unsigned inp, pt, flag;
    char str[6];

    pt = 0;
    flag = TRUE;
    while (flag == TRUE) {
        inp = getky(pline, pcol, maxcol, maxlne);
        if (inp == BS) {
            if (pt-- <= 0)
                pt = 0;
            else {
                curoff();
                puts("\010     \010\010\010\010\010");
                curon();
            }
        } else if (inp >= '0' && inp <= '9') {
            if (pt >= 4)
                pt = 4;
            else {
                str[pt++] = inp;
                outchr(inp);
            }
        } else
            flag = FALSE;
    }
    str[pt] = NULL;
    if (pt > 0)
        *pdata = atoi(str);
    return (inp);
}

initcur(curpos, stline, nline, stcol, ncol, colwid)     /* initializes the cursor  */
int *curpos;                    /* array.   */
int stline;                     /* starting line of screen */
int nline;                      /* number of lines on screen */
int stcol;                      /* starting column of screen */
int ncol;                       /* number of columns  */
int colwid;                     /* column width (all columns are the same) */
{
    int lpos, cpos, col, ln;
    for (lpos = (stline * getwidth()) + stcol, ln = 0; ln < nline;
         lpos += getwidth(), ln++)
        for (cpos = lpos, col = 0; col < ncol; cpos += colwid, col++)
            *(curpos + (ln * ncol) + col) = cpos;
}

ptcurmenu()
{                               /* prints cursor menu for menu1 menu2 and menu3 */
    prtcur();
}                               /* translation to routine in TERM.C */

clmn()
{                               /* clears submenu area on screen */
    int i;
    curoff();
    for (i = 0; i < (getlength() - (STMN / getwidth()) + 1); i++) {
        cursor((i * getwidth()) + STMN);
        clreel();
    }
    curon();
}

winmsg(strpt, linenum)          /* prints a unformated message in the window */
char *strpt;
int linenum;
{
    curoff();
    cursor(STMN + (getwidth() * (linenum - 1)));
    clreel();
    puts(strpt);
    curon();
}

prtwin(linenum, format)         /* prints a formated message in the window */
char *format;
int linenum;
{
    int outchr();

    cursor(STMN + ((linenum - 1) * getwidth()));
    _spr(&format, &outchr);     /* formated output libaray function */
}

curs(line, col)
char line, col;
{
    cursor((line - 1) * getwidth() + STMN + col);
}

makold(oldfile)
char *oldfile;
{
    char tmpfile[15], *chgext();
    strcpy(tmpfile, oldfile);
    unlink(chgext(tmpfile, ".OLD"));
    rename(oldfile, tmpfile);
}

char *chgext(filename, ext)
char *filename, *ext;
{
    int i;

    for (i = 0; filename[i] != '.' && filename[i] != NULL; ++i);
    filename[i] = NULL;
    strcat(filename, ext);
    return (filename);
}

char *errout(er)
int er;
{
    char *errout();
    switch (er) {
    case ERROR:
        if (errno() != 1)
            return (errmsg(errno()));
    case ERR1:
        return ("Invalid hex file format");
    case ERR2:
        return ("Invalid hex digit");
    case ERR3:
        return ("Incorrect check sum digit");
    default:
        return;
    }
}

cpyphy(phylist1, phylist2)      /* copy phyparm structures  */
struct phyparm *phylist1;       /* phylist1=phylist2  */
struct phyparm *phylist2;
{
    movmem(phylist2, phylist1, sizeof *phylist1);
}

fopens(name, iobuf)             /* uses the drive search order path */
char *name, *iobuf;             /* when running CP/M 3 */
{
    int drv;
    unsigned adr;
    char filename[20], scbpd[4];

    if (cpm3flg) {
        for (adr = DRVSC; adr <= DRVSC + 3; ++adr) {
            scbpd[0] = adr;
            scbpd[1] = 0;
            drv = bdos(GETSCB, scbpd) & 0xFF;
            if (drv == 0xFF)
                break;
            if (drv == 0)
                drv = bdos(GETDSK, 0) + 1;
            filename[0] = drv + 'A' - 1;
            filename[1] = ':';
            filename[2] = NULL;
            strcat(filename, name);
            if (fopen(filename, iobuf) == ERROR) {
                if (errno() != 11) {
                    return (ERROR);
                }
            } else
                return (OK);
        }
        return (ERROR);
    } else
        return (fopen(name, iobuf));
}

setibit(datlist)                /* Sets bit 8 of controller mfg to indicate */
struct datfile *datlist;        /* the default drive and controller when */
{                               /* defsasi starts. */
    datlist->dcontrmfg[0] |= 0x80;
}

clribit(datlist)                /* Clears the init bit */
struct datfile *datlist;
{
    datlist->dcontrmfg[0] &= 0x7F;
}

#define LCOLW 16
#define LNLN 5

prtcol(msg, pos)
char *msg;
int pos;
{
    int tpos, temp;
    tpos = STMN;
    temp = pos - 1;
    if (pos > LNLN * 3 || pos == NULL)
        return (ERROR);
    curoff();
    while (temp >= LNLN) {
        tpos += LCOLW;
        temp -= LNLN;
    }
    tpos += temp * getwidth();
    cursor(tpos);
    if (pos <= 9)
        printf("%-d. %-13.13s", pos, msg);
    else
        printf("%-c. %-13.13s", (pos - 10) + 'A', msg);
    curon();
    return (OK);
}

prtmcur()
{
    cursor(STMN0);
    puts("ENTER  = Execute functions\n");
    puts("<UP>   = Move up a line\n");
    puts("<DOWN> = Move down a line\n");
    puts("<HOME> = Jump to top line");
    return (0);
}

prtcur(f)
char *f;
{
    cursor(STMN0);
    printf("%-11.11s = End and update %s\n", termctrl.f6name, f);
    printf("%-11.11s = Quit (No update)\n", termctrl.f7name);
    printf("%-11.11s = Restart with original data\n", termctrl.f8name);
    puts("ARROWS      = Move to next field\n");
    puts("HOME        = Jump to top line");
    return (0);
}

/* end of COMFUN.C */
