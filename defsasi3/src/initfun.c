/*
 * INITFUN contains the functions to test and 
 * initialize a SASI drive 
 * Uses rdwrthex.c functions to read the boot loader hex file
 *
 * "INITFUN.C"
 *
 * Dated last updated: 07/18/84 08:42 drm
 *  
 */

#include "defsasi.h"

#define VERS "01"
#define RAMCHK	0               /* initsasi() command codes */
#define DRVCHK	1
#define OUTCERR 2
#define INSPEC	3
#define FORMAT	4
#define VERIFY	5
#define CONFIG	6
#define CLRDIR	7
#define BUFADR	8
#define CONCHK	9
#define CLRST	10
#define GETPORT 11
#define PUTLUN	12
#define PUTCNUM 13
#define GETSECS 14
#define GETSEN	15
#define GETERS	16

#define NOERRCD 0               /* No error */
#define NRDYMSG 1               /* Controller not ready */
#define PRTMSG1 2               /* SW105 wrong */
#define PRTMSG2 3               /* SW105 wrong */
#define DNRMSG	4               /* Drive not ready */
#define PRECONF 5               /* Magic sector has been configued */
#define CERR	6               /* Controller errror */
#define VERR	7               /* Verify error */
#define NOTSUP	8               /* Controller does not support dianogics error msg */
#define READER	9               /* read sector zero error */
#define SECER	10              /* Sector size error */
#define NOTHING 11              /* Do nothing error msg */

#define DIRSEC	8               /* number of logical (128 byte) sectors CLRDIR clears */
#define BOOTOFF 512             /* Offset to start of boot loader on magic sector */

#define STLNE	4               /* screen format defines */
#define NLNE	6
#define STCOL	23
#define NCOL	4
#define COLW	15
#define STM	(STLNE*getwidth()+1)
#define FMAT	"%22.22s\n"

initfun(phylist, parlist, filename)
struct phyparm *phylist;
struct parstruct *parlist;
char *filename;
{
    int curpos[NLNE][NCOL];

    clrscr();
    fmtflg = FALSE;
    initcur(curpos, STLNE, NLNE, STCOL, NCOL, COLW);
    inmenu();
    initlun(phylist, curpos);
    initcmenu();
    getcommand(phylist, parlist, curpos, filename);
    clrscr();
}

inmenu()
{
    char *getvers(), *getmach();

    printf("                       Drive Initialization v%s.%s\n",
           getvers(), VERS);
    printf("                            for %s computer", getmach());
    cursor(STM);
    printf(FMAT, "Logical Unit Number : ");
    printf(FMAT, "Test Controller : ");
    printf(FMAT, "Format Drive : ");
    printf(FMAT, "Test Drive : ");
    printf(FMAT, "Initialize Drive : ");
    printf(FMAT, "Clear Directories : ");
}

initcmenu()
{
    curoff();
    prtmcur();                  /* let COMFUN determine menu placement */
    printf("\n%-11.11s = exit to main menu", termctrl.f6name);
    curon();
}

initlun(phylist, curpos)
int curpos[][NCOL];
struct phyparm *phylist;
{
    int i, j;

    for (i = 0; i < phylist->numlun; i++) {
        for (j = 0; j < 6; ++j) {
            cursor(curpos[j][i]);
            if (j == 0)
                printf("%d", i);
            else if (!testxebec(phylist) && (j == 1 || j == 3))
                puts("Not Supported");
            else
                puts(".");
        }
    }
}

getcommand(phylist, parlist, curpos, filename)
struct phyparm *phylist;
struct parstruct *parlist;
int curpos[][NCOL];
char *filename;
{
    int inp, line, col, er;

    line = 1;
    col = inp = 0;
    while (inp != RED && inp != BLUE) {
        inp = initsasi(GETPORT);
        if (inp < NULL)
            initerrmsg(1, inp);
        initsasi(PUTCNUM, phylist->contrnum);
        inp = 0;
        while (inp != CRCD && inp != RED && inp != BLUE) {
            cursor(curpos[line][col]);
            inp = getky(&line, &col, phylist->numlun, NLNE);
            if (line == 0)
                line = 1;
            if (inp < CNTL && inp != CRCD)
                bell();
        }
        if (inp == RED || inp == BLUE)
            break;
        clmn();
        initsasi(PUTLUN, col);
        putbuf(phylist, parlist, col);
        switch (line) {
        case 1:
            er = testcontr(phylist, curpos, col);
            break;
        case 2:
            er = formatdr(phylist, parlist, curpos, col);
            break;
        case 3:
            er = testdriv(phylist, curpos, col);
            break;
        case 4:
            er = inishal(phylist, parlist, filename, curpos, col);
            break;
        case 5:
            er = cleardir(phylist, parlist, curpos, col);
            break;
        default:
            return;
        }
        switch (er) {
        case NOERRCD:
            prtnoerr(line, col, curpos);
            break;
        case NOTHING:
            break;
        default:
            prterror(line, col, curpos);
            initerrmsg(1, er);
        }
        if (line < NLNE - 1)
            ++line;
    }
}

