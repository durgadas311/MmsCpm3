; A util for 25LC512 EEPROM devices, attached in parallel-SPI interface
;
; Commands:
;	r <adr> <len>		Read NVRAM
;	w <adr> <val>...	Write NVRAM

	maclib	z80

spi	equ	40h	; base port of SPI interface

nv$dat	equ	spi+0
nv$ctl	equ	spi+1

SCS	equ	10b	; ctl port

READ	equ	00000011b
WRITE	equ	00000010b
RDSR	equ	00000101b
WREN	equ	00000110b

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5
cmd	equ	0080h

print	equ	9
getver	equ	12

	org	00100h

	jmp	start

usage:	db	'Usage: NVRAM R adr len',CR,LF
	db	'       NVRAM W adr val...',CR,LF,'$'

start:
	sspd	usrstk
	lxi	sp,stack
	lda	cmd
	ora	a
	jz	help

	lxi	h,cmd
	mov	b,m
	inx	h
pars0:
	mov	a,m
	cpi	' '
	jnz	pars1
	inx	h
	djnz	pars0
	jmp	help

pars1:
	cpi 	'R'
	jz	pars2
	cpi 	'W'
	jnz	help
pars2:	sta	com
	call	skipb
	jc	help
	call	parshx
	jc	help
	xchg
	shld	adr
	xchg
	call	skipb
	jc	help
	lda	com
	cpi	'R'
	jz	nvrd
	mvi	c,0
	lxix	buf
nvwr:
	call	parshx
	jc	help
	mov	a,d
	ora	a
	jnz	help
	stx	e,+0
	inxix
	inr	c
	mov	a,b
	ora	a
	jz	write1
	call	skipb
	jnc	nvwr
write1:
	mov	l,c
	mvi	h,0
	shld	num
	call	nvset
	jmp	exit

nvrd:
	call	parsnm
	jc	help
	; TODO: limit to space in 'buf'
	xchg
	shld	num
	call	nvget
read0:
	lhld	adr
	call	wrdout
	mvi	a,':'
	call	chrout
	mvi	b,16
	lxi	h,buf
	push	h
read1:
	mvi	a,' '
	call	chrout
	pop	h
	mov	a,m
	inx	h
	push	h
	call	hexout
	lhld	adr
	inx	h
	shld	adr
	lhld	num
	dcx	h
	shld	num
	mov	a,h
	ora	l
	jz	read2
	djnz	read1
	pop	h
	call	crlf
	jmp	read0
read2:
	pop	h
	call	crlf
exit:
	jmp	cpm

help:
	lxi	d,usage
	mvi	c,print
	call	bdos
	jmp	exit

nvget:
	mvi	a,SCS
	out	nv$ctl
	mvi	a,READ
	out	nv$dat
	lhld	adr
	mov	a,h
	out	nv$dat
	mov	a,l
	out	nv$dat
	in	nv$dat	; prime pump
	mvi	c,nv$dat
	lhld	num
	xchg
	mov	a,e
	ora	a
	jz	nvget1
	inr	d	; TODO: handle 64K... and overflow of 'buf'...
nvget1:	lxi	h,buf
	mov	b,e
nvget0:	inir	; B = 0 after
	dcr	d
	jnz	nvget0
	xra	a	; not SCS
	out	nv$ctl
	ret

nvset:
	; TODO: wait for WIP=0...
	mvi	a,SCS
	out	nv$ctl
	mvi	a,WREN
	out	nv$dat
	xra	a	; not SCS
	out	nv$ctl
	mvi	a,SCS
	out	nv$ctl
	mvi	a,WRITE
	out	nv$dat
	lhld	adr
	mov	a,h
	out	nv$dat
	mov	a,l
	out	nv$dat
	lhld	num	; can't exceed 128?
	mov	b,l
	lxi	h,buf
	mvi	c,nv$dat
	outir
	xra	a	; not SCS
	out	nv$ctl
	ret

chrout:
	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,002h
	call	bdos
	pop	b
	pop	d
	pop	h
	ret

crlf:
	mvi	a,CR
	call	chrout
	mvi	a,LF
	call	chrout
	ret

wrdout:
	push	h
	mov	a,h
	call	hexout
	pop	h
	mov	a,l
hexout:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
	;jmp	hexdig
hexdig:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jmp	chrout

skipb:
	inx	h	; skip option letter
	dcr	b
	stc
	rz
skip0:	mov	a,m
	ora	a
	cpi	' '
	rnz	; no carry?
	inx	h
	djnz	skip0
	stc
	ret

; Parse (up to) 16-bit hex value.
; input: HL is cmd buf, B remaining chars
; returns number in DE, CY if error, NZ end of text
parshx:
	lxi	d,0
pm0:	mov	a,m
	cpi	' '
	rz
	sui	'0'
	rc
	cpi	'9'-'0'+1
	jc	pm3
	sui	'A'-'0'
	rc
	cpi	'F'-'A'+1
	cmc
	rc
	adi	10
pm3:
	ani	0fh
	xchg
	dad	h
	jc	pme
	dad	h
	jc	pme
	dad	h
	jc	pme
	dad	h
	jc	pme
	xchg
	add	e	; carry not possible
	mov	e,a
	inx	h
	djnz	pm0
nzret:
	xra	a
	inr	a	; NZ
	ret
pme:	xchg
	stc
	ret

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

	ds	40
stack:	ds	0
usrstk:	dw	0

com:	db	0
adr:	dw	0
num:	dw	0

buf:	ds	0

	end
