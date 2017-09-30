/* This is the main() function for DEFSASI2.OV3
 *
 * Date last modified 12/1/83 12:53 mjm
 *
 */

#include "defsasi.h"

main(fnum, arg1, arg2, arg3)
int fnum, arg1, arg2, arg3;
{
    switch (fnum) {
    case 0:
        return (getvers());
    case 1:
        initfun(arg1, arg2, arg3);
    }
}

char *getvers()
{
    return (RVERS);
}
