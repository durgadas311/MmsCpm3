/* DEFSASI main menu functions
 *
 * "DEFSASI.C"
 * 
 * Date last modified: 07/18/84 08:34 drm
 */

#include "defsasi.h"

#define  MINMEM  0xA000         /* minimun TPA size */
#define  STLN	5               /* starting line of main menu */
#define  STRMN	STLN*getwidth()+1       /* start of main menu */
#define  STCOL	20              /* starting column of main menu */
#define  NLNE	8               /* number of main menu lines */

#define  OVERADR 0x4800         /* start of overlay area */

main(argc, argv)
int argc;                       /* number of arguments on command line */
char *argv[];                   /* pointer to list of arguments */
{
    struct phyparm mainlist;
    struct parstruct mparlist;
    char modname[15], codname[15], datname[15], outname[15], *errout(),
        *chgext();
    unsigned *wpt;
    int (*ovlayptr) (), er;

    if (bdos(GETVERS, 0) < 0x0030)
        cpm3flg = FALSE;
    else
        cpm3flg = TRUE;
    wpt = 6;
    wpt = *wpt - 6;
    if (wpt < MINMEM) {
        bell();
        puts("\nNot enough memory - will overwrite CP/M\n");
        return;
    }
    fdatflg = TRUE;
    datflg = initflg = dispflg = FALSE;
    ovlayptr = OVERADR;
    if (loadovl("DEFSASI3.OV1") == ERROR) {
        bell();
        puts("\nCan not load DEFSASI3.OV1\n");
        return;
    }
    if (cmpvers() == ERROR) {
        bell();
        puts("\nOverlay DEFSASI3.OV1 is wrong version\n");
        return;
    }
    gcurovl = 1;
    (*ovlayptr) (2, mainlist, mparlist);        /* initialize varaibles */
    datvers1 = atoi(RVERS);
    datvers2 = 0;
    initial();                  /* initialize terminal */
    clrscr();
    if (argc > 1) {
        /* First arg is used as *.COD or *.MOD as appropriate */
        strcpy(modname, argv[1]);
        strcpy(codname, argv[1]);
        if (argc > 2)
            /* Second arg, if supplied, is name of configuration file */
            strcpy(datname, argv[2]);
        else
            strcpy(datname, "DEFSASI3.DAT");
    } else {
        /* .REL driver for CP/M-3 */
        strcpy(codname, "DEFSASI3.COD");
        /* .HEX driver for CP/M-2 */
        strcpy(modname, "DEFSASI3.MOD");
        /* Saved configuration */
        strcpy(datname, "DEFSASI3.DAT");
    }
    getoutname(outname, mainlist, mparlist);
    ptmain(outname, datname);
    prtmcur();
    readdat(mainlist, mparlist, datname);       /* overlay already read in */
    getoutname(outname, mainlist, mparlist);
    ptmain(outname, datname);
    getmenus(mainlist, mparlist, datname, modname, codname, argc);
    cursor(23 * getwidth() + 1);
    deinit();                   /* deinitialize terminal */
}

