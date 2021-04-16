; CP/M program to read an arbitrary block
; from an SDCard attached to an MT011
; Card must have been initialized separately (e.g. SDTEST.COM)

	maclib	z80

TERSE	equ	0	; dump all of sector

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
	jrnc	st0
	lxi	h,cmdlin+1
	; Parse LBA from command line (dec)
st0:	call	parlba	; 32-bit LBA in BC:DE
	jrc	error	; different than "no entry"
	; LBA is big-endian...
	lxi	h,cmd17+1
	mov	m,b
	inx	h
	mov	m,c
	inx	h
	mov	m,d
	inx	h
	mov	m,e

	di	; don't need/want interrupts
	; read block LBA in cmd17
	lxi	h,cmd17
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	docmd
	jrc	bad
	lda	cmd17+6
	ora	a
	jrnz	bad
	lxi	h,buf
	lxi	b,512
	call	sdblk	; turns off SCS
	push	psw
	call	crlf
	pop	psw
	jrc	badblk
	lxi	h,buf
	call	dumpb
	jr	done
badblk:	call	hexout
bad:	xra	a
	out	spi?ctl	; SCS off
	jr	fail
done:	lxi	d,donems
exit0:	call	msgout
exit:
	ei
	jmp	cpm

fail:	lxi	d,failms
	jr	exit0

error:	lxi	d,errmsg
	jr	exit0

curcs:	db	SDSCS

; command is always 6 bytes
cmd17:	db	CMDST+17,0,0,0,0,0ffh
	db	0

; dump sector buffer, first and last 16 bytes...
; HL=buffer
dumpb:
	lxi	d,0	; offset
if TERSE
	call	dump16
	lxi	b,512-16-16
	dad	b
	xchg
	dad	b
	xchg
	push	d
	lxi	d,elipss
	call	msgout
	pop	d
	call	dump16
	call	crlf
else
	mvi	c,512/16
db0:	call	dump16
	call	crlf
	dcr	c
	jrnz	db0
endif
	ret

; dump 16 bytes at HL, offset in DE
dump16:
	mov	a,d
	call	hexout
	mov	a,e
	call	hexout
	mvi	a,':'
	call	chrout
	mvi	b,16
dumpb1:	mvi	a,' '
	call	chrout
	mov	a,m
	inx	h
	inx	d
	call	hexout
	djnz	dumpb1
	ret

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

crlf:	mvi	a,CR
	call	chrout
	mvi	a,LF
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

; Parse 32-bit decimal number from command line
; HL=command line (NUL terminated)
; Returns BC:DE = number, or 0 if none, CY if error
parlba:	lxi	d,0
	lxi	b,0
par0:	mov	a,m
	ora	a
	rz
	inx	h
	cpi	' '
	jrz	par0
par1:	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	sui	'0'
	call	mult10
	mov	a,m
	ora	a
	rz
	cpi	' '
	rz
	inx	h
	jr	par1

; Multiply BC:DE by 10 and add A
mult10:
	push	h
	push	b
	popix
	mov	l,e
	mov	h,d
	dadx	ix
	dad	h	; *2
	jrnc	mu0
	inxix
mu0:	dadx	ix
	dad	h	; *4
	jrnc	mu1
	inxix
mu1:	dadx	b
	dad	d	; *5
	jrnc	mu2
	inxix
mu2:	dadx	ix
	dad	h	; *10
	jrnc	mu3
	inxix
mu3:	xchg		; result in DE
	pushix
	pop	b	; and BC
	pop	h
	add	e
	mov	e,a
	mvi	a,0
	adc	d
	mov	d,a
	rnc
	inx	b
	ret

errmsg:	db	CR,LF,'*** cmd syn ***',0
failms:	db	CR,LF,'*** failed ***',0
donems:	db	CR,LF,'Done.',0
elipss:	db	CR,LF,' ...',CR,LF,0

; HL=command, D=resp len, E=scs flag
docmd:
	push	h
	push	d
	call	sdcmd
	pop	d
	pop	h
	ret

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success)
sdcmd:
	mvi	a,SDSCS
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for idle
	; TODO: timeout this loop
sdcmd0:	inp	a
	cpi	0ffh
	jrnz	sdcmd0
if spi?wr <> spi?rd
	mvi	c,spi?wr
endif
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
sdcmd4:
	mov	a,e	; SCS flag
	ora	a
	rz
	xra	a
	out	spi?ctl	; SCS off
	ret

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; HL=buffer, BC=length*
; return CY on error (A=error)
sdblk:
	mov	d,b	; save length to DE
	mov	e,c	; 
	mvi	a,SDSCS
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for packet header (or error)
	; TODO: timeout this loop
sdblk0:	inp	a
	cpi	0ffh
	jrz	sdblk0
	cpi	11111110b	; data start
	stc	; else must be error
	jrnz	sdblk2
	mov	b,e	; low byte of length, to B for INIR
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

buf:	ds	512

	ds	128
stack:	ds	0

	end
