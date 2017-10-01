/* Floppy disk IO module menu functions
 *
 * Version 3.103
 *
 * Date lasted modified: 7/4/84 14:31 drm
 *
 * "DISKIO.C"
 *
 */

#include "SETUP30.H"

#define  NCOL	12
#define  ACOL	11
#define  STCOL	3
#define  STLNE	6

setdiskio(maindsk,filename)		/* Main entry point for this menu */
	DISKTABL *maindsk;
	char *filename;
	{
	DISKTABL dskentry;
	bool confg;
	short inp,i;

	cpydsk(dskentry,maindsk);
	for(confg=TRUE,i=0;i<dskentry.compart.numdev;++i)
		if(dskentry.floppart[i].floppy)
			confg=FALSE;
	initcur(STLNE,dskentry.compart.numdev,STCOL,NCOL,9,6,7,4,4,8,7,4,4,8,9);
	prtdhd(dskentry,confg);
	prtdvar(dskentry,confg);
	prtcur(filename);
	curline=0; curcol=3;  oldcol=99;
	prtdmsg(dskentry,confg);
	if(confg)
		bell();
	do
		{
		inp=getdfld(dskentry,confg);
		if(inp==WHITE)
			{
			cpydsk(dskentry,maindsk);
			prtdvar(dskentry,confg);
			curline=0; curcol=3;
			}
		if(inp==BLUE)
			{
			if(confg)
				return;
			cpydsk(maindsk,dskentry);
			if(putdisktbl(dskentry)==ERROR)
				{
				putwin(7,errmsg(errno()));
				bell();
				inp=NULL;
				}
			}
		}
	while(inp!=BLUE && inp!=RED);
	curon();
	}

cpydsk(dsk1,dsk2)			/* copys dsk1 into dsk2 */
	DISKTABL *dsk1,*dsk2;
	{
	movmem(dsk2,dsk1,sizeof *dsk1);    
	}			       

prtdhd(dskentry,confg) 
	bool confg;
	DISKTABL *dskentry;
	{
	clrscr();
	printf(dskentry->compart.string);
	if(confg)
		{
		cursor(6*getwidth()+24);
		puts("Module not user configurable");
		return;
		}
	cursor(((STLNE-4)*getwidth())+18);
	printf("------Physical Drive-------");
	printf(" -------Default Media Mode--------\n");
	printf("Logical Physical Disk No of     Record");
	printf("  Step No of     Record  Media    Sector\n");
	printf(" Name    Number  Size Heads TPI Density");
	printf(" Rate Sides TPI Density Format   Size\n");
	}

prtdvar(dskentry,confg) 		    /* print variable portion */
	bool confg;
	DISKTABL *dskentry;
	{
	short i;

	if(confg)
		return;
	curoff();
	for(curline=0;curline<dskentry->compart.numdev;++curline)
		{
		for(curcol=0;curcol<NCOL;++curcol)
			if(dskentry->floppart[curline].floppy || (curcol!=0 && curcol!=1))
				prtfld(dskentry);
			else
				prtcnt(".");
		prtsecsiz(dskentry);
		}
	curon();
	}

getdfld(dskentry,confg) 		   /* select and execute a field */
	bool confg;
	DISKTABL *dskentry;
	{
	FLOPDEV flptemp;    /* temporary copy of table for error handling */
	short inp,er,er2;

	if(confg)
		return(getcntrl());
	currnt();
	curon();
	do
		{
		inp=getcntrl();
		putwin(7,"");
		if(inp==BLUE || inp==RED || inp==WHITE)
			return(inp);
		if(dskentry->floppart[curline].medmask[0]==0x7F && dskentry->floppart[curline].medmask[1]==0xFF)
			movcur(inp,ACOL-1,dskentry->compart.numdev);
		else
			movcur(inp,ACOL,dskentry->compart.numdev);
		if(curcol<=3 || inp==HMCD)
			curcol=3;
		prtdmsg(dskentry,confg);
		if(curcol==10)
			lstfmt(dskentry->floppart[curline]);
		currnt();
		curon();
		}
	while(inp!=NULL);
	if(dskentry->floppart[curline].floppy)
		{
		movmem(dskentry->floppart[curline],&flptemp,sizeof flptemp);
		switch(curcol)
			{
		case 3:
			er=dsidfld(dskentry->floppart[curline]);
			break;
		case 4:
			er=dtrkfld(dskentry->floppart[curline]);
			break;
		case 5:
			er=drecfld(dskentry->floppart[curline]);
			break;
		case 6:
			er=steprtfld(dskentry->floppart[curline]);
			break;
		case 7:
			er=msidfld(dskentry->floppart[curline]);
			break;
		case 8:
			er=mtrkfld(dskentry->floppart[curline]);
			break;
		case 9:
			er=mrecfld(dskentry->floppart[curline]);
			break;
		case 10:
			er=mformat(dskentry->floppart[curline]);
			break;
			}
		if((er2=serdp(dskentry->floppart[curline]))!=NULL)
			notsupmsg();
		if(er==ERROR || er2!=NULL)
			{
			cntrlbuf=NULL;
			bell();
			movmem(&flptemp,dskentry->floppart[curline],sizeof flptemp);
			}	
		curoff();
		prtfld(dskentry);
		prtsecsiz(dskentry);
		}
	else
		bell();
	return(NULL);
	}