ptmain(modname, datname)
char *modname;
char *datname;
{
    curoff();
    curhome();
    printf("DEFSASI3  v%s    (c) Magnolia Microsystems (%s terminal)\n\n\n",
           RVERS, termctrl.name);
    puts("                          M A I N  M E N U\n\n");
    puts("                   . Subsystem Data\n");
    if (fdatflg) {
        if (dispflg)
            printf("                   . Update '%s' file v%d.%03.3d\n",
                   datname, datvers1, datvers2);
        puts("                   . Partition Characteristics\n");
        puts("                   . Drive Initialization\n");
        if (cpm3flg)
            printf("                   . Write '%s.REL' CP/M 3 SASI module\n",
                   modname);
        else
            printf("                   . Write '%s.HEX' CP/M 2.24 SASI module\n",
                   modname);
        puts("                   . Exit to CPM\n");
        if (!cpm3flg)
            printf("                   . Write '%s.REL' CP/M 3 SASI module\n",
                   modname);
        else
            printf("                   . Write '%s.HEX' CP/M 2.24 SASI module\n",
                   modname);
        puts("                   . Drive Characteristics\n");
        if (!dispflg)
            printf("                   . Update '%s' file v%d.%03.3d\n",
                   datname, datvers1, datvers2);
    } else {
        puts("                   . Drive Characteristics\n");
        printf("                   . Update '%s' file v%d.%03.3d\n",
               datname, datvers1, datvers2);
        puts("                   . Partition Characteristics\n");
        puts("                   . Drive Initialization\n");
        if (cpm3flg)
            printf("                   . Write '%s.REL' CP/M 3 SASI module\n",
                   modname);
        else
            printf("                   . Write '%s.HEX' CP/M 2.24 SASI module\n",
                   modname);
        puts("                   . Exit to CPM\n");
        if (!cpm3flg)
            printf("                   . Write '%s.REL' CP/M 3 SASI module\n",
                   modname);
        else
            printf("                   . Write '%s.HEX' CP/M 2.24 SASI module\n",
                   modname);
    }
    curon();
}

getky(line, col, maxcol, maxlne)        /* used by many routines */
int *line, *col, maxcol, maxlne;
{
    int c;
    c = getkey();
    switch (c) {
    case CRCD:                 /* for "structure" only */
        break;
    case DOWN:
        if (*line < maxlne - 1)
            ++(*line);
        break;
    case UP:
        if (*line > 0)
            --(*line);
        break;
    case RIGHT:
        if (*col < maxcol - 1)
            ++(*col);
        break;
    case LEFT:
        if (*col > 0)
            --(*col);
        break;
    case HMCD:
        *line = *col = 0;
        break;
    default:
        break;
    }
    return (c);
}

getmenus(mainlist, mparlist, datname, modname, codname, argc)
struct phyparm *mainlist;
struct parstruct *mparlist;
char *datname, *modname, *codname;
int argc;
{
    int lun, t, inp, line, dum, er, curpos[NLNE];
    int (*ovlayptr) ();         /* pointer to overlay functions */
    char outname[15], *errout();

    initcur(curpos, STLN, NLNE, STCOL, 1, 0);
    line = 0;
    ovlayptr = OVERADR;

    while (TRUE) {
        curon();
        cursor(curpos[line]);
        inp = 0;
        while (inp != CRCD) {
            cursor(curpos[line]);
            inp = getky(&line, &dum, 1, NLNE);
            if (inp != CRCD && inp != DOWN && inp != HMCD && inp != UP)
                bell();
        }
        clmn();
        if (fdatflg) {
            if (dispflg) {
                switch (line + 1) {
                case 1:
                    subsyst(mainlist, mparlist);
                    break;
                case 2:
                    writdat(datname, mainlist);
                    break;
                case 3:
                    parchar(mainlist, mparlist);
                    --line;
                    break;
                case 4:
                    initfunc(mainlist, mparlist);
                    --line;
                    break;
                case 5:
                    if (cpm3flg)
                        writerel(mainlist, mparlist, codname, outname);
                    else
                        writehex(mainlist, mparlist, modname, outname,
                                 argc);
                    break;
                case 6:
                    return;
                case 7:
                    if (!cpm3flg)
                        writerel(mainlist, mparlist, codname, outname);
                    else
                        writehex(mainlist, mparlist, modname, outname,
                                 argc);
                    break;
                case 8:
                    drvchar(mainlist, mparlist);
                    --line;
                    break;
                default:
                    break;
                }
            } else {
                switch (line + 1) {
                case 1:
                    subsyst(mainlist, mparlist);
                    break;
                case 2:
                    parchar(mainlist, mparlist);
                    break;
                case 3:
                    initfunc(mainlist, mparlist);
                    break;
                case 4:
                    if (cpm3flg)
                        writerel(mainlist, mparlist, codname, outname);
                    else
                        writehex(mainlist, mparlist, modname, outname,
                                 argc);
                    break;
                case 5:
                    return;
                case 6:
                    if (!cpm3flg)
                        writerel(mainlist, mparlist, codname, outname);
                    else
                        writehex(mainlist, mparlist, modname, outname,
                                 argc);
                    break;
                case 7:
                    drvchar(mainlist, mparlist);
                    break;
                case 8:
                    writdat(datname, mainlist);
                    --line;
                    break;
                default:
                    break;
                }
            }
        } else {
            switch (line + 1) {
            case 1:
                subsyst(mainlist, mparlist);
                break;
            case 2:
                drvchar(mainlist, mparlist);
                break;
            case 3:
                writdat(datname, mainlist);
                break;
            case 4:
                parchar(mainlist, mparlist);
                break;
            case 5:
                initfunc(mainlist, mparlist);
                break;
            case 6:
                if (cpm3flg)
                    writerel(mainlist, mparlist, codname, outname);
                else
                    writehex(mainlist, mparlist, modname, outname, argc);
                break;
            case 7:
                return;
            case 8:
                if (!cpm3flg)
                    writerel(mainlist, mparlist, codname, outname);
                else
                    writehex(mainlist, mparlist, modname, outname, argc);
                break;
            default:
                break;
            }
        }
        getoutname(outname, mainlist, mparlist);
        ptmain(outname, datname);
        prtmcur();
        if (line < NLNE - 1)
            ++line;
    }
}

