;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Substitute command

	maclib	core
	maclib	core80
	maclib	ram

CR	equ	13
LF	equ	10
BEL	equ	7

	org	1000h
first:	db	HIGH (last-first)	; +0
	db	HIGH first		; +1
	db	255,0			; +2,+3

	jmp	init			; +4
	jmp	cmdsub			; +7

	db	'S'			; +10
	db	-1			; +11
	db	0			; +12
	db	11111111b,11111111b,11111111b ; +13...
	db	'Substitute [addr]',0	; +16...

init:	xra	a
	ret

subms:	db	'ubstitute ',0

cmdsub:
	lxi	h,subms
	call	msgout
	lxi	h,ABUSS
	ora	a	; NC
	mvi	d,CR
	call	adrin
	xchg
cmdsub0:
	call	adrnl
	mov	a,m
	call	hexout
	call	spout
cmdsub1:
	call	hexin
	jnc	cmdsub4
	cpi	CR
	jz	cmdsub2
	cpi	'-'
	jz	cmdsub3
	cpi	'.'
	rz
	call	belout
	jmp	cmdsub1
cmdsub2:
	inx	h
	jmp	cmdsub0
cmdsub3:
	call	chrout
	dcx	h
	jmp	cmdsub0
cmdsub4:
	mvi	m,000h
cmdsub5:
	call	chrout
	call	hexbin
	mov	b,a
	mov	a,m
	add	a
	add	a
	add	a
	add	a
	add	b
	mov	m,a
	call	inhexcr
	jnc	cmdsub2
	jmp	cmdsub5

belout:	mvi	a,BEL
chrout:	push	h
	lhld	conout
	xthl
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
