/* Bios file to module table 
 * conversion and moving functions.
 *
 * Last updated 1/31/84  11:47 mjm
 *
 * Version 3.103
 * 
 * "BTCONV.C"
 *
 */

#include "SETUP30.H"
 
gettables()
	{
	short test,er;
	word thread,nxtthd;
	
	if(getthdstr(&thread)==ERROR)
		return(ERROR);
	if(getnxtthd(&nxtthd,thread)==ERROR)
		return(ERROR);
	while(nxtthd!=NULL)
		{
		if((test=testchario(thread))==ERROR)
			return(ERROR);
		if(test==TRUE)		/* if character io module */
			{
			if((er=getcpt())<=ERROR)
				return(er);
			if((er=btcom(chrptrtbl[numchario]->compart,thread))<=ERROR)
				return(er);
			if((er=btchario(chrptrtbl[numchario],thread))<=ERROR)
				return(er);
			++numchario;
			}
		else			/* disk io module */
			{
			if((er=getdpt())<=ERROR)
				return(er);
			if((er=btcom(dskptrtbl[numdiskio]->compart,thread))<=ERROR)
				return(er);
			if((er=btdiskio(dskptrtbl[numdiskio],thread))<=ERROR)
				return(er);
			++numdiskio;
			}
		thread=nxtthd;
		if(getnxtthd(&nxtthd,thread)==ERROR)
			return(ERROR);
		}
	return(OK);
	}

testchario(modstr)		/* TRUE if module is chario */
	word modstr;
	{
	byte phynum;
	
	if(getbyte(&phynum,modstr+PHYDEVNUM)==ERROR)
		return(ERROR);
	if(phynum>=CHIONUM)
		return(TRUE);
	else
		return(FALSE);
	}

getcpt()			/* get free space for a CHARTABL entry */
	{
	CHARTABL *dumchr;

	if(numchario>=MAXCHR)
		return(ERROR-1);
	if((chrptrtbl[numchario]=alloc(sizeof *dumchr))==NULL)
		return(ERROR-5);
	return(OK);
	}

getdpt()			/* get free space for a DISKTABL entry */
	{
	DISKTABL *dumdsk;

	if(numdiskio>=MAXCHR)
		return(ERROR-2);
	if((dskptrtbl[numdiskio]=alloc(sizeof *dumdsk))==NULL)
		return(ERROR-5);
	return(OK);
	}

getthdstr(dptr) 		/* get starting thread */
	word *dptr;
	{
	return(getword(dptr,biosstart+THRDSTR));
	}

getnxtthd(nxtthd,thd)		    /* get next thread (module) */
	word *nxtthd,thd;
	{
	return(getword(nxtthd,thd));
	}

btcom(compart,modstr)		/* Moves the common part of all modules */
	COMTABL *compart;	/* to a module table */
	word modstr;
	{
	word stradr,i;
	char c;

	if(getbyte(&compart->phydevnum,modstr+PHYDEVNUM)==ERROR)
		return(ERROR);
	if(getbyte(&compart->numdev,modstr+NUMDEV)==ERROR)
		return(ERROR);
	if(compart->phydevnum>=CHIONUM)
		modstr+=CHRSTRADR;
	else
		modstr+=DSKSTRADR;
	if(getword(&stradr,modstr)==ERROR)
		return(ERROR);
	for(c=NULL,i=0;c!='$';++stradr)
		{
		if(getbyte(&c,stradr)==ERROR)
			return(ERROR);
		if(i>=MAXSTRL)
			return(ERROR-6);
		if(c>=' ')
			compart->string[i++]=c;
		}
	compart->string[i-1]=NULL;
	return(OK);
	}

