/* This is the main() function for DEFSASI2.OV1
 *
 * Date last modified 12/5/83 13:25 mjm
 *
 */

#include "defsasi.h"

main(fnum, arg1, arg2, arg3)
int fnum, arg1, arg2;
{
    switch (fnum) {
    case 0:
        return (getvers());
    case 1:
        return (readdatfile(arg1, arg2, arg3));
    case 2:
        initvar(arg1, arg2);
        break;
    case 3:
        subsys(arg1, arg2);
        break;
    }
}

char *getvers()
{
    return (RVERS);
}