prtdmsg(dskentry,confg) 		 /* print window help messages */
	bool confg;
	DISKTABL *dskentry;
	{
	if(confg)
		return;
	if(!dskentry->floppart[curline].floppy)
		{
		clmn();
		oldcol=99;
		return;
		}
	if(oldcol==curcol)
		return;
	oldcol=curcol;
	putwin(1,"");
	putwin(2,"");
	switch(curcol)
		{
	case 3:
	case 7:
		putwin(3,"1 = Single Sided");	
		putwin(4,"2 = Double Sided");
		putwin(5,"");
		putwin(6,"");
		break;
	case 4:
	case 8:
		putwin(3,"48 tpi (40 track)");
		putwin(4,"96 tpi (80 track)");
		putwin(5,"");
		putwin(6,"");
		break;
	case 5:
	case 9:
		putwin(3,"S = Single Density recording");
		putwin(4,"D = Double Density recording");
		putwin(5,"");
		putwin(6,"");
		break;
	case 6:
		putwin(2,"    8\"    5.25\"");
		putwin(3,"   3ms     6ms");
		putwin(4,"   6ms    12ms");
		putwin(5,"  10ms    20ms");
		putwin(6,"  15ms    30ms");
		break;
	case 10:
		break;
		}
	}

lstfmt(flpentry)		/* lists the valid formats for the drive */
	FLOPDEV *flpentry;
	{
	short fmtcd,i,cnt,lne;
	char *cpt;
	
	cnt=0; lne=1;
	curoff();
	cursor((lne-1+STMNLNE)*getwidth()+STMNCOL);
	puts("     ");
	for(fmtcd=15;fmtcd>=1;--fmtcd)
		{
		if(testbit(&flpentry->medmask,fmtcd)==0)
			{
			cpt=getfmt(fmtcd);
			for(i=0;i<FMTBLEN;++i)
				if(cpt==NULL)
					outchr(' ');
				else
					outchr(cpt[i]);
			outchr(' ');
			if(++cnt>=3)
				{
				clreel();
				cursor((++lne-1+STMNLNE)*getwidth()+STMNCOL);
				puts("     ");
				cnt=0;
				}
			}
		}
	clreel();
	while(lne<7)
		prtwin(++lne,"");
	}

 
dsidfld(flpentry)			/* drive/controller number of sides */
	FLOPDEV *flpentry;
	{
	short inp;
	
	inp=getchr();
	if(flpentry->drive_cont.sidemask)
		{
		if(inp=='1')
			{
			if(!flpentry->media.numsides)
				{
				putwin(7,"DS media in SS drive");
				return(ERROR);
				}
			else
				flpentry->drive_cont.numsides=TRUE;
			}
		else if(inp=='2')
			flpentry->drive_cont.numsides=FALSE;
		else if(inp!=NULL)
			return(ERROR);
		}
	else
		return(notsupmsg());
	return(OK);
	}

dtrkfld(flpentry)			/* drive/controller track density */
	FLOPDEV *flpentry;
	{
	short inp,temp;
	
	inp=getnum(2,&temp);
	if(flpentry->drive_cont.trkmask)
		{
		if(inp!=NULL)
			if(temp<60)
				{
				if(!flpentry->media.trkden)
					{
					putwin(7,"96 tpi media in a 48 tpi drive");
					return(ERROR);
					}
				else
					flpentry->drive_cont.trkden=TRUE;
				}
			else 
				flpentry->drive_cont.trkden=FALSE;
		}
	else
		return(notsupmsg());
	return(OK);
	}
 
