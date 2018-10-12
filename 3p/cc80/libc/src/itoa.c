/* itoa - convert n to characters in s. */
char *itoa(n, s)
char s[];
int n;
{
	static int c, k;
	static char *p, *q;

	if ((k = n) < 0)
		k = -k;
	q = p = s;
	do {
		*p++ = k % 10 + '0';
	} while (k /= 10);
	if (n < 0) *p++ = '-';
	*p = 0;
	while (q < --p) {
		c = *q; *q++ = *p; *p = c; }
	return (s);
}

