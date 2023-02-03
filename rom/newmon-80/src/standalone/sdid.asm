; program to initialize and identify an SDCard attached to an H8xSPI
	maclib core

spi	equ	40h

spi?wr	equ	spi+0
spi?rd	equ	spi+0
spi?ctl	equ	spi+1

CS0	equ	00000001b
CS1	equ	00000010b
CS2	equ	00000100b
CS3	equ	00001000b
NUMCS	equ	4
SDSCS0	equ	CS2	; SCS for SDCard 0
SDSCS1	equ	CS3	; SCS for SDCard 1
NUMSD	equ	2

CMDST	equ	01000000b	; command start bits

CR	equ	13
LF	equ	10

	cseg
	jmp	start

cstab:	db	SDSCS0,SDSCS1
retry:	db	5

start:	lxi	sp,stack
	mvi	a,SDSCS0	; default
	sta	curcs
	lxi	h,2280h	; NUL terminated
	inx	h	; skip length
	; skip program name
skp0:	mov	a,m
	inx	h
	ora	a
	jz	skp1
	cpi	' '
	jnz	skp0
	call	parcs	; curcs revised if needed
	jc	error
skp1:
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
	jz	ok8
	ani	0100b	; Illegal Command
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
	jz	init0
	ani	01111110b	; any errors?
	jz	init
	lda	retry
	dcr	a
	sta	retry
	jnz	init
	jmp	fail
init0:	; done with init
	; now try CMD58 if applicable
	lda	acmd41+1
	ora	a
	jz	next
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
	jnz	bad
	lxi	h,cid
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	jc	badblk
	; read CSD...
	lxi	h,cmd9
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	sdcmd
	jc	fail
	lda	cmd9+6
	ora	a
	jnz	bad
	lxi	h,csd
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	jnc	done
badblk:	call	hexout
bad:	xra	a
	out	spi?ctl	; SCS off
	jmp	fail
done:
	ei
	lda	dmp
	ora	a
	jz	nodmp
	call	crlf
	lxi	h,cidmsg
	call	msgout
	lxi	h,cid
	call	dmpline
	call	crlf
	lxi	h,csdmsg
	call	msgout
	lxi	h,csd
	call	dmpline
	call	crlf
	jmp	exit

nodmp:	call	prcid
	call	prcsd
	call	crlf
exit:
	ei
	lhld	retmon
	pchl

fail:	lxi	h,failms
exit0:	call	msgout
	jmp	exit

error:	lxi	h,synerr
	jmp	exit0

curcs:	db	SDSCS0
dmp:	db	0

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
	jmp	chrout

space:	mvi	a,' '
	jmp	chrout

slash:	mvi	a,'/'
	jmp	chrout

point:	mvi	a,'.'
	jmp	chrout

quote:	mvi	a,'"'
	;jmp	chrout

chrout:	push	h
	lhld	conout
	xthl
	ret

; parse for "CS#" and update 'curcs'
parcs:
par9:	mov	a,m
	ora	a
	rz
	inx	h
	cpi	' '
	jz	par9
	cpi	'0'
	rc
	cpi	'0'+NUMSD
	jnc	par0
	; check for NUL?
	sui	'0'
	mov	c,a
	mvi	b,0
	xchg
	lxi	h,cstab
	dad	b
	mov	a,m
	sta	curcs
	xchg
	jmp	par9
par0:	ani	01011111b
	cpi	'D'
	jnz	par9	; error?
	sta	dmp
	jmp	par9

synerr:	db	CR,LF,'*** syntax ***',0
failms:	db	CR,LF,'*** failed ***',0

; run-out at least 74 clock cycles... with SCS off...
run74:	mvi	b,10	; 80 cycles
run740:	in	spi?rd
	dcr b ! jnz	run740
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
sdcmd0:	in	spi?rd
	cpi	0ffh
	jnz	sdcmd0
	pop	h	; command buffer back
	mvi	b,6
	call	outir
	in	spi?rd	; prime the pump
	; TODO: timeout this loop
sdcmd2:	in	spi?rd
	cpi	0ffh
	jz	sdcmd2
	mov	b,d
	mov	m,a
	inx	h
	dcr	b
	jz	sdcmd4
	call	inir	; rest of response
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
sdblk0:	in	spi?rd
	cpi	0ffh
	jz	sdblk0
	pop	d		; length to DE
	cpi	11111110b	; data start
	stc	; else must be error
	jnz	sdblk2
	mov	b,e
sdblk3:	call	inir
	dcr	d
	jnz	sdblk3
	in	spi?rd	; CRC 1
	in	spi?rd	; CRC 2
	xra	a	; NC
sdblk2:	push	psw
	xra	a
	out	spi?ctl	; SCS off
	pop	psw
	ret

procr:	; ocr: 00 C0 FF 80 =? 80FFC000 = pwrup, 2.7-3.6V
	ret

