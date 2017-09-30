/* Data file functions for DEFSASI prog
 *
 * "WRITDAT.C"
 * 
 * Date last updated: 12/5/83  9:40 mjm
 *
 */

/*  writdatfile()  writes the data pointed to by datarray[]
 *
 *  writrec()	   writes a record (a datfile structure)
 *		   
 *  dwrit()	   does the lower level file I/O fuction
 *
 *  getfpt()	   returns a pointer to a datfile structure in free
 *		   memory. Uses alloc() to get the free memory.
 *		   returns a NULL if there is no more room in memory
 *		   or in datarray[].
 *
 *  insertdat()    inserts data from a phyparm struct into memory 
 *		   checks for duplicate controller mfg, mod, vers,
 *		   and drive mfg, model replacing the duplicate
 *		   with the new data.
 *  cmplists()	   used by insertdat() to compare the data.
 * 
 *  cpylists()	   copys data from or to a phyparm struct to a datfile struct
 *  
 */

#include "defsasi.h"

writdatfile(filename, phylist)
struct phyparm *phylist;
char *filename;
{
    char iobuf[BUFSIZ];
    int i;

    if (insertdat(phylist) == NULL)
        return (NULL);
    if (fcreat(filename, iobuf) == ERROR)
        return (ERROR);
    if (datflg) {               /* if drive data has been changed *//* increment the version number */
        ++datvers2;
        datflg = FALSE;
    }
    fprintf(iobuf, VERDAT, datvers1, datvers2);
    i = writrec(iobuf);
    putc(CPMEOF, iobuf);
    fclose(iobuf);
    return (i);                 /* returns same as readfile */
}

writrec(iobuf)
char *iobuf;
{
    int t, i;

    for (i = 0; i < _endarr && i < MAXREC; i++) {
        t = dwrit(iobuf, datarray[i]);
        if (t == ERROR)
            return (ERROR);
    }
    return (1);
}

dwrit(iobuf, fpt)
struct datfile *fpt;
char *iobuf;
{
    int i;

    i = fprintf(iobuf, CFTDAT, fpt->dcontrmfg, fpt->dcontrmod,
                fpt->dcontrver, fpt->dsizesect);
    if (i == ERROR)
        return (ERROR);
    i = fprintf(iobuf, DFTDAT, fpt->ddrivemfg, fpt->ddrivemod,
                fpt->dtypemed);
    if (i == ERROR)
        return (ERROR);
    i = fprintf(iobuf, NFTDAT, fpt->dnumcyl, fpt->dnumheads, fpt->dsectrk,
                fpt->dcontbyte, fpt->ddrivcont, fpt->dileavfac,
                fpt->dexfort, fpt->dexdtest);
    if (i == ERROR)
        return (ERROR);
    i = fprintf(iobuf, A1FTDAT, fpt->ddrivch[0], fpt->ddrivch[1],
                fpt->ddrivch[2], fpt->ddrivch[3]);
    if (i == ERROR)
        return (ERROR);
    i = fprintf(iobuf, A2FTDAT, fpt->dassigndata[0],
                fpt->dassigndata[1] & 0x1F, fpt->dassigndata[2],
                fpt->dassigndata[3], fpt->dassigndata[4],
                fpt->dassigndata[5]);
    if (i == ERROR)
        return (ERROR);
    return (1);
}

insertdat(phylist)
struct phyparm *phylist;
{
    int i, lun, flag;
    struct datfile *getfpt(), *fpt;

    for (lun = 0; lun < phylist->numlun; lun++) {
        if (cmpinit(phylist, lun)) {
            for (i = 0, flag = TRUE; i < _endarr && i < MAXREC; i++) {  /* Search for dup data  */
                if (cmplists(phylist, datarray[i], lun)) {
                    cpylists(phylist, datarray[i], lun);
                    if (lun == 0)
                        setibit(datarray[i]);   /* Set init bit  for the dup */
                    flag = FALSE;
                } else if (lun == 0)
                    clribit(datarray[i]);
            }
            if (flag) {
                fpt = getfpt();
                if (fpt == NULL)
                    return (NULL);
                cpylists(phylist, fpt, lun);
                if (lun == 0)
                    setibit(fpt);
            }
        }
    }
    return (1);
}

cmpinit(phylist, lun)
struct phyparm *phylist;
int lun;
{
    if (strcmp(phylist->contrmfg, INITFLD) == NULL)
        return (FALSE);
    if (strcmp(phylist->contrmod, INITFLD) == NULL)
        return (FALSE);
    if (strcmp(phylist->drivemfg[lun], INITFLD) == NULL)
        return (FALSE);
    if (strcmp(phylist->drivemod[lun], INITFLD) == NULL)
        return (FALSE);
    return (TRUE);
}

cmplists(phylist, datlist, lun)
struct phyparm *phylist;
struct datfile *datlist;
int lun;
{
    char temp[STRSIZE];

    strcpy(temp, datlist->dcontrmfg);
    temp[0] &= 0x7F;
    if (strcmp(phylist->contrmfg, temp) != NULL)
        return (FALSE);
    if (strcmp(phylist->contrmod, datlist->dcontrmod) != NULL)
        return (FALSE);
    if (strcmp(phylist->contrver, datlist->dcontrver) != NULL)
        return (FALSE);
    if (strcmp(phylist->drivemfg[lun], datlist->ddrivemfg) != NULL)
        return (FALSE);
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

    datlist->dtypemed = phylist->typemed[lun];
    strcpy(datlist->dcontrmfg, phylist->contrmfg);
    strcpy(datlist->dcontrmod, phylist->contrmod);
    strcpy(datlist->dcontrver, phylist->contrver);
    datlist->dsizesect = phylist->sizesect;
    strcpy(datlist->ddrivemfg, phylist->drivemfg[lun]);
    strcpy(datlist->ddrivemod, phylist->drivemod[lun]);
    datlist->dnumcyl = phylist->numcyl[lun];
    datlist->dnumheads = phylist->numheads[lun];
    datlist->dsectrk = phylist->sectrk[lun];
    datlist->dcontbyte = phylist->contbyte[lun];
    datlist->ddrivcont = phylist->drivcont[lun];
    datlist->dileavfac = phylist->ileavfac[lun];
    datlist->dexfort = phylist->exfort[lun];
    datlist->dexdtest = phylist->exdtest[lun];
    for (temp = 0; temp < 3; temp++)
        datlist->ddrivch[temp] = phylist->drivch[lun][temp];
    for (temp = 0; temp < 6; temp++)
        datlist->dassigndata[temp] = phylist->assigndata[lun][temp];
    datlist->dassigndata[1] = phylist->assigndata[lun][1] & 0x1F;
}

struct datfile *getfpt()
{                               /* get a pointer to a datfile struct *//* in memory and update datarray[] */
    struct datfile dumdat;

    if (_endarr >= MAXREC) {
        return (NULL);
    }
    datarray[_endarr] = alloc(sizeof(dumdat));
    if (datarray[_endarr] == NULL) {
        return (NULL);
    }
    return (datarray[_endarr++]);
}
