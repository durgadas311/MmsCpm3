/* February 5, 1986  19:52  drm  "STRTRK.C" */

/* STAR TREK game for STD graphics */

#include <stdio.h>
#ifdef _KP_
#include "termkp.h"
#endif
#ifdef _H19_
#include "termh19.h"
#endif
#ifdef _XT_
#include "termxt.h"
#endif

/* e.g. oscpm.c */
extern void osinit();
extern void osreset();
extern void outchr(char c);
extern char gc(); /* returns CHAR or 0 if not ready */
extern char gcto(); /* returns CHAR or 0 if not ready, after timeout */
extern char inch0();	/* wait for character */

/* e.g. termkp.c */
extern void trmin();
extern void trmde();
extern void clrscr();/* clear screen and home */
extern void cleol();	/* clear to end of line */
extern void curon();	/* cursor on */
extern void curoff();/* cursor off */
extern void revv();	/* reverse video (hilight) */
extern void nrmv();	/* normal video (undo revv()) */
extern void cursor(char r, char c);
extern void llc();	/* lower-left corner graphic */
extern void lrc();	/* lower right corner */
extern void ulc();	/* upper left corner */
extern void urc();	/* upper right corner */
extern void horz(int n, char t);	/* N horiz chars, T = top */
extern void vl(char l);	/* single vert line char, L = left */
extern void hits(char a);	/* 0/1 for two-step display */
extern char hit0(); /* "empty" hits cell char */
extern void pos0();
extern void putshl(char r, char c, char a);

/* table for skill levels
	 number-of-klingons = rnd / skill[0] + skill[1]
	number-of-bases = rnd / skill[2] + skill[3]
	  number-of-photons = ( numklg - skill[4] - rnd / skill[5] ) / numbas
		   time = numklg * skill[6] + rnd + skill[7]
	crit-hit-chance = skill[8]
   phaser-recharge-rate = skill[9]
   sheild-recharge-rate = skill[10]
  impulse-recharge-rate = skill[11]
		   -0--1--2--3---4---5-6---7--8---9--10--11-	 */
int skill[10][12]={
	{ 6,30,32, 3,-20,-10,0,  0,10,200,100, 20},
	{ 6,30,22, 2,  0,-10,7,  0,10,150,100, 20},
	{ 6,30,22, 2,  0, 10,6, 80,20,100, 75, 20},
	{ 3,30,22, 2,  0, 10,6, 50,20,100, 75, 20},
	{ 3,30,22, 2,  0,  6,5,100,30, 75, 75, 20},
	{ 3,30,16, 1,  5, 10,5, 80,40, 75, 75, 20},
	{ 2,33,16, 1, 10, 10,5, 50,40, 50, 75, 20},
	{ 2,33,22, 1, 10, 10,5, 20,50, 50, 75, 20},
	{ 2,45,22, 1, 10, 10,5,  0,50, 50, 75, 20},
	{ 2,50,32, 1, 16, 16,5,  0,60, 50, 50, 20}
};

char galaxy[64][16];

struct kt { int ix; int iy; int ti; } ep={-1,-1,1},sb[4],explod;

struct { struct kt; char fire; } kg[82];

char item[4]={'.','B','K','*'};

struct {
	char x;
	char y;
	int sin;
	int cos;
	   } direct[32]={
{ 11,39,-10000,0},   {11,41,-9809,1951}, {11,43,-9239,3827}, {11,45,-8315,5556},
{ 12,47,-7071,7071}, {13,48,-5556,8315}, {14,49,-3827,9239}, {15,49,-1951,9808},
{ 16,49,0,10000},    {17,49,1951,9808},  {18,49,3827,9239},  {19,48,5556,8315},
{ 20,47,7071,7071},  {21,45,8315,5556},  {21,43,9239,3827},  {21,41,9808,1951},
{ 21,39,10000,0},    {21,37,9808,-1951}, {21,35,9239,-3827}, {21,33,8315,-5556},
{ 20,31,7071,-7071}, {19,30,5556,-8315}, {18,29,3827,-9239}, {17,29,1951,-9808},
{ 16,29,0,-10000},   {15,29,-1951,-9808},{14,29,-3827,-9239},{13,30,-5556,-8315},
{ 12,31,-7071,-7071},{11,33,-8315,-5556},{11,35,-9239,-3827},{11,37,-9808,-1951}
};

int dist[8][8]={
	{   0,1000,2000,3000,4000,5000,6000,7000},
	{1000,1414,2236,3162,4123,5099,6083,7071},
	{2000,2236,2828,3606,4472,5385,6325,7280},
	{3000,3162,3606,4243,5000,5831,6708,7616},
	{4000,4123,4472,5000,5657,6403,7211,8062},
	{5000,5099,5385,5831,6403,7071,7810,8602},
	{6000,6083,6325,6708,7211,7810,8485,9220},
	{7000,7071,7280,7616,8062,8602,9220,9899}
};

