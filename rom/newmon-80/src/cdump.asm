;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dump command

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
	jmp	cmddmp

	db	'D'
	db	-1
	db	0
	db	11111111b,11111111b,11111111b
	db	'Dump [addr]',0

init:	xra	a
	ret

dmpms:	db	'ump ',0

cmddmp:
	lxi	h,dmpms
	call	msgout
	lxi	h,ABUSS
	ora	a	; NC
	mvi	d,CR
	call	adrin
	xchg	; HL=adr
	mvi	b,8	; 8 lines (one half page, 128 bytes)
dmp0:	push	b
	call	adrnl	; CR,LF,"AAAA " (HL=AAAA)
	push	h
	mvi	b,16
dmp1:	mov	a,m
	call	hexout
	call	spout
	inx	h
	dcr b ! jnz	dmp1
	pop	h
	mvi	b,16
dmp2:	mov	a,m
	cpi	' '
	jc	dmp3
	cpi	'~'+1
	jc	dmp4
dmp3:	mvi	a,'.'
dmp4:	call	chrout
	inx	h
	dcr b ! jnz	dmp2
	pop	b
	dcr b ! jnz	dmp0
	shld	ABUSS
	ret

chrout:	push	h
	lhld	conout
	xthl
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
