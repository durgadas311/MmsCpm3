; Stand-alone program to read two sectors from Z67 and dump in hex/ascii

	maclib	core
	maclib	z80
	aseg
	maclib	setup
	maclib	ram

CR	equ	13
LF	equ	10
CTLC	equ	3
DEL	equ	127

normal	equ	0	; 'true' for original version

	cseg
; get Z67 port...
init:
	di
	lxi	sp,stack
	lda	susave+h67pt
	cpi	0ffh
	jrnz	init1
	mvi	c,10b
	call	getport	; no return on error
	jrnz	init0	; not fatal, if caller gets port later
	mov	a,b
init1:	sta	cport
init0:	xra	a	; NC
	; ensure 2mS clock is enabled
	call	ena2ms
	ei
	
; Now read 2 sectors into buffer...
boot:
	lxi	h,tur
	call	sasi$cmd
	jc	sserr0	; no retries(?)
	lxi	h,recal
	call	sasi$cmd
	jc	sserr1
	lxi	h,0
	shld	count
loop:
if normal
	lxi	h,read16
	call	sasi$cmd
	jc	sserr2
else
	lxi	h,boot10
	call	sasi$cmd
	jc	sserr2
	lxi	h,readb9
	call	sasi$cmd
	jc	sserr2
endif

	lhld	count
	inx	h
	shld	count
	mov	a,l
	call	decwrd
	mvi	a,CR
	call	chrout

	in	0edh	; check for key pressed...
	ani	00000001b
	jrz	loop
	in	0e8h
	ani	01111111b
	cpi	CTLC
	jrz	quit
	cpi	DEL
	jrz	quit
	jr	loop

quit:
	call	crlf
; Now dump data...
	; in all cases, dump 512 bytes.
	lxi	h,buffer
	lxi	d,512
	call	dump
; Done.
exit:
	; more cleanup?
	call	dis2ms
	lhld	retmon
	pchl

; Turn on 2mS clock intrs, interrupts already disabled
ena2ms:	lda	nofp
	ora	a
	jrnz	nfp2ms	; H89 and/or extended H8-Z80 boards
	lxi	h,ctl$F0
	mov	a,m
	sta	sav$F0
	ori	01000000b	; 2mS ON
	mov	m,a
	out	0f0h
	ret
nfp2ms:	lxi	h,ctl$F2
	mov	a,m
	sta	sav$F2
	ori	00000010b	; 2mS ON
	mov	m,a
	out	0f2h
	ani	00000010b	; unlock enable
	out	0f3h		; special Z80 board extension
	ret

dis2ms:	lda	nofp
	ora	a
	jrnz	nfp0ms
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
	ret
nfp0ms:	lda	sav$F2
	sta	ctl$F2
	out	0f2h
	ani	00000010b	; unlock enable
	out	0f3h		; special Z80 board extension
	ret

; send SASI read command, get results
; HL=cmd buffer (512 bytes)
; Reads data until controller says stop...
sasi$cmd:
	shld	cmdptr
	lda	cport
	inr	a
	mov	c,a
	xra	a
	outp	a

	mvi	d,0	; controller number
	mvi	a,4	; delay 8mS, also NZ
	ora	a
;bsasi0:
	call	delay
	di
	mvi	b,0	; wait for "not BUSY" first
	mvi	e,6	;
	lxi	h,0	; 0x060000 loop/timeout count
sscmd0:
	inp	a
	ani	00001000b
	cmp	b
	jrz	sscmd1
	dcx	h
	mov	a,l
	ora	h
	jrnz	sscmd0
	dcr	e
	jrnz	sscmd0
	stc
	ret
sscmd1:
	mov	a,b
	xri	00001000b	; wait for BUSY
	jrz	sscmd2		; got BUSY...
	mov	b,a
	dcr	c
	xra	a
	outp	a
	inr	c
	inr	c
	outp	d	; controller number
	dcr	c
	mvi	a,040h	; SELECT
	outp	a
	jr	sscmd0	; wait for BUSY now...

sscmd2:
	mvi	a,002h	; enable INTR
	outp	a
	lhld	cmdptr