struct { char x; char y; char *str; }
	commnd[]={{2,52,"  LONG RANGE SCAN"},
		  {3,52,"  LIST STAREBASES"},
		  {4,52,"  OPERATION MANUALS"},
		  {6,52,"(TAB) = FIRE PHASORS"},
		  {7,52,"(ESC) = PHOTON TORPEDOS"},
		  {8,52,"(space) MOVE BY IMPULSE"},
		  {9,52," 1-6  = WARP (FACTOR)"},
		  {10,52,"(DEL) = SHIELDS"}},
	 opcom[]={{14,52,"Select Topic:"},
		  {15,52,"  NAVIGATION"},
		  {16,52,"  WEAPONRY"},
		  {17,52,"  THE ENEMY"},
		  {18,52,"  DAMAGE CONTROL"},
		  {19,52,"  GALACTIC MAP"},
		  {20,52,"  STARBASES"},
		  {22,52,"(ESC) when finished"}},
	stats[]={
	{1,21,"        CONDITION:"},
	{2,21,"          SHIELDS:"},
	{3,21,"          PHASORS:"},
	{4,21,"  PHOTON TORPEDOS:"},
	{5,21,"          SCANNER:"},
	{6,21,"     WARP ENGINES:"},
	{7,21,"    IMPULSE POWER:"},
	{8,21,"CRITICAL HITS:  .........."},
	{9,21,"   POSITION:"},
	{10,21,"         KLINGONS:"},
	{11,21,"TIME: 0      LEVEL:" }};

#define STROPS 8
#define NUMOPS 6
#define OPS1ST 1

#define NAVIGT 0
#define WEAPNR 1
#define ENEMY 2
#define DAMAGE 3

#define STRCOM 8
#define NUMCOM 3
#define COM1ST 0

#define NUMSTS 11

#define LRSCN 0
#define LSTBA 1
#define OPMAN 2

#define DCKST 0
#define SHLDST 1
#define PHSST 2
#define PHTST 3
#define SCNST 4
#define WRPST 5
#define IMPST 6
#define QUADR 8
#define TIMES 10
#define KLGONS 9
#define CRTHIT 7
#define LEVEL 10

char course,dir = -1;
int cmmnd = -1,oprnd = -1,phas = -1,imp = -1,shlds = -1,shlde,phot = -1;
int savpht,crithit;
char wrpe = -1,dock = -1,scnnr = -1;
char skil,key;
int phre,shre,imre,t1,t2,nklg,numklg,numbas;
int crh,wind,expe,xx,yy,dd,seed,type,idx,power;
char init=1,t0;
char strg[30];
char *outstr="OUT     ",*dec8="%-8d",*deadsb="#%1.1d  --*--      ";
char *wrking="WORKING ";

static void reset();
static void clrwin();
static void prtwin(int a);
static void setexp(int a, int b, int c);
static int sgn();
static int abs();
static int rnd();
static int coline();
static int kgcol();
static void settim(int t);
static void upde();
static char inchr();
static void hitinit();
static void sethit(int a);
static char setklg();
static int chkklg();
static void setwpe();
static void setdck();
static void setpht();
static void setphs();
static void setimp();
static void setcom();
static void setop();
static void setscn();
static void setdir();
static void setshl(); /* (shlds,shlde) */
static int setent();
static char chkdck();
static void longscan();
static void dispgm();
static void shortscan();
static void botline();
static void frame();
static void fiximp();
static void fixphs();
static void fixshl();
static void fixscn();
static void fixpht();
static void fixwpe();
int prts(char *s);

main() {
	osinit();
	trmin();
/*  if (*(defcom+1) != ' ') { if ((skil= *(defcom+1)-'0') > 9) skil=0; }
	else skil=0; */
	skil=0;
	/* init critical hits bargraph from term-dependent value */
	hitinit();
	curoff(); /* cursor off */
	frame();
	cursor(stats[LEVEL].x,stats[LEVEL].y+1); outchr(skil+'0');
	reset();  /* everything working */
	while ((key=inchr()) != KEXIT) {
		if (ep.ti==0) {if (key==0x01) reset(); continue;}
		if (nklg==0 || ep.ti==2) if (key==0x01) {reset(); continue;}
		switch (key) {
		case 0x11: reset(); break;
		case KLEFT: setdir((dir-1)&0x1F); break;
		case KRIGHT: setdir((dir+1)&0x1F); break;
		case KDOWN: setcom((cmmnd+1)%NUMCOM); break;
		case KUP: setcom(cmmnd<=0?NUMCOM-1:cmmnd-1); break;
		case 0x0D:
			switch (cmmnd) {
			case LRSCN: if (dock==0) longscan(); break;
			case LSTBA: prtwin(1); break;
			case OPMAN:
				prtwin(2);
				setop(0);
				while((key=inch0())!=0x1B) {
					switch (key) {
					case 0x18: setop((oprnd+1)%NUMOPS); break;
					case 0x05: setop(oprnd<=0?NUMOPS-1:oprnd-1);
						break;
					case 0x0D:
						prtwin(oprnd+3);
						while (inch0()!=0x1B);
						prtwin(2); setop(oprnd);
						break;
					default: break;
					}
				}
				clrwin(); key=0;
				break;
			default: break;
			}
			break;
		case KSHLD: if (dock==0) setshl(1-shlds,shlde); break;
		case 0x09:
			if (phas<=0 || dock==1) break;
			power=(phas>=1000?1000:phas);
			setphs(phas-power);
			if (coline()!=1) break;
			power=(power-((dd/100)*(power/10))/10);
			setexp(xx,yy,power);
			break;
		case 0x1B:
			if (phot<=0 || dock==1) break;
			setpht(phot-1);
			if (coline()!=1) break;
			setexp(xx,yy,3000); /* enough power to destroy anything */
			break;
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
			if (wrpe!=0 || dock==1) break;
			key=- '0';
			yy=(direct[dir].sin+1)/2;
			xx=(direct[dir].cos+1)/2;
			yy=(yy*key+313*sgn(yy))/625;
			xx=(xx*key+313*sgn(xx))/625;
			while (setent(ep.ix+yy,ep.iy+xx)==-1)
				{ yy=yy-sgn(yy); xx=xx-sgn(xx); }
			if (skil!=0) {
				t1 =- (key+2);
				settim(t1);
				if (t1<=0 && t2==0 && nklg!=0) prtwin(22);
			}
			key=0; /* prevent false-trigger on ^C */
			break;
		case 0x20:
			if(imp>=100) {
				yy=direct[dir].sin;
				yy=(yy+5000*sgn(yy))/10000;
				xx=direct[dir].cos;
				xx=(xx+5000*sgn(xx))/10000;
				setent(ep.ix+yy,ep.iy+xx);
				setimp(imp-100);
			}
			break;
		default:
			break;
		}
	}
	cursor(23,0);
	curon(); /* cursor on */
	trmde();
}

