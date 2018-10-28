; SPDSBC - set/show CPU speed for Norberto's H8 CPU card
	maclib	z80

cr	equ	13
lf	equ	10

spbits	equ	00010100b
mhz10	equ	00010100b
mhz8	equ	00000100b
mhz4	equ	00010000b
mhz2	equ	00000000b

gpp	equ	0f2h

cpm	equ	0000h
bdos	equ	0005h
ctlbyte	equ	000dh
cmd	equ	0080h

print	equ	9
vers	equ	12

ctlflg	equ	100	; offset from BIOS for ctlflg

	org	100h

	lxi	sp,stack
	mvi	c,vers
	call	bdos
	mov	a,l
	cpi	31h
	lxi	d,ctlbyte
	jnz	gotflg
	lhld	cpm+1	; BIOS+3
	lxi	d,ctlflg-3
	dad	d
	xchg
gotflg:
	lxi	h,cmd
	mov	a,m
	ora	a
	jz	show
	mov	b,a
skip:
	inx	h
	mov	a,m
	cpi	' '
	jnz	start
	djnz	skip
	jmp	show
start:
	cpi	'2'
	mvi	c,mhz2
	jz	gotit
	cpi	'4'
	mvi	c,mhz4
	jz	gotit
	cpi	'8'
	mvi	c,mhz8
	jz	gotit
	cpi	'1'
	mvi	c,mhz10
	jnz	help
	inx	h
	dcr	b
	jz	help
	mov	a,m
	cpi	'0'
	jnz	help
gotit:
	dcr	b
	jnz	help
	di
	ldax	d
	ani	not spbits
	ora	c
	stax	d
	;out	gpp
	ei
	; A = ctlflg value
	lxi	d,speed
	jmp	done
show:
	ldax	d
	lxi	d,speed
	jmp	done
help:
	ldax	d
	lxi	d,usage
done:
	ani	spbits
	cpi	mhz10
	lxi	b,'10'
	jz	prtspd
	cpi	mhz8
	lxi	b,' 8'
	jz	prtspd
	cpi	mhz4
	lxi	b,' 4'
	jz	prtspd
; must be 2MHz...
	lxi	b,' 2'
	;jmp	prtspd
prtspd:	mov	a,c
	sta	spdnum
	mov	a,b
	sta	spdnum+1
	mvi	c,print
	call	bdos
	jmp	cpm

usage:	db	'Usage: SPD {s} where s is 2, 4, 8 or 10 MHz.',cr,lf
speed:	db	'You are running at '
spdnum:	db	'xx MHz.',cr,lf,'$'

	ds	64
stack:	ds	0

	end