testcontr(phylist, curpos, col)
struct phyparm *phylist;
int curpos[][NCOL], col;
{
    int i;

    if (testxebec(phylist)) {
        winmsg("", 1);
        prtwin(1, "Testing controller ");
        if ((i = initsasi(CLRST)) == NOERRCD)
            if ((i = initsasi(RAMCHK)) == NOERRCD)
                i = initsasi(CONCHK);
    } else {
        winmsg("Controller has no diagnostics", 1);
        i = NOTHING;
    }
    return (i);
}

formatdr(phylist, parlist, curpos, col)
struct phyparm *phylist;
struct parstuct *parlist;
int curpos[][NCOL], col;
{
    int i, line, count, lasterr, firsterr, maxtrk, errcnt;
    unsigned secsiz;

    line = 1;
    if ((i = initsasi(CLRST)) != NOERRCD)
        return (i);
    if ((i = destroymsg(&line, phylist, parlist, col)) != NOERRCD)
        return (i);
    curoff();
    linpos = line;
    if (phylist->exfort[col] != NULL) {
        prtwin(line++, "Formatting (est. time %d-%d) ",
               phylist->exfort[col], phylist->exfort[col] + 2);
        colpos = 31;
    } else {
        prtwin(line++, "Formatting drive ");
        colpos = 17;
    }
    if ((i = initsasi(FORMAT, phylist->ileavfac[col])) != NULL)
        return (i);
    fmtflg = TRUE;
    secsiz = initsasi(GETSECS);
    if (secsiz == 0xFFFF)
        return (READER);
    if (secsiz != (phylist->sizesect / LSIZE))
        return (SECER);
    if (testz67(phylist))
        return (NOERRCD);
    curoff();
    prtwin(line++, "Verifying track number ");
    maxtrk = phylist->numheads[col] * phylist->numcyl[col];
    for (count = errcnt = lasterr = firsterr = 0; count < maxtrk; count++) {
        printf("%d", count);
        curs(line - 1, 23);
        i = initsasi(VERIFY, phylist->sectrk[col], phylist->ileavfac[col]);
        if (i == VERR) {
            if (errcnt == 0) {
                firsterr = count;
                prtwin(line, "First bad track: %d", firsterr);
                curs(line - 1, 23);
            }
            lasterr = count;
            errcnt++;
        }
    }
    curon();
    if (errcnt > 0) {
        prtwin(line++, "First bad track: %d   Last: %d", firsterr,
               lasterr);
        prtwin(line, "Number of bad tracks: %d", errcnt);
        prterror(2, col, curpos);
    } else
        prtnoerr(2, col, curpos);
    return (NOTHING);
}

REPOS()
{
    curs(linpos, colpos);
}                               /* used by PRTCNT in INITSASI.CSM */

testdriv(phylist, curpos, col)
struct phyparm *phylist;
int curpos, col;
{
    int i;

    if (testxebec(phylist)) {
        linpos = 1;
        if (phylist->exdtest[col] != 0) {
            prtwin(1, "Testing (est. time %d-%d) ", phylist->exdtest[col],
                   phylist->exdtest[col] + 2);
            colpos = 29;
        } else {
            prtwin(1, "Testing drive ");
            colpos = 15;
        }
        if ((i = initsasi(CLRST)) == NOERRCD) {
            curoff();
            i = initsasi(DRVCHK);
            curon();
        }
    } else {
        winmsg("Controller has no diagnostics", 1);
        i = NOTHING;
    }
    return (i);
}

inishal(phylist, parlist, filename, curpos, col)
int curpos[][NCOL], col;
char *filename;
{
    int i, er, line;

    line = 1;
    if ((i = initsasi(CLRST)) != NOERRCD)
        return (i);
    if ((i = destroymsg(&line, phylist, parlist, col)) != NOERRCD)
        return (i);
    prtwin(line++, "Reading %s ", filename);
    er = readboot(filename);    /* reads boot loader and puts in buffer */
    if (er < NULL) {
        winmsg(errout(er), line);
        prterror(4, col, curpos);
        return (NOTHING);
    }
    prtwin(line++, "Writing initialization data ");
    i = initsasi(CONFIG);
    return (i);
}