static void reset() {
	int a,b;
	osreset(); /* courtesy call */
	ep.ti = 1;
	ep.ix = ep.iy = (-1);
	init = 1;
	t0 = t1 = t2 = crithit = 0;
	for (a=0;a<64;++a) {
		for (b=0;b<16;++b) {
			galaxy[a][b]=0;
		}
	}
	for (a=14;a<22;++a) {
		cursor(a,2);
		prts("-- -- -- -- -- -- -- --");
	}
	prtwin(0);
	setdir(0);
	setcom(0);
	setshl(0,3000);	/* shields down */
	setphs(3000);   /* phasor energy = 3000 */
	setpht(10);     /* 10 photon torpedos */
	setscn(1);	/* clear scanner display */
	setscn(0);	/* scanner working */
	setwpe(0);		/* warp engines working */
	setimp(3000);   /* impulse power = 3000 */
	sethit(0);
}

static void clrwin() { for (xx=13;xx<24;++xx) {cursor(xx,52); cleol();} }

static void prtwin(int a) {
	clrwin();
	wind=a;
	switch (a) {
	case 0:
		cursor(14,52); prts(CMDS); prts(" selects command");
		cursor(15,52); prts("RETURN executes command");
		cursor(16,52); prts(DIRS); prts(" sets direction");
		cursor(17,52); prts("0-9 sets level");
		break;
	case 1:
		cursor(14,52); prts("Active Star Bases:");
		for (xx=0;xx<numbas;++xx) {
			cursor(16+xx,52);
			if (sb[xx].ix<0) sprintf(strg,deadsb,xx);
			else sprintf(strg,"#%1.1d  %2.2d,%2.2d  (%2.2d)",
				xx,sb[xx].ix,sb[xx].iy,sb[xx].ti);
			prts(strg);
		}
		break;
	case 2:
		for (xx=0;xx<STROPS;++xx) {
		cursor(opcom[xx].x,opcom[xx].y); prts(opcom[xx].str); }
		break;
	case 3:     /* NAVIGATION */
		cursor(13,52); prts("(Space) moves by impulse"); 
		cursor(14,52); prts("power 1 unit on scanner in");
		cursor(15,52); prts("current direction consum-");
		cursor(16,52); prts("ing 100 energy units.");    
		cursor(17,52); prts("1,2,3,4,5,6 move by warp"); 
		cursor(18,52); prts("engines 8 units per warp"); 
		cursor(19,52); prts("factor (Warp 6 moves 48).");
		cursor(20,52); prts("Upper left corner is 0,0.");
		cursor(21,52); prts("Lower left = 63,0. Upper"); 
		cursor(22,52); prts("right = 0,63. Outside");    
		cursor(23,52); prts("galaxy, scanner shows \"?\".");
		break;
	case 4:     /* WEAPONRY */
		cursor(13,52); prts("(TAB) fires 1000 units of");
		cursor(14,52); prts("phasor energy in current"); 
		cursor(15,52); prts("direction. Less energy");   
		cursor(16,52); prts("actually reaches target."); 
		cursor(17,52); prts("Starbases will be destroyd");
		cursor(18,52); prts("by any phasor hit of 750+.");
		cursor(19,52); prts("(ESC) fires photon torpedo");
		cursor(20,52); prts("destroying target unless"); 
		cursor(21,52); prts("its a star (*). Any object");
		cursor(22,52); prts("will flash when hit.");     
		break;
	case 5:     /* THE ENEMY */
		cursor(13,52); prts("Klingons are destoyed when");
		cursor(14,52); prts("phasor hits total 2000 or");
		cursor(15,52); prts("if hit by photon torpedo.");
		cursor(16,52); prts("They fire at you with 1500");
		cursor(17,52); prts("units periodically unless");
		cursor(18,52); prts("blocked by an object. The");
		cursor(19,52); prts("number of remaining");      
		cursor(20,52); prts("klingons is displayed on"); 
		cursor(21,52); prts("the status screen.");		 
		break;
	case 6:     /* DAMAGE CONTROL */
		cursor(13,52); prts("If shield energy is");      
		cursor(14,52); prts("depleted by klingon hits,");
		cursor(15,52); prts("damage randomly disables"); 
		cursor(16,52); prts("devices for random lengths");
		cursor(17,52); prts("of time, indicated by OUT");
		cursor(18,52); prts("on status screen. Shields,");
		cursor(19,52); prts("phasors and impulse");      
		cursor(20,52); prts("engines are recharged by"); 
		cursor(21,52); prts("warp engines at various");  
		cursor(22,52); prts("rates, only if warp");      
		cursor(23,52); prts("engines are working.");     
		break;
	case 7:     /* GALACTIC MAP */
		cursor(13,52); prts("The G.Map shows current");  
		cursor(14,52); prts("status of quadrants (8X8"); 
		cursor(15,52); prts("squares, scanner screens)");
		cursor(16,52); prts("with your position high-"); 
		cursor(17,52); prts("lighted. A \"+\" indicates"); 
		cursor(18,52); prts("starbase(s) and digit is"); 
		cursor(19,52); prts("the number of klingons.");  
		cursor(20,52); prts("Long range scan shows");    
		cursor(21,52); prts("status of adjacent quads.");
		break;
	case 8:     /* STARBASES */
		cursor(13,52); prts("To dock at a starbase you");
		cursor(14,52); prts("must be positioned");		 
		cursor(15,52); prts("directly above, below,");   
		cursor(16,52); prts("left, or right of it. You");
		cursor(17,52); prts("cannot fire, scan, warp,"); 
		cursor(18,52); prts("or raise shields while");   
		cursor(19,52); prts("docked. Klingons will not");
		cursor(20,52); prts("fire at you while docked.");
		cursor(21,52); prts("When docked all devices");  
		cursor(22,52); prts("are restored to fully");    
		cursor(23,52); prts("operational.");		 
		break;
	case 20:
		cursor(14,52); prts("Enterprize Destroyed");
		cursor(16,52); prts("push CTRL-A to re-start");
		break;
	case 21:
		cursor(14,52); prts("All Klingons Destroyed");
		cursor(16,52); prts("push CTRL-A to re-start");
		break;
	case 22:
		cursor(14,52); prts("You are out of time");
		cursor(15,52); prts("All startbases destroyed");
		cursor(16,52); prts("push CTRL-A to re-start");
		yy=0;
		for (xx=0;xx<numbas;++xx) { if (sb[xx].ix == -1) continue;
			galaxy[sb[xx].ix][sb[xx].iy/4] &= ~(0x3<<(sb[xx].iy&0x3)*2);
			if (((sb[xx].ix^ep.ix|sb[xx].iy^ep.iy)&0xFFF8)==0) yy=1;
			else dispgm(sb[xx].ix,sb[xx].iy,0);
			sb[xx].ix=(-1);
		}
		if (yy==1) {dispgm(ep.ix,ep.iy,1); shortscan();
		if (dock) setdck(0); }
		t2=1;
		ep.ti=2;
		break;
	default:
		break;
	}
/*  return(1); // must return .TRUE. */
}

