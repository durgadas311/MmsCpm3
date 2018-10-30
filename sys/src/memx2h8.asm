vers equ '2 ' ; Oct 29, 2018  18:12   drm "MEMX2H8.ASM"
;****************************************************************
; Banked Memory BIOS module for CP/M 3 (CP/M plus), 		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
	maclib Z80

true	equ -1
false	equ not true

memtest	equ	true

cr	equ 13
lf	equ 10
bell	equ 7

mmu	equ	000h	; Trionyx X/2-H8 Bank Switch Board

;  SCB registers
	extrn @bnkbf,@cbnk,@dtacb,@dircb,@heapt

;  Variables for use by other modules
	public @nbnk,@compg,@mmerr,@memstr

;  Routines for use by other modules
	public ?bnksl,?bnkck,?xmove,?mvccp,?move

	cseg		; GENCPM puts CSEG stuff in common memory

@nbnk:	db	4
@compg:	db	0c0h
@mmerr: db	cr,lf,bell,'No X/2-H8$'
@memstr: db	'X/2-H8 ',0,'Tryonix 256K RAM and MMU ',0,'v3.10'
	dw	vers
	db	'$'

; Uses XMOVE semantics...
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
	add	a
	add	a
	mov	c,a		;
	mvi	b,0		;
	dad	b		;
	mvi	b,4
	mvi	c,mmu
	ldai	; P = EI state (IFF2)
	push	psw
	di
	outir	; trashes P
	pop	psw	; restore IFF2 to P
	pop	h		;
	pop	b		; restore register b
	rpo	; P=0, leave interrupts off
	ei
	ret

table:
	db	0$001$1111b	; Bank 0
	db	0$010$1111b
	db	0$011$1111b
	db	0$000$0000b
	;
	db	0$000$0111b	; Bank 1
	db	0$010$1111b
	db	0$011$1111b
	db	0$001$1000b
	;
	db	0$000$0111b	; Bank 2
	db	0$001$1111b
	db	0$011$1111b
	db	0$010$1000b
	;
	db	0$000$0111b	; Bank 3
	db	0$001$1111b
	db	0$010$1111b
	db	0$011$1000b

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
; This code assumes the Bank Switch Board is set as for "bank 0" in 'table'
?bnkck:
 if memtest
	; setup pattern buffer
	lxi	h,4100h
	mvi	b,136
	mvi	a,10h
bnkck1:
	mov	m,a
	inx	h
	adi	1
	daa
	djnz	bnkck1

	; copy diff pattern to each bank
	lxi	h,4100h
	lxi	d,0100h
	lxi	b,128
	ldir
	mvi	a,0$000$0001b
	out	mmu
	mvi	a,0$001$1110b
	out	mmu
	lxi	h,4101h
	lxi	d,0100h
	lxi	b,128
	ldir
	mvi	a,0$001$1111b
	out	mmu
	mvi	a,0$010$1110b
	out	mmu
	lxi	h,4102h
	lxi	d,0100h
	lxi	b,128
	ldir
	mvi	a,0$010$1111b
	out	mmu
	mvi	a,0$011$1110b
	out	mmu
	lxi	h,4103h
	lxi	d,0100h
	lxi	b,128
	ldir
	; check pattern in each bank
	mvi	a,0$011$1111b
	out	mmu
	mvi	a,0$000$0000b
	out	mmu
	lxi	h,4100h
	call	bnkck9
	jrnz	noram
	mvi	a,0$000$0001b
	out	mmu
	mvi	a,0$001$1110b
	out	mmu
	lxi	h,4101h
	call	bnkck9
	jrnz	noram
	mvi	a,0$001$1111b
	out	mmu
	mvi	a,0$010$1110b
	out	mmu
	lxi	h,4102h
	call	bnkck9
	jrnz	noram
	mvi	a,0$010$1111b
	out	mmu
	mvi	a,0$011$1110b
	out	mmu
	lxi	h,4103h
	call	bnkck9
	jrnz	noram
 else
	lxi	d,40h
	mvi	a,0$000$0001b
	out	mmu
	mvi	a,0$001$1110b
	out	mmu
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$001$1111b
	out	mmu
	mvi	a,0$010$1110b
	out	mmu
	mvi	a,2
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$010$1111b
	out	mmu
	mvi	a,0$011$1110b
	out	mmu
	mvi	a,3
	stax	d	;put bank number in 40h of respective bank
	mvi	a,0$011$1111b
	out	mmu
	mvi	a,0$001$1110b
	out	mmu
	ldax	d
	cpi	1
	jrnz	noram
	mvi	a,0$001$1111b
	out	mmu
	mvi	a,0$010$1110b
	out	mmu
	ldax	d
	cpi	2
	jrnz	noram
	mvi	a,0$010$1111b
	out	mmu
	mvi	a,0$011$1110b
	out	mmu
	ldax	d
	cpi	3
	jrnz	noram
 endif
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
	mvi	a,true
	jr	bnkck0
noram:	xra	a
bnkck0:	push	psw
	xra	a
	call	?bnksl
	pop	psw
	ret
 if memtest
bnkck9:
	push	h	; pattern
	lxi	h,0100h
	lxi	d,4200h
	lxi	b,128
	ldir
	pop	h	; pattern
	lxi	d,4200h
	mvi	b,128
bnkck8:
	ldax	d
	cmp	m
	rnz
	inx	h
	inx	d
	djnz	bnkck8
	ret
 endif

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
