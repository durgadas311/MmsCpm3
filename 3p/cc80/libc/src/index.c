/*	*	*/

index(s,t)	/* find string t in s, return index, or -1 if fail*/
char s[], t[];
{
	static int i,j,k;

	for (i = 0; s[i] != '\0'; i++) {
	   for (j=i,k=0; t[k] != '\0' && s[j]==t[k]; ++j, ++k)
		;
	   if (t[k] == '\0') return(i);
	}
	return(-1); /* no match*/
}

