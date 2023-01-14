;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Test command

; TODO! this needs lots of work... Maybe only tests 2000H-FFFFH.

	maclib	core
	maclib	core80
	maclib	ram

CR	equ	13
LF	equ	10
BEL	equ	7

; ctl$F2 bits
ctl$SPD		equ	00010100b
ctl$ORG0	equ	00100000b

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
topms:	db	'Testing 2000-FFFF',CR,LF,0

seed:	db	0

cmdmt:
	lxi	h,mtms
	call	msgout
	call	waitcr
	lxi	h,topms
	call	msgout
	di
	lxi	sp,stack
	lda	ctl$F2
	ani	ctl$SPD	; all but speed bits OFF
	ori	ctl$ORG0	; set/keep ORG0 only
	out	0f2h
mtest0:
	lda	seed
	call	hexout
	mvi	a,CR
	call	chrout
mtest1:
	lda	seed
	lxi	h,2000h
mtest4:
	mov	m,a
	adi	1
	daa
	inr	l
	jnz	mtest4
	inr	h
	jnz	mtest4
	lda	seed
	lxi	h,2000h
mtest5:
	cmp	m
	jnz	mtest9
	adi	1
	daa
	inr	l
	jnz	mtest5
	inr	h
	jnz	mtest5

	lda	seed
	adi	1
	daa
	sta	seed
	jmp	mtest0

mtest9:	; HL=error addr
	; print "AAAA DD *" and beep forever
	call	adrnl
	call	spout
	lda	seed
	call	hexout
	call	spout
	mvi	a,'*'
	call	chrout
mtestG:
	mvi	a,BEL
	call	chrout
	xra	a
	mvi	b,0fah
mtestH:
	dcr	a
	jnz	mtestH
	dcr b ! jnz mtestH
	jmp	mtestG

chrout:	lhld	conout
	pchl

waitcr:
	call	conin
	cpi	CR
	jnz	waitcr
	jmp	crlf

	ds	64
stack:	ds	0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
