/* Allow C code to directly call functions */

/*
 * -set-r2l-by-default !!!
 *
 * SP -> return
 *    +2 routine
 *    +4 A
 *    +6 BC
 *    +8 DE
 *   +10 HL
 */

/* returns HL from routine */
int call(int rtn, int a, int bc, int de, int hl) {
#asm
	ld	de,here1
.there
	push	de
	ld	hl,2
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	push	de	; routine to call
	ld	a,(hl)
	inc	hl
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	push	af
	ld	a,(hl)
	inc	hl
	ld	l,(hl)
	ld	h,a
	pop	af
	ret		; go to routine
here1:			; return here
#endasm
}

/* returns A from routine */
int calla(int rtn, int a, int bc, int de, int hl) {
#asm
	ld	de,here2
	jp	there	; reset is the same
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
extern void _BSS_END_tail;
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
		sbrk = &_BSS_END_tail;
		sys = (int *)6;
		send = *sys & 0xff00;
		/* printf("heap = %04x .. %04x\n", sbrk, send); */
	}
	if (sbrk + len >= (&len - 256)) {
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
