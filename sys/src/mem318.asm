vers equ '2 ' ; Oct 29, 2018  18:14   drm "MEM318.ASM"
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
	extrn @bnkbf,@cbnk,@intby,@dtacb,@dircb,@heapt

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr,@memstr

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	3
@mmerr: db	cr,lf,bell,'No 77318$'
@memstr: db	'77318 ',0,'MMS 128K+48K RAM ',0,'v3.10'
	dw	vers
	db	'$'

; Uses XMOVE semantics
; C=source bank, B=dest bank, HL=address, A=num recs
?mvccp: exaf	;save number of records
	mov	a,c
	call	?bnksl	;select source bank
	push	b
	push	h
	lded	@bnkbf
	lxi	b,128
	ldir
	pop	h
	pop	b
	mov	a,b
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

table:	db	20H	;select code for bank 0 (B)
	db	14H	; bank 1 (56K) (G)
	db	34H	; bank 2 (56K) (H)

	endif

	IF bnksiz EQ 48

@compg	db	0c0h

table:	db	20H	;select code for bank 0 (B)
	db	10H	; bank 1 (48K) (E)
	db	30H	; bank 2 (48K) (F)

	endif

?move:	xchg		; we are passed source in DE and dest in HL
	ldir		; use Z80 block move instruction
	xchg		; need next addresses in same regs
?xmove:
	ret

; Data buffers must be in common memory
dtabf1: ds	1024
dtabf2: ds	1024-1
	db	0	;to force LINK to fill with "00"

	dseg	; this part can be banked

; Verify that we have banked RAM...
?bnkck:
	lxi	h,@intby	; presumed to be bank B
	lxi	d,40h
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mov	a,m
	ani	11001011b
	ori	04h	; bank C (G)
	out	port
	mvi	a,2
	stax	d
	mov	a,m
	ani	11001011b
	ori	24h	; bank D (H)
	out	port
	mvi	a,3
	stax	d
	mov	a,m	; presumed to be bank B
	out	port
	ldax	d
	cpi	1
	jrnz	noram
	mov	a,m
	ani	11001011b
	ori	04h	; bank C (G)
	out	port
	ldax	d
	cpi	2
	jrnz	noram
	mov	a,m
	ani	11001011b
	ori	24h	; bank D (H)
	out	port
	ldax	d
	cpi	3
	jrnz	noram
	; Allocate some buffers below BNKBDOS
	lhld	@heapt
	lxi	d,-1024	; max sector size = 1024
	dad	d
	shld	dirbf1
	dad	d
	shld	dirbf2
	shld	@heapt
	lxi	h,dtacb1
	shld	@dtacb
	lxi	h,dircb1
	shld	@dircb
	lxi	h,@intby ; *MUST* restore this
	mvi	a,true
	jr	bnkck0
noram:	xra	a
bnkck0:	push	psw
	mov	a,m
	out	port
	pop	psw
	ret

dtacb1: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dtabf1
	db 0
	dw dtacb2

dtacb2: db 0ffh ;drive
	db 0,0,0,0,0
	dw 0,0,dtabf2
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
