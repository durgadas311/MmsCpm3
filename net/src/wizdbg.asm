; A debug util for WizNET 850 devices, attached in parallel-SPI interface
;
; Commands:
;	g <bsb> <off> <num>	Get <num> bytes from <bsb> at <off>
;	s <bsb> <off> <dat>...	Set bytes to <bsb> at <off>

	maclib	z80

wiz	equ	40h	; base port of H8-WIZ550io

wiz$dat	equ	wiz+0
wiz$ctl	equ	wiz+1
wiz$sts	equ	wiz+1

SCS	equ	1	; ctl port
BSY	equ	1	; sts port

WRITE	equ	00000100b

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5
cmd	equ	0080h

print	equ	9
getver	equ	12

	org	00100h

	jmp	start

usage:	db	'Usage: WIZCFG {G bsb off num}',CR,LF
	db	'       WIZCFG {S bsb off dat...}',CR,LF
	db	'       bsb = Block Select Bits, hex 00..1F',CR,LF
	db	'       off = Offset within BSB, hex',CR,LF
	db	'       num = Number of bytes to GET, dec',CR,LF
	db	'       dat = Byte(s) to SET, hex',CR,LF,'$'
done:	db	'Set',CR,LF,'$'
nocpn:	db	'CP/NET is running. Stop it first',CR,LF,'$'

start:
	sspd	usrstk
	lxi	sp,stack
	mvi	c,getver
	call	bdos
	mov	a,h
	ani	02h
	jz	nocpnt
	lxi	d,nocpn
	mvi	c,print
	call	bdos
	jmp	exit
nocpnt:
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
	cpi	'G'
	jz	pars2
	cpi	'S'
	jnz	help
pars2:
	sta	com
	call	skipb
	jc	help
	; <bsb> and <off> are always present,
	; plus either <num> or (at least) one <dat>.
	call	parshx
	jc	help
	mov	a,d
	ora	a
	jnz	help
	mov	a,e
	cpi	32	; 00..1F allowed
	jnc	help
	rlc
	rlc
	rlc
	sta	bsb
	call	skipb
	jc	help
	call	parshx
	jc	help
	xchg
	shld	off
	xchg
	call	skipb
	jc	help
	lda	com
	cpi 	'G'
	jz	get
	mvi	c,0
	lxix	buf
set0:
	call	parshx
	jc	help
	mov	a,d
	ora	a
	jnz	help
	stx	e,+0
	inxix
	inr	c	; can't overflow with 128-byte buffer
	call	skipb
	jnc	set0

	mov	a,c
	sta	num
	call	wizset
	jmp	exit

get:
	call	parsnm
	jc	help
	mov	a,d
	ora	a
	jnz	help
	mov	a,e
	sta	num
	call	wizget
	lxi	h,buf
	push	h
; dump 'num' bytes from 'buf'... label with bsb/off...
get0:
	lda	bsb
	call	hexout
	mvi	a,':'
	call	chrout
	lhld	off
	call	wrdout
	; now output <=16 bytes " XX"...
	mvi	b,16
get1:
	mvi	a,' '
	call	chrout
	pop	h
	mov	a,m
	inx	h
	push	h
	call	hexout
	lhld	off
	inx	h
	shld	off
	lda	num
	dcr	a
	sta	num
	jz	get2
	djnz	get1
	call	crlf
	jmp	get0
get2:
	call	crlf
exit:
	jmp	cpm

help:
	lxi	d,usage
	mvi	c,print
	call	bdos
	jmp	exit

; Read (GET) data from chip.
; 'num', 'bsb', 'off' setup.
; Returns: 'buf' filled with 'num' bytes.
wizget:
	mvi	a,SCS
	out	wiz$ctl
	lhld	off
	mov	a,h
	out	wiz$dat
	mov	a,l
	out	wiz$dat
	lda	bsb
	out	wiz$dat
	in	wiz$dat	; prime pump
	mvi	c,wiz$dat
	lxi	h,buf
	lda	num
	mov	b,a
	inir
	xra	a	; not SCS
	out	wiz$ctl
	ret

; Write (SET) data in chip.
; 'num', 'buf', 'bsb', 'off' setup.
wizset:
	mvi	a,SCS
	out	wiz$ctl
	lhld	off
	mov	a,h
	out	wiz$dat
	mov	a,l
	out	wiz$dat
	lda	bsb
	ori	WRITE
	out	wiz$dat
	lda	num
	mov	b,a
	mvi	c,wiz$dat
	lxi	h,buf
	outir
	xra	a	; not SCS
	out	wiz$ctl
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

dec16:
	xchg	; remainder in HL
	mvi	c,0
	lxi	d,10000
	call	div16
	lxi	d,1000
	call	div16
	lxi	d,100
	call	div16
	lxi	d,10
	call	div16
	mov	a,l
	adi	'0'
	call	chrout
	ret

div16:	mvi	b,0
dv0:	ora	a
	dsbc	d
	inr	b
	jrnc	dv0
	dad	d
	dcr	b
	jrnz	dv1
	bit	0,c
	jrnz	dv1
	ret
dv1:	setb	0,c
	mvi	a,'0'
	add	b
	call	chrout
	ret

; leading zeroes blanked - must preserve B
decout:
	push	b
	mvi	c,0
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	call	chrout
	pop	b
	ret

divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	jrnz	div1
	bit	0,c
	jrnz	div1
	ret
div1:	setb	0,c
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

; Print 16-bit hex value from HL
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
	jz	nzret
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

; IX=destination
parsadr:
	mvi	c,'.'
pa00:
	mvi	d,0
pa0:	mov	a,m
	cmp	c
	jz	pa1
	cpi	' '
	jz	pa2
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	mov	e,a
	mov	a,d
	add	a	; *2
	add	a	; *4
	add	d	; *5
	add	a	; *10
	add	e
	rc
	mov	d,a
	inx	h
	djnz	pa0
pa2:
	; TODO: check for 4 bytes...
	stx	d,+0
	ora	a
	ret

pa1:
	stx	d,+0
	inxix
	inx	h
	djnz	pa00
	; error if ends here...
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
bsb:	db	0
off:	dw	0
num:	db	0

buf:	ds	0

	end