btchario(chrmod,modstr)
	CHARTABL *chrmod;
	word modstr;
	{
	word i,xmodadr,chrtbladr;
	
	if(getxmadr(&xmodadr,modstr)==ERROR)
		return(ERROR);
	if(getctadr(&chrtbladr,modstr,chrmod->compart.phydevnum)==ERROR)
		return(ERROR);
	for(i=0;i<chrmod->compart.numdev;++i)
		{
		if(i>=MAXCDEV)
			return(ERROR-3);
		chrmod->charpart[i].xmodeaddr=xmodadr;
		if(btxmode(&chrmod->charpart[i])==ERROR)
			return(ERROR);
		chrmod->charpart[i].chtbladdr=chrtbladr;
		if(btchrtbl(&chrmod->charpart[i])==ERROR)
			return(ERROR);
		chrtbladr+=8;
		xmodadr+=4;
		}
	if(chrmod->compart.phydevnum==NETLSTN)
		return(getnode(modstr));	/* in netnode.c */
	return(OK);			
	}

btdiskio(diskmod,modstr)
	DISKTABL *diskmod;
	word modstr;
	{
	word modeadr;
	short i;

	if(getmadr(&modeadr,modstr)==ERROR)
		return(ERROR);
	for(i=0;i<diskmod->compart.numdev;++i)
		{
		if(i>=MAXFDEV)
			return(ERROR-4);
		diskmod->floppart[i].modeaddr=modeadr;
		if(btmode(&diskmod->floppart[i])==ERROR)
			return(ERROR);
		modeadr+=8;
		}
	return(OK);
	}

btxmode(chrentry)		/* convert and move the xmode bytes from */
	CHARDEV *chrentry;	/* bios to char io table */
	{
	short bitpos,i;
	byte xmodbyt[4];
	
	if(getbyts(4,xmodbyt,chrentry->xmodeaddr)==ERROR)
		return(ERROR);

	if(testbit(xmodbyt,DCEBIT)==1)		/* dce/dte bit */
		chrentry->dce_dte=FALSE;
	else
		chrentry->dce_dte=TRUE;

	if(testbit(xmodbyt,USEBIT)==1)		/* usage bit */
		chrentry->usage=FALSE;
	else
		chrentry->usage=TRUE;

	chrentry->baseport=*(xmodbyt+3);	/* base port address */

	if(testbit(xmodbyt,INITBIT)==1) 	/* initialization bit */
		chrentry->initflg=TRUE;
	else
		chrentry->initflg=FALSE;

/*	      STK   EPS   PEN
 *	   N   0     0	   0	
 *	   E   0     1	   1	
 *	   O   0     0	   1	
 *	   0   1     1	   1	 
 *	   1   1     0	   1	  
 */
	if(testbit(xmodbyt,PENBIT)==0)		/* parity bits */
		chrentry->parity='N';  
	else
		if(testbit(xmodbyt,STKBIT)==0)
			{
			if(testbit(xmodbyt,EPSBIT)==1)
				chrentry->parity='E';
			else
				chrentry->parity='O';
			}
		else
			{
			if(testbit(xmodbyt,EPSBIT)==1)
				chrentry->parity='0';
			else
				chrentry->parity='1';
			}

	if(testbit(xmodbyt,STBBIT)==0)		/* number of stop bits */
		chrentry->stopbits=1;
	else
		chrentry->stopbits=2;

	switch(*(xmodbyt+2) & 0x03)		/* word length bits */
		{
	case 0:
		chrentry->wordlen=5;
		break;
	case 1:
		chrentry->wordlen=6;
		break;
	case 2:
		chrentry->wordlen=7;
		break;
	case 3:
		chrentry->wordlen=8;
		break;
	default:
		break;
		}

	bitpos=RLSDENBIT;			/* input handshaking bits */
	for(i=0;i<4;++i,++bitpos)
		{
		if(testbit(xmodbyt,bitpos)==0)
			chrentry->hsinput[i]='X';
		else
			if(testbit(xmodbyt,bitpos+8)==0)
				chrentry->hsinput[i]='0';
			else
				chrentry->hsinput[i]='1';
		}

	bitpos=OUT2BIT; 			/* output handshaking bits */
	for(i=3;i>-1;--i,++bitpos)
		{
		if(testbit(xmodbyt,bitpos)==0)
			chrentry->hsoutput[i]='0';
		else
			chrentry->hsoutput[i]='1';
		}
	return(OK);
	}

