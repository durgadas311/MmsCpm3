vers equ '1 ' ; Sep 24, 2017  17:05   drm "MEM512K.ASM"
;****************************************************************
; Banked Memory BIOS module for CP/M 3 (CP/M plus)		*
; Copyright (c) 2018 Douglas Miller <durgadas311@gmail.com>	*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

mmu	equ	03fh	; base port of RAM256K

bnksiz	equ	56
compag	equ	bnksiz*4
bnktop	equ	compag shl 8

;  SCB registers
	extrn @bnkbf,@cbnk

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	4	; num banks possible
@compg:	db	compag
@mmerr: db	cr,lf,bell,'No 256K$'

; Uses XMOVE semantics
; C=source bank, B=dest bank, HL=address, A=num recs
?mvccp:
	push	psw
	push	h
	call	?xmove
	pop	h
	pop	psw
	mov	b,a
	mvi	c,0
	srlr	b
	rarr	c	; BC = A * 128
	mov	e,l
	mov	d,h	; same address, diff banks
	call	?move
	ret

; TODO: avoid redundant selection...
; But must handle xmove also...
?bnksl:
	sta	@cbnk		; remember current bank
	push	b		; save register b for temp
	mov	b,a
	add	a
	add	a
	ora	b
	ori	compag
	out	mmu
	pop	b		; restore register b
	ret

xflag:	db	0

?move:	lda	xflag
	ora	a
	jrz	xxm0
	out	mmu
xxm0:
	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
	ora	a
	lda	@cbnk
	cnz	?bnksl
	xra	a
	sta	xflag
	ret

?xmove:
	mov	a,b	;WR bnk
	add	a
	add	a
	ora	c	;RD bnk
	ori	compag
	sta	xflag
	ret

	dseg	; this part can be banked

?bnkck:
	; TODO: verify we have 256K
	mvi	a,true
	ret		; A<>0 banked memory available

	end
