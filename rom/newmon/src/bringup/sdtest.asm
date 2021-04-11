; CP/M program to test initialization of an SDCard attached to an MT011

	maclib	z80

TERSE	equ	0	; dump all of sector

spi	equ	5ch

spi?wr	equ	spi+0
spi?rd	equ	spi+1
spi?ctl	equ	spi+2

CS0	equ	00001000b
CS1	equ	00010000b
CS2	equ	00100000b
SDSCS	equ	CS2	; SCS for SDCard

CMDST	equ	01000000b	; command start bits

cpm	equ	0000h
bdos	equ	0005h

conout	equ	2

CR	equ	13
LF	equ	10

	org	100h

	di	; don't need/want interrupts
	lxi	sp,stack
	; waive 1mS delay... we are well past that...
	call	run74	; must cycle >= 74 clocks

	; CMD0 - enter SPI mode
	lxi	h,cmd0
	mvi	d,1
	mvi	e,1	; turn off SCS
	call	docmd
	jc	fail
	lda	cmd0+6	; R1
	cpi	00000001b	; IDLE bit set?
	jnz	fail
	lxi	h,cmd8
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	docmd
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
	call	zero
init:	; this could take a long time... don't flood console
	call	iszero
	mov	e,a
	lxi	h,acmd41
	mvi	d,1
	call	doacmd
	jc	fail
	call	incr
	lda	acmd41+6
	cpi	00000000b	; READY?
	jrnz	init
	; done with init
	call	show	; print count
	lxi	h,acmd41	; dump last command
	mvi	d,1
	call	dumpa
	; now try CMD58 if applicable
	lda	acmd41+1
	ora	a
	jrz	next
	; SD2... get CMD58
	lxi	h,cmd58
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	docmd
next:
	; read CID...
	lxi	h,cmd10
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	docmd
	jc	fail
	lda	cmd10+6
	ora	a
	jrnz	bad
	lxi	h,buf
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	push	psw
	call	crlf
	pop	psw
	jrc	badblk
	lxi	h,buf
	call	dump16
	; read CSD...
	lxi	h,cmd9
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	docmd
	jrc	fail
	lda	cmd9+6
	ora	a
	jrnz	bad
	lxi	h,buf
	lxi	b,0110h	; 16 bytes, 1 loop
	call	sdblk	; turns off SCS
	push	psw
	call	crlf
	pop	psw
	jrc	badblk
	lxi	h,buf
	call	dump16
	; read block LBA 0
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
	call	dumpb0
bad:	xra	a
	out	spi?ctl	; SCS off
	jr	fail
done:	lxi	d,donems
	call	msgout
exit:
	ei
	jmp	cpm

fail:	lxi	d,failms
	call	msgout
	jr	exit

incr:	lxi	h,count
	inr	m
	rnz
	inx	h
	inr	m
	rnz
	inx	h
	inr	m
	rnz
	inx	h
	inr	m
	ret

iszero:	lxi	h,count
	mov	a,m
	inx	h
	ora	m
	inx	h
	ora	m
	inx	h
	ora	m
	ret

zero:	lxi	h,0
	shld	count
	shld	count+2
	ret

show:	call	crlf
	lxi	h,count+3
	mov	a,m
	call	hexout
	dcx	h
	mov	a,m
	call	hexout
	dcx	h
	mov	a,m
	call	hexout
	dcx	h
	mov	a,m
	jmp	hexout

count:	dw	0,0

; command is always 6 bytes (?)
cmd0:	db	CMDST+0,0,0,0,0,95h
	db	0
cmd8:	db	CMDST+8,0,0,01h,0aah,87h
	db	0,0,0,0,0
cmd55:	db	CMDST+55,0,0,0,0,0
	db	0
acmd41:	db	CMDST+41,40h,0,0,0,0
	db	0
cmd58:	db	CMDST+58,0,0,0,0,0
	db	0,0,0,0,0
cmd17:	db	CMDST+17,0,0,0,0,0
	db	0
cmd9:	db	CMDST+9,0,0,0,0,0
	db	0
cmd10:	db	CMDST+10,0,0,0,0,0
	db	0

; HL=command+response buffer, D=response length
dumpa:	push	d
	lxi	d,acmdms
	jr	dump9
dump:	push	d
	lxi	d,cmdmsg
dump9:	call	msgout
	mov	a,m
	inx	h
	ani	00111111b
	call	decout
	mvi	b,5
