VERS EQU '1 ' ; Feb 15, 2020  16:39  drm  "RDZ180'3.ASM"
;*********************************************************
;	Disk I/O module for MMS CP/M 3.1
;	for RAM disk on the Z180 MMU 1M RAM
;	Copyright (c) 2020 Douglas Miller
;*********************************************************
false	equ	0
true	equ	not false

	maclib z180

	extrn	@trk,@sect,@dma,@dbnk,@cbnk
	extrn	@compg
	extrn	@dircb,@dtacb
	extrn	@tz180,@dz180
	extrn	?bnksl

;---------------------------------------------------------
;
;	Physical drives are assigned as follows:
;
;	40 - 1st drive
;
;---------------------------------------------------------
;	Ports and Constants
;---------------------------------------------------------
;  PORT ASSIGNMENTS

mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah
sar0l	equ	20h
sar0h	equ	21h
sar0b	equ	22h
dar0l	equ	23h
dar0h	equ	24h
dar0b	equ	25h
bcr0l	equ	26h
bcr0h	equ	27h
dstat	equ	30h
dmode	equ	31h
dcntl	equ	32h

; CP/M 3 uses 00000-39FFF, ROM is at F8000-FFFFF
base$pg	equ	3ah	; 778240 bytes, 760.0K, 6080 sectors (128B)
num$pgs	equ	190	; in case anyone asks

driv0	equ	40		; first drive in system
ndriv	equ	1		; # of drives is system

dsm	equ	380-1	; 778240 bytes for ramdisk
bsh	equ	4
blm	equ	15	; 2K block size
exm	equ	0
drm	equ	128-1	; still requires manual ALV0 setup
alv0	equ	11000000b
;-------------------------------------------------------
;	Start of relocatable disk I/O module.
;-------------------------------------------------------
	cseg

	dw	thread
	db	driv0,ndriv
	jmp	init$rd
	jmp	login$rd
	jmp	read$rd
	jmp	write$rd
	dw	string
	dw	dphtbl,modtbl

string: DB	'RDZ180 ',0
	DB	'760K RAM Disk ',0,'v3.10'
	DW	VERS
	DB	'$'

modtbl: db	10000000b,00000000b,00000000b,00000000b ; drive 40, like HDD
	  db	11111111b,11111111b,11111111b,11111111b

rddpb:	dw	128	; SPT - arbitrary
	db	bsh,blm,exm
	dw	dsm,drm
	db	alv0,0
	dw	08000h,0
	db	0,0	; PSH,PSM = 128byte sectors

; 128 bytes to/from 'pbuf', HL=src, DE=dst
xfer$dma:
	di
	lda	@dbnk
	call	?bnksl
	lxi	b,128
	ldir
	xra	a
	call	?bnksl
	ei
	ret

pbuf:	ds	128

thread	equ	$

	dseg

usr$addr: db	0,0,0
dsk$addr: db	0,0,0

; No bank switching required, most of the time.
; No data buffers, no HASH
dphtbl: dw	0,0,0,0,0,0,rddpb,0,alv40,@dircb,0ffffh,0ffffh
	db 0

alv40:	ds	(dsm+1)/4 	;

; This could be overlapped with alv40: never used after init$rd.
label:	db	020h,'RAMDISK3LBL'
lblen	equ	$-label
	db	00000001b,0,0,0	; no modes (yet)
	db	0,0,0,0,0,0,0,0	; password
	db	0,0,0,0		; ctime
	db	0,0,0,0		; utime

init$rd:	; interrupts are disabled - leave them that way
	; Check if a valid directory already exists...
	; carefully change mapping to make this easier...
	; note: we must be (are) in bank 0...
	mvi	a,1000$0000b	; common at 8000, 32K for ramdisk view
	out0	a,mmu$cbar
	mvi	a,base$pg
	out0	a,mmu$bbr	; map in first part of ramdisk
	lxi	h,0	; first sector... first dirent (label)
	lxi	d,label
	mvi	b,lblen
ird2:	ldax	d
	cmp	m
	jrnz	ird1
	inx	d
	inx	h
	djnz	ird2
	jr	ird3
