; Command module for CPU Speed Control

	maclib	core
	maclib	ram
	maclib	z80

CR	equ	13
LF	equ	10
BS	equ	8
CTLC	equ	3
BEL	equ	7
ESC	equ	27

spbits	equ	00010100b
mhz10	equ	00010100b
mhz8	equ	00000100b
mhz4	equ	00010000b
mhz2	equ	00000000b

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	's'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'CPU Speed [2|4|8|M]',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

exec:
	lxi	h,signon
	call	msgout
	lxi	h,mis
spd0:	call	conin
	cpi	CR
	jrz	show
	cpi	'2'
	mvi	c,mhz2
	jrz	ok
	cpi	'4'
	mvi	c,mhz4
	jrz	ok
	cpi	'8'
	mvi	c,mhz8
	jrz	ok
	ani	01011111b
	cpi	'M'
	mvi	c,mhz10
	jrz	ok
	mvi	a,BEL
	call	chrout
	jr	spd0
ok:	call	chrout
	call	conin
	cpi	CR
	jrz	ok1
	mvi	a,BEL
	jr	ok
ok1:	lxi	h,ctl$F2
	di
	mov	a,m
	ani	NOT spbits
	ora	c
	mov	m,a
	out	0f2h
	ei
	lxi	h,mset
show:	push	h
	call	crlf
	lxi	h,signon+1
	call	msgout
	pop	h
	call	msgout
	lda	ctl$F2
	ani	spbits
	cpi	mhz2
	mvi	c,'2'
	jrz	got
	cpi	mhz4
	mvi	c,'4'
	jrz	got
	cpi	mhz8
	mvi	c,'8'
	jrz	got
	; must be MAX
	lxi	h,mmax
	call	msgout
	jr	fin
got:	mov	a,c
	call	chrout
	lxi	h,mmhz
	call	msgout
fin:	jmp	crlf

chrout:	lhld	conout
	pchl

signon:	db	' CPU Speed ',0

mis:	db	'is ',0
mset:	db	'set to ',0
mmax:	db	'Max',0
mmhz:	db	'MHz',0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