prcid:	lxi	h,cid
	call	crlf
	mov	a,m	; +0	; MID
	call	hexout
	call	space
	call	quote
	inx	h
	mov	a,m	; +1	; OID[0]
	call	chrout
	inx	h
	mov	a,m	; +2	; OID[1]
	call	chrout
	call	quote
	call	space
	call	quote
	inx	h
	mov	a,m	; +3	; PNM[0]
	call	chrout
	inx	h
	mov	a,m	; +4	; PNM[1]
	call	chrout
	inx	h
	mov	a,m	; +5	; PNM[2]
	call	chrout
	inx	h
	mov	a,m	; +6	; PNM[3]
	call	chrout
	inx	h
	mov	a,m	; +7	; PNM[4]
	call	chrout
	call	quote
	call	space
	inx	h
	mov	a,m	; +8	; PRV
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	call	point
	mov	a,m	; +8	; PRV
	call	hexdig
	call	space
	; s/n - for now, print in hex...
	inx	h
	mov	a,m	; +9	; PSN[0]
	call	hexout
	inx	h
	mov	a,m	; +10	; PSN[1]
	call	hexout
	inx	h
	mov	a,m	; +11	; PSN[2]
	call	hexout
	inx	h
	mov	a,m	; +12	; PSN[3]
	call	hexout
	call	space
	inx	h
	mov	d,m	; +13	; MDT hi
	inx	h
	mov	e,m	; +14	; MDT lo
	push	d
	mov	a,e
	ani	0fh
	call	decout
	call	slash
	pop	h
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

prcsd:	lxi	h,csd
	call	crlf
	mvi	a,'v'
	call	chrout
	mov	a,m	; +0
	ani	11000000b	; CSD_STRUCTURE
	mvi	a,'1'
	jz	v10
	mvi	a,'2'
v10:	call	chrout
	call	point
	mvi	a,'0'
	call	chrout
	mov	a,m	; +0
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
	inx	h	; +1
	inx	h	; +2
	inx	h	; +3
	inx	h	; +4
	inx	h	; +5
	inx	h	; +6
	inx	h	; +7
	mov	b,m	; +7	; C_SIZE << 10
	inx	h
	mov	c,m	; +8
	inx	h
	mov	d,m	; +9
	mvi	e,0	;	BC:DE is << 8, need two more
	mvi	a,1	; C_SIZE+1
	add	d
	mov	d,a
	mvi	a,0
	adc	c
	mov	c,a
	mvi	a,0
	adc	b
	mov	b,a
	call	shl32
	call	shl32
	call	dec32
endif
	lxi	h,blks
	call	msgout
	ret

blks:	db	' blks',0
cidmsg:	db	'CID: ',0
csdmsg:	db	'CSD: ',0
spcs:	db	'  ',0

; BC:DE <<= 1
shl32:
	mov	a,e
	add	a
	mov	e,a
	mov	a,d
	ral
	mov	d,a
	mov	a,c
	ral
	mov	c,a
	mov	a,b
	ral
	mov	b,a
	ret

; print number in BC:DE
dec32:
	mvi	l,0
	mvi	h,9
	push	h	; control vars on stack
	lxi	h,mlt10
dd1:	xra	a
dd0:	call	sub32
	inr	a
	jnc	dd0
	call	add32
	xthl	; control vars in HL
	dcr	a
	jnz	dd2
	dcr	l
	inr	l
	jz	dd3
dd2:	mvi	l,1
	adi	'0'
	call	chrout
dd3:
	dcr	h
	xthl	; control vars back on stack
	inx	h
	inx	h
	inx	h
	inx	h
	jnz	dd1
	pop	h
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

; BC:DE += (mlt10[HL])
add32:	push	psw
	inx	h
	inx	h
	inx	h
	mov	a,e
	add	m
	mov	e,a
	dcx	h
	mov	a,d
	adc	m
	mov	d,a
	dcx	h
	mov	a,c
	adc	m
	mov	c,a
	dcx	h
	mov	a,b
	adc	m
	mov	b,a
	pop	psw
	ret	; CY ignored

; BC:DE += (mlt10[HL])
sub32:	push	psw
	inx	h
	inx	h
	inx	h
	mov	a,e
	sub	m
	mov	e,a
	dcx	h
	mov	a,d
	sbb	m
	mov	d,a
	dcx	h
	mov	a,c
	sbb	m
	mov	c,a
	dcx	h
	mov	a,b
	sbb	m
	mov	b,a
	; CY = borrow... must preserve
	jc	sb0
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
	call	dsbc
	inr	b
	jnc	dv0
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
	jnc	div0
	add	d
	dcr	e
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

dsbc:	push	psw
	mov	a,l
	sbb	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	jc	dsbc0
	pop	psw
	ora	a
	ret
dsbc0:	pop	psw
	stc
	ret

; Dump 16 bytes at HL
dmpline:
	push	d
	push	h
	; blank space provided by dmphex
	pop	h
	push	h
	call	dmphex
	lxi	h,spcs
	call	msgout
	pop	h
	push	h
	call	dmpchr
	pop	h
	pop	d
	ret

dmphex:
	mvi	b,16
dh0:	mvi	a,' '
	call	chrout
	mov	a,m
	call	hexout
	inx	h
	dcr b ! jnz	dh0
	ret

dmpchr:
	mvi	b,16
dc0:	mov	a,m
	cpi	' '
	jc	dc1
	cpi	'~'+1
	jc	dc2
dc1:	mvi	a,'.'
dc2:	call	chrout
	inx	h
	dcr b ! jnz	dc0
	ret

inir:	push	psw
inir0:	in	spi?rd
	mov	m,a
	inx	h
	dcr	b
	jnz	inir0
	pop	psw
	ret

outir:	push	psw
outir1:	mov	a,m
	out	spi?wr
	inx	h
	dcr	b
	jnz	outir1
	pop	psw
	ret

cid:	ds	16
csd:	ds	16

	ds	128
stack:	ds	0

	end
