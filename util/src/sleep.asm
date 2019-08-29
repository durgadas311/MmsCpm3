; Delay for number of seconds
;
	maclib z80

cpm	equ	0
bdos	equ	5

	org	100h

	jmp	start

getscb:	db	3ah,0
secp:	dw	0
secs:	dw	0

start:	lxi	sp,stack

        mvi     c,12
        call    bdos
	mov	a,l
	cpi	31h
	jnz	nocpm3

	lxi	d,getscb
	mvi	c,49
	call	bdos
	lxi	d,005ch
	dad	d
	shld	secp

	lxi	h,0080h
	mov	b,m
	inx	h
	call	skipb
	jc	cpm	; ignore no param
	call	parsnm
	jc	cpm	; ignore errors
	xchg
	shld	secs
	;...
	lhld	secs
	xchg
	lhld	secp
loop:	mov	a,m
loop1:	cmp	m
	jz	loop1
	dcx	d
	mov	a,e
	ora	d
	jnz	loop

	jmp	cpm

nocpm3:	lxi	d,xcpm3
	mvi	c,9
	call	bdos
	jmp	cpm

; Parse a 16-bit (max) decimal number
parsnm:
	lxi	d,0
pd0:	mov	a,m
	cpi	' '
	rz
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	push	h
	mov	h,d
	mov	l,e
	dad	h	; *2
	jc	pd1
	dad	h	; *4
	jc	pd1
	dad	d	; *5
	jc	pd1
	dad	h	; *10
	jc	pd1
	mov	e,a
	mvi	d,0
	dad	d
	xchg
	pop	h
	rc
	inx	h
	djnz	pd0
	ora	a	; NC
	ret

pd1:	pop	h
	ret	; CY still set

skipb:
	mov	a,b
	ora	a
	stc
	rz
skip0:	mov	a,m
	cpi	' '
	stc
	cmc
	rnz
	inx	h
	djnz	skip0
	stc
	ret

xcpm3:	db	'Requires CP/M 3',13,10,'$'

	ds	256
stack:	ds	0

	end
