; Stand-Alone Program to flash the ROM from an image on VDIP1 USB stick
VERN	equ	10h
	maclib	z80

CR	equ	13
LF	equ	10
BS	equ	8
BEL	equ	7
CTLC	equ	3

monrom	equ	4096	; length of first contig block in ROM (monitor)
romlen	equ	8000h	; full ROM is 32K
rombeg	equ	0000h	; start of ROM runtime image (in-place)
romend	equ	rombeg+romlen	; end of in-place ROM

; buffer used to hold ROM image for flashing.
; NOTE: the first monrom bytes will be destroyed during flash.
imgbuf	equ	romend-monrom	; 4K below end of full ROM
imgtop	equ	imgbuf+romlen	; end of imgbuf
; The overlap is OK because the first 4K is flashed using
; the !ORG0,!MEM1 "legacy" map, and the memory (image buf)
; at imgbuf is still accessible. Once that 4K is flash, we
; switch to !ORG0,MEM1 "extended" map, and continue flashing.

ticcnt	equ	201bh	; for vdip1.lib
ctl$F0	equ	2009h
ctl$F2	equ	2036h

	cseg
begin:
	lxi	sp,stack
	lxi	d,signon
	call	msgout
	; 2mS clock is needed for accessing VDIP1 (timeouts)
	lxi	h,ctl$F0
	mov	a,m
	ori	01000000b	; 2mS back on
	mov	m,a
	out	0f0h
	ei
	call	runout
	call	sync
	jc	error
over:	lxi	d,quest
	call	msgout
	call	linin
	jc	cancel
	mov	a,c
	ora	a
	jrnz	go1	; already CR terminated...
	lxi	h,defrom
	lxi	d,inbuf
	call	strcpy
	mvi	a,CR
	stax	d
go1:	lxi	h,opr
	call	vdcmd
	jc	nofile
	lxi	h,imgbuf	; 4k below end of ROM
loop0:	call	vdrd
	jrc	rderr
	call	progress
	mov	a,h
	cpi	HIGH imgtop
	jrnz	loop0
	; one more read, should be error (EOF)
	lxi	h,4000h	; a safe place to destroy...
	call	vdrd
	jrnc	rderr
	call	close
	lxi	d,imgbuf
	call	vchksm	; verify checksum
	jrc	ckerr
	; now, ready to start flash...
	lxi	d,ready
	call	msgout
	call	linin
	jrc	cancel
	; after started, there's no going back...
	; disable any interruptions, as each page must be
	; entirely written with strict time constraints
	; (<<150uS between each byte).
	di
	mvi	a,10000000b	; WE, partial ROM
	out	0f2h
	lxi	h,imgbuf
	lxi	d,0	; ROM
	lxi	b,4096/64	; first 4K
	call	flash
	jrc	error
	mvi	a,10001000b	; WE, enable full ROM
	out	0f2h
	lxi	b,(8000h-4096)/64	; rest of ROM
	call	flash
	jrc	error
	lxi	d,0	; ROM
	call	vchksm
	jrc	ckerr2
	lxi	d,done
	call	msgout
error:
	xra	a
	out	0f2h
	; do something smarter...?
	lxi	d,die
	call	msgout
	di
	hlt

ckerr2:	lxi	d,cserr
	call	msgout
	jr	error

ckerr:	lxi	d,cserr
eloop:	call	msgout
	jmp	over

; file is still open...
rderr:	call	close
	lxi	d,fierr
	jr	eloop

nofile:	lxi	d,nferr
	jr	eloop

close:	lxi	h,clf
	call	vdcmd
	ret

; cancel, before any flash took place...
; safe return to ROM possible?
cancel:	lxi	d,canc
	call	msgout
	mvi	a,CR
	call	conout
	mvi	a,LF
	call	conout
	call	conout
	di
	xra	a
	out	0f2h
	mvi	a,0dfh	; reset state of FP
	out	0f0h
	jmp	0

signon:	db	CR,LF,'VFLASH v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
	db	' - Update ROM from VDIP1',CR,LF,0
