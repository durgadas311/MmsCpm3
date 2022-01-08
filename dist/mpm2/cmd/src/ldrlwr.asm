$title	('MP/M II V2.0  Load, Relocate, and Write File')
	name	ldrlwr
;
;/*
;  Copyright (C) 1979,1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

	cseg

	extrn	mon1	;BDOS entry point
	extrn	FCBin	;FCB for input
	extrn	FCBout	;FCB for output
	extrn	sctbfr	;sector buffer
	extrn	offset	;relocation offset
	extrn	prgsiz	;program size
	extrn	bufsiz	;buffer size
;
;	Procedure to Load, Relocate, and Write an SPR or RSP
;
LdRl:
	public	LdRl
	;compute number of sectors to be read
	lhld	prgsiz
	lxi	d,007fh
	dad	d
	mov	a,l
	ral		;carry = high order bit
	mov	a,h
	ral		;A = # sectors
	sta	wrcnt
	lxi	h,sctbfr
rdloop:
	sta	rdcnt
	shld	DMA
	xchg
	mvi	c,26
	call	mon1	;set DMA address for next sector
	call	read	;read next sector
	lhld	DMA
	lxi	d,0080h
	dad	d
	lda	rdcnt
	dcr	a
	jnz	rdloop

	lxi	h,bitmap
	xchg
	mvi	c,26
	call	mon1	;set DMA address to bit map
;
	;file loaded, ready for relocation
	lhld	prgsiz
	mov	b,h
	mov	c,l	;BC = program size
	xchg
	lxi	h,sctbfr
	xchg		;DE = base of program
	dad	d	;HL = bit map base
	push	h	;save bit map base in stack
	lda	DMA
	adi	128
	sta	btmptp
	lda	offset
	mov	h,a	;H = relocation offset
pgrel0:
	mov	a,b	;bc=0?
	ora	c
	jz	ExitLdRl
;
;	not end of the relocation,
;	  may be into next byte of bit map
	dcx	b	;count length down
	mov	a,e
	sui	low(sctbfr)
	ani	111b	;0 causes fetch of next byte
	jnz	pgrel3
;	fetch bit map from stacked address
	xthl
	lda	btmptp
	cmp	l
	jnz	pgrel2
	mvi	a,low(bitmap+128)
	sta	btmptp
	push	b
	push	d
	lxi	d,FCBin
	mvi	c,20
	call	mon1
	pop	d
	pop	b
	lxi	h,bitmap
	ora	a
	jnz	errtn	;return with error condition
pgrel2:
	mov	a,m	;next 8 bits of map
	inx	h
	xthl		;base address goes back to stack
	mov	l,a	;l holds map as 8 bytes done
pgrel3:
	mov	a,l
	ral		;cy set to 1 if reloc necessary
	mov	l,a	;back to l for next time around
	jnc	pgrel4	;skip relocation if cy=0
;
;	current address requires relocation
	ldax	d
	add	h	;apply bias in h
	stax	d
pgrel4:
	inx	d	;to next address
	jmp	pgrel0	;for another byte to relocate
;
;	Write out relocated data (top to bottom)
;
ExitLdRl:
	pop	h
	lxi	h,0
	mov	a,h
	ret

;
FxWr:
	public	FxWr
;prefill buffer with zeros for filler record
	lhld    DMA
	lxi	b,128
	dad	b
	xra	a
filloop:
	mov	m,a
	inx	h
	dcr	c
	jnz	filloop
	lhld	bufsiz
	mov	a,l
	ora	h
	jz	nobuf
	lxi	d,255
	dad	d
	mov	a,h
	add	a
	push	psw
	lhld	DMA
	lxi	b,128
	dad	b
	xchg
	mvi	c,26
	call	mon1	;set DMA address for next sector
	pop	psw
bufwr:
	push	psw
	call	write	;write next sector
	pop	psw
	dcr	a
	jnz	bufwr
nobuf:
	lxi	b,0
	lxi	h,wrcnt
	mov	a,m
	ani	1
	jz	evenrecord
	inr	m	;force even # of records
	mvi	c,128
evenrecord:
	lhld	DMA
	dad	b
Wrloop:
	shld	DMA
	xchg
	mvi	c,26
	call	mon1	;set DMA address for next sector
	call	write	;write next sector
	lhld	DMA
	lxi	d,-0080h
	dad	d
	lda	wrcnt
	dcr	a
	sta	wrcnt
	jnz	Wrloop
;
;	Load, Relocation, and Write finished
;
	ret


;
;	Local Procedures
;
write:
	lxi	h,FCBout
	xchg
	mvi	c,21	;write sequential
	call	mon1
	ora	a
	jnz	errtn
	ret

read:
	lxi	h,FCBin
	xchg
	mvi	c,20	;read sequential
	call	mon1
	ora	a
	rz
errtn:
	pop	h	;discard return address
	lxi	h,0ffffh
	mov	a,h
	ret		;return with error condition
;
;	Local Data Segment
;
rdcnt:	ds	2	;read counter
wrcnt:	ds	2	;write counter
DMA:	ds	2	;DMA address
bitmap:	ds	128	;bit map buffer
btmptp:	ds	1	;bit low (bitmap+128)

	end
