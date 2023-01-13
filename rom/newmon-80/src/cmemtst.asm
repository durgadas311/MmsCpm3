;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Test command

; TODO! this needs lots of work... Maybe only tests 2000H-FFFFH.

	maclib	core
	maclib	core80
	maclib	ram

CR	equ	13
LF	equ	10
BEL	equ	7

	org	1000h
first:	db	HIGH (last-first)
	db	HIGH first
	db	255,0

	jmp	init
	jmp	cmdmt

	db	'M'
	db	-1
	db	0
	db	11111111b,11111111b,11111111b
	db	'Mem test',0

init:	xra	a
	ret

mtms:	db	'em test',0
cserms:	db	BEL,'Cksum error',0
topms:	db	'Top of Mem: ',0

cserr:
	lxi	h,cserms
	jmp	msgout

cmdmt:
	lxi	h,mtms
	call	msgout
	call	waitcr
	lxi	h,topms
	call	msgout
	lxi	h,0
	dad	sp
	mov	a,h
	inr	a
	jz	cmdmt0
	sui	020h
cmdmt0:
	mov	h,a
	mvi	l,0
	dcx	h
	sui	'0'
	mov	e,a
	call	adrout
	call	crlf
if 1 ; TODO: de-zilog memory test
	.warning	'de-zilog memory test'
	ret
else ; TODO: de-zilog memory test
	mvi	d,000h
	mvi	c,030h
	mvi	b,000h
	exx
	lxi	h,mtest0
	lxi	d,memtest - (mtest1-mtest0)
	lxi	b,mtestZ-mtest0
	call	ldir
	lxi	d,memtest
	lxi	h,mtest1
	mvi	c,mtestZ-mtest1
	xra	a
	exaf
	xra	a
cmdmt1:
	add	m
	exaf
	xchg
	add	m
	exaf
	xchg
	inx	h
	inx	d
	dcr	c
	jnz	cmdmt1
	mov	c,a
	exaf
	cmp	c
	jnz	cserr
	di
	lda	ctl$F2
	ani	ctl$SPD	; all but speed bits OFF
	ori	ctl$ORG0	; set ORG0 only
	; pass ctl$F2 in A...
	jmp	memtest - (mtest1-mtest)

;------------------------------------------------
; Start of relocated code...
; Memory Test routine, position-independent
;
mtest0:
mtest:
	; A reg contains desired ctl$F2 image
	out	0f2h
mtest1:		; lands at 03000h - retained relocated code
	exx
	mov	h,d
	mvi	l,0
	mov	a,b
	exx
	mov	c,a
	mvi	b,2
mtest2:
	mov	a,c
	rlc
	rlc
	rlc
	rlc
	mov	c,a
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
mtest3:
	in	0edh
	ani	020h
	jz	mtest3
	dcr	b
	jnz	mtest2
	mvi	a,CR
	out	0e8h
	exx
	mov	a,b
mtest4:
	mov	m,a
	adi	1
	daa
	inr	l
	jnz	mtest4
	inr	h
	dcr	c
	jnz	mtest4
	mov	a,h
	sub	d
	mov	c,a
	mov	h,d
	mvi	l,0
	mov	a,b
mtest5:
	cmp	m
	jnz	mtest9
	adi	1
	daa
	inr	l
	jnz	mtest5
	inr	h
	dcr	c
	jnz	mtest5
	exx
	lxi	h,memtest
	lxi	d,0
	lxi	b,mtestZ-mtest1
	exx
	mov	a,d
	xri	030h
	mov	d,a
	jz	mtest6
	mov	c,e
	jmp	mtest7
mtest6:
	mvi	c,030h
	mvi	a,001h
	add	b
	daa
	mov	b,a
	exx
	xchg
	exx
mtest7:
	exx
	call	ldir
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	mvi	c,mtestZ-mtest1
	xra	a
mtest8:
	add	m
	inx	h
	dcr	c
	jnz	mtest8
	mov	c,a
	exaf
	cmp	c
	jnz	mtestE
	exaf
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	pchl
mtest9:
	xra	m
	mov	d,a
	mvi	a,LF
	out	0e8h
mtestA:
	in	0edh
	ani	020h
	jz	mtestA
	mvi	c,2
	mvi	b,4
mtestB:
	mov	a,h
	rlc
	rlc
	rlc
	rlc
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
mtestC:
	in	0edh
	ani	020h
	jz	mtestC
	dad	h
	dad	h
	dad	h
	dad	h
	dcr b ! jnz	mtestB
	mvi	a,' '
	out	0e8h
mtestD:
	in	0edh
	ani	020h
	jz	mtestD
	dcr	c
	xchg
	mvi	b,002h
	jnz	mtestB
	mvi	a,'*'
	out	0e8h
	jmp	mtestG
mtestE:
	in	0edh
	ani	020h
	jz	mtestE
	mvi	a,LF
	out	0e8h
mtestF:
	in	0edh
	ani	020h
	jz	mtestF
	mvi	a,'!'
	out	0e8h
mtestG:
	in	0edh
	ani	020h
	jz	mtestG
	xra	a
	mvi	b,0fah
mtestH:
	dcr	a
	jnz	mtestH
	dcr b ! jnz	mtestH
	mvi	a,BEL
	out	0e8h
	jmp	mtestG
; End of relocated code
mtestZ	equ	$
endif

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
