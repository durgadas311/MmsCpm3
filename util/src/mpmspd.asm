; MPMSPD - set/show CPU speed for Norberto's H8 CPU card under MP/M
	maclib	z80

cr	equ	13
lf	equ	10

; "index" numbers for speeds
mhz10	equ	3
mhz8	equ	2
mhz4	equ	1
mhz2	equ	0

cpm	equ	0000h
bdos	equ	0005h
cmd	equ	0080h

print	equ	9
vers	equ	12

setspdv	equ	005dh	; page offset of MP/M setspd JMP vector.

	org	100h

	lxi	sp,stack
	mvi	c,vers
	call	bdos
	mov	a,h
	ani	01h
	jz	notmpm
	lhld	cpm+1	; XIOS landing pad
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg		; HL=XIOSJMP.TBL
	mvi	l,setspdv
	shld	spdjmp
	; TODO: sanity check this?

	; parse commandline
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
	jnz	cmax
	inx	h
	dcr	b
	jz	help
	mov	a,m
	cpi	'0'
	jz	gotit	; allow "10" or "16" (or "MAX")
	cpi	'6'
	jnz	help
gotit:
	dcr	b
	jnz	help
	; C=speed index
	mov	a,c
	jmp	done
cmax:
	cpi	'M'
	jnz	help
	inx	h
	dcr	b
	jz	help
	mov	a,m
	cpi	'A'
	jnz	help
	inx	h
	dcr	b
	jz	help
	mov	a,m
	cpi	'X'
	jnz	help
	jmp	gotit

show:
	mvi	a,0ffh
done:
	call	setspd
	cpi	0ffh
	jz	failed
	cpi	0feh
	jz	notsup
	; TODO: sanity check 0..3?
	; A=speed index
	add	a
	add	a	; *4
	mov	e,a
	mvi	d,0
	lxi	h,spdtbl
	dad	d
	push	h	; text string for speed
	lxi	d,speed
	mvi	c,print
	call	bdos
	pop	d
	mvi	c,print
	call	bdos
	lxi	d,spdnum
exit:
	mvi	c,print
	call	bdos
	jmp	cpm

help:	lxi	d,usage
	jmp	exit

notmpm:	lxi	d,nmpmii
	jmp	exit

notsup:	lxi	d,nsuppt
	jmp	exit

failed:	lxi	d,nchg
	jmp	exit

setspd:	lhld	spdjmp
	pchl

spdjmp:	dw	0

spdtbl:
	db	'2$  '
	db	'4$  '
	db	'8$  '
	db	'MAX$'

usage:	db	'Usage: MPMSPD {s} where s is 2, 4, 8 or MAX (MHz).',cr,lf,'$'
speed:	db	'You are running at $'
spdnum:	db	' MHz.',cr,lf,'$'
nmpmii:	db	'Requires MP/M',cr,lf,'$'
nsuppt:	db	'CPU Speed change not supported',cr,lf,'$'
nchg:	db	'Error changing CPU speed',cr,lf,'$'

	ds	64
stack:	ds	0

	end
