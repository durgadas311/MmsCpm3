vers equ '1 ' ; Sep 24, 2017  17:30   drm "MEM318.ASM"
;****************************************************************
; Banke Membory BIOS module for CP/M 3 (CP/M plus),		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

bnksiz	equ	56	;size of banks, in "K". Either 48 or 56.

cr	equ 13
lf	equ 10
bell	equ 7

port	equ	0f2h	;interupt/memory control port

;  SCB registers
	extrn @bnkbf,@cbnk,@intby

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	3
@mmerr: db	cr,lf,bell,'No 77318$'

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
	mov	c,a		;
	mvi	b,0		;
	dad	b		;
	mov	b,m		;
	lxi	h,@intby	;
	mov	a,m		;
	ani	11001011b	;
	ora	b		;
	mov	m,a		;
	out	port		;
	pop	h		;
	pop	b		; restore register b
	ret


	IF bnksiz EQ 56

@compg	db	0e0h

table:	db	20H	;select code for bank 0
	db	14H	; bank 1 (56K)
	db	34H	; bank 2 (56K)

	endif

	IF bnksiz EQ 48

@compg	db	0c0h

table:	db	20H	;select code for bank 0
	db	10H	; bank 1 (48K)
	db	30H	; bank 2 (48K)

	endif

?move:	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
?xmove:
	ret

	dseg	; this part can be banked

; Verify that we have banked RAM...
?bnkck:
	lxi	h,@intby
	lxi	d,40h
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mov	a,m
	ani	11001011b
	ori	04h
	out	port
	mvi	a,2
	stax	d
	mov	a,m
	ani	11001011b
	ori	24h
	out	port
	mvi	a,3
	stax	d
	mov	a,m
	out	port
	ldax	d
	cpi	1
	jnz	noram
	mov	a,m
	ani	11001011b
	ori	04h
	out	port
	ldax	d
	cpi	2
	jnz	noram
	mov	a,m
	ani	11001011b
	ori	24h
	out	port
	ldax	d
	cpi	3
	jnz	noram
	mvi	a,true
noram:	push	psw
	mov	a,m
	out	port
	pop	psw
	ret

	end
