/* Data file reading functions for DEFSASI prog
 *
 * "READDAT.C"
 *
 * Date last updated: 12/9/83  9:25 mjm
 *
 */

/*  readdatfile()  reads data file and puts the data in free memory
 *		   also updates datarray[] which is an array of 
 *		   pointers to the data read in.
 *
 *  readrec	   reads or a record (a datfile structure)
 *		   
 *  dread(),	   does the lower level file I/O fuction
 *
 *  getfpt()	   returns a pointer to a datfile structure in free
 *		   memory. Uses alloc() to get the free memory.
 *		   returns a NULL if there is no more room in memory
 *		   or in datarray[].
 */

#include "defsasi.h"


readdatfile(phylist, parlist, filename)
struct phyparm *phylist;
struct parstruct *parlist;
char *filename;
{
    char iobuf[BUFSIZ], temp[6];
    int i;

    _endarr = NULL;
    if (fopens(filename, iobuf) == ERROR)
        return (ERROR);
    fscanf(iobuf, RVERDAT, &datvers1, temp);
    datvers2 = atoi(temp);
    do {
        i = readrec(phylist, parlist, iobuf);
    }
    while (i != ERROR && i != NULL);
    fclose(iobuf);
    if (i == ERROR && (errno() == 1 || errno() == 0))
        return (1);
    return (i);                 /* returns ERROR if file error */
}                               /* returns NULL if memory or */

                                        /* datarray[] overflow */
readrec(phylist, parlist, iobuf)
struct phyparm *phylist;
struct parstruct *parlist;
char *iobuf;
{
    struct datfile *fpt;        /* pointer to a datfile struct */
    struct datfile *getfpt();   /* function returns a pointer ... */
    int i;

    fpt = getfpt();             /* get a pointer to a blank datfile */
    if (fpt == NULL)            /*  struct and update datarray[] */
        return (NULL);
    i = dread(phylist, parlist, iobuf, fpt);
    if (i == ERROR)
        _endarr--;
    return (i);
}

dread(phylist, parlist, iobuf, fpt)
struct phyparm *phylist;
struct parstruct *parlist;
struct datfile *fpt;
char *iobuf;
{
    int i;

    i = fscanf(iobuf, CFTDAT, &fpt->dcontrmfg, &fpt->dcontrmod,
               &fpt->dcontrver, &fpt->dsizesect);
    if (i == ERROR)
        return (ERROR);
    i = fscanf(iobuf, DFTDAT, &fpt->ddrivemfg, &fpt->ddrivemod,
               &fpt->dtypemed);
    if (i == ERROR)
        return (ERROR);
    i = fscanf(iobuf, NFTDAT, &fpt->dnumcyl, &fpt->dnumheads,
               &fpt->dsectrk, &fpt->dcontbyte, &fpt->ddrivcont,
               &fpt->dileavfac, &fpt->dexfort, &fpt->dexdtest);
    if (i == ERROR)
        return (ERROR);
    i = fscanf(iobuf, A1FTDAT, &fpt->ddrivch[0], &fpt->ddrivch[1],
               &fpt->ddrivch[2], &fpt->ddrivch[3]);
    if (i == ERROR)
        return (ERROR);
    i = fscanf(iobuf, A2FTDAT, &fpt->dassigndata[0], &fpt->dassigndata[1],
               &fpt->dassigndata[2], &fpt->dassigndata[3],
               &fpt->dassigndata[4], &fpt->dassigndata[5]);
    if (i == ERROR)
        return (ERROR);
    if (testibit(fpt)) {
        cpylists(phylist, fpt, 0);
        cpylists(phylist, fpt, 1);
        initpar(phylist, parlist);
        initflg = TRUE;
    }
    clribit(fpt);
    return (1);
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

testibit(datlist)
struct datfile *datlist;
{
    if ((datlist->dcontrmfg[0] & 0x80) == 0)
        return (FALSE);
    else
        return (TRUE);
}