drecfld(flpentry)			/* drive/controller record density */
	FLOPDEV *flpentry;
	{
	short inp;
	
	inp=toupper(getchr());
	if(flpentry->drive_cont.recmask)
		{
		if(inp=='S')
			{
			if(!flpentry->media.recden)
				{	
				putwin(7,"DD media in a SD drive");
				return(ERROR);
				}
			else
				flpentry->drive_cont.recden=TRUE;
			}
		else if(inp=='D')
			flpentry->drive_cont.recden=FALSE;
		else if(inp!=NULL)
			return(ERROR);
		}
	else
		return(notsupmsg());
	return(OK);
	}

steprtfld(flpentry)			/* step rate field */
	FLOPDEV *flpentry;
	{
	short inp,temp;
	
	inp=getnum(2,&temp);
	if(inp!=NULL)
		{
		if(flpentry->stepmask)
			{
			if(flpentry->disksize)
				{
				if(temp<=4)		/* 8" disk */
					temp=3;
				else if(temp<=8)
					temp=6;
				else if(temp<=12)
					temp=10;
				else 
					temp=15;
				}
			else
				{			/* 5.25" */
				if(temp<=8)
					temp=6;
				else if(temp<=15)
					temp=12;
				else if(temp<=25)
					temp=20;
				else 
					temp=30;
				}
			flpentry->steprate=temp;
			}
		else
			return(notsupmsg());
		}
	return(OK);
	}
 
msidfld(flpentry)		/* media number of sides field */
	FLOPDEV *flpentry;
	{
	short inp;
	
	inp=getchr();
	if(flpentry->media.sidemask)
		{
		if(inp=='1')
			flpentry->media.numsides=TRUE;
		else if(inp=='2')
			{
			if(flpentry->drive_cont.numsides)
				{
				putwin(7,"DS media in SS drive");
				return(ERROR);
				}
			else
				flpentry->media.numsides=FALSE;
			}
		else if(inp!=NULL)
			return(ERROR);
		}
	else
		return(notsupmsg());
	return(OK);
	}

mtrkfld(flpentry)		/* media track density field */
	FLOPDEV *flpentry;
	{
	short inp,temp;
	
	inp=getnum(2,&temp);
	if(flpentry->media.trkmask)
		{
		if(inp!=NULL)
			if(temp<60)
				flpentry->media.trkden=TRUE;
			else 
				{
				if(flpentry->drive_cont.trkden)
					{
					putwin(7,"96 tpi media in a 48 tpi drive");
					return(ERROR);
					}
				else
					flpentry->media.trkden=FALSE;
				}
		}
	else
		return(notsupmsg());
	return(OK);
	}
 
mrecfld(flpentry)			/* media record density field */
	FLOPDEV *flpentry;
	{
	short inp;
	
	inp=toupper(getchr());
	if(flpentry->media.recmask)
		{
		if(inp=='S')
			flpentry->media.recden=TRUE;
		else if(inp=='D')
			{
			if(flpentry->drive_cont.recden)
				{	
				putwin(7,"DD media in a SD drive");
				return(ERROR);
				}
			else
				flpentry->media.recden=FALSE;
			}
		else if(inp!=NULL)
			return(ERROR);
		}
	else
		return(notsupmsg());
	return(OK);
	}

mformat(flpentry)		/* media format field */
	FLOPDEV *flpentry;
	{
	short inp,fmtcd;
	char temp[9];

	inp=getstr(8,temp);
	if(inp!=NULL)
		{
		if((fmtcd=searchfmt(temp))==ERROR)
			{
			if(serdpadr==NULL)	
				return(OK);
			else
				{
				putwin(7,"Format does not exist");
				return(ERROR);
				}
			}
		if(testbit(&flpentry->medmask,fmtcd)==0)
			flpentry->medforcd=fmtcd;
		else
			{				 
			notsupmsg();
			return(ERROR);
			}
		}
	return(OK);
	}

searchfmt(fmtstr)
	char *fmtstr;
	{
	short fmtcd;
	char *getfmt();
	
	if(getfmt(1)==NULL)
		return(ERROR);
	for(fmtcd=1;fmtcd<=15;++fmtcd)
		if(cmpfmt(fmtstr,getfmt(fmtcd)))
			return(fmtcd);
	return(ERROR);
	}

