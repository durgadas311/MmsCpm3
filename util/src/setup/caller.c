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
	mov	d,m
	dcx	h
	mov	e,m
	dcx	h
	push	de
	mov	a,m
	dcx	h
	dcx	h
	mov	b,m
	dcx	h
	mov	c,m
	dcx	h
	mov	d,m
	dcx	h
	mov	e,m
	dcx	h
	push	af
	mov	a,m
	dcx	h
	mov	l,m
	mov	h,a
	pop	af
	ret
here1:
#endasm
}

/* returns A from routine */
int calla(int rtn, int a, int bc, int de, int hl) {
}

void _spr(void **fmt, void (*outp)(char c)) {
}