clf:	db	'clf',CR
cserr:	db	BEL,'ROM image checksum error',CR,LF,0
fierr:	db	BEL,'ROM image read error, or size wrong',CR,LF,0
nferr:	db	BEL,'ROM image file not found',CR,LF,0
canc:	db	'ROM flash cancelled',CR,LF,0
ready:	db	'Press RETURN to start flash: ',0

quest:	db	'Enter ROM image file: ',0
done:	db	'ROM update complete',CR,LF,0
die:	db	'Press RESET',CR,LF,0

defrom:	db	'h8mon2.rom',0	; default rom image file

; DE=start of ROM image
vchksm:	lxi	h,0
	shld	sum
	shld	sum+2
	lxi	b,8000h-4
vchk0:	ldax	d
	call	sum1
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	vchk0
	lxi	h,sum
	mvi	b,4
vchk1:	ldax	d
	cmp	m
	stc
	rnz
	inx	d
	inx	h
	djnz	vchk1
	xra	a	; NC
	ret

sum1:	lxi	h,sum
	add	m
	mov	m,a
	rnc
	inx	h
	inr	m
	rnz
	inx	h
	inr	m
	rnz
	inx	h
	inr	m
	ret

sum:	db	0,0,0,0

linix:	mvi	a,CR
	mov	m,a	; terminate buffer
	call	conout
	mvi	a,LF
	jr	conout

; input a filename from console, allow backspace
; returns C=num chars
linin:
	lxi	h,inbuf
	mvi	c,0	; count chars
lini0	call	conin
	cpi	CR
	jrz	linix
	cpi	CTLC	; cancel
	stc
	rz
	cpi	BS
	jrz	backup
	cpi	'.'
	jrz	chrok
	cpi	'-'
	jrz	chrok
	cpi	'0'
	jrc	chrnak
	cpi	'9'+1
	jrc	chrok
	ani	01011111b	; toupper
	cpi	'A'
	jrc	chrnak
	cpi	'Z'+1
	jrnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	c
	call	conout
	; TODO: detect overflow...
	jr	lini0
chrnak:	mvi	a,BEL
	call	conout
	jr	lini0
backup:
	mov	a,c
	ora	a
	jrz	lini0
	dcr	c
	dcx	h
	mvi	a,BS
	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	lini0

conout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

conin:	in	0edh
	ani	00000001b
	jrz	conin
	in	0e8h
	ani	01111111b
	ret

msgout:	ldax	d
	ora	a
	rz
	call	conout
	inx	d
	jr	msgout

; flash ROM from HL to DE, 64 bytes at a time.
; DE must be on a 64-byte boundary.
; BC=num pages to flash
; returns CY on error, else HL,DE at next 64 bytes
; caller must set WE... and MEM1 as needed.
flash:
	push	b
	lxi	b,64
	ldir
	; -----
	dcx	h
	dcx	d	; last addr written...
	; wait for write cycle to begin...
	; TODO: timeout this loop?
flash2:	ldax	d
	xra	m
	ani	10000000b	; bit7 is inverted when busy...
	jrz	flash2
	; wait for write cycle to end...
	; TODO: timeout this loop?
flash0:	ldax	d
	xra	m
	ani	10000000b	; bit7 is inverted when busy...
	jrnz	flash0
	inx	h
	inx	d
	; done with page...
	call	progress
	pop	b
	dcx	b
	mov	a,b
	ora	c
	jrnz	flash
	;xra	a	; NC already
	ret

progress:
	push	h
	push	b
	lxi	h,spinx
	inr	m
	mov	a,m
	ani	00000011b
	mov	c,a
	mvi	b,0
	lxi	h,spin
	dad	b
	mov	a,m
	call	conout
	mvi	a,BS
	call	conout
	pop	b
	pop	h
	ret

spinx:	db	0
spin:	db	'-','\','|','/'

	maclib	vdip1

opr:	db	'opr '	; is posisiotn for filename...
inbuf:	ds	128	; file name entry buffer

	ds	128
stack:	ds	0

vdbuf:	ds	128	; for vdip1.lib
	end