cmpfmt(fmtstr,tblpt)
	char *fmtstr,*tblpt;
	{
	short i;

	for(i=0;(i<FMTBLEN && tblpt[i]!=' ') || fmtstr[i]!=NULL;++i)
		{
		if(fmtstr[i]!=tblpt[i])
			return(FALSE);
		}
	return(TRUE);
	}

notsupmsg()
	{
	if(serdpadr==NULL)
		putwin(7,"GETDP.REL not linked in");
	else
		putwin(7,"Not support by this drive");
	return(ERROR);
	}

prtfld(dskentry)
	DISKTABL *dskentry;
	{
	switch(curcol)
		{
	case 0:
		prtdrvlt(dskentry);
		break;
	case 1:
		prtphydrv(dskentry);
		break;
	case 2:
		prtdsiz(dskentry);
		break;
	case 3:
		prtsides(dskentry->floppart[curline].drive_cont);
		break;
	case 4:
		prttrkden(dskentry->floppart[curline].drive_cont);
		break;
	case 5:
		prtrecden(dskentry->floppart[curline].drive_cont);
		break;
	case 6:
		prtstrt(dskentry);
		break;
	case 7:
		prtsides(dskentry->floppart[curline].media);
		break;
	case 8:
		prttrkden(dskentry->floppart[curline].media);
		break;
	case 9:
		prtrecden(dskentry->floppart[curline].media);
		break;
	case 10:
		prtformat(dskentry);
		}
	}

prtphydrv(dskentry)
	DISKTABL *dskentry;
	{
	prtcnt("%d",dskentry->compart.phydevnum+curline);
	}

prtdsiz(dskentry)
	DISKTABL *dskentry;
	{
	if(dskentry->floppart[curline].disksize)
		prtcnt("8\"");
	else
		prtcnt("5.25\"");
	}

prtdrvlt(dskentry)
	DISKTABL *dskentry;
	{
	short drv;

	if((drv=searchlp(dskentry->compart.phydevnum+curline))!=ERROR)
		prtcnt("%c",drv+'A');
	else
		prtcnt(".");
	}

searchlp(devnum)			/* search logical-physcial table */
	ushort(devnum); 		/* device number */
	{
	short i;

	for(i=0;i<MAXDRV;++i)
		if(drivtable.logphytbl[i]==devnum)
			return(i);
	return(ERROR);
	}

prtsides(flpchar)			/* print number of sides-both media */
	FLOPCHAR *flpchar;		/*  and drive/controller */
	{
	if(flpchar->numsides)
		prtcnt("1");
	else
		prtcnt("2");
	}

prttrkden(flpchar)			/* print track density */
	FLOPCHAR *flpchar;
	{
	if(flpchar->trkden)
		prtcnt("48");
	else
		prtcnt("96");
	}

prtrecden(flpchar)			/* print record density */
	FLOPCHAR *flpchar;
	{
	if(flpchar->recden)
		prtcnt("Single");
	else
		prtcnt("Double");
	}

prtstrt(dskentry)			/* print step rate */
	DISKTABL *dskentry;
	{
	prtcnt("%2.2ums ",dskentry->floppart[curline].steprate);
	}

prtformat(dskentry)			/* print format field */
	DISKTABL *dskentry;
	{
	short i;
	char *cpt,*getfmt();

	currnt();
	cpt=getfmt(dskentry->floppart[curline].medforcd);
	for(i=0;i<FMTBLEN;++i)
		if(cpt==NULL)
			outchr(' ');
		else
			outchr(cpt[i]);
	}
 
 
char *getfmt(fmtcd)			/* get format string from format */
	short fmtcd;			/* code - calls serdp with dummy */
	{				/* mode */
	byte dummode[4];
	char *tblpt;

	if(serdpadr==NULL)
		return(NULL);
	initb(dummode,"0,1,128,0");
	tblpt=call(serdpadr,0,serdpadr,0,dummode)+serdpadr+((15-fmtcd)*FMTBLEN);	return(tblpt);
	}

prtsecsiz(dskentry) 
	DISKTABL *dskentry;
	{
	prtpos(curline,11,"%-4.4d",getsecsiz(dskentry->floppart[curline]));
	}

getsecsiz(flpentry)
	FLOPDEV *flpentry;
	{
	switch(flpentry->modebyt[2] & 0x03)
		{
	case 0:
		return(128);
	case 1:
		return(256);
	case 2:
		return(512);
	case 3:
		return(1024);
		}
	}			      