static void setexp(int a, int b, int c) {
	if (type==2) kg[idx].ti =- c;
	if (scnnr==0) {
		if (explod.ti!=0) {
			cursor(1+(explod.ix&0x07),32+(explod.iy&0x07)*2);
			outchr(item[galaxy[explod.ix][explod.iy/4]>>(explod.iy&0x03)*2 &0x03]);
		}
		cursor(1+(a&0x07),32+(b&0x07)*2);
		revv();
		if(type==3 || type==2 && kg[idx].ti>0 || type==1 && c<750)
			outchr(item[galaxy[a][b/4]>>(b&0x03)*2 &0x03]);
		else outchr(' ');
		nrmv();
		explod.ix=a; explod.iy=b; explod.ti=2;
	}
	if (type==2 && kg[idx].ti<=0 && (kg[idx].ix=(-1),setklg(nklg-1)) ||
			type==1 && c>=750 && (sb[idx].ix=(-1),wind!=1||
			(cursor(16+idx,52),sprintf(strg,deadsb,idx),
			prts(strg)))) {
		galaxy[a][b/4] &= ~(0x3<<(b&0x3)*2);
		dispgm(a,b,1);
	}
}

static int sgn(a) int a; { if(a<0) return(-1); if (a>0) return(1); return(0); }

static int abs(a) int a; {return(a<0?-a:a);}

static int rnd() { seed=(seed*0x3295+0x1B0D)&0x7FFF; return(seed/512); } /* 0-63 */

