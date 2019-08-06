; Initialization code for NDOS3 on WIZ850io
; Checks for duplicate NDOS3, then initializes WIZ850io
;
	maclib	z80

cr	equ	13
lf	equ	10

; System page-0 constants
cpm	equ	0
bdos	equ	5

; BDOS functions
print	equ	9

; base port of H8-WIZx50io SPI interface
spi	equ	40h

spi$dat	equ	spi+0
spi$ctl	equ	spi+1
spi$sts	equ	spi+1

WZSCS	equ	01b	; SCS for WIZNET
NVSCS	equ	10b	; SCS for NVRAM

; NVRAM/SEEPROM commands
NVRD	equ	00000011b

; WIZNET CTRL bit for writing
WRITE	equ	00000100b

GAR	equ	1	; offset of GAR, etc.
SUBR	equ	5
SHAR	equ	9
SIPR	equ	15
PMAGIC	equ	29	; used for node ID

nsock	equ	8
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

; Socket SR values
CLOSED	equ	00h

; Socket CR commands
DISCON	equ	08h

; RSX is already linked-in, but might be a duplicate

	org	100h
	lxi	sp,stack

	lixd	bdos+1	; this should be our NDOS3
	sixd	us
	jmp	dup0
dup1:
	ldx	a,+18	; LOADER3?
	cpi	0ffh
	jz	ldr3
	call	chkdup
	lxi	d,dupmsg
	jz	rm$us	; duplicate NDOS3, remove "us"
dup0:
	ldx	l,+4	; next RSX...
	ldx	h,+5	;
	push	h
	popix
	jmp	dup1

; DE = message to print
rm$us:
	lixd	us
	mvix	0ffh,+8	; set remove flag
	; also short-circuit it
	ldx	l,+4	; next RSX...
	ldx	h,+5	;
	stx	l,+1	; by-pass duplicate
	stx	h,+2	;
	; report what happened
	mvi	c,print
	call	bdos
	jmp	cpm

; hit LOADER3 RSX, no dup found...
ldr3:
	call	wizcfg
	jnz	nocfg
	jmp	cpm	; let RSX init itself

chkdup:	pushix
	pop	h
	lxi	d,10	; offset of name
	dad	d
	lxi	d,ndos3
	lxi	b,8
chk0:	ldax	d
	cmp	m
	rnz
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	chk0
	ret	; ZR = match

wizcfg:	; restore config from NVRAM
	lxi	h,0
	lxi	d,512
	call	nvget
	call	vcksum
	rnz
	lxi	h,nvbuf+GAR
	mvi	d,0
	mvi	e,GAR
	mvi	b,18	; GAR, SUBR, SHAR, SIPR
	call	wizset
	lxi	h,nvbuf+PMAGIC
	mvi	d,0
	mvi	e,PMAGIC
	mvi	b,1
	call	wizset
	lxix	nvbuf+32
	mvi	d,SOCK0
	mvi	b,8
rest0:	push	b
	ldx	a,SnPORT
	cpi	31h
	jnz	rest1	; skip unconfigured sockets
	call	close
	call	settcp	; ensure MR is set to TCP/IP
	mvi	e,SnPORT
	mvi	b,2
	call	setsok
	mvi	e,SnDIPR
	mvi	b,6	; DIPR and DPORT
	call	setsok
rest1:	lxi	b,32
	dadx	b
	mvi	a,001$00$000b	; socket BSB incr value
	add	d
	mov	d,a
	pop	b
	djnz	rest0
	xra	a
	ret

; Send socket command to WIZNET chip, wait for done.
; A = command, D = socket BSB
; Destroys A
wizcmd:
	push	psw
	mvi	a,WZSCS
	out	spi$ctl
	xra	a
	out	spi$dat
	mvi	a,SnCR
	out	spi$dat
	mov	a,d
	ori	WRITE
	out	spi$dat
	pop	psw
	out	spi$dat	; start command
	xra	a	;
	out	spi$ctl
wc0:
	mvi	a,WZSCS
	out	spi$ctl
	xra	a
	out	spi$dat
	mvi	a,SnCR
	out	spi$dat
	mov	a,d
	out	spi$dat
	in	spi$dat	; prime pump
	in	spi$dat
	push	psw
	xra	a	;
	out	spi$ctl
	pop	psw
	ora	a
	jnz	wc0
	ret