readboot(filename)
char *filename;
{
    int i, er, count, data[17];
    char iobuf[BUFSIZ], *bufpt, *initsasi();
    unsigned addr;

    er = NULL;
    if (fopens(filename, iobuf) == ERROR)
        return (ERROR);
    bufpt = initsasi(BUFADR) + BOOTOFF;
    while (er >= NULL) {
        er = inrec(iobuf, &addr, &count, data); /* in rdwrthex.c */
        if (er == HEOF)
            break;
        if (er < NULL)
            return (er);
        for (i = 0; i < count; i++) {
            *(bufpt++) = data[i];
        }
    }
    fclose(iobuf);
    return (OK);
}

cleardir(phylist, parlist, curpos, col)
struct phyparm *phylist;
struct parstruct *parlist;
int curpos[][NCOL], col;
{
    int i, line;

    line = 1;
    if (!fmtflg) {
        winmsg("Continuing will DESTROY any data on the drive", line++);
        prtwin(line++, "Clear the directories? (Y or N) N\b");
        i = inchar();
        if (toupper(i) != 'Y')
            return (NOTHING);
    }
    prtwin(line, "Clearing directories ");
    if ((i = initsasi(CLRST)) == NOERRCD)
        i = doclear(phylist, parlist, col);
    clmn();
    return (i);
}

doclear(phylist, parlist, lun)
struct phyparm *phylist;
struct parstruct *parlist;
int lun;
{
    unsigned par, in, numsec, seccnt;
    LONG phyadd, diradd, paradd, temp, temp2;

    itol(paradd, STARTSEC);
    for (par = 0; par < parlist->numpar; par++) {
        if (lun == parlist->parlun[par]) {
            ladd(diradd, paradd, itol(temp, (parlist->off[par] * LSPT)));
            numsec =
                dirblk(parlist, par) * (parlist->blocksize[par] / LSIZE);
            for (seccnt = 0; seccnt < numsec / DIRSEC; seccnt++) {
                ldiv(phyadd, diradd,
                     itol(temp, phylist->sizesect / LSIZE));
                in = initsasi(CLRDIR, phyadd);
                if (in != NULL)
                    return (in);
                ladd(diradd, diradd, itol(temp, DIRSEC));
            }
            itol(temp, parlist->parsize[par]);
            itol(temp2, LSPT);
            lmul(temp, temp, temp2);
            ladd(paradd, paradd, temp);
        }
    }
    return (NOERRCD);
}

prterror(line, col, curpos)
int line, col, curpos[][NCOL];
{
    curoff();
    cursor(curpos[line][col]);
    puts("ERROR     ");
    curon();
}

prtnoerr(line, col, curpos)
int line, col, curpos[][NCOL];
{
    curoff();
    cursor(curpos[line][col]);
    puts("NO ERRORS ");
    curon();
}

destroymsg(ptline, phylist, parlist, col)
struct phyparm *phylist;
struct parstruct *parlist;
int *ptline, col;
{
    int c;

    c = initsasi(INSPEC);
    if (c == PRECONF) {
        winmsg("Drive previously initialized", (*ptline)++);
        winmsg("Continuing DESTROYS any data on drive", (*ptline)++);
        winmsg("", *ptline);
        prtwin((*ptline)++, "Continue? (Y or N) N\b");
        c = inchar();
        if (toupper(c) != 'Y')
            c = NOTHING;
        else {
            clmn();
            *ptline = 1;
            winmsg("Data has been destroyed", (*ptline)++);
            c = NOERRCD;
        }
    } else
        c = NOERRCD;
    putbuf(phylist, parlist, col);      /* reinitialize the buffer */
    return (c);
}

initerrmsg(line, c)
int line, c;
{
    char *bptr, *initsasi();

    bell();
    switch (c) {
    case NRDYMSG:
        winmsg("Controller not ready", line);
        break;
    case CERR:
        if (initsasi(GETSEN) != NULL) {
            winmsg("Controller not ready", line);
            break;
        }
        winmsg("Controller reported error:", line++);
        winmsg(initsasi(OUTCERR), line++);
        bptr = initsasi(GETERS);
        winmsg("", line);
        prtwin(line, "Sense bytes: %02.2x %02.2x %02.2x %02.2x", *bptr,
               *(bptr + 1), *(bptr + 2), *(bptr + 3));
        break;
    case PRTMSG1:
        winmsg("SW501 set wrong-no port selected", line);
        break;
    case PRTMSG2:
        winmsg("SW501 setting does not match port", line);
        break;
    case DNRMSG:
        winmsg("Drive not ready", line);
        break;
    case READER:
        winmsg("Read error", line);
        break;
    case SECER:
        winmsg("Controller sector size jumper wrong", line++);
        winmsg("Correct error and reformat drive", line);
        break;
    default:
        break;
    }
}

/* end of INITFUN.C */
