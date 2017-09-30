VERS equ '0n' ; January 18, 1983  17:22  drm  "SNIOS.ASM"

	maclib	Z80

;*****************************************************
;**** CP/NET I/O module 			 *****
;****  Copyright (C) 1983 Magnolia microsystems  *****
;*****************************************************
; Printer-Server support.  A printer server is characterized
;	by a type number of 030H in Net$table (bytes 1-64)

false	equ	0
true	equ	not false

cpm	equ	0
bdos	equ	5
intbyt	equ	13
RST5	equ	(5)*8

cr	equ	13
lf	equ	10
bell	equ	7

port	equ	0f2h


; Relative positions of message elements
FMT	equ	0
DID	equ	1
SID	equ	2
FNC	equ	3
SIZ	equ	4
MSG	equ	5	;message starts at frame+5

	public	NTWKIN, NTWKST, CNFTBL, SNDMSG, RCVMSG, NTWKER, NTWKBT, CFGTBL

	cseg

CFGTBL:
	db	0	;network status
	db	0	;network address
	db	0,0	;A:=local A:
	db	1,0	;B:=local B:
	db	2,0	; ...
	db	3,0
	db	4,0
	db	5,0
	db	6,0
	db	7,0
	db	8,0
	db	9,0
	db     10,0
	db     11,0
	db     12,0
	db     13,0
	db     14,0
	db     15,0	;P:=local P:
	db	0,0	;console: local
	db	0,0	;list: local
	db	0	;list buffer index
	db	0	;list message header
	db	0	;DID
sid1:	db	0	;SID - must be set by init.
	db	5	;FNC - always #5, list output.
	db	0	;SIZ
	db	0	; ??
	ds	128	;list buffer
Netstat:		; ;added by MMS
maddr:	  db	0	; ;
nstat:	  db	0	; ;
sndsts:   db	0	; ;
srsts:	  db	0	; ; bit0=cpflag, bit1=mailflag, 2=sndsts, 3=netsts
	  dw	rcmsg	; ; buffer that contains the mail.
Net$table:		; ;
	ds	65	; ;

CNFTBL:
	lxi	h,CFGTBL
NTWKER:		;
	ret

; When running as an RSX, we have to always setup page-0.
; Something keeps clobbering our INT5 trap. Probably
; need to call set$jumps in BIOS but we can't.
; Need a mechanism to add/remove INT from BIOS (bank 0 page 0).
; Could try to doctor bank 0 page 0 from here...
NTWKBT:
	mvi	a,(JMP)
	sta	RST5
	lxi	h,INT5
	shld	RST5+1
	ret

NTWKIN:
	xra	a
	sta	srsts
	sta	sndsts
	call	NTWKBT
	in	port
	mvi	c,07cH
	ani	11b
	cpi	11b
	jrz	re0
	mvi	c,078h
	in	port
	ani	1100b
	cpi	1100b
	jrz	re0
	xra	a
	dcr	a
	ret

re0:	mov	a,c
	sta	porta

	call	runout	;clear any characters stacked up in DMA buffer.

	mvi	a,0d1h	;request network status
	sta	func
	call	put
	mvi	a,1000b ;wait for netsts frame
	call	get$frames	;get response
	lda	maddr	;node address
	sta	CFGTBL+1
	sta	sid1
; anywhere else?
; anything else?
	xra	a
	ret

NTWKST:
	call	NTWKBT	; always have to setup page-0
	lxi	h,CFGTBL
	mov	a,m
	res	0,m
	res	1,m
nws:	push	psw
	mvi	a,0d1h	;request network status
	sta	func
	call	put
	lxi	h,srsts
	res	3,m
	mvi	a,1000b ;wait for netsts
	call	get$frames	;get response
	pop	psw
	ret

get$frames:
	lxi	h,srsts
	mov	b,a
	ana	m
	rnz		;quit if frame has been received
	push	b	;POP PSW will put mask in A again.
	call	get
	lda	func
	cpi	0d0h	;status frame
	jrz	nsts
	cpi	0d6h	;send status frame
	jrz	ssts
	cpi	0c2h	;unsolicited message. (does not terminate routine)
	jrz	mail
	cpi	0e0h	;execute
	jrz	exec
	cpi	0c0h	;CP/NET message response
	jrz	cpnet
; What else could it be??
gf0:	pop	psw
	jr	get$frames

