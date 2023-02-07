#asm
	;maclib	core	/* entry points to ROMX */
#include "core.lib"
	public	gets
#endasm
#define	CR	13
#define	LF	10
#define	ESC	27
#define	BEL	7
#define	CTLC	3
#define	BS	8

/* Get a (edited) line from the console */
gets(s) char *s; {
#asm
	pop	b
	pop	h	/* buffer to HL */
	push	h
	push	b
	push	h
	/* can't use ROMs linin due to DEL breakage */
	mvi	c,0
lini0:	call	conin
	cpi	CR
	jz	linix
	cpi	ESC
	jz	liniz
	cpi	CTLC
	jz	xxxx
	cpi	BS
	jz	backup
	cpi	' '
	jc	chrnak
	cpi	'~'+1
	jnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	c
	jm	chrovf
linoy:	push	h
	call	chrout
	pop	h
	jmp	lini0
liniz:	pop	h
	mov	m,a
	mvi	c,1
	jmp	linoz
chrovf:	dcx	h
	dcr	c
chrnak:	mvi	a,BEL
	jmp	linoy
backup:	mov	a,c
	ora	a
	jz	lini0
	dcr	c
	dcx	h
	push	h
	mvi	a,BS
	call	chrout
	mvi	a,' '
	call	chrout
	mvi	a,BS
	call	chrout
	pop	h
	jmp	lini0
xxxx:	pop	h
	lxi	h,-1
	jmp	linow
chrout:	lhld	conout
	pchl
linix:	mvi	m,0
	pop	h
linoz:	mov	l,c	/* return count */
	mvi	h,0
linow:	call	crlf
#endasm
}
