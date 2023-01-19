vers equ '1 ' ; Feb 14, 2020  17:00   drm "MEMZ180.ASM"
;****************************************************************
; Banked Memory BIOS module for CP/M 3 (CP/M plus)		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
; For Z180 MMU and 1M memory
	maclib z180

COMMPG	equ	0e0h

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

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

BNK0$PG	equ	00h	; 00000-0DFFF, 0E000-0FFFF common
BNK1$PG	equ	10h	; 10000-0DFFF
BNK2$PG	equ	1eh	; 1E000-2BFFF
BNK3$PG	equ	2ch	; 2C000-39FFF

;  SCB registers
	extrn @bnkbf,@cbnk,@dtacb,@dircb,@heapt

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr,@memstr
	public @tz180,@dz180 ; for ramdisk

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	4	; not total, just for CP/M
@compg:	db	COMMPG
@mmerr: db	cr,lf,bell,'No Z180$'
@memstr: db	'RAMZ180 ',0,'Z180 MMU 1M ',0,'v3.10'
	dw	vers
	db	'$'

; Uses XMOVE semantics
; C=source bank, B=dest bank, HL=address, A=num recs
?mvccp:
	push	psw
	push	h
	call	?xmove
	pop	h
	pop	psw
	mov	b,a
	mvi	c,0
	srlr	b
	rarr	c	; BC = A * 128
	mov	e,l
	mov	d,h	; same address, diff banks
	call	?move
	ret

; DE=src, HL=dst, BC=count
; Common memory addresses must use bank 0.
; A move must not span common boundary.
; Also, common memory must be bank 0 = 00000.
xmv:
	xra	a
	sta	xflag
	push	h	; save dst
	out0	e,sar0l
	lhld	xsrc
	mov	a,d
	cpi	COMMPG
	jrc	xmv1
	lxi	h,dmatbl+0	; use bank 0
xmv1:	mov	a,m
	add	d
	out0	a,sar0h
	inx	h
	mov	a,m
	aci	0
	out0	a,sar0b
	xchg
	xthl		; save src, get dst
	xchg		; DE=dst (TOS=src)
	out0	e,dar0l
	lhld	xdst
	mov	a,d
	cpi	COMMPG
	jrc	xmv2
	lxi	h,dmatbl+0	; use bank 0
xmv2:	mov	a,m
	add	d
	out0	a,dar0h
	inx	h
	mov	a,m
	aci	0
	out0	a,dar0b
	pop	h	; get src
	dad	b	; final src
	xchg
	dad	b	; final dst
	out0	c,bcr0l
	out0	b,bcr0h
	mvi	a,00000010b	; mem2mem, burst mode
	;xra	a	; mem2mem, cycle-steal
	out0	a,dmode
	mvi	a,01100000b	; DE0,/DWE0 - start ch 0
	out0	a,dstat
	; DMA starts now...
xmv0:	in0	a,dstat
	ani	01000000b
	jrnz	xmv0
	ret

; unless xflag, move between common and current bank
?move:	lda	xflag
	ora	a
	jrnz	xmv	; disables interrupts
	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
	ret

; TODO: avoid redundant selection...
; But must handle xmove also...
?bnksl:
	sta	@cbnk		; remember current bank
	push	b		; save register b for temp
	push	h		;
	lxi	h,table 	;
	mov	c,a		;
	mvi	b,0		;
	dad	b		;
	mov	a,m
	out0	a,mmu$bbr
	pop	h		;
	pop	b		; restore register b
	ret

@tz180:
table:	db	BNK0$PG
	db	BNK1$PG
	db	BNK2$PG
	db	BNK3$PG

@dz180:
dmatbl:	dw	BNK0$PG SHL 4
	dw	BNK1$PG SHL 4
	dw	BNK2$PG SHL 4
	dw	BNK3$PG SHL 4

xflag:	db	0
xsrc:	dw	0	; ptr to dmatbl[src]
xdst:	dw	0	; ptr to dmatbl[dst]

; B=wr bank, C=rd bank
; BDOS30 saves DE/HL
?xmove:
	lxi	d,dmatbl
	mov	l,c	; src bnk
	mvi	h,0
	dad	h
	dad	d
	shld	xsrc
	mov	l,b	; dst bnk
	mvi	h,0
	dad	h
	dad	d
	shld	xdst
	xra	a
	dcr	a
	sta	xflag
	ret

	dseg	; this part can be banked

noram:	xra	a	; disable banked memory
	out0	a,mmu$bbr
	ret		; A=0 no banked memory

?bnkck:
	; init MMU - this must not disturb current memory
	xra	a		;
	out0	a,mmu$cbr	; just to be sure...
	out0	a,mmu$bbr	; ...
	; special com/bnk for test...
	mvi	a,0010$0000b	; compag 2000, bnk base 0000
	out0	a,mmu$cbar
	;
	lxi	d,0040h	; a likely addr in low 16K
	lda	table+1	; bank 1 map code
	out0	a,mmu$bbr
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	lda	table+2	; bank 2 map code
	out0	a,mmu$bbr
	mvi	a,2
	stax	d	;put bank number in 40h of respective bank
	lda	table+3	; bank 3 map code
	out0	a,mmu$bbr
	mvi	a,3
	stax	d	;put bank number in 40h of respective bank
	lda	table+1	; bank 1 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	1
	jnz	noram
	lda	table+2	; bank 2 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	2
	jnz	noram
	lda	table+3	; bank 3 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	3
	jnz	noram
	xra	a		; restore "bank 0"
	out0	a,mmu$bbr	; ...
	; the real com/bnk setup
	mvi	a,1110$0000b	; compag E000, bnk base 0000
	out0	a,mmu$cbar
	xra	a	; redundant?
	call	?bnksl	;
	; Allocate some buffers below BNKBDOS
	lhld	@heapt
	lxi	d,-1024	; max sector size = 1024
	dad	d
	shld	dirbf1
	dad	d
	shld	dirbf2
	dad	d
	shld	dtabf1
	dad	d
	shld	dtabf2
	shld	@heapt
	lxi	h,dtacb1
	shld	@dtacb
	lxi	h,dircb1
	shld	@dircb
	mvi	a,true
	ret		; A<>0 banked memory available

dtacb1: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0
dtabf1:	dw	0
	db 0
	dw dtacb2

dtacb2: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0
dtabf2:	dw	0
	db 0
	dw 0000 ;end of data buffers

dircb1: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0
dirbf1:	dw	0
	db 0
	dw dircb2

dircb2: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0
dirbf2:	dw	0
	db 0
	dw 0000 ;end of DIR buffers

	end
