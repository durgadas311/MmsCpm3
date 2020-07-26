/* Allow C code to directly call functions */

/*
 * SP -> return
 *    +2 HL
 *    +4 DE
 *    +6 BC
 *    +9 A
 *   +10 routine
 */

/* returns HL from routine */
int call(int rtn, int a, int bc, int de, int hl) {
#asm
	ld	hl,11
	add	hl,sp
	ld	de,here1
	push	de
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	push	de
	ld	a,(hl)
	dec	hl
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	push	af
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	pop	af
	ret
here1:
#endasm
}

/* returns A from routine */
int calla(int rtn, int a, int bc, int de, int hl) {
#asm
	ld	hl,11
	add	hl,sp
	ld	de,here2
	push	de
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	push	de
	ld	a,(hl)
	dec	hl
	dec	hl
	ld	b,(hl)
	dec	hl
	ld	c,(hl)
	dec	hl
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	push	af
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	pop	af
	ret
here2:
	ld	l,a
	ld	h,0
#endasm
}

/*
 * z88dk "malloc" facility seems totally broken.
 * Cannot get auto-init to work, there seems to be no
 * way to locate the last byte in a program...
 */
long heap;	/* should be BSS, nearly last in program */
#if 1
static void *sbrk = 0;
static void *send = 0;
#else
#include <malloc.h>
extern int printf(char *format, ...);
#endif
void *memalloc(int len) {
	void *adr;
#if 1
	int *sys;
	if (sbrk == 0) {
		/* printf("heap = %04x\n", &heap); */
		sbrk = (void *)(&heap + 256); /* major kludge */
		sys = (int *)6;
		send = *sys & 0xff00;
	}
	if (sbrk + len >= send) {
		return 0;
	}
	adr = sbrk;
	sbrk += len;
#else
	adr = malloc(len);
	printf("malloc(%d) = %04x (%04x: %04x)\n", len, adr, &heap, heap);
#endif
	return adr;
}

int bdos2(int fnc, int prm) {
#asm
	ld	hl,2
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	call	5
#endasm
}
