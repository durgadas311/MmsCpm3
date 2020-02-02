; Boot Module for H37
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	46,4	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'C'	; +10: Boot command letter
	db	3	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	10010010b,11100000b,11110001b	; +13: FP display ("H37")
	db	'H37',0	; +16: mnemonic string

init:	ret

boot:
	lxi	h,intz37
	shld	vrst4+1
	dcx	h
	shld	l2037h
	lda	AIO$UNI
	cpi	004h
	rnc
	inr	a
	mvi	l,00001000b
bz37$0:
	dad	h
	dcr	a
	jrnz	bz37$0
	out	079h
	in	0f2h
	ani	00ch
	rnz
	mvi	a,078h
	sta	cport
	mvi	a,0d0h
	out	07ah
	mov	a,l
	ori	00001000b
	mov	d,a
	out	078h
	inr	d
	mvi	e,019h
	mvi	a,5
	call	take$A
	lxi	b,0147bh	; mask, port
bz37$1:
	in	07ah
	xra	b
	ani	002h
	jrz	bz37$1
	djnz	bz37$1
bz37$2:
	lxi	h,bootbf
	mvi	a,001h
	out	079h
	out	07ah
	mov	a,d
	out	078h
	mvi	b,004h
bz37$3:
	xra	a
	out	079h
	mvi	a,040h
	out	07ah
	call	ei$spin
	djnz	bz37$3
	xra	a
	out	079h
	mvi	a,00bh
	out	07ah
	call	ei$spin
	mov	a,d
	xri	004h
	mov	d,a
	ori	002h
	out	078h
	mvi	a,09ch
	out	07ah
	call	hlt$ini
	ani	0efh
	jrnz	bz37$4
	mov	a,h
	cpi	02ch
	jrc	bz37$4
	mvi	a,008h
	out	078h
	pop	h
	jmp	hwboot
bz37$4:
	dcr	e
	jrnz	bz37$2
	ret

intz37:	in	07ah
	xthl
	lhld	l2037h
	xthl
	ei
	ret

ei$spin: ei
	jr	$-1	; wait for intr to break us out

hlt$ini: ei
rd316$0: hlt
	ini
	jmp	rd316$0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