ird1:	; must re-initialize directory (to empty)
	lxi	d,0
	lxi	h,label
	lxi	b,32
	ldir
	xchg	; make rest empty
	lxi	d,32	; bytes/dirent
	mvi	b,drm	; DRM (one already done)
	mvi	a,0e5h	; empty entry
ird0:	mov	m,a
	dad	d
	djnz	ird0
ird3:
	; restore mapping
	xra	a
	out0	a,mmu$bbr	; map in first part of ramdisk
	mvi	a,1110$0000b	; standard mapping (TODO: get from memz180)
	out0	a,mmu$cbar
	ret

login$rd:
	xra	a
	ret

punt:	db	0

; transfer crosses common boundary,
; this really can only happen when @dbnk == 1.
; setup temp buf in known region.
punt$rw:
	xra	a
	sta	usr$addr+2
	lxi	h,pbuf
	shld	usr$addr
	inr	a
	sta	punt
	jr	join$rw

; TODO: handle buffer that crosses common boundary...
setup$rw:
	xra	a
	sta	punt
	; convert bank,vaddr to paddr
	lhld	@dma
	xchg
	lxi	h,@dz180
	lda	@compg	; check for common memory buffer...
	dcr	a
	cmp	d
	jrc	comm$rw	; use bank 0 for common
	jrz	punt$rw
	lda	@dbnk
	add	a
	mov	c,a
	mvi	b,0
	dad	b
comm$rw:
	; add 0:D:E (user dma)
	;   + H:L:0 (actually, (HL+1):(HL):0)
	mov	a,d
	add	m
	mov	d,a
	inx	h
	mvi	a,0
	adc	m
	sta	usr$addr+2
	xchg
	shld	usr$addr
join$rw:
	lda	@sect	; 0-127
	ora	a
	rar	; * 128
	mov	d,a
	mvi	a,0
	rar
	mov	e,a	; DE=sector*128
	lda	@trk	; 0-47 (16K each)
	mov	c,a
	xra	a
	rarr	c	;
	rar		;
	rarr	c	;
	rar		; C:A:0 = track * 128 * 128
	; (0000xxxx:xx000000:00000000) track  C:A:0
	; (00000000:00xxxxxx:x0000000) sector 0:D:E
	; merge C:A:0 (track) and 0:D:E (sector) (no carry possible)
	ora	d
	mov	d,a
	; LBA is C:D:E
	lxi	h,base$pg SHL 4	; base addr of disk
	; add C:D:E
	;   + H:L:0
	mov	a,d
	add	l
	mov	d,a
	mov	a,c
	adc	h
	sta	dsk$addr+2
	xchg
	shld	dsk$addr
	ret

read$rd:
	call	setup$rw
	lxi	h,dsk$addr	; source
	lxi	d,usr$addr	; dest
	call	rw$common
	lda	punt
	ora	a
	rz	; never an error?
	lhld	@dma
	xchg
	lxi	h,pbuf
	jmp	xfer$dma

write$rd:
	call	setup$rw
	lda	punt
	ora	a
	jrz	wr0
	lhld	@dma
	lxi	d,pbuf
	call	xfer$dma
wr0:	lxi	h,usr$addr	; source
	lxi	d,dsk$addr	; dest
	call	rw$common
	xra	a	; never an error?
	ret

rw$common:
	di	; needed?
	mov	a,m
	out0	a,sar0l
	inx	h
	mov	a,m
	out0	a,sar0h
	inx	h
	mov	a,m
	out0	a,sar0b
	ldax	d
	out0	a,dar0l
	inx	d
	ldax	d
	out0	a,dar0h
	inx	d
	ldax	d
	out0	a,dar0b
	mvi	a,128
	out0	a,bcr0l
	xra	a
	out0	a,bcr0h
	mvi	a,00000010b	; mem2mem, burst mode
	out0	a,dmode
	mvi	a,01100000b	; DE0,/DWE0(not /DWE1) - start ch 0
	lxi	b,dstat		; B must be 0, 64-bit I/O internally
	outp	a		; DMA starts now...
rwc0:	tstio	01000000b	; wait for DMAC to idle
	jrnz	rwc0
	ei
	ret

	end
