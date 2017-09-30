/* Read and write hex file routines
 *
 * Date last modified: 12/1/83 10:49 mjm
 *
 *
 * "RDWRTHEX.C"
 * 
 */

#include "defsasi.h"

inrec(iobuf, addr, count, data)
char *iobuf;
int *count, *data;
unsigned *addr;
{
    int cksum, c, in;

    in = getc(iobuf);
    if (in == ';') {
        while (in != ':') {
            in = getc(iobuf);
            if (in == ERROR)
                return (in);
        }
    } else if (in != ':')
        return (ERR1);
    in = inhex(iobuf);
    if (in <= ERROR)
        return (in);
    if (in == 0) {
        while (in != LF) {
            in = getc(iobuf);
            if (in == ERROR)
                return (in);
            if (in != '0' && in != CR && in != LF)
                return (ERR1);  /* invalid hex eof */
        }
        return (HEOF);
    }
    *count = cksum = in;
    in = inhex(iobuf);
    if (in <= ERROR)
        return (in);
    *addr = in * 256;
    cksum += in;
    in = inhex(iobuf);
    if (in <= ERROR)
        return (in);
    *addr += in;
    cksum += in;
    in = inhex(iobuf);          /* null byte */
    if (in <= ERROR)
        return (in);
    for (c = 0; c < *count; c++) {
        in = inhex(iobuf);
        if (in <= ERROR)
            return (in);
        data[c] = in;
        cksum += in;
    }
    in = inhex(iobuf);          /* cksum */
    if (in <= ERROR)
        return (in);
    cksum = ((~cksum & 0x00FF) + 1) & 0xFF;
    if (cksum != in)
        return (ERR3);
    if (getc(iobuf) != CR)
        return (ERR2);
    if (getc(iobuf) != LF)
        return (ERR2);
    return (OK);
}

inhex(iobuf)
char *iobuf;
{
    int digit, out, c;

    for (out = 0, c = 0; c < 2; c++) {
        if ((digit = getc(iobuf)) == ERROR)
            return (ERROR);
        if (digit == CPMEOF)
            return (HEOF);
        if (digit >= '0' && digit <= '9')
            out += digit - '0';
        else if (digit >= 'A' && digit <= 'F')
            out += (digit - 'A') + 10;
        else
            return (ERR2);
        out *= 16;
    }
    return (out / 16);
}

outrec(iobuf, addr, count, data)
char *iobuf;
int count, *data;
unsigned addr;
{
    int cksum, c;

    if (addr == 0 && count == 0)        /* send EOF */
        return (fputs(":0000000000\n\032", iobuf));
    if (putc(':', iobuf) == ERROR)
        return (ERROR);
    if (outhex(iobuf, count) == ERROR)
        return (ERROR);
    cksum = count;
    if (outhex(iobuf, addr >> 8) == ERROR)
        return (ERROR);
    if (outhex(iobuf, addr & 0xFF) == ERROR)
        return (ERROR);
    cksum += addr / 256;
    cksum += addr & 0xFF;
    if (outhex(iobuf, 0) == ERROR)      /* null byte */
        return (ERROR);
    for (c = 0; c < count; c++) {
        if (outhex(iobuf, data[c] & 0xFF) == ERROR)
            return (ERROR);
        cksum += data[c];
    }
    if (outhex(iobuf, ((~cksum & 0xFF) + 1) & 0xFF) == ERROR)
        return (ERROR);
    if (fputs("\n", iobuf) == ERROR)
        return (ERROR);
    return (OK);
}

outhex(iobuf, byt)
char byt, *iobuf;
{
    outnib(byt >> 4, iobuf);
    outnib(byt, iobuf);
}

outnib(byt, iobuf)
char byt, *iobuf;
{
    if ((byt &= 0x0F) > 9)
        byt += 'A' - 10;
    else
        byt += '0';
    return (putc(byt, iobuf));
}