cpnet:	lded	rBC
	lxi	h,cpmsg
	call	get422
	lxi	h,srsts
	setb	0,m
	jr	gf0

mail:	lded	rBC
	lxi	h,rcmsg
	call	get422
	lxi	h,srsts
	setb	1,m
	jr	gf0

ssts:	lxi	h,srsts
	setb	2,m
	lda	rBC
	sta	sndsts	;normally this overwrites an "FF"
	ora	a	;(to flag reception of response code)
	jrz	gf0
	jm	gf0
	lxi	h,CFGTBL
	setb	0,m
	jr	gf0

nsts:	lhld	rBC
	shld	netstat
	lxi	h,net$table
	lxi	d,65
	call	get422
	lxi	h,srsts
	setb	3,m
	jr	gf0

exec:	lhld	rHL
	push	h
	lded	rBC
	jmp	get422

RCVMSG:
	lda	nstat
	ani	00010000b
	jrz	error
	push	b
	call	NTWKBT	; always have to setup page-0
	mvi	a,0001b ;wait for cpnet message.
	call	get$frames
	lda	cpmsg+SIZ	;size of message
	mov	l,a
	mvi	h,0
	lxi	d,MSG+1
	dad	d
	mov	c,l
	mov	b,h
	pop	d
	lxi	h,cpmsg
	ldir
	lxi	h,srsts
	res	0,m
	xra	a
	ret

SNDMSG:
	sbcd	savmsg
	call	NTWKBT	; always have to setup page-0
	lda	nstat
	ani	00010000b
	jrz	error
	lxi	h,SIZ	;point to size field
	dad	b
	mov	l,m
	mvi	h,0
	lxi	d,MSG+1 	;add 5 bytes for header, plus bias
	dad	d
	shld	rBC
	push	h
	mvi	a,0c1h	;cp/net message code
	sta	func
	push	b
	call	put
	pop	h
	pop	d
	call	put422
	lxi	h,srsts
	res	2,m	;prevent false-triggering
	mvi	a,0100b ;wait for sndsts
	call	get$frames
	lda	sndsts
	ora	a	;indicate that at least the message got to the 77422.
	rz
error:	xra	a
	dcr	a
	ret

savmsg: dw	0

runout: lda	porta
	mov	c,a
	lxi	h,junk
ro0:	inr	c
	inp	a	;
	ani	1000b
	rz		;no characters waiting
	dcr	c
	inp	a
	jmp	ro0

junk:	db	0,0,0,0

put:	lxi	h,func
	lxi	d,7
; Byte count (DE) must be greater than 1.
put422: mov	a,e	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,d
	jz	pu3
	inr	e
pu3:	mov	b,a
	lda	porta
	mov	c,a
pu1:	inr	c
pu0:	inp	a
	ani	0100b	;check channel 2 for idle
	jz	pu0
	dcr	c
	outi		;send first byte
	jnz	pu1
	dcr	e
	jnz	pu1
	ret

INT5:	inr	c
	outp	a	;this routine will usually terminate "get422".
	dcr	c
	ini		;get last byte of transfer.
	pop	b	;discard interupt return address.
	ei
	ret		;and return to caller.


get:	lxi	h,func
	lxi	d,7
; byte count (DE) must be greater than 1.
get422: dcx	d	;count first byte,
	mov	a,e	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,d
	jrz	ge6
	inr	e
ge6:	mov	b,a
	lda	porta
	mov	c,a
ge1:	inr	c
ge0:	inp	a
	ani	1000b	;check channel 3 for idle
	jrz	ge0
	dcr	c
	ini		;get the characters.
	jnz	ge1
	dcr	e
	jrnz	ge1
ge5:	inp	a	;at this point we have all the characters we want but
	jr	ge5	;the 77422 still has more to send (or it would have
			;interupted us before this point) so we must continue
			;to take characters untill it interupts us.


porta:	db	0

;Network input header:

func:	db	0	;function code (C1 or C6)
rBC:	dw	0	;message size (bytes)
rDE:	dw	0	;
rHL:	dw	0	;


; CP/NET message in:

cpmsg:	db	0	;FMT
	db	0	;DID
	db	0	;SID
	db	0	;FNC
	db	0	;SIZ
	ds	257	;actual message

; CP/NET Mail in:

rcmsg:	db	0	;FMT
	db	0	;DID
	db	0	;SID
	db	0	;FNC
	db	0	;SIZ
rmsg:	ds	257	;actual message

	end
