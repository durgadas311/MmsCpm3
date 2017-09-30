/* Data functions for DEFSASI prog
 *
 * "LISTDAT.C"
 *
 * Date last updated: 07/17/84 14:35 drm
 *
 */

/*  cmplists()	   used by listdat() to compare the data.
 * 
 *  cpylists()	   copys data from or to a phyparm struct to a datfile struct
 *  
 *  datsearch()    searchs the data file in memory and puts it into the phylist
 *
 *  dsearch()	   searchs the data file in memory for all luns to match
 *
 *  listdat()	   lists the data in memory on screen (formated) for menu1
 *
 *  cpyfld()	   copys the selected data into any field in a phyparm struct
 * 
 *  prtcol()	   prints the data for listdat() on screen in rows
 *
 *  getdpt()	   returns a pointer to the selected field in a phyparm struct
 *
 */

#include "defsasi.h"


cmplists(phylist, datlist, lun, level)
struct phyparm *phylist;
struct datfile *datlist;
int lun, level;
{
    char temp[STRSIZE];

    strcpy(temp, datlist->dcontrmfg);
    temp[0] &= 0x7F;
    if (level <= 0)
        return (TRUE);
    if (strcmp(phylist->contrmfg, temp) != NULL)
        return (FALSE);
    if (level <= 1)
        return (TRUE);
    if (strcmp(phylist->contrmod, datlist->dcontrmod) != NULL)
        return (FALSE);
    if (level <= 2)
        return (TRUE);
    if (strcmp(phylist->contrver, datlist->dcontrver) != NULL)
        return (FALSE);
    if (level <= 3)
        return (TRUE);
    if (strcmp(phylist->drivemfg[lun], datlist->ddrivemfg) != NULL)
        return (FALSE);
    if (level <= 4)
        return (TRUE);
    if (strcmp(phylist->drivemod[lun], datlist->ddrivemod) != NULL)
        return (FALSE);
    return (TRUE);
}

cpylists(phylist, datlist, lun) /* copies structs */
struct phyparm *phylist;
struct datfile *datlist;
int lun;
{
    int temp;

    phylist->typemed[lun] = datlist->dtypemed;
    strcpy(phylist->contrmfg, datlist->dcontrmfg);
    phylist->contrmfg[0] &= 0x7F;
    strcpy(phylist->contrmod, datlist->dcontrmod);
    strcpy(phylist->contrver, datlist->dcontrver);
    phylist->sizesect = datlist->dsizesect;
    strcpy(phylist->drivemfg[lun], datlist->ddrivemfg);
    strcpy(phylist->drivemod[lun], datlist->ddrivemod);
    phylist->numcyl[lun] = datlist->dnumcyl;
    phylist->numheads[lun] = datlist->dnumheads;
    phylist->sectrk[lun] = datlist->dsectrk;
    phylist->contbyte[lun] = datlist->dcontbyte;
    phylist->drivcont[lun] = datlist->ddrivcont;
    phylist->ileavfac[lun] = datlist->dileavfac;
    phylist->exfort[lun] = datlist->dexfort;
    phylist->exdtest[lun] = datlist->dexdtest;
    for (temp = 0; temp < 3; temp++)
        phylist->drivch[lun][temp] = datlist->ddrivch[temp];
    for (temp = 0; temp < 6; temp++)
        phylist->assigndata[lun][temp] = datlist->dassigndata[temp];
}

datsearch(phylist, lun)
struct phyparm *phylist;
int lun;
{
    int i;

    for (i = 0; i < _endarr && i < MAXREC; i++) {
        if (cmplists(phylist, datarray[i], lun, 5) == TRUE) {
            cpylists(phylist, datarray[i], lun);
            break;
        }
    }
}

dsearch(phylist)                /* searchs dat file in memory */
struct phyparm *phylist;        /* for a match; if any of the luns */
{                               /* don't match return a FALSE */
    int i, lun, exit;           /* else if all the luns match */
    /* return TRUE */
    for (lun = 0; lun < phylist->numlun; ++lun) {
        for (i = 0, exit = FALSE; i < _endarr && i < MAXREC; ++i) {
            if (cmplists(phylist, datarray[i], lun, 5) == TRUE) {
                exit = TRUE;
                break;
            }
        }
        if (exit == FALSE)
            break;
    }
    return (exit);
}

listfile(phylist, lun, fnum)
struct phyparm *phylist;
int lun, fnum;
{
    int endr, t, i, flag;
    char *getdpt();

    endr = 0;
    for (t = 0; t < _endarr; t++) {
        if (cmplists(phylist, datarray[t], lun, fnum) == TRUE) {
            for (i = 0, flag = FALSE; i < endr; i++) {
                if (strcmp
                    (getdpt(listarr[i], fnum),
                     getdpt(datarray[t], fnum)) == NULL)
                    flag = TRUE;
            }
            if (flag == FALSE)
                listarr[endr++] = datarray[t];
        }
    }
    for (t = 0; t < endr; t++) {
        if ((prtcol(getdpt(listarr[t], fnum), t + 1)) == ERROR) {
            endr = t;
            break;
        }
    }
    prtcol("Other", t + 1);
    return (endr);
}

cpyfld(phylist, lun, linum, fnum)
struct phyparm *phylist;
int lun, linum, fnum;
{
    strcpy(getppt(phylist, fnum, lun), getdpt(listarr[linum - 1], fnum));
}

char *getdpt(datpt, fnum)       /* gets a point to a field  */
struct datfile *datpt;          /* in a datfile struct  */
int fnum;                       /* determined by fnum  */
{
    switch (fnum) {
    case 0:
        clribit(datpt);
        return (datpt->dcontrmfg);
    case 1:
        return (datpt->dcontrmod);
    case 2:
        return (datpt->dcontrvers);
    case 3:
        return (datpt->ddrivemfg);
    case 4:
        return (datpt->ddrivemod);
    default:
        return (datpt->dcontrmfg);
    }
}

/* end of LISTDAT.C */
