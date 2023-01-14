; Boot Module for H37
; TODO: make port variable...

	maclib	ram
	maclib	core
	maclib	setup

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	46,4	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'C'	; +10: Boot command letter
	db	3	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	10010010b,11100000b,11110001b	; +13: FP display ("H37")
	db	'H37',0	; +16: mnemonic string

init:
	lda	susave+h37pt
	cpi	0ffh
	jnz	init0
	in	0f2h
	ani	00001100b	; the only standard setup
	stc
	rnz
	mvi	a,078h
init0:	sta	cport
	xra	a	; NC
	ret

boot:
	lxi	h,intz37
	shld	vrst4+1
	lxi	h,nulz37
	shld	l2037h
	lda	cport
	mov	c,a
	lda	AIO$UNI
	cpi	004h
	rnc
	inr	a
	mvi	l,00001000b
bz37$0:
	dad	h
	dcr	a
	jnz	bz37$0
	inr	c	; cport+1
	call	outp	; cport+1 - A=0
	inr	c	; cport+2
	mvi	a,0d0h	; FORCE INTERRUPT
	call	outp	; cport+2
	mov	a,l
	ori	00001000b	; add MOTOR ON
	mov	d,a
	dcr	c	; cport+1
	dcr	c	; cport+0
	call	outp	; cport+0
	inr	d	; add INTRQ EN for later
	mvi	e,25	; number of retries
	mvi	a,5
	call	take$A
	inr	c	; cport+1
	inr	c	; cport+2
	; see 20 index pulses before continuing...
	mvi	b,20
bz37$1:
	call	inp	; cport+2
	ani	002h	; INDEX
	jz	bz37$1
	dcr b ! jnz	bz37$1
	; diskette must be inserted and spinning...
bz37$2:	; C=cport+2
	dcr	c	; cport+1
	lxi	h,bootbf
	mvi	a,001h
	call	outp	; cport+1 - MUX to track/sector regs
	inr	c	; cport+2
	call	outp	; cport+2 - track = 1?
	dcr	c	; cport+1
	dcr	c	; cport+0
	mov	a,d
	call	outp	; cport+0 - INTRQ EN now
	mvi	b,4	; step in 4 tracks...
	inr	c	; cport+1
	inr	c	; cport+2
bz37$3:
	dcr	c	; cport+1
	xra	a
	call	outp	; cport+1 - MUX to cmd/sts/data regs
	inr	c	; cport+2
	mvi	a,040h	; STEP IN
	call	outp	; cport+2 - start command
	call	ei$spin	; returns C=cport+2
	dcr b ! jnz	bz37$3
	dcr	c	; cport+1
	xra	a
	call	outp	; cport+1 - MUX to cmd/sts/data regs
	inr	c	; cport+2
	mvi	a,00bh	; RESTORE
	call	outp	; cport+2 - start command
	call	ei$spin	; returns C=cport+2
	dcr	c	; cport+1
	dcr	c	; cport+0
	mov	a,d
	xri	004h	; toggle DDEN
	mov	d,a
	ori	002h	; DRQ EN
	call	outp	; cport+0
	inr	c	; cport+1
	inr	c	; cport+2
	mvi	a,09ch	; READ MULTI
	call	outp	; cport+2 - start command
	call	hlt$ini
	; assume C=cport+2 after intz37...
	ani	0efh	; ignore RNF (always set for READ MULTI)
	jnz	bz37$4
	mov	a,h
	cpi	02ch	; 2280h + 10 sectors min
	jc	bz37$4
	dcr	c	; cport+1
	dcr	c	; cport+0
	mvi	a,008h	; MOTOR ON only
	call	outp	; cport+0
	pop	h
	jmp	hwboot
bz37$4:	; error, retry
	dcr	e
	jnz	bz37$2
	ret

inp:	mov	a,c
	sta	inp0+1
inp0:	in	0
	ret

outp:	push	psw
	mov	a,c
	sta	outp0+1
	pop	psw
outp0:	out	0
	ret

; must have C=cport+2... could assume came from rd316$0...
intz37:
	lda	cport
	adi	2	; cport+2
	mov	c,a
	call	inp
	xthl
	lhld	l2037h
	xthl
	ei
nulz37:	ret

ei$spin: ei
	jmp	$-1	; wait for intr to break us out

hlt$ini:	; must have C=cport+3
	lda	cport
	adi	3	; cport+3
	sta	ini0+1
	ei
rd316$0: hlt
ini0:	in	0
	mov	m,a
	inx	h
	jmp	rd316$0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
