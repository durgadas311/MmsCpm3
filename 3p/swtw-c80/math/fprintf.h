/* fprintf.h: definitions for printf and fprintf to allow multiple args.
 */

#undef printf
#undef fprintf
#undef sprintf
#define printf prnf_1(),prnf_2
#define fprintf prnf_1(),prnf_3
#define sprintf prnf_1(),prnf_4















