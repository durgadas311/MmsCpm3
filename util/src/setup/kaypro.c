/* Terminal definition (TERMINAL.SYS) for Kaypro with MagicWand keypad map */

/* NOTE: Kaypro versions expanded struct tcb, not done here (yet) */

#include "terminal.h"

struct tcb termctrl = {
/* name */	"KayPro",
/* cls */	"\032",	/* ^Z */
/* home */	"\036",	/* RS */
/* cleft */	"\010",	/* BS */
/* cright */	"\014",	/* ^L */
/* cup */	"\013",	/* ^K */
/* cdown */	"\012",	/* LF */
/* ceop */	"\027",	/* ^W */
/* ceol */	"\030",	/* ^X */
/* revvid */	"\033B0",
/* nrmvid */	"\033C0",
/* coff */	"\033C4",
/* con */	"\033B4",
/* cpos */	"\033=\200\040\201\040", /* note - fmt: 80=line#, 81=colm# */
/* tinit */	"",
/* tdeinit */	"",
/* inln **	"\033E", ** Kaypro extension */
/* delln **	"\033R", ** Kaypro extension */
/* jnk3 */	"",
/* khome */	"\001",	/* ^A - KP7 */
/* kleft */	"\023",	/* ^S - LEFT */
/* kright */	"\004",	/* ^D - RIGHT */
/* kup */	"\005",	/* ^E - UP */
/* kdown */	"\030",	/* ^X - DOWN */
/* f1 */	"\016",	/* ^N - KP8 */
/* f2 */	"\007",	/* ^G - KP9 */
/* f3 */	"\024",	/* ^T - KP- */
/* f4 */	"\022",	/* ^R - KP4 */
/* f5 */	"\017",	/* ^O - KP5 */
/* f6 */	"\006",	/* ^F - KP6 */
/* f7 */	"\002",	/* ^B - KP, */
/* f8 */	"\026",	/* ^V - KP1 */
/* f9 */	"\027",	/* ^W - KP2 */
/* f10 */	"\031",	/* ^Y - KP3 */
/* f11 */	"\021",	/* ^Q - ENTER */
/* f12 */	"\020",	/* ^P - KP0 */
/* f13 **	"\025",	** ^U - KP. ** Kaypro extension */
/* f14 **	"",	**	** Kaypro extension */
/* f1name */	"BACK LINE",
/* f2name */	"BACK PAGE",
/* f3name */	"TOP",
/* f4name */	"BLOCK",
/* f5name */	"FWD LINE",
/* f6name */	"FWD PAGE",
/* f7name */	"BOTTOM",
/* f8name */	"SEARCH",
/* f9name */	"RPT SRCH",
/* f10name */	"CHR DEL",
/* f11name */	"FULL INS",
/* f12name */	"CHR INS",
/* f13name **	"LINE DEL",	** Kaypro extension */
/* f14name **	"",	** Kaypro extension */
};
