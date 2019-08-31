; util to display socket status
;

	maclib	z80

wiz	equ	40h	; base port of H8-WIZx50io SPI interface

wiz$dat	equ	wiz+0
wiz$ctl	equ	wiz+1
wiz$sts	equ	wiz+1

SCS	equ	01b	; SCS for WIZNET
NVSCS	equ	10b	; SCS for NVRAM

; NVRAM/SEEPROM commands
NVRD	equ	00000011b
NVWR	equ	00000010b
RDSR	equ	00000101b
WREN	equ	00000110b
; NVRAM/SEEPROM status bits
WIP	equ	00000001b

; WIZNET CTRL bit for writing
WRITE	equ	00000100b

GAR	equ	1	; offset of GAR, etc.
SUBR	equ	5
SHAR	equ	9
SIPR	equ	15
PMAGIC	equ	29	; used for node ID
PHYCFGR	equ	46

SOCK0	equ	000$01$000b
SOCK1	equ	001$01$000b
SOCK2	equ	010$01$000b
SOCK3	equ	011$01$000b
SOCK4	equ	100$01$000b
SOCK5	equ	101$01$000b
SOCK6	equ	110$01$000b
SOCK7	equ	111$01$000b

SnMR	equ	0
SnCR	equ	1
SnIR	equ	2
SnSR	equ	3
SnPORT	equ	4
SnDIPR	equ	12
SnDPORT	equ	16
SnTXBUF	equ	31	; TXBUF_SIZE

; Socket SR values
CLOSED	equ	00h
INIT	equ	13h
ESTAB	equ	17h

; Socket CR commands
OPEN	equ	01h
CONN	equ	04h
DISC	equ	08h
CLOSE	equ	10h
KEEP	equ	22h

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5
cmd	equ	0080h

print	equ	9
getver	equ	12
cfgtbl	equ	69

	org	00100h

	jmp	start

start:
	sspd	usrstk
	lxi	sp,stack
	; commandline arg is socket number...
	lxi	h,cmd
	mov	c,m
	inr	c
st0:	inx	h
	dcr	c
	jrz	nopar
	mov	a,m
	cpi	' '
	jrz	st0
	mov	b,a
	sui	'0'
	jrc	nopar
	cpi	8
	jrnc	nopar
	rrc
	rrc
	rrc		; sss00000
	ori	SOCK0
	sta	sokn
	mov	a,b
	sta	premsg+7
nopar:

	lxi	h,buf
	lda	sokn
	mov	d,a
	mvi	e,SnCR
	mvi	b,3
	call	wizget
	lxi	d,premsg
	mvi	c,print
	call	bdos
	lda	buf+2
	lxi	d,clsmsg
	cpi	CLOSED
	jrz	gotsta
	lxi	d,intmsg
	cpi	INIT
	jrz	gotsta
	lxi	d,estmsg
	cpi	ESTAB
	jrz	gotsta
	lxi	d,synmsg
	cpi	15h
	jrz	gotsta
	lxi	d,watmsg
	cpi	1ch
	jrz	gotsta
	call	hexout
	jr	gs0
gotsta:	mvi	c,print
	call	bdos
gs0:	lxi	d,midmsg
	mvi	c,print
	call	bdos
	lda	buf+1
	call	hexout
	call	crlf
;	jmp	exit

exit:
	jmp	cpm

; E = BSB, D = CTL, HL = data, B = length
wizget:
	mvi	a,SCS
	out	wiz$ctl
	xra	a	; hi adr always 0
	out	wiz$dat
	mov	a,e
	out	wiz$dat
	mov	a,d
	out	wiz$dat
	in	wiz$dat	; prime pump
	mvi	c,wiz$dat
	inir
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

	ds	40
stack:	ds	0
usrstk:	dw	0

sokn:	db	SOCK0

premsg:	db	'Socket 0 is $'
midmsg:	db	' intr is $'
clsmsg:	db	'CLOSED$'
intmsg:	db	'INIT$'
estmsg:	db	'ESTABLISHED$'
synmsg:	db	'SYNSENT$'
watmsg:	db	'CLOSE_WAIT$'

buf:	ds	512

	end