sscmd3:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd3
	bit	4,a	; CMD
	jrz	sscmd4
	bit	6,a	; MSG
	jrz	sscmd6
	dcr	c
	outi		; output command byte
	inr	c
	jr	sscmd3

sscmd4:
	lxi	h,buffer
sscmd5:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd5
	bit	4,a	; CMD - indicates data done
	jrnz	sscmd6
	dcr	c
	ini		; input data byte
	inr	c
	jr	sscmd5
sscmd6:
	inp	a
	ani	0d0h	; REQ, OUT, CMD
	cpi	090h	; must be REQ, CMD
	jrnz	sscmd6	; wait for it...
	dcr	c
	inp	l	; result 0
	inr	c
sscmd7:
	inp	h	; status
	mov	a,h
	ani	0e0h	; REG, OUT, MSG
	cpi	0a0h	; must be REQ, MSG
	jrnz	sscmd7
	shld	resbuf	; command results
	dcr	c
	inp	a	; last data byte
	inr	c
	ei
	ora	a
	stc
	rnz		; error
	bit	0,l	; SASI error bit
	rnz
	bit	1,l	; or other error?
	rnz
	bit	1,h	; ACK
	rnz
	xra	a	; success
	ret

sserr0:	lxi	h,err0
sserrs:	call	msgout
	jmp	exit

sserr1:	lxi	h,err1
	jr	sserrs

sserr2:	lxi	h,err2
	; TODO: dump 'resbuf'?
	jr	sserrs

; HL=buffer, DE=length (multiple of 16)
dump:
	call	dmpline
	call	crlf
	lxi	b,16
	dad	b
	xchg
	ora	a
	dsbc	b
	xchg
	mov	a,d
	ora	e
	jrnz	dump
	ret

; dump amount specified by cmdptr+4 (block count)
; HL=buffer
mdump:
	push	h
	lhld	cmdptr
	inx	h
	inx	h
	inx	h
	inx	h
	mov	d,m	; number of 256-byte blocks
	mvi	e,0
	pop	h
	jr	dump

; fill buffer by amount specified by cmdptr+4 (block count)
mfill:
	lhld	cmdptr
	inx	h
	inx	h
	inx	h
	inx	h
	mov	b,m	; number of 256-byte blocks
	mvi	c,0
	lxi	h,buffer
	mov	e,l
	mov	d,h
	inx	d
	dcx	b
	mvi	m,0ffh
	ldir
	ret

; Dump 16 bytes at HL
dmpline:
	push	d
	push	h
	; yuk... need offset, not address...
	lxi	d,buffer
	ora	a
	dsbc	d
	call	hexwrd
	mvi	a,':'
	call	chrout
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
	djnz	dh0
	ret

dmpchr:
	mvi	b,16
dc0:	mov	a,m
	cpi	' '
	jrc	dc1
	cpi	'~'+1
	jrc	dc2
dc1:	mvi	a,' '
dc2:	call	chrout
	inx	h
	djnz	dc0
	ret

; HL=word
hexwrd:	mov	a,h
	call	hexout
	mov	a,l
hexout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
chrout:	lixd	conout
	pcix

; Print out HL in decimal
decwrd:
	mvi	c,0	; leading zero suppression
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

spcs:	db	'    ',0
nofp:	db	0
sav$F0:	db	0
sav$F2:	db	0

err0:	db	'Reset failed',CR,LF,0
err1:	db	'Recal failed',CR,LF,0
err2:	db	'Read failed',CR,LF,0

cport:	db	0
count:	dw	0
tur:	db	00h,20h,00h,00h,00h,00h	; Test Unit Ready, unit 1
recal:	db	01h,20h,00h,00h,00h,00h	; Recalibrate, unit 1
read16:	db	08h,20h,00h,00h,02h,00h	; Read, unit 1, 2 sectors
boot10:	db	08h,00h,00h,00h,0ah,80h	; Read, unit 0, 10 sectors, retry
readb9:	db	08h,00h,00h,09h,01h,00h	; Read, unit 0, sector 9
cmdptr:	dw	0
resbuf:	dw	0

	ds	128
stack:	ds	0

buffer:	ds	0	; 512
	; possibly up to 2560 bytes...

	end
