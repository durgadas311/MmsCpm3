/*
 *  PRTMAG - prints the magic sector of a SASI drive
 *
 *  Date last modified: 07/16/84 13:31 drm
 *
 */

#include "hardware.h"
#include "bdscio.h"

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

int dev, bootflg;

main(argc, argv)
int argc;
char *argv[];
{
    int lun, cnum, c;

    dev = 1;
    bootflg = FALSE;
    lun = cnum = 0;
    if (argc > 1) {
        if (*argv[1] == '?') {
            help();
            exit();
        }
        if (!testarg(argv[1])) {
            lun = atoi(argv[1]);
            if (argc > 2) {
                if (!testarg(argv[2]))
                    cnum = atoi(argv[2]);
                if (argc > 3) {
                    testarg(argv[3]);
                    if (argc > 4)
                        testarg(argv[4]);
                }
            }
        }
    }
    printf("\nLogical Unit Number: %d\n", lun);
    printf("Controller Number: %d\n\n", cnum);
    c = initsasi(GETPORT);
    if (c == NOERRCD) {
        initsasi(PUTLUN, lun);
        initsasi(PUTCNUM, cnum);
        c = initsasi(INSPEC);
        if (c == PRECONF)
            prtbuf();
        else
            errmsg(c);
    } else
        errmsg(c);
}

REPOS()
{
  return;
}

bell()
{
  printf("%c",7);
}


testarg(argv)
char *argv;
{
    int i;

    i = FALSE;
    if (strcmp(argv, "-P") == NULL) {
        dev = 2;
        i = TRUE;
    }
    if (strcmp(argv, "-B") == NULL)
        i = bootflg = TRUE;
    return (i);
}

prtbuf()
{
    char *initsasi(), *prtpt;
    int i, j, line;

    prtpt = initsasi(BUFADR);
    for (i = 0; i < 20; i++) {
        if (i <= 3)
            prnt("%02.2x ", *(prtpt + i));
        else
            prnt("%2.2d ", *(prtpt + i));
    }
    prnt("\n\n");
    prtpt += 20;
    for (i = 0; i < 9; i++, prtpt += 3) {
        prnt("%02.2x %02.2x %02.2x\n", *(prtpt), *(prtpt + 1),
             *(prtpt + 2));
    }
    prnt("\n");
    prtpt = initsasi(BUFADR) + 47;
    for (i = 0; i < 9; i++, prtpt += 21) {
        prnt("%u\n", *(prtpt) + (*(prtpt + 1) * 256));
        prnt("%u %u %u\n", *(prtpt + 2), *(prtpt + 3), *(prtpt + 4));
        prnt("%u %u\n", *(prtpt + 5) + (*(prtpt + 6) * 256),
             *(prtpt + 7) + (*(prtpt + 8) * 256));
        prnt("%02.2x %02.2x\n", *(prtpt + 9), *(prtpt + 10));
        prnt("%u %u\n", *(prtpt + 11) + (*(prtpt + 12) * 256),
             *(prtpt + 13) + (*(prtpt + 14) * 256));
        prnt("%02.2x %02.2x %02.2x\n", *(prtpt + 15), *(prtpt + 16),
             *(prtpt + 17));
        prnt("%02.2x %02.2x %02.2x\n", *(prtpt + 18), *(prtpt + 19),
             *(prtpt + 20));
        prnt("\n");
        if (i == 4)
            prnt("\f");
    }

    for (i = 0; i < 20; i++)
        prnt("%02.2x ", *(prtpt++));
    outc('\n');
    if (bootflg) {
        outc('\f');
        for (line = i = 0; i < 1024; ++i) {
            if ((i & 0x000F) == 0) {
                prnt("\n%04.4x ", i + 0x100);
                if (++line > 60) {
                    outc('\f');
                    line = 0;
                }
            }
            prnt("%02.2x ", *(prtpt++));
        }
    }
}

prnt(format)
char *format;
{
    int outc();

    return (_spr(&format, &outc));
}

outc(c)
int c;
{
    if (c == '\n') {
        putc('\n', dev);
        putc('\r', dev);
        return (OK);
    }
    putc(c, dev);
    return (OK);
}

errmsg(c)
int c;
{
    char *bptr, *initsasi();

    bell();
    switch (c) {
    case NRDYMSG:
        puts("Controller not ready\n");
        break;
    case CERR:
        if (initsasi(GETSEN) != NULL) {
            puts("Controller not ready\n");
            break;
        }
        puts(initsasi(OUTCERR));
        bptr = initsasi(GETERS);
        printf("\nSense bytes: %02.2x %02.2x %02.2x %02.2x\n", *bptr,
               *(bptr + 1), *(bptr + 2), *(bptr + 3));
        break;
    case PRTMSG1:
        puts("SW501 setting incorrect-no port selected\n");
        break;
    case PRTMSG2:
        puts("SW501 setting does not match port choice\n");
        break;
    case DNRMSG:
        puts("Drive not ready\n");
        break;
    default:
        break;
    }
}

help()
{
    puts("\nPRTMAG ? | {LUN} {CONTROLLER#} {-P} {-B}\n");
    puts("\nLUN and controller number default to zero\n");
    puts("  ? = this help menu\n");
    puts(" -P = redirect to printer\n");
    puts(" -B = print boot loader\n");
}