static int coline() /* is there an object co-linear with enterprize? */
	{ int qx,qy,x0,y0,e; char a,b,c,d;
	if (ep.ix<0 || ep.ix>63 || ep.iy<0 || ep.iy>63) return(-1);
	dd=10000;
	qx=ep.ix&0xFFF8;
	qy=(ep.iy&0xFFF8)/4;
	for (a=0;a<8;++a)
	{ for (b=0;b<2;++b)
		{
		if ((d=galaxy[a+qx][b+qy])!=0)
		{
		for (c=0;c<4;++c)
			{
			if ((d&0x03)!=0)
			{
			x0=(a+qx)-ep.ix; y0=((b+qy)*4+c)-ep.iy;
			e=dist[abs(x0)][abs(y0)];
 if (abs(((direct[dir].sin+2)/4)*y0-((direct[dir].cos+2)/4)*x0)<e/4 &&
					 sgn(direct[dir].sin)==sgn(x0) &&
					 sgn(direct[dir].cos)==sgn(y0))
				{ if (e<dd) { dd=e; xx=qx+a; yy=(qy+b)*4+c;
				type=d&0x03;
				}
				}
			}
			d>>=2;
			}
		}
		}
	}
	if (dd==10000) return(0);
	if (type==3) return(1);
	if (type==1) b=numbas; else b=numklg;
	for(a=0;a<b;++a) {
	if (type==1 && sb[a].ix==xx && sb[a].iy==yy ||
		type==2 && kg[a].ix==xx && kg[a].iy==yy) {idx=a; break; }
	}
	return(1);
	}

static int kgcol(x) /* is there an object between klingon X and the enterprize? */
int x;
	{ int qx,qy,dx,dy,x0,y0,e; char a,b,c,d;
	dx=ep.ix-kg[x].ix; dy=ep.iy-kg[x].iy;
	dd=dist[abs(dx)][abs(dy)];
	qx=ep.ix&0xFFF8;
	qy=(ep.iy&0xFFF8)/4;
	for (a=0;a<8;++a)
	{ for (b=0;b<2;++b)
		{
		if ((d=galaxy[a+qx][b+qy])!=0)
		{
		for (c=0;c<4;++c)
			{
			if ((d&0x03)!=0)
			{
			x0=(a+qx)-kg[x].ix; y0=((b+qy)*4+c)-kg[x].iy;
			e=dist[abs(x0)][abs(y0)];
			if (sgn(dx)==sgn(x0) && sgn(dy)==sgn(y0) &&
				abs(dx*y0-dy*x0)<=e/3000)
				{ if (e<dd) { return(0); } }
			}
			d>>=2;
			}
		}
		}
	}
	return(1);
	}

static void settim(int t) { cursor(stats[TIMES].x,stats[TIMES].y-13);
		   sprintf(strg,"%-6.6d",t); prts(strg); }

static void upde() {
	char c;
	int a,b,d,e;
	a = -1;
	while((a=chkklg(a+1))!=-1) {
		if ((--kg[a].fire&0x7) != 0) continue;
/*
		if ((kg[a].fire&0xF)==0) {
			b= -1; e=0; d=dd;
			while((b=chkklg(b+1))!=-1) {if(a==b)continue;
			e =+ 10500-dd; }
			e =+ 5250;
			}
 */
		if (kgcol(a)!=1) continue;
		power=1500-dd/7;
		if (scnnr==0) {
			cursor(1+(ep.ix&0x7),32+(ep.iy&0x7)*2);
			revv(); outchr('E'); nrmv(); expe=2;
		}
		if (shlds==1) {
			if (shlde>=power) {
				setshl(shlds,shlde-power);
				power=0;
			} else {
				power =- shlde;
				setshl(shlds,0);
			}
		}
		if (power<150) continue;
		dd=rnd()/10; /* 0-5(6) */
		xx=(rnd()%10)+1; /* 1-10 */
		switch (dd) {
		case 0: /* damage to phasors */
			setphs(0-xx);
			break;
		case 1: /* damage to photon torpedos */
			if (phot<0) phot=savpht;
			savpht=(phot*(((yy=rnd())<60)+(yy<50)+(yy<30))+2)/3;
			setpht(0-xx);
			break;
		case 2: /* damage to warp engines */
			setwpe(xx);
			break;
		case 3:
			break;
		case 4: /* damage to shields */
			setshl(shlds,0-xx);
			break;
		case 5: /* damage to scanner */
			setscn(xx);
			break;
		case 6: /* damage to impulse engines */
			setimp(0-xx);
			break;
		}
		if (rnd()>crh) continue;
		if (crithit<20) {sethit(crithit+1); continue;}
		if (scnnr==0) {
			cursor(1+(ep.ix&0x7),32+(ep.iy&0x7)*2);
			revv(); outchr(' '); nrmv();
		}
		ep.ti=0;
		dispgm(ep.ix,ep.iy,0);
		prtwin(20);
		return(0);
	}
}