; E = BSB, D = CTL, HL = data, B = length
wizget:
	mvi	a,WZSCS
	out	spi$ctl
	xra	a	; hi adr always 0
	out	spi$dat
	mov	a,e
	out	spi$dat
	mov	a,d
	out	spi$dat
	in	spi$dat	; prime pump
	mvi	c,spi$dat
	inir
	xra	a	; not SCS
	out	spi$ctl
	ret

; HL = data to send, E = offset, D = BSB, B = length
; destroys HL, B, C, A
wizset:
	mvi	a,WZSCS
	out	spi$ctl
	xra	a	; hi adr always 0
	out	spi$dat
	mov	a,e
	out	spi$dat
	mov	a,d
	ori	WRITE
	out	spi$dat
	mvi	c,spi$dat
	outir
	xra	a	; not SCS
	out	spi$ctl
	ret

; Close socket if active (SR <> CLOSED)
; D = socket BSB
; Destroys HL, E, B, C, A
close:
	lxi	h,tmp
	mvi	e,SnSR
	mvi	b,1
	call	wizget
	lda	tmp
	cpi	CLOSED
	rz
	mvi	a,DISCON
	call	wizcmd
	; don't care about results?
	ret

; IX = base data buffer for socket, D = socket BSB, E = offset, B = length
; destroys HL, B, C
setsok:
	pushix
	pop	h
	push	d
	mvi	d,0
	dad	d	; HL points to data in 'buf'
	pop	d
	call	wizset
	ret

; Set socket MR to TCP.
; D = socket BSB (result of "getsokn")
; Destroys all registers except D.
settcp:
	lxi	h,tmp
	mvi	m,1	; TCP/IP mode
	mvi	e,SnMR
	mvi	b,1
	call	wizset	; force TCP/IP mode
	ret

nocfg:	lxi	d,ncfg
	mvi	c,print
	call	bdos
	jmp	cpm

; IX = buffer, BC = length
; return: HL = cksum hi, DE = cksum lo
cksum32:
	lxi	h,0
	lxi	d,0
cks0:	ldx	a,+0
	inxix
	add	e
	mov	e,a
	jrnc	cks1
	inr	d
	jrnz	cks1
	inr	l
	jrnz	cks1
	inr	h
cks1:	dcx	b
	mov	a,b
	ora	c
	jrnz	cks0
	ret

; Validates checksum in 'buf'
; return: NZ on error
; a checksum of 00 00 00 00 means the buffer was all 00,
; which is invalid.
vcksum:
	lxix	nvbuf
	lxi	b,508
	call	cksum32
	lbcd	nvbuf+510
	mov	a,b	;
	ora	c	; check first half zero
	dsbc	b
	rnz
	lbcd	nvbuf+508
	ora	b	;
	ora	c	; check second half zero
	xchg
	dsbc	b	; CY is clear
	rnz
	ora	a	; was checksum all zero?
	jrz	vcksm0
	xra	a	; ZR
	ret
vcksm0:	inr	a	; NZ
	ret

; HL = nvram address, DE = length
nvget:
	mvi	a,NVSCS
	out	spi$ctl
	mvi	a,NVRD
	out	spi$dat
	mov	a,h
	out	spi$dat
	mov	a,l
	out	spi$dat
	in	spi$dat	; prime pump
	mvi	c,spi$dat
	mov	a,e
	ora	a
	jz	nvget1
	inr	d	; TODO: handle 64K... and overflow of 'buf'...
nvget1:	lxi	h,nvbuf
	mov	b,e
nvget0:	inir	; B = 0 after
	dcr	d
	jrnz	nvget0
	xra	a	; not SCS
	out	spi$ctl
	ret

tmp:	db	0

us:	dw	0	; our copy of NDOS3 (remove if dup)

dupmsg:	db	'NDOS3 already loaded',cr,lf,'$'
ndos3:	db	'NDOS3   '
ncfg:	db	'NVRAM not configured',cr,lf,'$'

	ds	64
stack:	ds	0

nvbuf:	ds	512

	end
