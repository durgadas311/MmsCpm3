/* unlink - remove (erase) a file from the file directory  */
/* May 10, 1984 07:40 drm */
extern defbuf;
unlink(name)
char *name[];
{
	char fcb[36];

	makfcb(name,fcb);	       /* make fcb for name */
	bdos(26,defbuf);	       /* first, set dma addr to junk area */
	bdos(19, fcb);		       /* erase the file */
}

