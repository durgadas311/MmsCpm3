/* This is the main() function for DEFSASI2.OV4
 *
 * Date last modified 12/1/83 12:55 mjm
 *
 */

#include "defsasi.h"

main(fnum, arg1, arg2, arg3, arg4)
int fnum, arg1, arg2, arg3, arg4;
{
    switch (fnum) {
    case 0:
        return (getvers());
    case 1:
        return (writmod(arg1, arg2, arg3, arg4));
    case 2:
        return (wrtrel(arg1, arg2, arg3, arg4));
    }
}

char *getvers()
{
    return (RVERS);
}
