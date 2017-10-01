/*
 * Terminal Control header file 
 *
 * Contains global definations and variables.
 *
 * Last updated 7/12/84 15:28 drm
 *
 * "TERMINAL.H"
 */

#define BS 8
#define CR 13
#define LF 10
#define DELETE 127

/* keyboard constants, dictated by routines in TERM.C */
#define CNTL 0x80
#define CRCD 0x0D
#define HMCD 0x80
#define LEFT 0x81
#define RIGHT 0x82
#define UP 0x83
#define DOWN 0x84
#define BLUE 0x8A
#define RED 0x8B
#define WHITE 0x8C

struct tcb {
	char name[12];	/* terminal I.D. string */
	char cls[8];	/* must be NULL terminated */
	char home[8];
	char cleft[8];
	char cright[8];
	char cup[8];
	char cdown[8];
	char ceop[8];
	char ceol[8];
	char revvid[8];
	char nrmvid[8];
	char coff[8];
	char con[8];
	char cpos[12];	/* note - special format: 80=line#, 81=colm# */
	char tinit[12];
	char tdeinit[12];
	char jnk3[28];
	char khome[4];	/* returns code 0x80 */
	char kleft[4];	/* 0x81 */
	char kright[4]; /* 0x82 */
	char kup[4];	/* 0x83 */
	char kdown[4];	/* 0x84 */
	char f1[4];	/* 0x85 */
	char f2[4];	/* 0x86 */
	char f3[4];	/* 0x87 */
	char f4[4];	/* 0x88 */
	char f5[4];	/* 0x89 */
	char f6[4];	/* 0x8A */
	char f7[4];	/* 0x8B */
	char f8[4];	/* 0x8C */
	char f9[4];	/* 0x8D */
	char f10[4];	/* 0x8E */
	char f11[4];	/* 0x8F */
	char f12[4];	/* 0x90 */
	char f1name[12];
	char f2name[12];
	char f3name[12];
	char f4name[12];
	char f5name[12];
	char f6name[12];
	char f7name[12];
	char f8name[12];
	char f9name[12];
	char f10name[12];
	char f11name[12];
	char f12name[12];
	} termctrl;

/* end of TERMINAL.H */
