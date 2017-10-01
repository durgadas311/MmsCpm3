;	Dump program, reads input file and displays hex data
;
	org	100h
bdos	equ	0005h	;dos entry point
cons	equ	1	;read console
typef	equ	2	;type function
printf	equ	9	;buffer print entry
brkf	equ	11	;break key function (true if char ready)
openf	equ	15	;file open
readf	equ	20	;read function
;
fcb	equ	5ch	;file control block address
buff	equ	80h	;input disk buffer address
;
;	non graphic characters
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
;
;	file control block definitions
fcbdn	equ	fcb+0	;disk name
fcbfn	equ	fcb+1	;file name
fcbft	equ	fcb+9	;disk file type (3 characters)
fcbrl	equ	fcb+12	;file's current reel number
fcbrc	equ	fcb+15	;file's record count (0 to 128)
fcbcr	equ	fcb+32	;current (next) record number (0 to 127)
fcbln	equ	fcb+33	;fcb length
;
;	set up stack
	lxi	h,0
	dad	sp
;	entry stack pointer in hl from the ccp
	shld	oldsp
;	set sp to local stack area (restored at finis)
	lxi	sp,stktop
;	read and print successive buffers
	call	setup	;set up input file
	cpi	255	;255 if file not present
	jnz	openok	;skip if open is ok
;
;	file not there, give error message and return
	lxi	d,opnmsg
	call	err
	jmp	finis	;to return
;
openok:	;open operation ok, set buffer index to end
	mvi	a,80h
	sta	ibp	;set buffer pointer to 80h
;	hl contains next address to print
	lxi	h,0	;start with 0000
;
gloop:
	push	h	;save line position
	call	gnb
	pop	h	;recall line position
	jc	finis	;carry set by gnb if end file
	mov	b,a
;	print hex values
;	check for line fold
	mov	a,l
	ani	0fh	;check low 4 bits
	jnz	nonum
;	print line number
	call	crlf
;
;	check for break key
	call	break
;	accum lsb = 1 if character ready
	rrc		;into carry
	jc	finis	;don't print any more
;
	mov	a,h
	call	phex
	mov	a,l
	call	phex
nonum:
	inx	h	;to next line number
	mvi	a,' '
	call	pchar
	mov	a,b
	call	phex
	jmp	gloop
;
finis:
;	end of dump
	call	crlf
	lhld	oldsp
	sphl
;	stack pointer contains ccp's stack location
	ret		;to the ccp
;
;
;	subroutines
;
break:	;check break key (actually any key will do)
	push h! push d! push b; environment saved
	mvi	c,brkf
	call	bdos
	pop b! pop d! pop h; environment restored
	ret
;
pchar:	;print a character
	push h! push d! push b; saved
	mvi	c,typef
	mov	e,a
	call	bdos
	pop b! pop d! pop h; restored
	ret
;
crlf:
	mvi	a,cr
	call	pchar
	mvi	a,lf
	call	pchar
	ret
;
;
pnib:	;print nibble in reg a
	ani	0fh	;low 4 bits
	cpi	10
	jnc	p10
;	less than or equal to 9
	adi	'0'
	jmp	prn
;
;	greater or equal to 10
p10:	adi	'a' - 10
prn:	call	pchar
	ret
;
phex:	;print hex char in reg a
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	pnib	;print nibble
	pop	psw
	call	pnib
	ret
;
err:	;print error message
;	d,e addresses message ending with "$"
	mvi	c,printf	;print buffer function
	call	bdos
	ret
;
;
gnb:	;get next byte
	lda	ibp
	cpi	80h
	jnz	g0
;	read another buffer
;
;
	call	diskr
	ora	a	;zero value if read ok
	jz	g0	;for another byte
;	end of data, return with carry set for eof
	stc
	ret
;
g0:	;read the byte at buff+reg a
	mov	e,a	;ls byte of buffer index
	mvi	d,0	;double precision index to de
	inr	a	;index=index+1
	sta	ibp	;back to memory
;	pointer is incremented
;	save the current file address
	lxi	h,buff
	dad	d
;	absolute character address is in hl
	mov	a,m
;	byte is in the accumulator
	ora	a	;reset carry bit
	ret
;
setup:	;set up file 
;	open the file for input
	xra	a	;zero to accum
	sta	fcbcr	;clear current record
;
	lxi	d,fcb
	mvi	c,openf
	call	bdos
;	255 in accum if open error
	ret
;
diskr:	;read disk file record
	push h! push d! push b
	lxi	d,fcb
	mvi	c,readf
	call	bdos
	pop b! pop d! pop h
	ret
;
;	fixed message area
signon:	db	'file dump version 2.0$'
opnmsg:	db	cr,lf,'no input file present on disk$'

;	variable area
ibp:	ds	2	;input buffer pointer
oldsp:	ds	2	;entry sp value from ccp
;
;	stack area
	ds	64	;reserve 32 level stack
stktop:
;
	end