static char inchr() {
	char c;
	int a,b,d,e;
	if (init) {
		while((c=gc())==0) ++seed;
		cursor(17,52); cleol();
		if (c >= '0' && c <= '9') {
			skil = c-'0';
			c = 0;
			cursor(stats[LEVEL].x,stats[LEVEL].y+1); outchr(skil+'0');
			setdck(0);
		}
		init = 0;
		e = (rnd()*2+rnd())*2+rnd()+1; /* max 442 stars */
		for (a = 0; a < e; ++a) { /* make up to 442 stars */
			while ((galaxy[b=rnd()][(d=rnd())/4]&(0x03<<(d&0x03)*2))!=0);
			galaxy[b][d/4]|=(3<<(d&0x03)*2);
		}
		numbas = rnd()/skill[skil][2]+skill[skil][3]; /* number of bases */
		numklg = rnd()/skill[skil][0]+skill[skil][1]; /* nmbr of klingons */
		e = (numklg-skill[skil][4]-rnd()/skill[skil][5])/numbas; /* photons*/
		for (a = 0; a < numbas; ++a) {  /* init star bases */
			while ((galaxy[b=rnd()][(d=rnd())/4]&(0x03<<(d&0x03)*2))!=0);
			galaxy[b][d/4]|=(1<<(d&0x03)*2);
			sb[a].ix=b; sb[a].iy=d; sb[a].ti=e;
		}
		while (setent(rnd(),rnd()) == -1);
		for (a = 0; a < numklg; ++a) {  /* 30 klingons */
			while ((galaxy[b=rnd()][(d=rnd())/4]&(0x03<<(d&0x03)*2))!=0 ||
				((ep.ix^b|ep.iy^d)&0xFFF8)==0);
			galaxy[b][d/4]|=(2<<(d&0x03)*2);
			kg[a].ix=b;
			kg[a].iy=d;
			kg[a].ti=2000;
			kg[a].fire=(rnd()+8)/8;
		}
		setklg(numklg);
		if (skil!=0) t1 = numklg*skill[skil][6]+rnd()+skill[skil][7];
		crh = skill[skil][8]; /* critical hit chance */
		settim(t1);
		phre = skill[skil][9];
		shre = skill[skil][10];
		imre = skill[skil][11];
		return(c);
	}
	while((c=gcto())==0) {
		if ((++t0&0x7)==0) {
			if (skil!=0) {
				settim(--t1);
				if (t1<=0 && t2==0 && ep.ti!=0 && nklg!=0) prtwin(22);
			}
			if (imp<0) fiximp();
			if (phas<0) fixphs();
			if (shlde<0) fixshl();
			if (scnnr>0) fixscn();
			if (phot<0) fixpht();
			if (wrpe>0) fixwpe();
		}
		if (wrpe==0) { /* warp engines are working */
 			if (imp>=0 && imp<3000)
				setimp((imp+imre>3000 ? 3000 : imp+imre));
 			if (phas>=0 && phas<3000)
				setphs((phas+phre>3000 ? 3000 : phas+phre));
			if (shlde>=0 && shlde<3000) {
				a=(shlde+shre>3000 ? 3000 : shlde+shre);
				setshl(shlds,a);
			}
		}
		if (dock==0) setdck(0);    /* revise condition */
		if (explod.ti!=0 && --explod.ti==0 && scnnr==0) {
			cursor(1+(explod.ix&0x07),32+(explod.iy&0x07)*2);
			outchr(item[galaxy[explod.ix][explod.iy/4]>>(explod.iy&0x03)*2 &0x03]);
		}
		if (expe!=0 && --expe==0 && scnnr==0) {
			cursor(1+(ep.ix&0x07),32+(ep.iy&0x07)*2);
			if (ep.ti==0) outchr('.'); else outchr('E');
		}
		if (dock==0 && ep.ti!=0) {
			upde();
  		}
	}
	return(c);
}

static void hitinit() {
	char h;
	char *s;
	h = hit0();
	s = stats[CRTHIT].str + 16;
	while (*s != 0) {
		*s++ = h;
	}
}

static void sethit(int a) {
	if (a==0) {
		/* reset bargraph */
		cursor(stats[CRTHIT].x,stats[CRTHIT].y-19);
		prts(stats[CRTHIT].str);
	} else {
		/* add 1 or 2 ticks to current cell */
		cursor(stats[CRTHIT].x,(stats[CRTHIT].y-3)+(a-1)/2);
		hits(a&0x1);
	}
	crithit=a;
}

static char setklg(int a) {
	cursor(stats[KLGONS].x,stats[KLGONS].y);
	sprintf(strg,dec8,a); prts(strg);
	if (a==0) prtwin(21);
	nklg=a;
	return(1);  /* must return .TRUE. */
}

static int chkklg(a)
int a;
{
	int b;
	if (a<0||a>=numklg) return(-1);
	for (b=a;b<numklg;++b) {
		if (kg[b].ix==-1) continue;
		if (((kg[b].ix^ep.ix|kg[b].iy^ep.iy)&0xFFF8)==0) return(b);
	}
	return(-1);
}

static void fixwpe() {
	if (wrpe == 1) setwpe(0);
	else --wrpe;
}
static void setwpe(c)
char c;
{
	if (wrpe == c) return;
	cursor(stats[WRPST].x,stats[WRPST].y);
	if (c==0) prts(wrking);
	else prts(outstr);
	wrpe=c;
}