readdat(mainlist, mparlist, filename)
struct phyparm *mainlist;
struct parstruct *mparlist;
char *filename;
{
    int (*ovlayptr) (), i;

    ovlayptr = OVERADR;
    prtwin(1, "Reading data file ");
    i = (*ovlayptr) (1, mainlist, mparlist, filename);
    curoff();
    if (i == ERROR) {
        if (errno() == 11)
            winmsg("Creating new a data file", 1);
        else {
            winmsg(errmsg(errno()), 3);
            bell();
        }
        return;
    }
    if (i == NULL) {
        winmsg("File too big--out of memory", 3);
        bell();
        return;
    }
    clmn();
}

subsyst(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    int (*ovlayptr) ();

    ovlayptr = OVERADR;
    if (swapovl(1) != ERROR)
        (*ovlayptr) (3, mainlist, mparlist);
    if (initflg)
        dispflg = FALSE;
    else
        dispflg = TRUE;
}

parchar(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    int (*ovlayptr) ();

    ovlayptr = OVERADR;
    if (swapovl(2) != ERROR)
        (*ovlayptr) (1, mainlist, mparlist);
    if (initflg)
        dispflg = FALSE;
    else
        dispflg = TRUE;
}

initfunc(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    int (*ovlayptr) ();

    ovlayptr = OVERADR;
    if (swapovl(3) != ERROR)
        (*ovlayptr) (1, mainlist, mparlist, "DEFSASI3.BOT");
    if (initflg)
        dispflg = FALSE;
    else
        dispflg = TRUE;
}

drvchar(mainlist, mparlist)
struct phyparm *mainlist;
struct parstruct *mparlist;
{
    int (*ovlayptr) ();

    ovlayptr = OVERADR;
    if (swapovl(5) != ERROR)
        (*ovlayptr) (1, mainlist, mparlist);
    if (initflg)
        dispflg = FALSE;
    else
        dispflg = TRUE;
}

writehex(mainlist, mparlist, modname, outname, argc)
struct phyparm *mainlist;
struct parstruct *mparlist;
char *modname, *outname;
int argc;
{
    int er, (*ovlayptr) ();
    char c, inname[15];

    prtwin(1, "Continue? (Y or N) N\b");
    c = inchar();
    if (toupper(c) != 'Y')
        return;
    if (swapovl(4) == ERROR)
        return;
    ovlayptr = OVERADR;
    getoutname(outname, mainlist, mparlist);
    if (testz67(mainlist) && argc <= 1)
        strcpy(inname, "DEFSASI3.Z67");
    else
        strcpy(inname, modname);
    strcat(outname, ".HEX");
    winmsg("", 1);
    prtwin(1, "Writing %s CP/M 2.24 module ", outname);
    makold(outname);
    er = (*ovlayptr) (1, mainlist, mparlist, inname, outname);
    if (er < NULL && er != HEOF) {
        winmsg(errout(er), 3);
        bell();
    } else
        clmn();
}

