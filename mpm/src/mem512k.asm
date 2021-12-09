vers equ '1 ' ; Dec 5, 2021  07:58   drm "MEM512K.ASM"
;****************************************************************
; Banked Memory BIOS module for MP/M              		*
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
	extrn @cbnk

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr,@memstr
	public @m512k,@t512k	; used by RD512K'3

;  Routines for use by other modules
	public ?memsl,?bnksl,?bnkck,?xmove,?move

	dseg		; GENSYS results in DSEG stuff in common memory

@nbnk:	db	10	; use all 512K
@compg:	db	0c0h
@mmerr: db	cr,lf,bell,'No RAM512K$'
@m512k:	db	mmu
@memstr: db	'RAM512K ',0,'H8 512K RAM with MMU ',0,'v3.00'
	dw	vers
	db	'$'

xbnksl:	
	di	; might already be disabled??
	push	b
	push	h
	lhld	xtable+2
	push	h
	lhld	xtable
	jr	bnksl0	; restores HL, BC...

; Interrupts disabled - must not enable
?memsl:		; MP/M entry - BC=memsegtbl[x]
	inx	b
	inx	b
	inx	b
	ldax	b	; 'bank' from memsegtbl[]
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
@t512k:
table:
	db	 0, 1, 2,3	; Bank 0 map pattern (same as RESET)
	db	 4, 5, 6,3	; Bank 1 map pattern
	db	 7, 8, 9,3	; Bank 2 map pattern
	db	10,11,12,3	; Bank 3 map pattern
	db	13,14,15,3	; Bank 4
	db	16,17,18,3	; Bank 5
	db	19,20,21,3	; Bank 6
	db	22,23,24,3	; Bank 7
	db	25,26,27,3	; Bank 8
	db	28,29,30,3	; Bank 9
	db	0	; safety stop for RD512K'3
tablez	equ	$-table

xcache:	dw	0
xtable:	dw	table,table

; This is only called from an XMOVE scenario,
; immediately after the ?xmove call.
; Must ensure we are not dispatched in the middle,
; so on entry A=0 if interrupts are (already) disabled.
; HL=dest addr, DE=source addr, BC=length
?move:	ora	a
	push	psw
	call	xbnksl	; disables interrupts
xxm0:
	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
	lda	@cbnk
	call	?bnksl
	pop	psw
	rz	; leave interrupts as-is
	ei
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
	; return NZ status (required?)
	pop	h
	ret

	cseg	; this part can be banked

noram:	xra	a	; disable banked memory
	out	mmu
	ret		; A=0 no banked memory

; Interrupts are disabled
; A=compag from MP/M GENSYS
; TODO: assert(@compg == A)
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
