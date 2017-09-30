/* This is the main() function for DEFSASI2.OV5
 * 
 * Date last modified 12/1/83 12:56 mjm
 *
 */

#include "defsasi.h"

main(fnum, arg1, arg2)
int fnum, arg1, arg2;
{
    switch (fnum) {
    case 0:
        return (getvers());
    case 1:
        drivch1(arg1, arg2);
        break;
    case 2:
        return (writdatfile(arg1, arg2));
    }
}

char *getvers()
{
    return (RVERS);
}