btchrtbl(chrentry)		/* convert and move cpm3 chrtbl to flp table */
	CHARDEV *chrentry;
	{
	short i;
	byte chrtbl[8];
	
	if(getbyts(8,chrtbl,chrentry->chtbladdr)==ERROR)
		return(ERROR);
	for(i=0;i<6;++i)
		chrentry->chrstr[i]=chrtbl[i];
	chrentry->chrstr[i]=NULL;

	switch(chrtbl[7])			/* baud rate */
		{
	case 0:
		chrentry->baudrate=0;
		break;
	case 1:
		chrentry->baudrate=50;
		break;
	case 2:
		chrentry->baudrate=75;
		break;
	case 3:
		chrentry->baudrate=110;
		break;
	case 4:
		chrentry->baudrate=134;
		break;
	case 5:
		chrentry->baudrate=150;
		break;
	case 6:
		chrentry->baudrate=300;
		break;
	case 7:
		chrentry->baudrate=600;
		break;
	case 8:
		chrentry->baudrate=1200;
		break;
	case 9:
		chrentry->baudrate=1800;
		break;
	case 10:
		chrentry->baudrate=2400;
		break;
	case 11:
		chrentry->baudrate=3600;
		break;
	case 12:
		chrentry->baudrate=4800;
		break;
	case 13:
		chrentry->baudrate=7200;
		break;
	case 14:
		chrentry->baudrate=9600;
		break;
	case 15:
		chrentry->baudrate=19200;
		break;
	default:
		chrentry->baudrate=0;
		break;
		}
	if(testbit(chrtbl,SOFTBAUDBIT)==1)
		chrentry->baudmask=TRUE;
	else
		chrentry->baudmask=FALSE;

	if(testbit(chrtbl,PMASKBIT)==1) 	/* protocol bit */
		chrentry->protomask=TRUE;
	else
		chrentry->protomask=FALSE;
	if(testbit(chrtbl,XONBIT)==1)
		chrentry->softproto='X';
	else
		chrentry->softproto='N';

	if(testbit(chrtbl,OUTDVBIT)==1) 	/* device type bits */
		chrentry->outdev=TRUE;
	else
		chrentry->outdev=FALSE;
	if(testbit(chrtbl,INDVBIT)==1)
		chrentry->indev=TRUE;
	else
		chrentry->indev=FALSE;
	return(OK);
	}

getnode(modstr) 			/* get netlist node number */
	word modstr;			/* module start */
	{
	byte c; 									
	if(getword(&nodeadr,modstr+CHRSTRADR)==ERROR)
		return(ERROR);
	do
		{
		if(getbyte(&c,nodeadr++)==ERROR)
			return(ERROR);
		}
	while(c!='$');
	return(getbyte(&nodenum,nodeadr));
	}

btmode(flpentry)		/* convert and move floppy disk mode bytes */
	FLOPDEV *flpentry;	/* to floppy table */
	{
	if(getbyts(8,flpentry->modebyt,flpentry->modeaddr)==ERROR)
		return(ERROR);
	if(testbit(flpentry->modebyt,HARDBIT)==0)
		flpentry->floppy=TRUE;		/* floppy disk */
	else
		flpentry->floppy=FALSE; 	/* hard disk */
	if(flpentry->floppy)
		{
		btdsize(flpentry);
		btsteprt(flpentry);
		btdrvcontr(flpentry);
		btmedia(flpentry);
		btmediaft(flpentry);
		}
	return(OK);
	}

getxmadr(adr,modstr)		/* get xmode byte address in module */
	word *adr,modstr;
	{
	return(getword(adr,modstr+XMODEADR));
	}

getctadr(adr,modstr,phydevnum)	/* get chrtbl address in module */
	word *adr,modstr;
	byte phydevnum;
	{
	byte biospd[8]; 	/* bios parameter block for bdos func 50 */

	if(bioscurflg)
		return(getword(adr,modstr+CHRTBLADR));
	else
		{
		biospd[0]=20;	     /* get chrtbl address is bios entry #20 */
		*adr=(bdos(50,biospd)+((phydevnum-CHIONUM)*8));
		return(OK);	     /* bdos func 50 is direct bios calls */
		}
	}