static void setdck(c)
char c;
{
	int ttt;
	if (dock == c) return;
	cursor(stats[DCKST].x,stats[DCKST].y);
	if (c) {
		prts("DOCKED  ");
		setshl(0,3000);  /* shields down */
		setphs(3000);	/* phasor energy = 3000 */
		setimp(3000);	/* impulse power = 3000 */
		if (phot<0) phot=savpht;
		ttt=(10-phot>sb[idx].ti?sb[idx].ti:10-phot);
		setpht(phot+ttt); sb[idx].ti =- ttt;
		if (wind==1) {
			cursor(16+idx,64);
			sprintf(strg,"%2.2d",sb[idx].ti); prts(strg);
		}
		setwpe(0);	/* warp engines working */
		if (scnnr!=0) {setscn(0); shortscan(); }
	} else if (chkklg(0)!=-1) {
		revv(); prts(" RED    "); nrmv();
	} else if (shlde<2500||phas<2500||wrpe!=0||imp<200||phot<0) prts("YELLOW  ");
	else prts("GREEN   ");
	dock=c;
}

static void fixpht() {
	if (phot == -1) setpht(savpht);
	else ++phot;
}
static void setpht(a)
int a;
{
	if (phot == a) return;
	cursor(stats[PHTST].x,stats[PHTST].y);
	if (a<0) prts(outstr);
	else {
		sprintf(strg,dec8,a);
		prts(strg);
	}
	phot=a;
}

static void fixphs() {
	if (phas == -1) setphs(0);
	else ++phas;
}
static void setphs(a)
int a;
{
	if (phas == a) return;
	cursor(stats[PHSST].x,stats[PHSST].y);
	if (a<0) prts(outstr);
	else {
		sprintf(strg,dec8,a);
		prts(strg);
	}
	phas=a;
}

static void fiximp() {
	if (imp == -1) setimp(0);
	else ++imp;
}
static void setimp(a)
int a;
{
	if (imp == a) return;
	cursor(stats[IMPST].x,stats[IMPST].y);
	if (a<0) prts(outstr);
	else {
		sprintf(strg,dec8,a);
		prts(strg);
	}
	imp=a;
}

static void setcom(c)
int c;
{
	if (cmmnd == c) return;
	cursor(commnd[COM1ST+cmmnd].x,commnd[COM1ST+cmmnd].y);
	outchr(' ');
	cursor(commnd[COM1ST+c].x,commnd[COM1ST+c].y);
	pos0();
	cmmnd=c;
}

static void setop(c)
int c;
{
	if (oprnd == c) return;
	cursor(opcom[OPS1ST+oprnd].x,opcom[OPS1ST+oprnd].y); outchr(' ');
	cursor(opcom[OPS1ST+c].x,opcom[OPS1ST+c].y); outchr('*');
	oprnd=c;
}

static void fixscn() {
	if (scnnr == 1) {
		setscn(0);
		shortscan();
	} else --scnnr;
}
static void setscn(c)
char c;
{
	char a;
	if (scnnr == c) return;
	cursor(stats[SCNST].x,stats[SCNST].y);
	if (c==0) prts(wrking);
	else {
		prts(outstr);
		for (a=0;a<8;++a) {
			cursor(a+1,32); prts("               ");
		}
	}
	scnnr=c;
}


static void setdir(a)
char a;
{
	if (dir == a) return;
	if (dir >= 0) {
		cursor(direct[dir].x,direct[dir].y);
		outchr(' ');
	}
	cursor(direct[a].x,direct[a].y);
	pos0();
	dir=a;
}

static void fixshl() {
	if (shlde == -1) setshl(shlds,0);
	else ++shlde;
}
static void setshl(a,b)
int a,b;
{
	if (shlds == a && shlde == b) return;
	shlds=a;
	shlde=b;
	cursor(15,38);
	if (shlde<=0) a=0;
	putshl(15,38,a);
	cursor(stats[SHLDST].x,stats[SHLDST].y);
	if (a) {
		sprintf(strg,"UP %-4.4d ",shlde); prts(strg);
	} else if (shlde<=0) prts(outstr);
	else prts("DOWN    ");
}

static int setent(a,b)
int a,b;
{
	char f,g,h;
	if (ep.ix == a && ep.iy == b) return(0); /* TODO: right value? */
	if (g= !(a<0 || a>63 || b<0 || b>63)) {
		if ((galaxy[a][b/4]&(0x03<< (b&0x03)*2)) != 0) return(-1);
	}
	expe=0;
	h= !(ep.ix<0 || ep.ix>63 || ep.iy<0 || ep.iy>63);
	if (f=(((ep.ix^a|ep.iy^b)&0xFFF8)!=0)) {
		dispgm(ep.ix,ep.iy,0);	/* clear galaxy map current position marker */
		dispgm(a,b,1);		  /* set galaxy map current position */
	} else if (!f && g && h && scnnr==0) {
		cursor(1+(ep.ix&0x07),32+(ep.iy&0x07)*2); outchr('.');
		cursor(1+(a&0x07),32+(b&0x07)*2);
		if (expe!=0) { revv(); outchr('E'); nrmv(); }
		else outchr('E');
	}
	ep.ix=a; ep.iy=b;
	cursor(stats[QUADR].x,stats[QUADR].y-6);
	sprintf(strg,"%3.3d,%3.3d ",ep.ix,ep.iy);
	prts(strg);
	if (f) shortscan();
	if (dock != chkdck()) setdck(1-dock);
	return(0);
}

