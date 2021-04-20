; CP/M program to initialize an SDCard attached to an MT011

	maclib	z80

spi	equ	5ch

spi?wr	equ	spi+0
spi?rd	equ	spi+1
spi?ctl	equ	spi+2

CS0	equ	00001000b
CS1	equ	00010000b
CS2	equ	00100000b
NUMCS	equ	3
SDSCS	equ	CS2	; SCS for SDCard

CMDST	equ	01000000b	; command start bits

cpm	equ	0000h
bdos	equ	0005h
cmdlin	equ	0080h

conout	equ	2

CR	equ	13
LF	equ	10

	org	100h
	jmp	start

cstab:	db	CS0,CS1,CS2
retry:	db	5

start:	lxi	sp,stack
	mvi	a,SDSCS	; default
	sta	curcs
	lxi	h,cmdlin
	mov	c,m
	inx	h
	mvi	b,0
	dad	b
	mvi	m,0	; NUL term
	lxi	h,cmdlin+1
	call	parcs	; curcs revised if needed
	jc	error

	di	; don't need/want interrupts
	; waive 1mS delay... we are well past that...
	call	run74	; must cycle >= 74 clocks

	; CMD0 - enter SPI mode
	lxi	h,cmd0
	mvi	d,1
	mvi	e,1	; turn off SCS
	call	sdcmd
	jc	fail
	lda	cmd0+6	; R1
	cpi	00000001b	; IDLE bit set?
	jnz	fail
	lxi	h,cmd8
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	sdcmd
	jc	fail
	lda	cmd8+6
	cpi	00000001b	; no error, IDLE bit still set
	jrz	ok8
	bit	2,a	; Illegal Command
	jz	fail	; must be some other error - fatal
	; CMD8 not recognized, SD1 card... (not supported?)
	mvi	a,0
	sta	acmd41+1
ok8:
	mvi	a,5
	sta	retry
init:	; this could take a long time... don't flood console
	lxi	h,acmd41
	mvi	d,1
	call	doacmd
	jc	fail
	lda	acmd41+6
	cpi	00000000b	; READY?
	jrz	init0
	ani	01111110b	; any errors?
	jrz	init
	lda	retry
	dcr	a
	sta	retry
	jrnz	init
	jmp	fail
init0:	; done with init
	; now try CMD58 if applicable
	lda	acmd41+1
	ora	a
	jrz	next
	; SD2... get CMD58
	lxi	h,cmd58
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	sdcmd
next:
	; read CID...
	lxi	h,cmd10
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	sdcmd
	jc	fail
	lda	cmd10+6
	ora	a
	jrnz	bad
	lxi	h,cid
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	jrc	badblk
	; read CSD...
	lxi	h,cmd9
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	sdcmd
	jrc	fail
	lda	cmd9+6
	ora	a
	jrnz	bad
	lxi	h,csd
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	jrnc	done
badblk:	call	hexout
bad:	xra	a
	out	spi?ctl	; SCS off
	jr	fail
done:	lxi	d,donems
	call	msgout
	call	prcid
	call	prcsd
exit:
	ei
	jmp	cpm

fail:	lxi	d,failms
exit0:	call	msgout
	jr	exit

error:	lxi	d,synerr
	jr	exit0

curcs:	db	SDSCS

; command is always 6 bytes (?)
; From RomWBW:
;    AT LEAST ONE SD CARD IS KNOWN TO FAIL ANY COMMAND
;    WHERE THE CRC POSITION IS NOT $FF
; This explains the problems with "Samsung 32Pro",
; although that card only requires the end-command bit.
cmd0:	db	CMDST+0,0,0,0,0,95h
	db	0
cmd8:	db	CMDST+8,0,0,01h,0aah,87h
	db	0,0,0,0,0
cmd55:	db	CMDST+55,0,0,0,0,1
	db	0
acmd41:	db	CMDST+41,40h,0,0,0,1
	db	0
cmd58:	db	CMDST+58,0,0,0,0,1
ocr:	db	0,0,0,0,0
cmd17:	db	CMDST+17,0,0,0,0,1
	db	0
cmd9:	db	CMDST+9,0,0,0,0,1	; SEND_CSD
	db	0
cmd10:	db	CMDST+10,0,0,0,0,1	; SEND_CID
	db	0

hexout:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
hexdig:
	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jr	chrout

