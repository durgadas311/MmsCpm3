/*	*	*/

atoi(s)        /* convert string to integer */
char *s;
{
	static int n, sign;
	sign = 1;
	n = 0;
	switch (*s) {
		case '-': sign = -1;
		case '+': ++s;
		}
	while (*s >= '0' && *s <= '9') n = 10 * n + *s++ - '0';
	return(sign * n);
}

