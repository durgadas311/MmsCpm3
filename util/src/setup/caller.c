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
