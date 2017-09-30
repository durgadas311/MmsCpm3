vers equ '1 ' ; Sep 24, 2017  16:24   drm "MEMX2H8.ASM"
;****************************************************************
; Banked Memory BIOS module for CP/M 3 (CP/M plus), 		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

cr	equ 13
lf	equ 10
bell	equ 7

mmu	equ	000h	; Trionyx X/2-H8 Bank Switch Board

;  SCB registers
	extrn @bnkbf,@cbnk

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	4
@compg:	db	0c0h
@mmerr: db	cr,lf,bell,'No X/2-H8$'

; B=source bank, C=dest bank, HL=address, A=num recs
?mvccp: exaf	;save number of records
	mov	a,b
	call	?bnksl	;select source bank
	push	b
	push	h
	lded	@bnkbf
	lxi	b,128
	ldir
	pop	h
	pop	b
	mov	a,c
	call	?bnksl	;select destination bank
	push	b
	xchg
	lhld	@bnkbf
	lxi	b,128
	ldir
	xchg
	pop	b
	exaf
	dcr	a
	jrnz	?mvccp
	ret

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
	mvi	b,4
	mvi	c,mmu
	outir
	pop	h		;
	pop	b		; restore register b
	ret

table:
	db	0$000$1111b	; Bank 0
	db	0$001$0000b
	db	0$010$0000b
	db	0$011$0000b
	db	0$000$1000b	; Bank 1
	db	0$001$0111b
	db	0$010$0000b
	db	0$011$0000b
	db	0$000$1000b	; Bank 2
	db	0$001$0000b
	db	0$010$0111b
	db	0$011$0000b
	db	0$000$1000b	; Bank 3
	db	0$001$0000b
	db	0$010$0000b
	db	0$011$0111b

?move:	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
?xmove:
	ret

	dseg	; this part can be banked

; Verify that we have banked RAM...
; This code assumes the Bank Switch Board is set as for "bank 0" in 'table'
?bnkck:
	lxi	d,40h
	mvi	a,0$000$1110b
	out	mmu
	mvi	a,0$001$0001b
	out	mmu
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$001$0000b
	out	mmu
	mvi	a,0$010$0001b
	out	mmu
	mvi	a,2
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$010$0000b
	out	mmu
	mvi	a,0$011$0001b
	out	mmu
	mvi	a,3
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$011$0000b
	out	mmu
	mvi	a,0$001$0001b
	out	mmu
	ldax	d
	cpi	1
	jnz	noram
	mvi	a,0$001$0000b
	out	mmu
	mvi	a,0$010$0001b
	out	mmu
	ldax	d
	cpi	2
	jnz	noram
	mvi	a,0$010$0000b
	out	mmu
	mvi	a,0$011$0001b
	out	mmu
	ldax	d
	cpi	3
	jnz	noram
	mvi	a,true
noram:	push	psw
	xra	a
	call	?bnksl
	pop	psw
	ret

	end