crlf:	mvi	a,CR
	call	chrout
	mvi	a,LF
	jr	chrout

space:	mvi	a,' '
	jr	chrout

slash:	mvi	a,'/'
	jr	chrout

point:	mvi	a,'.'
	jr	chrout

quote:	mvi	a,'"'
	jr	chrout

msgout:	ldax	d
	ora	a
	rz
	inx	d
	call	chrout
	jr	msgout

chrout:	push	psw
	push	b
	push	d
	push	h
	mov	e,a
	mvi	c,conout
	call	bdos
	pop	h
	pop	d
	pop	b
	pop	psw
	ret

; parse for "CS#" and update 'curcs'
parcs:
par9:	mov	a,m
	ora	a
	rz
	inx	h
	cpi	' '
	jrz	par9
	cpi	'C'
	stc
	rnz
	inx	h
	mov	a,m
	cpi	'S'
	stc
	rnz
	inx	h
	mov	a,m
	cpi	'0'
	rc
	cpi	'0'+NUMCS
	cmc
	rc
	inx	h
	; check for NUL?
	sui	0
	mov	c,a
	mvi	b,0
	xchg
	lxi	h,cstab
	dad	b
	mov	a,m
	sta	curcs
	xchg
	xra	a
	ret

synerr:	db	CR,LF,'*** syntax ***',0
failms:	db	CR,LF,'*** failed ***',0
donems:	db	CR,LF,'Done.',0

; run-out at least 74 clock cycles... with SCS off...
run74:	mvi	b,10	; 80 cycles
	mvi	c,spi?rd
run740:	inp	a
	djnz	run740
	ret

; always turns off SCS
doacmd:
	push	h
	push	d
	lxi	h,cmd55
	mvi	d,1
	mvi	e,0	; do not turn off SCS
	call	sdcmd
	; ignore results? CMD55 never gives error?
	pop	d
	pop	h
	mvi	e,1	; do turn off SCS
	call	sdcmd
	push	psw
	; for some reason, this is required (at least for ACMD41)
	; when certain cards (Flexon) are in-socket during power up.
	; If the card is re-seated after power up, this is not needed.
	; Unclear if this is a MT011 anomaly or universal.
	in	spi?rd
	in	spi?rd
	pop	psw
	ret

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success), HL=idle length, DE=gap length
sdcmd:
	lda	curcs
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for idle
	; TODO: timeout this loop
	push	h	; save command+response buffer
sdcmd0:	inp	a
	cpi	0ffh
	jrnz	sdcmd0
if spi?wr <> spi?rd
	mvi	c,spi?wr
endif
	pop	h	; command buffer back
	mvi	b,6
	outir
if spi?wr <> spi?rd
	mvi	c,spi?rd
endif
	inp	a	; prime the pump
	; TODO: timeout this loop
sdcmd2:	inp	a
	cpi	0ffh
	jrz	sdcmd2
	mov	b,d
	mov	m,a
	inx	h
	dcr	b
	jrz	sdcmd4
	inir	; rest of response
sdcmd4:	mov	a,e	; SCS flag
	ora	a
	rz
	xra	a
	out	spi?ctl	; SCS off
	ret

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; HL=buffer, BC=length* (multiple of 256)
; return CY on error (A=error), DE=gap length
sdblk:
	push	b
	lda	curcs
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for packet header (or error)
	; TODO: timeout this loop
sdblk0:	inp	a
	cpi	0ffh
	jrz	sdblk0
	pop	d		; length to DE
	cpi	11111110b	; data start
	stc	; else must be error
	jrnz	sdblk2
	mov	b,e
sdblk3:	inir
	dcr	d
	jrnz	sdblk3
	inp	a	; CRC 1
	inp	a	; CRC 2
	xra	a	; NC
sdblk2:	push	psw
	xra	a
	out	spi?ctl	; SCS off
	pop	psw
	ret

procr:	; ocr: 00 C0 FF 80 =? 80FFC000 = pwrup, 2.7-3.6V
	ret

