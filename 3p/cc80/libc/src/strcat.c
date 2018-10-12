/* Copy 0-terminated string tt onto end of 0-terminated string ss */
strcat(ss,tt)
char ss[], tt[];
{
	while (*ss) ++ss;		/* find end of string */
	while (*ss++ = *tt++);		/* copy til zero byte */
}

