/* getline - get a string from the console.  Returns length of the string,
	0 terminated, without the newline at the end. */
getline(s,lim)
char *s;
{	static char *t;

	for (t = s; --lim > 0 && (*t = getchar()) != '\n' && *t != -1; ++t);
	*t = '\0';
	return t - s;
}