writerel(mainlist, mparlist, codname, outname)
struct phyparm *mainlist;
struct parstruct *mparlist;
char *codname, *outname;
{
    int er, (*ovlayptr) ();
    char c;

    prtwin(1, "Continue? (Y or N) N\b");
    c = inchar();
    if (toupper(c) != 'Y')
        return;
    if (swapovl(4) == ERROR)
        return;
    ovlayptr = OVERADR;
    getoutname(outname, mainlist, mparlist);
    strcat(outname, ".REL");
    winmsg("", 1);
    prtwin(1, "Writing %s CP/M 3 module ", outname);
    makold(outname);
    er = (*ovlayptr) (2, mainlist, mparlist, outname, codname);
    if (er < NULL) {
        winmsg(errout(er), 3);
        bell();
    } else
        clmn();
}

writdat(filename, phylist)
struct phyparm *phylist;
char *filename;
{
    int (*ovlayptr) (), er;
    char c;

    prtwin(1, "Continue? (Y or N) N\b");
    c = inchar();
    if (toupper(c) != 'Y')
        return;
    if (swapovl(5) == ERROR)
        return;
    ovlayptr = OVERADR;
    winmsg("", 1);
    prtwin(1, "Writing data file ");
    (*ovlayptr) (2, filename, phylist);
    initflg = TRUE;             /* forces the MAIN MENU to be normal */
    if (er == ERROR) {
        winmsg(errmsg(errno()), 3);
        bell();
        return;
    }
    if (er == NULL) {
        winmsg("Can't update file--out of memory", 3);
        bell();
        return;
    }
    clmn();
}

swapovl(overlay)
int overlay;
{
    char name[20];

    strcpy(name, "DEFSASI3.OV");
    name[11] = overlay + '0';
    name[12] = NULL;
    if (gcurovl != overlay) {
        winmsg("", 1);
        prtwin(1, "Loading overlay %s ", name);
        if (loadovl(name) == ERROR) {
            winmsg("", 3);
            prtwin(3, "Can not load overlay %s", name);
            bell();
            return (ERROR);
        }
        gcurovl = overlay;
    }
    if (cmpvers() == ERROR) {
        winmsg("", 3);
        prtwin(3, "Overlay %s is wrong version", name);
        bell();
        return (ERROR);
    }
    clmn();
    return (OK);
}

loadovl(name)
char *name;
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
            if (swapin(filename, OVERADR) == ERROR) {
                if (errno() != 11)
                    return (ERROR);
            } else
                return (OK);
        }
        return (ERROR);
    } else
        return (swapin(name, OVERADR));
}

cmpvers()
{
    char *(*ovlayptr) ();

    ovlayptr = OVERADR;
    if (strcmp(RVERS, (*ovlayptr) (0)) == NULL)
        return (NULL);
    else
        return (ERROR);
}

getoutname(outname, phylist, parlist)
struct phyparm *phylist;
struct parstruct *parlist;
char *outname;
{
    int i;

    strcpy(outname, "M320");
    if (testZ67(phylist))
        outname[0] = 'Z';
    outname[4] = 'F';
    for (i = 0; i < phylist->numlun; i++)
        if (phylist->typemed[i] == 'R')
            outname[4] = 'R';
    outname[5] = parlist->numpar + '0';
    outname[6] = phylist->numlun + '0';
    outname[7] = phylist->contrnum + '0';
    outname[8] = NULL;
}

/* end of DEFSASI.C */
