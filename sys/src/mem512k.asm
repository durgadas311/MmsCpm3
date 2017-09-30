vers equ '1 ' ; Sep 24, 2017  17:05   drm "MEM512K.ASM"
;****************************************************************
; Banked Memory BIOS module for CP/M 3 (CP/M plus)		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

mmu	equ	000h	; base port of RAM256K

rd	equ	0	; mmu offset for read
wr	equ	4	; mmu offset for write
map	equ	080h	; mmu flag to enable mapping...

;  SCB registers
	extrn @bnkbf,@cbnk

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr,@m512k

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	4	; actually, 8 but we save 4 for ramdisk...
@compg:	db	0c0h
@mmerr: db	cr,lf,bell,'No H89-512K$'
@m512k:	db	mmu

; B=source bank, C=dest bank, HL=address, A=num recs
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

xbnksl:	
	di	; might already be disabled??
	push	b
	push	h
	lhld	xtable+2
	push	h
	lhld	xtable
	jr	bnksl0	; restores HL, BC...
; TODO: avoid redundant selection...
; But must handle xmove also...
?bnksl:
	sta	@cbnk		; remember current bank
	push	b		; save register b for temp
	push	h		;
	lxi	h,table 	;
	add	a
	add	a
	mov	c,a		;
	mvi	b,0		;
	dad	b		;
	push	h	; same mapping for WR
bnksl0:	; HL = RD table entry, TOS = WR table entry
	mvi	b,4
	mvi	c,mmu-1
bnksl1:
	inr	c
	outi
	jrnz	bnksl1
	pop	h
	mvi	b,4
bnksl2:
	inr	c
	outi
	jrnz	bnksl2
	pop	h		;
	pop	b		; restore register b
	ret

; Once memory is verified, these all have 'map' bit set.
table:
	db	 0, 1, 2,3	; Bank 0 map pattern
	db	 4, 5, 6,3	; Bank 1 map pattern
	db	 8, 9,10,3	; Bank 2 map pattern
	db	12,13,14,3	; Bank 3 map pattern
tablez	equ	$-table

xcache:	dw	0
xtable:	dw	table,table
xflag:	db	0

?move:	lda	xflag
	ora	a
	cnz	xbnksl	; disables interrupts
xxm0:
	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
	ora	a
	rz
	lda	@cbnk
	call	?bnksl
	xra	a
	sta	xflag
	ei	; is this OK??
	ret

?xmove:
	push	h
	; cache mappings...
	lhld	xcache
	ora	a
	dsbc	b
	jrz	xnomap
xremap:
	sbcd	xcache
	push	d
	lxi	d,table
	mov	a,b	; WR bank number
	add	a
	add	a
	mov	l,a
	mvi	h,0
	dad	d
	shld	xtable+2
	mov	a,c	; RD bank number
	add	a
	add	a
	mov	l,a
	mvi	h,0
	dad	d	; RD bank in HL
	shld	xtable
	pop	d
xnomap:
	xra	a
	dcr	a
	sta	xflag	; return NZ status (required?)
	pop	h
	ret

	dseg	; this part can be banked

noram:	xra	a	; disable banked memory
	out	mmu
	ret		; A=0 no banked memory

?bnkck:
	xra	a
	call	?bnksl	; setup mapping without enabling
	lxi	d,40h	; a likely addr in low 16K
	mvi	a,4+map		; bank 1 map code
	out	mmu+wr
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mvi	a,8+map		; bank 2 map code
	out	mmu+wr
	mvi	a,2
	stax	d	;put bank number in 40h of respective bank
	mvi	a,12+map	; bank 3 map code
	out	mmu+wr
	mvi	a,3
	stax	d	;put bank number in 40h of respective bank
	mvi	a,4+map		; bank 1 map code
	out	mmu
	ldax	d
	cpi	1
	jnz	noram
	mvi	a,8+map		; bank 2 map code
	out	mmu
	ldax	d
	cpi	2
	jnz	noram
	mvi	a,12+map	; bank 3 map code
	out	mmu
	ldax	d
	cpi	3
	jnz	noram
	; Set the "map" enable bit on all mappings
	lxi	h,table
	mvi	b,tablez
in6:	setb	7,m	; (HL) |= map
	inx	h
	djnz	in6
	xra	a
	call	?bnksl	; this enables mapping...
	mvi	a,true
	ret		; A<>0 banked memory available

	end
