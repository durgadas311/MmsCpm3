; Stand-Alone Program to flash the ROM from an image on VDIP1 USB stick
VERN	equ	09h
	maclib	z180

CR	equ	13
LF	equ	10
BS	equ	8
BEL	equ	7
CTLC	equ	3

monrom	equ	4096	; length of first contig block in ROM (monitor)
romlen	equ	8000h	; full ROM is 32K
rombeg	equ	0000h	; start of ROM runtime image (in-place)
romend	equ	rombeg+romlen	; end of in-place ROM
K16	equ	16384	; constant: 16K

mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah

; buffer used to hold ROM image for flashing.
; NOTE: the first monrom bytes will be destroyed during flash.
imgbuf	equ	romend-monrom	; 4K below end of full ROM
imgtop	equ	imgbuf+romlen	; end of imgbuf
; The overlap is OK because the first 4K is flashed using
; the not ORG0,not MEM1 "legacy" map, and the memory (image buf)
; at imgbuf is still accessible. Once that 4K is flash, we
; switch to not ORG0,MEM1 "extended" map, and continue flashing.

ctl$F0	equ	2009h
ctl$F2	equ	2036h

	extrn	strcpy,strcmp
	extrn	vdcmd,vdrd,sync,runout
	public	vdbuf

	cseg
begin:
	lxi	sp,stack
	call	cpu$type
	sta	z180	; 'true' if a Z180
	lxi	d,signon
	call	msgout
	lda	z180
	ora	a
	jrz	begin0
	lxi	d,mz180
	call	msgout
begin0:	call	crlf
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
	jc	rderr
	call	progress
	mov	a,h
	cpi	HIGH imgtop
	jrnz	loop0
	; one more read, should be error (EOF)
	lxi	h,4000h	; a safe place to destroy...
	call	vdrd
	jnc	rderr
	call	close
	lxi	d,imgbuf
	call	vchksm	; verify checksum
	jc	ckerr
	; now validate product codes..
	lhld	imgbuf+0ffeh
	lded	0ffeh
	ora	a
	dsbc	d
	mov	a,h
	ora	l
	jnz	pcerr
	; see if we should clear setup area
	lxi	d,clear
	call	msgout
	call	linin
	lda	inbuf
	cpi	'Y'
	jrnz	noera
	sta	era
	lxi	d,clring
	call	msgout
noera:
	; now, ready to start flash...
	lxi	d,ready
	call	msgout
	call	linin
	jc	cancel
	; after started, there's no going back...
	; disable any interruptions, as each page must be
	; entirely written with strict time constraints
	; (<<150uS between each byte).
	di
	lda	z180
	ora	a
	jrz	z80$flash
; z180$flash:
	xra	a	; base page of RAM, where we are now.
	out0	a,mmu$cbr
	mvi	a,0f8h	; start page of ROM in padr space.
	out0	a,mmu$bbr
	mvi	a,0111$0000b	; bnk at 0000, com1 at 7000
	out0	a,mmu$cbar
	; 0000-6FFF is ROM...
	mvi	a,10100000b	; WE, no legacy ROM
	out	0f2h
	lxi	h,imgbuf
	lxi	d,0	; ROM
	lxi	b,K16/64	; first 16K
	lda	era
	ora	a
	jrnz	flsall
	lxi	b,1000h/64	; first 4K
	call	flash
	jrc	error
	lxi	b,0800h
	dad	b
	xchg
	dad	b
	xchg
	lxi	b,(K16-1800h)/64
flsall:
	call	flash
	jrc	error
	; now slide window sash for rest of ROM...
	mvi	a,1000$0000b	; bnk at 0000, com1 at 8000
	out0	a,mmu$cbar
	lxi	b,(8000h-K16)/64	; rest of ROM
	call	flash
	jrc	error
	mvi	a,00100000b	; WE off, no legacy ROM
	out	0f2h
	jr	comm$flash
;
z80$flash:
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
	lda	era
	ora	a
	jrnz	flsal1
	lxi	b,0800h
	dad	b
	xchg
	dad	b
	xchg
	lxi	b,(8000h-1800h)/64	; rest of ROM
flsal1:	call	flash
	jrc	error
	mvi	a,00001000b	; WE off, enable full ROM
	out	0f2h
comm$flash:	; full ROM still mapped at 0000...
	; NOTE: first 32K RAM has been trashed...
	; no point to restoring it in any way.
	; if we decide to try and return to monitor,
	; need to go back to legacy mode and jump 0000.
	lxi	d,0	; ROM
	call	vchksm
	jrc	ckerr2
	; even though RAM is trashed, allow Z180 to
	; restore ROM even if we don't jump to it.
	lda	z180
	ora	a
	jrz	comm0
	xra	a
	out0	a,mmu$bbr	; switch back to normal
comm0:
	lxi	d,done
	call	msgout
error:
	xra	a	; back to RESET state (WE off)
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

pcerr:	lxi	d,perr
	jr	eloop

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
	call	crlf
	call	conout	; another LF
	di
	xra	a
	out	0f2h
	mvi	a,0dfh	; reset state of FP
	out	0f0h
	jmp	0

; Destroys BC and A...
; Return A==0 for Z80, A<>0 for Z180
cpu$type:
	mvi	a,1
	mlt	b	; NEG if Z80... 01 -> FF
	sui	0ffh	; FF (Z80): NC,00; else (Z180): CY,nn
	sbb	a	; FF: Z180, 00: Z80
	ret

z180:	db	0
era:	db	0	; erase setup?
signon:	db	CR,LF,'VFLASH v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
	db	' - Update ROM from VDIP1',0
mz180:	db	' (Z180)',0
clf:	db	'clf',CR
perr:	db	BEL,'ROM image does not match system',CR,LF,0
cserr:	db	BEL,'ROM image checksum error',CR,LF,0
fierr:	db	BEL,'ROM image read error, or size wrong',CR,LF,0
nferr:	db	BEL,'ROM image file not found',CR,LF,0
canc:	db	'ROM flash cancelled',CR,LF,0
clear:	db	'Clear setup data (Y/N)? ',0
clring:	db	'Erasing setup data!',CR,LF,0
ready:	db	'Press RETURN to start flash: ',0

quest:	db	'Enter ROM image file: ',0
done:	db	'ROM update complete',CR,LF,0
die:	db	'Press RESET',CR,LF,0

defrom:	db	'h8mon2.rom',0	; default rom image file

; DE=start of ROM image
; must skip block 0x1000-0x17ff (relative)
vchksm:	lxi	h,0
	shld	sum
	shld	sum+2
	lxi	b,1000h
	call	sum$bc
	lxi	h,0800h	; skip block
	dad	d
	xchg
	lxi	b,8000h-1800h-4
	call	sum$bc
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

sum$bc:	ldax	d
	call	sum1
	inx	d
	dcx	b
	mov	a,c
	ora	a
	jrnz	sum$bc
	mov	a,b
	ora	a
	rz
	ani	00000011b
	cz	progress
	jr	sum$bc

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

crlf:	mvi	a,CR
	call	conout
	mvi	a,LF
	jmp	conout

spinx:	db	0
spin:	db	'-','\','|','/'

opr:	db	'opr '	; in position for filename...
inbuf:	ds	128	; file name entry buffer

	ds	128
stack:	ds	0

vdbuf:	ds	128	; for vdip1.lib
	end
