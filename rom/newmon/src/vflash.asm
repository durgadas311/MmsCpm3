; Stand-Alone Program to flash the ROM from an image on VDIP1 USB stick
VERN	equ	10h
	maclib	z80

CR	equ	13
LF	equ	10
BS	equ	8
BEL	equ	7
CTLC	equ	3

imgbuf	equ	7000h
imgtop	equ	imgbuf+8000h
ticcnt	equ	201bh	; for vdip1.lib
ctl$F0	equ	2009h
ctl$F2	equ	2036h

	cseg
begin:
	lxi	sp,stack
	lxi	d,signon
	call	msgout
	lxi	h,ctl$F0
	mov	a,m
	ori	01000000b	; 2mS back on
	mov	m,a
	out	0f0h
	ei
	call	runout
	call	sync
	jrc	error
over:	lxi	d,quest
	call	msgout
	call	linin
	jrc	cancel
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
	jrc	nofile
	lxi	h,imgbuf	; 4k below end of ROM
loop0:	call	vdrd
	jrc	rderr
	mov	a,h
	cpi	HIGH imgtop
	jrnz	loop0
	; one more read, should be error (EOF)
	lxi	h,4000h	; a safe place to destroy...
	call	vdrd
	jrnc	rderr
	call	close
	call	vchksm	; verify checksum
	jrc	ckerr
	; now, ready to start flash...
	lxi	d,ready
	call	msgout
	call	linin
	jrc	cancel
	; after started, there's no going back...
	; ...
	; success (?)
	lxi	d,done
	call	msgout
error:
	; do something smarter...
	lxi	d,die
	call	msgout
	di
	hlt

ckerr:	lxi	d,cserr
eloop:	call	msgout
	jr	over

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
	db	' - Update ROM from VDIP1',0
clf:	db	'clf',CR
cserr:	db	CR,LF,BEL,'ROM image checksum error',0
fierr:	db	CR,LF,BEL,'ROM image read error, or size wrong',0
nferr:	db	CR,LF,BEL,'ROM image file not found',0
canc:	db	CR,LF,'ROM flash cancelled',0
ready:	db	CR,LF,'Press RETURN to start flash: ',0

quest:	db	CR,LF,'Enter ROM image file: ',0
done:	db	CR,LF,'ROM update complete',0
die:	db	CR,LF,'Press RESET',0

defrom:	db	'h8mon2.rom',0	; default rom image file

vchksm:	lxi	h,0
	shld	sum
	shld	sum+2
	lxi	b,8000h-4
	lxi	d,imgbuf
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

; input a filename from console, allow backspace
; returns C=num chars
linin:
	lxi	h,inbuf
	mvi	c,0	; count chars
lini0	call	conin
	cpi	CR
	mvi	m,CR
	jrz	conout	; echo CR and return
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

; flash ROM from HL to DE, 64 bytes only.
; DE must be on a 64-byte boundary.
; returns CY on error, else HL,DE at next 64 bytes
; caller must set WE... and MEM1 as needed.
flash:
	di
	lxi	b,64
	ldir
	; -----
	; wait for write to begin... 150uS...
	; 2400 cycles at 16MHz...
	lxi	b,100
flash1:	dcx	b	; 6
	mov	a,b	; 4
	ora	c	; 4
	jrnz	flash1	; 12 = 26, *100 = 2600
	; -----
	dcx	h
	dcx	d	; last addr written...
	; TODO: timeout this loop?
flash0:	ldax	d
	xra	m
	ani	10000000b	; bit7 is inverted when busy...
	jrnz	flash0
	inx	h
	inx	d
	; done with page...
	xra	a	; NC
	ret

	maclib	vdip1

opr:	db	'opr '	; is posisiotn for filename...
inbuf:	ds	128	; file name entry buffer

	ds	128
stack:	ds	0

vdbuf:	ds	128	; for vdip1.lib
buf:	ds	128	; file read buffer
	end
