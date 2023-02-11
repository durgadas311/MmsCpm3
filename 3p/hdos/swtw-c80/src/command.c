/* command: expand wild cards in the command line.
 * usage: command(&argc, &argv) modifies argc and argv as necessary
 *
 * uses sbrk to create the new arg list
 * mod. 11/14/80: checks DK:; accepts dk?:/sy?:.
 */

#define MAXFILES 255	/* max number of expanded files */
#define ENTR 22 /* number of entries per [track?] */
#define SLOP 6	/* number of characters between [tracks?] */
#define FNSIZE 17	/* filename: 4(SY1:)+8+1+3+null */

int COMdir[7] = {0,0,0,0,0,0,0}; /* may have directory for sy0-2:, dk0-3: */
char *COMunit = "0120123";	  /* Unit numbers */
int COMnf,*COMfn;

int COMc,*COMv;
char *COMarg,*COMs;

command(argcp,argvp)
int *argcp,*argvp;
{
	int f_alloc[MAXFILES];

	COMfn = f_alloc;
	COMnf = 0;
	COMc = *argcp;
	COMv = *argvp;
	for (COMarg = *COMv; COMc--; COMarg = *++COMv)
	{	for (COMs = COMarg; *COMs; COMs++)
			if (*COMs == '?' || *COMs == '*')
			{	expand();
				goto contn;  /* expand each name at most once */
			}
		COMfn[COMnf++] = COMarg; /* no expansion */
	    contn:;
	}
	*argcp = COMnf;
	COMv = *argvp = sbrk(2 * COMnf);
	while (COMnf--) COMv[COMnf] = COMfn[COMnf];
}

char *EXPname = "sy?:direct.sys";
char *EXPdknam= "dk?:direct.sys";
#define UNIT 2	/* UNIT is the place in the string to plug in the drive */

int EXPn,*EXPd,EXPfull;
char *EXPf,*EXPa,*EXPnext,*EXPfile;

expand() /* expand * and/or ? */
{	int i;
	if (COMarg && COMarg[1] && COMarg[2] == '?' && COMarg[3] == ':') {
		for (i = '0'; i < '4'; ++i) {
			COMarg[UNIT] = i; expand(); }
		return; }
	EXPfull = 1;	/* most filenames are complete */
	if (COMarg[3] == ':' && COMarg[2] >= '0') {	/* It's a device */
		EXPn = COMarg[2] - '0';
		if (COMarg[0]=='S' && COMarg[1]=='Y' && COMarg[2]<='2');
		else if (COMarg[0]=='D' && COMarg[1]=='K' && COMarg[2]<='3')
			{ EXPn =+ 3; EXPname = EXPdkname; }
		else return; }				/* Not one we know */
	else EXPfull = EXPn = 0;  /* SY0: assumed */
	EXPname[UNIT] = COMunit[EXPn];
	if (rdir(EXPn)) 	/* check the directory if we haven't yet */
	 for (EXPd = COMdir[EXPn]; EXPd; EXPd = *EXPd) /* ck each filename */
	{	EXPf = EXPd + 1;
		while (*EXPf++ != ':');  /* skip to filename */
		EXPa = COMarg;
		if (EXPfull) while (*EXPa++ != ':'); /* skip in the arg */

		for (; *EXPf && *EXPa; EXPf++, EXPa++)
		{	if (*EXPa == '?' || *EXPa == *EXPf) continue; /* match*/
			if (*EXPa != '*') goto outloop; /* failed to match */
			EXPnext = *++EXPa; /* got a *; scan in f to next ltr */
			if (EXPnext == 0) goto success; /* * at end of string */
			while (*EXPf) if (*EXPf++ == EXPnext) break;
			if (*--EXPf == EXPnext) continue; /* matched the * */
			goto outloop;	/* didn't match char after */
		}
		if (*EXPf || *EXPa) continue;
	    success:
		COMfn[COMnf++] = EXPd + 1; /* matched */
		if (COMnf >= MAXFILES) err("Too many filenames.\n");
	    outloop:;
	}
}

err(s) char *s; {
	while (putchar(*s++)); exit(); }

strmatch(string,prefix) /* does string start with prefix? */
char *string, *prefix;
{	while (*string && *prefix) if (*string++ != *prefix++) return 0;
	return (*prefix? 0 : 1); /* string ran out before prefix ? */
}

int Rc,Ri,Rj,Rk,Rl,Rdirfd,Rnentry,*Rd;
char *Rs,*Rt,*Rentry;

rdir(n) /* read directory for sy<n> */
int n;
{	char entry[23];

	Rentry = entry;
	if (COMdir[n]) return 1;  /* already taken care of */
	if ((Rdirfd = fopen(EXPname,"rb")) == 0) return 0;  /* Not mounted */

	for (Rnentry = 0, Rd = &COMdir[n];;)
	{
		for (Rk = 0; Rk < ENTR; Rk++)
		{	for (Ri = 0; Ri < 23; Ri++)
			{	if ((Rc = getc(Rdirfd)) == -1) goto done;
				entry[Ri] = Rc;
			}
			Rj = entry[0] & 0377;
			if (Rj == 0376) goto done; /* i think this works */
			if (Rj != 0377)
			{	Rl = 8; /* length of alloc */
				for (Ri = 0; Ri < 8; Ri++) if (Rentry[Ri]) Rl++;
				for (Ri = 8; Ri < 11;Ri++) if (Rentry[Ri]) Rl++;
				*Rd = sbrk(Rl);
				Rd = *Rd;
				Rs = Rd + 1;
				*Rs++ = EXPname[0];
				*Rs++ = EXPname[1];
				*Rs++ = EXPname[2];
				*Rs++ = ':';
				for (Ri = 0; Ri < 8; Ri++)
					if (Rc = Rentry[Ri]) *Rs++ = Rc;
				*Rs++ = '.';
				for (Ri = 8; Ri < 11; Ri++)
					if (Rc = Rentry[Ri]) *Rs++ = Rc;
				*Rs++ = 0;
				*Rd = 0; /* last entry in the list */
			}
		}
		for (Ri = 0; Ri < SLOP; Ri++) getc(Rdirfd);
	}
    done:
	fclose(Rdirfd);
	return 1;
}