prcid:	lxix	cid
	call	crlf
	ldx	a,+0	; MID
	call	hexout
	call	space
	call	quote
	ldx	a,+1	; OID[0]
	call	chrout
	ldx	a,+2	; OID[1]
	call	chrout
	call	quote
	call	space
	call	quote
	ldx	a,+3	; PNM[0]
	call	chrout
	ldx	a,+4	; PNM[1]
	call	chrout
	ldx	a,+5	; PNM[2]
	call	chrout
	ldx	a,+6	; PNM[3]
	call	chrout
	ldx	a,+7	; PNM[4]
	call	chrout
	call	quote
	call	space
	ldx	a,+8	; PRV
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	call	point
	ldx	a,+8	; PRV
	call	hexdig
	call	space
	; s/n - for now, print in hex...
	ldx	a,+9	; PSN[0]
	call	hexout
	ldx	a,+10	; PSN[1]
	call	hexout
	ldx	a,+11	; PSN[2]
	call	hexout
	ldx	a,+12	; PSN[3]
	call	hexout
	call	space
	ldx	h,+13	; MDT hi
	ldx	l,+14	; MDT lo
	mov	a,l
	ani	0fh
	call	decout
	call	slash
	dad	h
	dad	h
	dad	h
	dad	h	; shift year into H
	mov	e,h
	mvi	d,0
	lxi	h,2000
	dad	d
	call	dec16
	ret

prcsd:	lxix	csd
	call	crlf
	mvi	a,'v'
	call	chrout
	ldx	a,+0
	ani	11000000b	; CSD_STRUCTURE
	mvi	a,'1'
	jrz	v10
	mvi	a,'2'
v10:	call	chrout
	call	point
	mvi	a,'0'
	call	chrout
	ldx	a,+0
	ani	11000000b	; CSD_STRUCTURE
	rz	; nothing more for v1.0...
	; v2.0...
	call	space
if 0
	ldx	l,+7	; C_SIZE...
	ldx	d,+8
	ldx	e,+9
	; TODO: print decimal...
	mov	a,l
	call	hexout
	mov	a,d
	call	hexout
	mov	a,e
	call	hexout
else
	ldx	h,+7	; C_SIZE << 10
	ldx	l,+8
	ldx	d,+9
	mvi	e,0	;
	ora	a	; NC
	ralr	d
	dadc	h
	ora	a	; NC
	ralr	d
	dadc	h
	call	dec32
endif
	lxi	d,blks
	call	msgout
	ret

blks:	db	' blks',0

; print number in HL:DE
dec32:
	mvi	c,0
	lxix	mlt10
	mvi	b,9
dc1:	xra	a
dc0:	call	sub32
	inr	a
	jrnc	dc0
	call	add32
	dcr	a
	jrnz	dc2
	bit	0,c
	jrz	dc3
dc2:	setb	0,c
	adi	'0'
	call	chrout
dc3:	inxix
	inxix
	inxix
	inxix
	djnz	dc1
	mvi	a,'0'
	add	e
	jmp	chrout

mlt10:
	db	3Bh,9Ah,0CAh,00h	;  1,000,000,000
	db	05h,0F5h,0E1h,00h	;    100,000,000
	db	00h,98h,96h,80h		;     10,000,000
	db	00h,0Fh,42h,40h		;      1,000,000
	db	00h,01h,86h,0A0h	;        100,000
	db	00h,00h,27h,10h		;         10,000
	db	00h,00h,03h,0E8h	;          1,000
	db	00h,00h,00h,64h		;            100
	db	00h,00h,00h,0ah		;             10

add32:	push	psw
	mov	a,e
	addx	+3
	mov	e,a
	mov	a,d
	adcx	+2
	mov	d,a
	mov	a,l
	adcx	+1
	mov	l,a
	mov	a,h
	adcx	+0
	mov	h,a
	pop	psw
	ret	; CY ignored

sub32:	push	psw
	mov	a,e
	subx	+3
	mov	e,a
	mov	a,d
	sbbx	+2
	mov	d,a
	mov	a,l
	sbbx	+1
	mov	l,a
	mov	a,h
	sbbx	+0
	mov	h,a
	; CY = borrow... must preserve
	jrc	sb0
	pop	psw
	ora	a	; NC
	ret
sb0:	pop	psw
	stc
	ret

; print number in HL, 0-9999
dec16:
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
	mvi	a,'0'
	add	b
	call	chrout
	ret

; A=number to print, 0-99
; destroys B, C, D, E (and A)
decout:
	mvi	d,10
	call	divide
	adi	'0'
	call	chrout
	ret

divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

cid:	ds	16
csd:	ds	16

	ds	128
stack:	ds	0

	end
