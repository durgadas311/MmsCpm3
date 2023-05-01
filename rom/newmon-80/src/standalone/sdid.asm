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

; locations inside CID
CIDMFG	equ	0	; for 1
CIDOEM	equ	1	; for 2
CIDPRD	equ	3	; for 5
CIDREV	equ	8	; for 1
CIDSN	equ	9	; for 4
CIDMDT	equ	13	; for 2 (xY YM)
; locations inside CSD
CSDVER	equ	0	; various, v2 indicator
CSDSIZ	equ	7	; for 3 (v2 only)

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
	; CMD8 not recognized, SD1 card...
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
	; CMD58 is listed "optional"...
	lxi	h,cmd58
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	sdcmd
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
	lda	ocr	; actually, the response
	ani	0100b	; Illegal Command
	jnz	dmp0	; No OCR returned
	call	crlf
	lxi	h,ocrmsg
	call	msgout
	lxi	h,ocr+1
	call	dmpline
dmp0:
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

nodmp:
	call	crlf
	lxi	h,model
	call	msgout
	call	prver	; "SDv2.0"
	call	space
	mvi	a,'('
	call	chrout
	lda	cid+CIDMFG	; manufacturer ID
	call	decout		; TODO: "(%d)"?
	mvi	a,')'
	call	chrout
	call	space
	lxi	h,cid+CIDOEM
	mvi	b,2
	call	numout
	call	space
	lxi	h,cid+CIDPRD
	mvi	b,5
	call	numout
	call	space
	call	prmdt
	call	crlf
	call	prsn
	call	crlf
	call	prrev
	call	crlf
	call	prcap	; incl CR/LF
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
	db	0,0,0,0,0,0,0,0,0,0,0,0	; for dmpline
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

; like message out, but num chrs in B (> 0)
numout:	mov	a,m
	inx	h
	call	chrout
	dcr	b
	jnz	numout
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

prmdt:
	lxi	h,cid+CIDMDT
	mov	d,m	; +13	; MDT hi
	inx	h
	mov	e,m	; +14	; MDT lo
	push	d
	mov	a,e
	ani	0fh
	call	dec02
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

prsdx:
	mvi	a,'S'
	call	chrout

; Print SD version from CSD, preceded by SDSC/SDHC/SDXC
; return A=version bits (11000000b)
prver:
	mvi	a,'S'
	call	chrout
	mvi	a,'D'
	call	chrout
	lda	cmd58+7
	ani	40h
	mvi	a,'S'
	jz	v00
	; test for SDHC or SDXC (C_SIZE > xxx)
	lhld	csd+CSDSIZ+1
	lxi	d,1
	dad	d
	lda	csd+CSDSIZ
	aci	0
	mvi	a,'H'
	jz	v00
	mvi	a,'X'
v00:	call	chrout
	mvi	a,'C'
	call	chrout
	call	space
	mvi	a,'v'
	call	chrout
	lda	csd+CSDVER
	ani	11000000b	; CSD_STRUCTURE
	push	psw
	mvi	a,'1'
	jz	v10
	mvi	a,'2'
v10:	call	chrout
	call	point
	mvi	a,'0'
	call	chrout
	pop	psw
	ret

prrev:
	lxi	h,rev
	call	msgout
	lda	cid+CIDREV ; BCD "n.m"
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	mvi	a,'.'
	call	chrout
	pop	psw
	call	hexdig
	ret

; print s/n from CID
prsn:
	lxi	h,serial
	call	msgout
	lxi	h,cid+CIDSN
	mvi	b,4
sn0:	mov	a,m
	inx	h
	call	hexout
	dcr	b
	jnz	sn0
	ret

; print capacity from CSD
prcap:
	lxi	h,cap
	call	msgout
	lda	csd+CSDVER
	ani	11000000b	; CSD_STRUCTURE
	jz	prcap1		; use v1 CSD structure
	lxi	h,csd+CSDSIZ
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
prc0:	call	dec32
	lxi	h,blks	; incl. CR/LF
	call	msgout
	ret

prcap1:
	; TODO: compute CSD v1 capacity - yuk.
	; MULT = CSD[49:47] ((csd[10] & 0x80) >> 7) | ((csd[9] & 0x03) << 1)
	; C_SIZE = CSD[76:62] (csd[6] & 0x03) << 10) | (csd[7] << 2) | ((csd[8] & 0xc0) >> 6)
	; CAP = (C_SIZE + 1) * MULT
	lda	csd+6
	ani	3
	mov	h,a	; << 8
	lda	csd+7
	ora	a
	ral
	mov	l,a
	mov	a,h
	ral
	mov	h,a
	mov	a,l
	ora	a
	ral
	mov	l,a
	mov	a,h
	ral
	mov	h,a
	lda	csd+8
	rlc
	rlc
	ani	3
	ora	l
	mov	l,a	; HL = CSD[73:62]
	inx	h	; HL = C_SIZE+1
	lda	csd+9
	ani	3
	mov	e,a
	lda	csd+10
	ral
	mov	a,e
	ral		; A = CSD[49:47] = C_SIZE_MULT
	adi	2	; C_SIZE_MULT+2
	xchg		;
	lxi	b,0	; BC:DE = C_SIZE+1, A = C_SIZE_MULT+2
	call	shl32n	; BC:DE <<= A
	jmp	prc0

model:	db	'Model: ',0
serial:	db	'S/N: ',0
rev:	db	'Rev: ',0
cap:	db	'Capacity: ',0
blks:	db	' blocks(sectors)',CR,LF,0
ocrmsg:	db	'OCR: ',0
cidmsg:	db	'CID: ',0
csdmsg:	db	'CSD: ',0
spcs:	db	'  ',0

; BC:DE <<= A
shl32n:	ora	a	; just in case it's zero
	rz
shl32x:
	push	psw
	call	shl32
	pop	psw
	dcr	a
	jnz	shl32x
	ret

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

; print number in BC:DE, leading zero suppr
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

; print decimal 00-99
dec02:
	mvi	c,1
	jmp	dec00
; A=number to print, 0-255 (leading zero suppr)
; destroys B, C, D, E (and A)
decout:
	mvi	c,0
	mvi	d,100
	call	divide
dec00:	mvi	d,10
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
	jnz	div1
	dcr	c
	inr	c
	rz
div1:	mvi	c,1
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
