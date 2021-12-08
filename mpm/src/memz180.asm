vers equ '0 ' ; Nov 14, 2021  08:06   drm "MEMZ180.ASM"
;****************************************************************
; Banked Memory BIOS module for MP/M              		*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
; For Z180 MMU and at least 512K RAM at 00000

	maclib z180

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

	extrn	@cbnk

;  Variables for use by other modules
	public	@nbnk,@compg,@mmerr,@memstr

;  Routines for use by other modules
	public ?memsl,?bnksl,?bnkck,?xmove,?move

	dseg		; GENSYS results in DSEG in common memory

@nbnk:	db	4	; not total, just for MP/M
@compg:	db	0c0h	; must match GENSYS value?
@mmerr: db	cr,lf,bell,'No Z180$'
@memstr: db	'MMUZ180 ',0,'Z180 Native MMU ',0,'v3.00'
	dw	vers
	db	'$'

; Translate bank # into Z180 MMU values
; BC = MP/M memory descriptor:
;	{ base, size, attr, num }
; TODO: how much detail to use...
?memsl:	; MP/M entry - BC=memsegtbl[x]
	inx	b
	inx	b
	inx	b
	ldax	b
?bnksl:	; BIOS/XIOS entry - A=bank#
	sta	@cbnk	; remember current bank
	; assume banks 0..n are 64K regions, excluding common.
	; convert to 4k-page number, 00000-7ffff = RAM
	add	a
	add	a
	add	a
	add	a	; 4K-page number, 00,10,20,...70
	out0	a,mmu$bbr
	ret

; B=dest bank, C=source bank
; DE=source address, HL=dest address
; Bank # directly translates to A16-A19
; TODO: do interrupts need to be disabled?
?xmove:
	lda	@compg
	cmp	h
	jrz	xm0
	jrnc	xm1
xm0:	mvi	b,0
xm1:	out0	b,dar0b
	cmp	d
	jrz	xm2
	jrnc	xm3
xm2:	mvi	c,0
xm3:	out0	c,sar0b
	ret

; DE=source address, HL=dest address, BC=length
; TODO: do interrupts need to be disabled?
; Not efficient for small moves.
?move:
xxmove:
	out0	e,sar0l
	out0	d,sar0h
	out0	l,dar0l
	out0	h,dar0h
	out0	c,bcr0l
	out0	b,bcr0h
	mvi	a,00000010b	; mem2mem, burst mode
	out0	a,dmode
	mvi	a,01100000b	; DE0,/DWE0 - start ch 0
	out0	a,dstat		; DMA runs now...
xxmv0:	in0	a,dstat		; should be done before we get here...
	ani	01000000b
	jrnz	xxmv0
	; Must return registers as if moved by CPU...?
	dad	b
	xchg
	dad	b
	xchg
	lxi	b,0
	ret

	cseg	; this part can be banked

noram:	xra	a	; disable banked memory
	out0	a,mmu$bbr
	ret		; A=0 no banked memory

; Verify MMU, and initialize it.
; A=compag from MP/M GENSYS
?bnkck:
	sta	@compg		; must be XXXX0000b
	ani	00001111b
	jrnz	noram
	; init MMU - this must not disturb current memory
	xra	a		;
	out0	a,mmu$cbr	; just to be sure...
	out0	a,mmu$bbr	; ...
	; special com/bnk for test...
	mvi	a,0010$0000b	; compag 2000, bnk base 0000
	out0	a,mmu$cbar
	;
	lxi	d,0040h	; a likely addr in low 16K
	mvi	a,10h	; bank 1 map code
	out0	a,mmu$bbr
	mvi	a,1
	stax	d	;put bank number in 40h of respective bank
	mvi	a,20h	; bank 2 map code
	out0	a,mmu$bbr
	mvi	a,2
	stax	d	;put bank number in 40h of respective bank
	mvi	a,30h	; bank 3 map code
	out0	a,mmu$bbr
	mvi	a,3
	stax	d	;put bank number in 40h of respective bank
	mvi	a,10h	; bank 1 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	1
	jnz	noram
	mvi	a,20h	; bank 2 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	2
	jnz	noram
	mvi	a,30h	; bank 3 map code
	out0	a,mmu$bbr
	ldax	d
	cpi	3
	jnz	noram
	xra	a		; restore "bank 0"
	out0	a,mmu$bbr	; ...
	; the real com/bnk setup
	lda	@compg	; must be XXXX0000b
	ani	11110000b	;must already be on 4K boundary to work!
	out0	a,mmu$cbar	;should be bank base 0000, combas X000
	xra	a	; redundant?
	call	?bnksl	;
	mvi	a,true
	ret		; A<>0 banked memory available

	end
