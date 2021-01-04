; Stand-alone program to read entire range by two sectors

	maclib	core
	maclib	z80
	aseg
	maclib	setup
	maclib	ram

CR	equ	13
LF	equ	10
BS	equ	8
CTLC	equ	3
DEL	equ	127

SSZ	equ	256	; default sector size, must match the device

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
	call	chkarg

	call	getok	; make sure user wants to do this...
	jc	exit

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
	call	progress
	call	fill
	call	sasi$wr
	jc	sserr2
	mvi	a,0ffh
	sta	buffer	; "poison" buffer contents
	call	sasi$rd
	jc	sserr2
	call	check
	jrz	loop0
	; error... count it...
	mvi	a,CR
	call	chrout
	lhld	count
	inx	h
	shld	count
	call	decwrd
	; let progress "spinner" appear imm. after
loop0:
	lda	seed
	adi	1
	daa
	sta	seed
	call	nxtblk
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

progress:
	lxi	h,spinx
	inr	m
	mov	a,m
	ani	00000011b
	mov	c,a
	mvi	b,0
	lxi	h,spin
	dad	b
	mov	a,m
	call	chrout
	mvi	a,BS
	jmp	chrout

spinx:	db	0
spin:	db	'-\|/'

quit:
	call	crlf
	lxi	h,lstmsg
	call	msgout
	lxi	h,read16
	mvi	b,6
	call	dh0
	call	crlf

; Now dump data...
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

sasi$wr:
	mvi	a,0a3h	; OUTI
	sta	fixcmd+1
	lxi	h,read16
	mvi	m,0ah	; WRITE16 command
	jr	sasi$cmd

sasi$rd:
	mvi	a,0a2h	; INI
	sta	fixcmd+1
	lxi	h,read16
	mvi	m,08h	; READ16 command
;	jr	sasi$cmd

; send SASI read command, get results
; HL=cmd buffer
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
bsasi0:
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
fixcmd:	ini		; input/output data byte
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

sserr2:	lda	read16
	ani	00000010b	; "1" if WRITE
	lxi	h,err2r
	jrz	sserrs
	lxi	h,err2w
	jr	sserrs

; Fill 'buffer' with pattern for 'seed'
fill:	lxi	h,buffer
	lxi	b,512
	lda	seed
	push	psw
fil0:	pop	psw
	mov	m,a
	adi	1
	daa
	push	psw
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jrnz	fil0
	pop	psw
	ret

; Verify that 'buffer' contains pattern for 'seed'
; Returns NZ if failed verification
check:	lxi	h,buffer
	lxi	b,512
	lda	seed
	push	psw
chk0:	pop	psw
	cmp	m
	rnz	; NZ - failed
	adi	1
	daa
	push	psw
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jrnz	chk0
	pop	psw
	xra	a
	ret	; ZR

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

; Advance LBA in 'read16' to next block (1 or two sectors).
nxtblk:
	lxi	h,read16+4	; "num secs" field: 1 or 2
	mov	a,m
	dcx	h
	add	m
	mov	m,a
	dcx	h
	mvi	a,0
	adc	m
	mov	m,a
	dcx	h	; now at LUN/hi-lba, must splice
	mvi	a,0
	adc	m
	ani	00011111b	; wrap back to 0
	mov	c,a
	mov	a,m
	ani	11100000b	; get LUN
	ora	c		; splice LUN into hi-lba
	mov	m,a
	ret

; Scan past ":wrrd256" to see if anything follows...
; Valid args: '0' or '1' for LUN.
chkarg:
	call	chkssz
	lxi	h,2280h
	mov	b,m
	inx	h
ca0:	mov	a,m
	inx	h
	ora	a
	rz
	cpi	' '
	jrz	ca1	; HL=next char after ' '
	djnz	ca0
	ret	; no paramters
ca1:	mov	a,m
	inx	h
	cpi	' '
	jrnz	ca2
	djnz	ca1
	ret	; done with parameters
ca2:	ora	a
	rz	; no more parameters
	; parse param...
	cpi	'0'
	jrc	ca1	; skip invalid
	cpi	'1'
	jrnc	ca1	; skip invalid
	ani	1	; -------d
	rrc		; d-------
	rrc		; -d------
	rrc		; --d-----
	sta	tur+1
	sta	recal+1
	sta	read16+1
	jr	ca1

chkssz:
	lda	2280h+1+4	; "wrrdXYZ": get 'X'
	cpi	'2'		; 256-byte sectors
	jrz	ssz256
	cpi	'5'
	jrz	ssz512
	; error?

	ret	; no change
ssz256:	mvi	a,512/256
	sta	read16+4
	ret
ssz512:	mvi	a,512/512
	sta	read16+4
	ret

getok:	lda	read16+1	; LUN
	ani	11100000b
	rlc
	rlc
	rlc
	adi	'0'
	sta	okmsg0
	sta	usg1
	lxi	h,usgmsg
	call	msgout
	lda	read16+4	; 1=512, 2=256
	cpi	2
	lxi	h,256
	jrz	getok0
	lxi	h,512
getok0:	call	decwrd
	lxi	h,usg0
	call	msgout
	lxi	h,okmsg
	call	msgout
	call	conin
	push	psw
	call	crlf
	pop	psw
	cpi	CR
	rz
	stc	; abort!
	ret

conin:	in	0edh
	ani	00000001b
	jrz	conin
	in	0e8h
	ani	01111111b
	ret

usgmsg:	db	'Assuming ',0
usg0:	db	'-byte sectors, using LUN '
usg1:	db	'X',CR,LF,0
	
okmsg:	db	'This will destroy data on Z67 unit '
okmsg0:	db	'X! Press RETURN to continue: ',0

spcs:	db	'    ',0
nofp:	db	0
sav$F0:	db	0
sav$F2:	db	0

err0:	db	'Reset failed',CR,LF,0
err1:	db	'Recal failed',CR,LF,0
err2r:	db	'Read failed',CR,LF,0
err2w:	db	'Write failed',CR,LF,0

lstmsg:	db	'Last command:',0

seed:	db	0
cport:	db	0
count:	dw	0
tur:	db	00h,20h,00h,00h,00h,00h	; Test Unit Ready, unit 1
recal:	db	01h,20h,00h,00h,00h,00h	; Recalibrate, unit 1

; Read or Write, unit 1, 2 sectors
read16:	db	08h,20h,00h,00h,512/SSZ,00h

cmdptr:	dw	0
resbuf:	dw	0

	ds	128
stack:	ds	0

buffer:	ds	0	; 512 bytes

	end
