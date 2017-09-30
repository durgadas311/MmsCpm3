/* July 18, 1984  09:28  drm  "TERM.C" */
/* terminal control module - for BDS "C" */

/* This modules reads a file "TERMINAL.SYS" from drive A: and uses
 * it to control the console. The format of the file is indicated by
 * the structure "tcb".
 *
 */

/* CP/M specific */

#include "defsasi.h"

#define TWIDTH 80
#define TLENGTH 24

#define numrec 3                /* based on size of termctrl */

initial()
{
    char *tcbuf, *fp;
    int p;
    if ((fp = open("A:TERMINAL.SYS", 0)) == -1) {
        printf("Terminal control file not on drive A:.\n");
        exit(0);
    }
    tcbuf = termctrl;
    if (read(fp, tcbuf, numrec) != numrec) {
        printf("Terminal control file incomplete.\n");
        exit(0);
    }
    close(fp);
    putctl(termctrl.tinit);
    return (0);
}

deinit()
{
    int x;
    putctl(termctrl.tdeinit);
    return (0);
}

getkey()
{
    char c[4], cd, *ktbl;
    int p, pp, qq;
    ktbl = termctrl.khome;
    p = 0;
    cd = HMCD;
    c[0] = inchar();
    while (p < 68 && *(ktbl + p) != c[0]) {
        p += 4;
        ++cd;
    }
    if (p >= 68)
        return (c[0]);
    qq = 0;
    for (pp = 1; pp < 4; ++pp) {
        if (*(ktbl + p + pp) == 0)
            return (cd);
        if (pp > qq) {
            c[pp] = inchar();
            qq = pp;
        }
        if (*(ktbl + p + pp) != c[pp]) {
            p += 4;
            ++cd;
            while (p < 68 && *(ktbl + p) != c[0]) {
                p += 4;
                ++cd;
            }
            pp = 0;
        }
        if (p >= 68)
            return (c[qq]);
    }
    return (cd);
}

inchar()
{
    char c;
    while ((c = bdos(6, 0xFF)) == NULL);
    return (c);
}

puts(buf)
char *buf;
{
    char c;
    while (*buf != 0) {
        outchr(*buf++);
    }
    return (0);
}

outchr(c)
char c;
{
    if (c == '\n')
        bdos(6, '\r');
    bdos(6, c);
    return (0);
}

printf(format)
char *format;
{
    void outchr();
    return _spr(&format, &outchr);
}

putctl(buf)                     /* for outputing screen control sequences only ! */
char *buf;                      /* this routine does not change '\n' into '\r','\n' */
{
    char c;
    while ((c = *buf++) != 0) {
        if (c >= 0x80)
            putnul(c);
        else
            bdos(6, c);
    }
    return (0);
}

putnul(c)
char c;
{
    c &= 0x7F;
    while (c-- > 0) {
        bdos(6, 0);
    }
}

cursor(position)
int position;
{
    char line, col;
    char c;
    int p;
    line = --position / TWIDTH;
    col = position % TWIDTH;
    for (p = 0; p < 12; ++p) {
        c = termctrl.cpos[p];
        if (c == 0)
            break;
        if (c < 0x80) {
            bdos(6, c);
            continue;
        }
        if (c == 0x80)
            c = line;
        else if (c == 0x81)
            c = col;
        else {
            putnul(c);
            continue;
        }
        ++p;
        if (termctrl.cpos[p] == 0xFF)
            printf("%d", c + 1);
        else
            bdos(6, c + termctrl.cpos[p]);
    }
    return (0);
}

getwidth()
{
    return (TWIDTH);
}

getlength()
{
    return (TLENGTH);
}

getterm()
{
    return (termctrl.name);
}

clrscr()
{
    putctl(termctrl.cls);
    return (0);
}

curhome()
{
    putctl(termctrl.home);
    return (0);
}

curleft()
{
    putctl(termctrl.cleft);
    return (0);
}

curright()
{
    putctl(termctrl.cright);
    return (0);
}

curup()
{
    putctl(termctrl.cup);
    return (0);
}

curdown()
{
    putctl(termctrl.cdown);
    return (0);
}

clreel()
{
    putctl(termctrl.ceol);
    return (0);
}

clreop()
{
    putctl(termctrl.ceop);
    return (0);
}

curoff()
{
    putctl(termctrl.coff);
    return (0);
}

curon()
{
    putctl(termctrl.con);
    return (0);
}

invon()
{
    putctl(termctrl.revvid);
    return (0);
}

invoff()
{
    putctl(termctrl.nrmvid);
    return (0);
}

bell()
{
    bdos(6, 0x07);
    return (0);
}

/* end of TERMSYS */
