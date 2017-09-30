/* This is the main() function for DEFSASI2.OV2
 *
 * Date last modified 12/1/83 12:51 mjm
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
        parmenu(arg1, arg2);
    }
}

char *getvers()
{
    return (RVERS);
}
