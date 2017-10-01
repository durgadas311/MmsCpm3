/* Logical-physical table, redirection vectors, search type
 * to bios file conversion and moving functions.
 *
 * Last updated 11/4/83  9:36 mjm
 *
 * Version 3.103
 * 
 * "PUTDRVTB.C"
 *
 */

#include "SETUP30.H"

putdrvtbl()
	{
	short er;

	if((er=putlptbl())>ERROR)
		if(!mpmfile)
			{
			if((er=putsord())>ERROR)
				er=puttdrv();
			}
	return(er);
	}

putlptbl()
	{
	word lptr,i;
	
	lptr=drivtable.logphyaddr;
	for(i=0;i<MAXDRV;++i,++lptr)
		if(putbyte(&drivtable.logphytbl[i],lptr)==ERROR)
			return(ERROR);
	return(OK);
	}

putsord()
	{
	word adr,i;
	byte scbpd[4];
	
	if(bioscurflg)
		{
		adr=biosstart+DEFSRC;
		for(i=0;i<4;++i,++adr)
			if(putbyte(&drivtable.drvsch[i],adr)==ERROR)
				return(ERROR);
		}
	else
		{
		adr=SORDSCB;
		for(i=0;i<4;++i,++adr)
			{
			scbpd[0]=adr;
			scbpd[1]=0xFF;
			scbpd[2]=drivtable.drvsch[i];
			bdos(49,scbpd);
			}
		}
	return(OK);
	}

puttdrv()
	{
	word adr;
	byte scbpd[4];
	
	if(bioscurflg)
		{
		adr=biosstart+TMPDRV;
		if(putbyte(&drivtable.tempdrv,adr)==ERROR)
			return(ERROR);
		}
	else
		{
		scbpd[0]=TDRVSCB;
		scbpd[1]=0xFF;
		scbpd[2]=drivtable.tempdrv;
		bdos(49,scbpd);
		}
	return(OK);
	}
  
putredir()
	{
	word adr,i,temp;
	byte scbpd[4];
	
	if(bioscurflg)
		{
		adr=biosstart+REDIRVEC;
		if(putword(&redirvec[1],adr)==ERROR)	 /* conout */
			return(ERROR);
		if(putword(&redirvec[0],adr+2)==ERROR)	/* conin */
			return(ERROR);
		if(putword(&redirvec[3],adr+4)==ERROR)	/* auxout */
			return(ERROR);
		if(putword(&redirvec[2],adr+6)==ERROR)	/* auxin */
			return(ERROR);
		if(putword(&redirvec[4],adr+8)==ERROR)	/* lst */
			return(ERROR);
		}
	else
		{
		adr=REDSCB;
		for(i=0;i<5;++i,adr+=2)
			{
			scbpd[0]=adr;
			scbpd[1]=0;
			redirvec[i]=(redirvec[i] & 0xFFF0) | (bdos(49,scbpd) & 0x000F);
			scbpd[1]=0xFE;
			scbpd[2]=redirvec[i] & 0xFF;
			scbpd[3]=redirvec[i] >>8;
			bdos(49,scbpd);
			}
		}
	return(OK);
	}

puttyps()
	{
	word adr;
	byte scbpd[4],temp;

	temp=(subcom<<3 & 0x18);
	if(bioscurflg)
		{
		adr=biosstart+SCRTYP;
		if(putbyte(&temp,adr)==ERROR)
			return(ERROR);
		}
	else
		{
		scbpd[0]=STYPSCB;
		scbpd[1]=0;
		temp=temp | (bdos(49,scbpd) & 0xE7);
		scbpd[1]=0xFF;
		scbpd[2]=temp;
		bdos(49,scbpd);
		}
	return(OK);
	}
