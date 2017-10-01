/*
 * Setup30 display handling routines
 *
 * Version 3.103
 * 
 * Date last modified: 7/18/84 09:19 drm
 *
 * "DISPLAY.C"
 */

#include "SETUP30.H"
 
/* Keyboard routines */

getnum(fldsiz,pdata)			/* gets a number from the */
	short fldsiz,*pdata;		/* the screen and puts in */
	{				/* pdata if it's ok  */
	short i,inp,pt,flag;
	char str[8];
  
	pt=0;	flag=TRUE;
	while(flag==TRUE) 
		{
		inp=getchr();
		if(inp==BS)
			{
			if(pt--<=0)
				pt=0;
			else
				{
				outchr(BS);
				outchr(' ');
				outchr(BS);
				}
			}
		else if(inp>='0' && inp<='9')
			{
			if(pt==0)
				{
				for(i=0;i<fldsiz;++i)
					outchr(' ');
				currnt();
				}
			str[pt]=inp;
			outchr(inp);
			if(++pt>=fldsiz)
				flag=FALSE;
			}     
		else if(inp==NULL)
			flag=FALSE;
		else
			bell();
		}
	str[pt]=NULL;
	if(pt==0)		/* return null if no char were entered */
		return(NULL);
	*pdata=atoi(str);
	return(!NULL);
	}

getstr(fldsiz,pdata)			/* input a string on the screen */
	short fldsiz;
	char *pdata;
	{
	short i,inp,pt,flag;

	pt=0; flag=TRUE;
	while(flag==TRUE)
		{
		inp=toupper(getchr());
		if(inp==BS)
			{
			if(pt--<=0)
				pt=0;
			else
				{
				outchr(BS);
				outchr(' ');
				outchr(BS);
				}
			}
		else  if((inp>='A' && inp<='Z') || (inp>='0' && inp<='9'))
			{	       
			if(pt==0)
				{
				for(i=0;i<fldsiz && pt==0;++i)
					outchr(' ');
				currnt(); 
				}
			pdata[pt]=inp;
			outchr(inp);
			if(++pt>=fldsiz) 
				flag=FALSE;
			}
		else  if(inp==NULL)
			flag=FALSE;
		else
			bell();
		}
	if(pt==0)
		return(NULL);	    /* if no char were entered return null */
	pdata[pt]=NULL;
	return(!NULL);			   
	}

getchr()
	{
	char c;
	
	if(charbuf==NULL)
		{
		c=getkey();
		if(c>=CNTL || c==CRCD)
			{
			cntrlbuf=c;
			return(NULL);
			}
		}
	else
		{
		c=charbuf;
		charbuf=NULL;
		}
	return(c);
	}

getcntrl()
	{
	char c;

	if(cntrlbuf==NULL)
		{
		c=getkey();
		if(c<CNTL && c!=CRCD)
			{
			charbuf=c;
			return(NULL);
			}
		}
	else
		{
		c=cntrlbuf;
		cntrlbuf=NULL;
		}
	return(c);
	}

movcur(c,maxcol,maxlne) 	/* moves cursor according to c which is */
	short maxcol,maxlne;	/* a cursor control char */
	char c; 		
	{			
	switch(c)
		{
	case DOWN:			/* down arrow */
	case CRCD:
		if(++curline>maxlne-1)
			curline=maxlne-1;
		break;
	case UP:			/* up arrow */
		if(--curline<=0)
			curline=0;
		break;
	case RIGHT:			/* right arrow */
		if(++curcol>=maxcol)
			curcol=maxcol-1;
		break;
	case LEFT:			/* left arrow */
		if(--curcol<=0)
			curcol=0;
		break;
	case HMCD:			/* home key */
		curline=curcol=0;
		break;
	default:
		break;
		}
	}

/* Screen routines */
	      
initcur(stline,nline,stcol,ncol,colwids) /* initializes the cursor  */
	ushort stline,		   /* starting line of screen */
	       nline,		   /* number of lines on screen */
	       stcol,		   /* starting column of screen */
	       ncol,		   /* number of columns and colwids */
	       colwids; 	   /* first column width */
	{
	ushort *cptr,lpos,cpos,col,ln;

	for(lpos=((stline-1)*getwidth())+stcol,ln=0;ln<nline;lpos+=getwidth(),ln++) 
		{
		cptr=&colwids;
		for(cpos=lpos,col=0;col<ncol;cpos+=*cptr++,col++)
				curpos[ln][col]=cpos;
		}
	}

prtpos(line,col,format) 	/* print formated data at line and col */
	ushort line,col;
	char *format;
	{
	void outchr();
	
	cursor(curpos[line][col]);
	_spr(&format,&outchr);	       /* formated output libaray function */
	}

prtcnt(format)
	char *format;
	{
	void outchr();

	currnt();
	_spr(&format,&outchr);
	}

currnt()		/* move cursor to current position */
	{
	cursor(curpos[curline][curcol]);
	}

prtmcur()
    {
    cursor((STMNLNE+2)*getwidth()+1);
    puts("ENTER  = Execute functions\n");
    puts("<UP>   = Move up a line\n");
    puts("<DOWN> = Move down a line\n");
    puts("<HOME> = Jump to top line");
    return(0);
    }

prtcur(f)
char *f;
    {
    cursor((STMNLNE+2)*getwidth()+1);
    printf( "%-11.11s = End and update %s\n",termctrl.f6name,f);
    printf( "%-11.11s = Quit (No update)\n",termctrl.f7name);
    printf( "%-11.11s = Restart with original data\n",termctrl.f8name);
    puts("ARROWS      = Move to next field\n");
    puts("HOME        = Jump to top line");
    return(0);
    }

clmn()			/* clears window on screen */
	{
	ushort i;

	curoff();
	for(i=0;i<(getlength()-(STMNLNE+1));++i)
		{
		cursor(((i+STMNLNE)*getwidth())+STMNCOL);
		clreel();
		}
	curon();
	}

putwin(linenum,strpt)	       /* prints a unformated message in the window */
	char *strpt;
	ushort linenum;
	{
	curoff();
	cursor(((linenum-1+STMNLNE)*getwidth())+STMNCOL);
	clreel();
	puts(strpt);
	curon();
	}
 
prtwin(linenum,format)	       /* prints a formated message in the window */
	char *format;
	ushort linenum;
	{
	void outchr();
	
	cursor(((linenum-1+STMNLNE)*getwidth())+STMNCOL);
	clreel();
	_spr(&format,&outchr);	       /* formated output libaray function */
	}

/* end of DISPLAY */
