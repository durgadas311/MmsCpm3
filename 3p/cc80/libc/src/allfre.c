/* alloc and free - (c) 1983 Walt Bilofsky.

  Usage: alloc(n) returns pointer to n bytes of memory. 
	 free(p) returns memory at p to free pool; p must have
		been gotten from alloc.
	 Uses: sbrk(). */

static struct block0 {
	unsigned size0;
	char *next0; }
    freelist = { 0, -1 };		/* -1 is largest unsigned */

#define PSIZE sizeof(unsigned)		/* Size of header word */
#define TRIFLE sizeof(struct block0)	/* Largest allowable wastage */

alloc(n) unsigned n; {
	static char *p,*pn;
	static int size;
	if ((n =+ PSIZE) < sizeof(struct block0))
				n = sizeof(struct block0);
	for (;;) {
		for (p = &freelist; (pn = p->next0) != -1; p = pn)
			if (n <= pn->size0) {
				/* Decide whether to fragment block */
				if (n + TRIFLE <= pn->size0) {
					p = p->next0 = pn + n;
					p->size0 = pn->size0 - n;
					pn->size0 = n; }
				p->next0 = pn->next0;
				return pn + PSIZE; }
		if ((p = sbrk(size = n < 1024 ? 1024 : n)) == -1) return -1;
		p->size0 = size;
		free(p + PSIZE);
	}	}

free(q) char *q; {
	static char *p, *pn;
	q =- PSIZE;
	for (p = &freelist; p != -1; p = pn)
	    if ((pn = p->next0) > q) {
		/* Merge with following block? */
		if (q + q->size0 == pn) {
			q->size0 =+ pn->size0;
			pn = pn->next0; }
		/* Merge with preceding block? */
		if (p + p->size0 == q) {
			p->size0 =+ q->size0;
			q = p; }
		p->next0 = q;
		q->next0 = pn;
		return; }
	}

