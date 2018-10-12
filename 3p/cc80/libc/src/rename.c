/* rename - rename oldfile to be newfile  */
/* May 10, 1984 07:34 drm */
extern defbuf;
rename(old,new)
char *old,*new;
{
	char fcb[54];

	makfcb(new,fcb+16);	       /* enter new name */
	makfcb(old,fcb);	       /* and old one. */
	bdos(26,defbuf);	       /* first, set dma addr to junk area */
	return bdos(23,fcb);	       /* rename it */
}

