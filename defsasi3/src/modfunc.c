/* Modfunc contains the functions to write 
 * the CP/M 2.24 .HEX SASI driver modules.
 * Uses rdwrthex.c functions to read and write a hex file
 *
 * "MODFUNC.C"
 *
 * Date last updated 12/1/83 10:48 mjm
 *
 */

#include "defsasi.h"

/* addresses of values that need to change in the module */

#define BUFLEN	0x0002          /* where BUFLEN is in the module */
#define MIXER	0x163C          /* start of MIXER table starts  */
#define DBASE	0x164C          /* start of DRIVE$BASE table starts */
#define ASCPAR	0x1F            /* addr of partition number in the string */
#define DPHCSV	0x42            /* addr of first CSV addr. in DPH */
#define CNUM	0xC6            /* addr of controller number */
#define DDEFSTR 0xC7            /* start of DDEFTBL */

/* addresses for a Z67 sasi module */

#define Z67DPH	0x57
#define Z67CNUM 0xD7
#define Z67DDEF 0xDC

writmod(phylist, parlist, infname, outfname)
struct phyparm *phylist;
struct parstruct *parlist;
char *infname, *outfname;
{
    char inbuf[BUFSIZ], outbuf[BUFSIZ];
    int in, i;
    unsigned addr, d;

    /* open linkable disk model (HEX) */
    if (fopens(infname, inbuf) == ERROR)
        return (ERROR);
    /* create dest file */
    if (fcreat(outfname, outbuf) == ERROR)
        return (ERROR);
    in = inrec(inbuf, &gcaddr, &gccnt, gdata);
    if (in >= NULL) {
        for (i = 0, d = 0; i < parlist->numpar; i++)
            if (phylist->typemed[parlist->parlun[i]] == 'R')
                d += CSLEN;
        if (testz67(phylist))
            d += Z67HST + Z67FLOP + (ALEN * parlist->numpar);
        else
            d += HSTBUF + (ALEN * parlist->numpar);
        addr = BUFLEN;
        in = chgbyt(inbuf, outbuf, &addr, d & 0xFF);
        if (in >= NULL)
            in = chgbyt(inbuf, outbuf, &addr, d / 256);
    }
    if (testz67(phylist))
        d = parlist->numpar + 1;
    else
        d = parlist->numpar;
    for (i = 0, addr = MIXER; i < d && in >= NULL; i++)
        in = chgbyt(inbuf, outbuf, &addr,
                    phylist->contrnum * 10 + PHYDRNUM + i);
    if (in >= NULL) {
        addr = DBASE;
        in = chgbyt(inbuf, outbuf, &addr,
                    phylist->contrnum * 10 + PHYDRNUM);
    }
    if (in >= NULL)
        if (testz67(phylist))
            in = chgbyt(inbuf, outbuf, &addr,
                        phylist->contrnum * 10 + PHYDRNUM +
                        parlist->numpar + 1);
        else
            in = chgbyt(inbuf, outbuf, &addr,
                        phylist->contrnum * 10 + PHYDRNUM +
                        parlist->numpar);
    if (in >= NULL)
        if (!testz67(phylist)) {
            addr = ASCPAR;
            d = parlist->numpar + '0';
            in = chgbyt(inbuf, outbuf, &addr, d);
        }
    if (testz67(phylist)) {
        addr = Z67DPH;
        d = CKBUF + Z67HST + Z67FLOP;
    } else {
        addr = DPHCSV;
        d = CKBUF + HSTBUF;
    }
    for (i = 0; i < parlist->numpar && in >= NULL; i++, addr += 12) {
        in = chgbyt(inbuf, outbuf, &addr, d & 0xFF);
        if (in < NULL)
            break;
        in = chgbyt(inbuf, outbuf, &addr, d / 256);
        if (in < NULL)
            break;
        if (phylist->typemed[parlist->parlun[i]] == 'R')
            d += CSLEN;
        in = chgbyt(inbuf, outbuf, &addr, d & 0xFF);
        if (in < NULL)
            break;
        in = chgbyt(inbuf, outbuf, &addr, d / 256);
        if (in < NULL)
            break;
        d += ALEN;
    }
    if (in >= NULL) {
        if (testz67(phylist))
            addr = Z67CNUM;
        else
            addr = CNUM;
        in = chgbyt(inbuf, outbuf, &addr, phylist->contrnum);
    }
    if (testz67(phylist))
        addr = Z67DDEF;
    else
        addr = DDEFSTR;
    for (i = 0; i < parlist->numpar && in >= NULL; i++) {
        in = chgbyt(inbuf, outbuf, &addr, parlist->parlun[i] << 5);
        if (in < NULL)
            break;
        addr += 2;
        if (phylist->typemed[parlist->parlun[i]] == 'R')
            in = chgbyt(inbuf, outbuf, &addr, parlist->parnum[i] | 0x20);
        else
            in = chgbyt(inbuf, outbuf, &addr, parlist->parnum[i]);
    }
    if (in >= NULL)
        in = chgbyt(inbuf, outbuf, 0, 0);
    fclose(inbuf);
    fclose(outbuf);
    return (in);
}

chgbyt(inbuf, outbuf, addr, data)
char *inbuf, *outbuf;
unsigned *addr;                 /* pt to address to be changed */
int data;                       /* new data  */
{
    int er, i;
    er = i = NULL;

    if (addr == 0 && data == 0) {       /* out put to end of file */
        while (i >= NULL) {
            er = outrec(outbuf, gcaddr, gccnt, gdata);
            if (er < NULL)
                break;
            i = inrec(inbuf, &gcaddr, &gccnt, gdata);
        }
        if (er >= NULL)
            er = outrec(outbuf, 0, 0, gdata);   /* write hex eof */
        return (er);
    }
    while ((*addr < gcaddr || *addr > gcaddr + gccnt - 1) && er >= NULL) {
        er = outrec(outbuf, gcaddr, gccnt, gdata);
        if (er < NULL)
            return (er);
        er = inrec(inbuf, &gcaddr, &gccnt, gdata);
    }
    if (er < NULL)
        return (er);
    gdata[((*addr)++) - gcaddr] = data;
    return (OK);
}
