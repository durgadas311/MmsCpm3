VERS EQU '3 ' ; Nov  1, 2018  11:20  drm  "RD512K'3.ASM"
;*********************************************************
;	Disk I/O module for MMS CP/M 3.1
;	for RAM disk on the 512K RAM board
;	Copyright (c) 2018 Douglas Miller
;*********************************************************
false	equ	0
true	equ	not false

	maclib z80

	extrn	@trk,@sect,@dma,@dbnk,@cbnk
	extrn	@dircb,@dtacb
	extrn	@m512k,@t512k
	extrn	?bnksl

larger	equ	true	; larger ramdisk, but larger block size?

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
rd	equ	0	; TODO: get these from mem512k.rel
wr	equ	4	;
map	equ	080h	;

base$pg	equ	13	; memory pages 0-12 used by CP/M 3

driv0	equ	40		; first drive in system
ndriv	equ	1		; # of drives is system

if larger
dsm	equ	151	; 19 pages for ramdisk, 2k blocks
bsh	equ	4
blm	equ	15
exm	equ	1
drm	equ	63	; still requires manual ALV0 setup
alv0	equ	10000000b
else
dsm	equ	255	; 16 pages for ramdisk, 1k blocks
bsh	equ	3
blm	equ	7
exm	equ	0
drm	equ	63	; still requires manual ALV0 setup
alv0	equ	11000000b
endif
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

string: DB	'RD512K ',0
if larger
	DB	'304'
else
	DB	'256'
endif
	DB	'K RAM Disk ',0,'v3.10'
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

r$port:	db	0,0	; mmu,mmu+wr

rd$map:
	db	0	; map value, not bank number
rd$addr:
	dw	0	; always in low 16K
usr$map:
	dw	0	; pointer to map value, not bank number, from @dbnk + @dma
usr$addr:
	dw	0	; always in low 16K, from @dma

; common memory routines to copy to/from ramdisk
; Interrupts must be disabled before calling.
; Caller must restore bank 0 mapping on return.
rd$read:
	lbcd	r$port	; B=WR, C=RD
	lda	rd$map	; source mapping
	outp	a
	mov	c,b	; WR port
	lhld	usr$map	; dest mapping
	outi	; OK in all cases that matter...
	inr	c
	outi
	lhld	usr$addr; DATA BUFFER ADDRESS (dest)
	xchg
	lhld	rd$addr	; source addr
	lxi	b,128
	ldir
	ret

rd$write:
	lbcd	r$port	; B=WR, C=RD
	mov	a,b	; save from OUTI
	lhld	usr$map	; src mapping
	outi	; OK in all cases that matter...
	inr	c
	outi
	mov	c,a
	lda	rd$map	; dest mapping
	outp	a
	lhld	rd$addr	; dest addr
	xchg
	lhld	usr$addr; DATA BUFFER ADDRESS (source)
	lxi	b,128
	ldir
	ret

thread	equ	$

	dseg

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
	lda	@m512k
	sta	r$port
	mov	c,a
	adi	wr
	sta	r$port+1
	mov	b,a
	mvi	a,base$pg+map	; first page of upper 304K
	outp	a
	mov	c,b
	outp	a
	lxi	h,0	; first sector... first dirent (label)
	lxi	d,label
	mvi	b,lblen
ird2:	ldax	d
	cmp	m
	jnz	ird1
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
	lda	@cbnk
	call	?bnksl
	ret

login$rd:
	xra	a
	ret

setup$rw:
	lhld	@dma
	mov	a,h
	ani	0c0h
	rlc
	rlc
	mov	b,a	; 000000aa
	mov	a,h
	ani	03fh
	mov	h,a
	shld	usr$addr
	lda	@dbnk
	add	a
	add	a	; 0000bb00
	ora	b	; 0000bbaa
	mov	c,a
	mvi	b,0
	lxi	h,@t512k
	dad	b
	shld	usr$map
	lda	@sect	; 0-127
	ora	a
	rar	; * 128
	mov	h,a
	mvi	a,0
	rar
	mov	l,a
	shld	rd$addr
	lda	@trk	; 0-18
	adi	base$pg+map	; upper 304K, enable mapping
	sta	rd$map
	ret

read$rd:
	call	setup$rw
	di
	call	rd$read
	lda	@cbnk
	call	?bnksl
	ei
	ret

write$rd:
	call	setup$rw
	di
	call	rd$write
	lda	@cbnk
	call	?bnksl
	ei
	ret

	end
