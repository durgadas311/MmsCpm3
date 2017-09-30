/* DEFSASI initialize varaibles function
 *
 * "INITVAR.C"
 * 
 * Date last modified: 12/9/83 15:57 mjm
 */

#include "defsasi.h"

initvar(phylist, parlist)
struct phyparm *phylist;
struct parstruct *parlist;
{
    int i;
    phylist->contrnum = 0;
    strcpy(phylist->contrmfg, INITFLD);
    strcpy(phylist->contrmod, INITFLD);
    strcpy(phylist->contrver, ".");
    phylist->sizesect = 512;
    phylist->numlun = 1;
    strcpy(phylist->drivemfg[0], INITFLD);
    strcpy(phylist->drivemfg[1], INITFLD);
    strcpy(phylist->drivemfg[2], INITFLD);
    strcpy(phylist->drivemfg[3], INITFLD);

    strcpy(phylist->drivemod[0], INITFLD);
    strcpy(phylist->drivemod[1], INITFLD);
    strcpy(phylist->drivemod[2], INITFLD);
    strcpy(phylist->drivemod[3], INITFLD);
    setmem(phylist->typemed, 4, 'F');
    setmem(phylist->numcyl, 8 * 4 * 2, 0);      /* 8 fields 4 colmuns 2 bytes */
    setmem(phylist->drivch, 4 * 3 * 2, 0);
    setmem(phylist->assigndata, 4 * 6 * 2, 0);
    setmem(parlist->parlun, 18, 0);

/* Minimum number of tracks to cover 512 dir. entries and 2 system trks = 4 */

    initw(parlist->parsize, "4,4,4,4,4,4,4,4,4");

    initw(parlist->blocksize,
          "4096,4096,4096,4096,4096,4096,4096,4096,4096");
    initw(parlist->numdir, "512,512,512,512,512,512,512,512,512");
    initw(parlist->off, "2,2,2,2,2,2,2,2,2");
    initw(parlist->parnum, "0,1,2,3,4,5,6,7,8");
    parlist->numpar = 8;
}