static char chkdck() {
	int aa,bb;
	for(idx=0;idx<numbas;++idx) {
		if (sb[idx].ix==-1) continue;
		if (((ep.ix^sb[idx].ix|ep.iy^sb[idx].iy)&0xFFF8)!=0) continue;
		aa=abs(ep.ix-sb[idx].ix); bb=abs(ep.iy-sb[idx].iy);
		if (aa==0 && bb==1 || aa==1 && bb==0) return(1);
	}
	return(0);
}

static void longscan() {
	int a,b;
	if (scnnr==0) {
		for (a= -1;a<2;++a) {
			for (b= -1;b<2;++b) {
				if (a==0 && b==0) continue;
				dispgm(ep.ix+a*8,ep.iy+b*8,0);
			}
		}
	}
}

static void dispgm(a,b,c)
int a,b;
char c;
{
	char d,e,k,s;
	int f;
	if (a<0 || a>63 || b<0 || b>63) return(0);
	k=s=0;
	a=a&0xFFF8;
	b=(b&0xFFF8)/4;
	for (d=0;d<8;++d) {
		f = galaxy[d+a][b]<<8 | galaxy[d+a][b+1];
		for (e=0;e<8;++e) {
			if ((f&0x03) == 1) s=1;
			if ((f&0x03) == 2) ++k;
			f=f>>2;
		}
	}
	if (c) revv();
	cursor(14+a/8,2+(b/2)*3);
	outchr(k+'0'); outchr(s?'+':' ');
	if (c) nrmv();
}

static void shortscan() {
	char a,b,c;
	int qx,qy;
	explod.ti=0;
	if (scnnr==0) {
		if (ep.ix<0 || ep.ix>63 || ep.iy<0 || ep.iy>63) {
			for (a=0;a<8;++a) {
				cursor(a+1,32);
				prts("? ? ? ? ? ? ? ?");
			}
			return(0);
		}
		qy=ep.ix&0xFFF8;
		qx=(ep.iy&0xFFF8)/4;
		for (a=0;a<8;++a) {
			cursor(a+1,32);
			for (b=0;b<2;++b) {
				for (c=0;c<4;++c) {
					outchr(item[(galaxy[a+qy][b+qx]>>(c*2))&0x03]);
					outchr(' ');
				}
			}
		}
		if (ep.ti!=0) {
			cursor(1+(ep.ix&0x07),32+(ep.iy&0x07)*2);
			outchr('E');
		}
	}
}

static void botline() { llc(); horz(28,0); lrc(); }

static void frame() {
	char a;
	clrscr();	/* clear screen and home */
	ulc(); horz(10,1); prts(" STATUS "); horz(10,1); urc();
	ulc(); horz(17,1); urc();
	ulc(); horz(9,1); prts(" COMMAND "); horz(10,1); urc();
	for (a = 1; a < 9; ++a) {
		cursor(a,0); vl(1);
		cursor(a,29); vl(0); vl(1);
		cursor(a,48); vl(0); vl(1);
		cursor(a,78); vl(0);
	}
	cursor(9,0); vl(1);
	cursor(9,29); vl(0); llc(); horz(4,0); prts(" SCANNER "); horz(4,0); lrc(); vl(1);
	cursor(9,78); vl(0);
	for (a = 10; a < 12; ++a) {
		cursor(a,0); vl(1);
		cursor(a,29); vl(0);
		cursor(a,49); vl(1);
		cursor(a,78); vl(0);
	}
	cursor(12,0); botline();
	cursor(12,49); botline();
	cursor(13,0); ulc(); horz(5,1); prts(" GALACTIC MAP "); horz(6,1); urc();
	for (a = 14; a < 22; ++a) {
		cursor(a,0); vl(1); cursor(a,26); vl(0);
	}
	cursor(22,0); llc(); horz(25,0); lrc();
	cursor(12,39);       outchr('|');
	cursor(13,33);  prts("\\     |     /");
	cursor(14,35);    prts("\\   |   /");
	cursor(15,37);      prts("\\   /");
	cursor(16,31); prts("- - - - E - - - -");
	cursor(17,37);      prts("/   \\");
	cursor(18,35);     prts("/   |   \\");
	cursor(19,33);   prts("/     |     \\");
	cursor(20,39);       outchr('|');
	cursor(22,35);     prts("DIRECTION");
	for (a = 0; a < STRCOM; ++a) {
		cursor(commnd[a].x,commnd[a].y);
		prts(commnd[a].str);
	}
	for (a = 0; a < NUMSTS; ++a) {
		cursor(stats[a].x,stats[a].y-19);
		prts(stats[a].str);
	}
}

int prts(char *s) {
	while (*s != 0) { outchr(*s++); }
	return(1);
}

/* end */