getmadr(adr,modstr)		/* get mode byte address in module */
	word *adr,modstr;
	{
	return(getword(adr,modstr+MODEADR));
	}

/* Disk io module byte converion routines */

btdsize(flpentry)
	FLOPDEV *flpentry;
	{
	if(testbit(flpentry->modebyt,SIZEBIT)==0)
		flpentry->disksize=FALSE; /* 5.25" */
	else
		flpentry->disksize=TRUE;  /*  8" */
	}

btdrvcontr(flpentry)
	FLOPDEV *flpentry;
	{
	btsides(&flpentry->drive_contr,flpentry->modebyt);
	bttrkden(&flpentry->drive_contr,flpentry->modebyt);
	btrecden(&flpentry->drive_contr,flpentry->modebyt);
	}

btsteprt(flpentry)
	FLOPDEV *flpentry;
	{
	switch((flpentry->modebyt[2] & 0x0C) >>2)
		{
	case 0:
		flpentry->steprate=3;
		break;
	case 1:
		flpentry->steprate=6;
		break;
	case 2:
		flpentry->steprate=10;
		break;
	case 3:
		flpentry->steprate=15;
		break;
	default:
		break;
		}
	if(testbit(flpentry->modebyt,SIZEBIT)==0) /* 5.25" double step rate */
		flpentry->steprate*=2;
	if(testbit((flpentry->modebyt+4),STEPBIT1)==0)
		flpentry->stepmask=TRUE;
	else
		flpentry->stepmask=FALSE;
	}

btmedia(flpentry)
	FLOPDEV *flpentry;
	{
	btsides(&flpentry->media,flpentry->modebyt+1);
	bttrkden(&flpentry->media,flpentry->modebyt+1);
	btrecden(&flpentry->media,flpentry->modebyt+1);
	}

btmediaft(flpentry)
	FLOPDEV *flpentry;
	{
	bits fmt;
	ushort count;
	
	fmt=((flpentry->modebyt[0] << 8) | flpentry->modebyt[1]) & 0x7FFF;
	for(count=0;fmt!=0;++count)
		fmt=fmt<<1;
	flpentry->medforcd=count-1;
	flpentry->medmask[0]=flpentry->modebyt[4] & 0x7F;
	flpentry->medmask[1]=flpentry->modebyt[5];
	}

btsides(flpchar,modebyt)
	FLOPCHAR *flpchar;
	byte *modebyt;
	{
	if(testbit(modebyt,DDSBIT)==0)
		flpchar->numsides=TRUE;
	else
		flpchar->numsides=FALSE;
	if(testbit(modebyt+4,DDSBIT)==0)
		flpchar->sidemask=TRUE;
	else
		flpchar->sidemask=FALSE;
	}

bttrkden(flpchar,modebyt)
	FLOPCHAR *flpchar;
	byte *modebyt;
	{
	if(testbit(modebyt,DDTBIT)==0)
		flpchar->trkden=TRUE;
	else
		flpchar->trkden=FALSE;
	if(testbit(modebyt+4,DDTBIT)==0)
		flpchar->trkmask=TRUE;
	else
		flpchar->trkmask=FALSE;
	}

btrecden(flpchar,modebyt)
	FLOPCHAR *flpchar;
	byte *modebyt;
	{
	if(testbit(modebyt,DDDBIT)==0)
		flpchar->recden=TRUE;
	else
		flpchar->recden=FALSE;
	if(testbit(modebyt+4,DDDBIT)==0)
		flpchar->recmask=TRUE;
	else
		flpchar->recmask=FALSE;
	}

testbit(array,bitpos)
	byte *array;
	ushort bitpos;
	{
	byte mask;
	
	mask=0x80>>(bitpos % 8);
	if((array[bitpos/8] & mask)==NULL)
		return(0);
	else
		return(1);
	}