dump0:	mvi	a,' '
	call	chrout
	mov	a,m
	inx	h
	call	hexout
	djnz	dump0
	mvi	a,':'
	call	chrout
	pop	b	; B=response length
dump1:	mvi	a,' '
	call	chrout
	mov	a,m
	inx	h
	call	hexout
	djnz	dump1
	; now dump idle/gap
	mvi	a,' '
	call	chrout
	mvi	a,'('
	call	chrout
	lhld	idle
	xchg
	call	dec16
	mvi	a,'/'
	call	chrout
	lhld	gap
	xchg
	call	dec16
	mvi	a,')'
	call	chrout
	ret

; dump sector buffer, first and last 16 bytes...
; HL=buffer
dumpb:
if TERSE
	call	dump16
	lxi	d,512-16-16
	dad	d
	lxi	d,elipss
	call	msgout
	call	dump16
	call	crlf
else
	mvi	e,512/16
db0:	call	dump16
	call	crlf
	dcr	e
	jrnz	db0
endif
	; now dump gap
dumpb0:	mvi	a,' '
	call	chrout
	mvi	a,'('
	call	chrout
	lhld	gap
	xchg
	call	dec16
	mvi	a,')'
	call	chrout
	ret

; dump 16 bytes at HL
dump16:
	mvi	b,16
dumpb1:	mvi	a,' '
	call	chrout
	mov	a,m
	inx	h
	call	hexout
	djnz	dumpb1
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

; A=number to print
; destroys B, C, D, E (and A)
decout:
	mvi	c,0
	mvi	d,100
	call	divide
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

acmdms:	db	CR,LF,'ACMD',0
cmdmsg:	db	CR,LF,'CMD',0
failms:	db	CR,LF,'*** failed ***',0
donems:	db	CR,LF,'Done.',0
elipss:	db	CR,LF,' ...',CR,LF,0

; run-out at least 74 clock cycles... with SCS off...
run74:	mvi	b,10	; 80 cycles
	mvi	c,spi?rd
run740:	inp	a
	djnz	run740
	ret

idle:	dw	0
gap:	dw	0

; HL=command, D=resp len, E=scs flag
docmd:
	push	h
	push	d
	call	sdcmd
	pop	d
	pop	h
	push	psw
	call	dump
	pop	psw
	ret

; E=dump flag, always turns off SCS
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
	push	h
	push	d
	mvi	e,1
	call	sdcmd
	pop	d
	pop	h
	push	psw
	mov	a,e
	ora	a
	cz	dumpa
	pop	psw
	ret

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success), HL=idle length, DE=gap length
sdcmd:
	mvi	a,SDSCS
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for idle
	; TODO: timeout this loop
	push	h	; save command+response buffer
	lxi	h,0	; count idle length
	shld	idle
	shld	gap
sdcmd0:	inp	a
	cpi	0ffh
	jrz	sdcmd1
	inx	h
	mov	a,h
	ora	l
	jrz	sdcmd5	; timeout at overflow...
	jr	sdcmd0
sdcmd1:	shld	idle
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
	push	h	; points to response area...
	; TODO: timeout this loop
	lxi	h,0	; count gap length
sdcmd2:	inp	a
	cpi	0ffh
	jrnz	sdcmd3
	inx	h
	mov	a,h
	ora	l
	jrz	sdcmd6	; timeout at overflow...
	jr	sdcmd2
sdcmd3:	shld	gap
	pop	h	; response buffer back
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
sdcmd5:	lxi	h,-1
	shld	idle
sdcmd7:	pop	h
	call	sdcmd4	; SCS off if needed
	stc
	mvi	a,0ffh
	ret
sdcmd6:	lxi	h,-1
	shld	gap
	jr	sdcmd7

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; HL=buffer, BC=length*
; return CY on error (A=error), DE=gap length
sdblk:
	push	b
	mvi	a,SDSCS
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for packet header (or error)
	; TODO: timeout this loop
	lxi	d,0	; count gap length
sdblk0:	inp	a
	cpi	0ffh
	jrnz	sdblk1
	inx	d
	mov	a,d
	ora	e
	jrz	sdblk4	; timeout at overflow...
	jr	sdblk0
sdblk1:	sded	gap
	pop	d
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
sdblk4:	lxi	h,-1
	shld	gap
	pop	b
	stc
	mvi	a,0ffh
	jr	sdblk2

buf:	ds	512

	ds	128
stack:	ds	0

	end
