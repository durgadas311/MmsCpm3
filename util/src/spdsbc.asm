; SPDSBC - set/show CPU speed for Norberto's H8 CPU card
	maclib	z80

cr	equ	13
lf	equ	10

spbits	equ	00010100b
mhz10	equ	00010100b
mhz8	equ	00000100b
mhz4	equ	00010000b
mhz2	equ	00000000b

; "index" numbers for speeds
xmhz10	equ	3
xmhz8	equ	2
xmhz4	equ	1
xmhz2	equ	0

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
	mvi	c,xmhz2
	jz	gotit
	cpi	'4'
	mvi	c,xmhz4
	jz	gotit
	cpi	'8'
	mvi	c,xmhz8
	jz	gotit
	cpi	'M'
	jnz	help
	mvi	c,xmhz10
	inx	h
	dcr	b
	jz	gotit0
	mov	a,m
	cpi	'A'
	jnz	help
	inx	h
	dcr	b
	jz	help
	mov	a,m
	cpi	'X'
	jnz	help
gotit:
	dcr	b
	jnz	help
gotit0:	; C=speed index
	lxi	h,spdval
	mvi	b,0
	dad	b
	mov	c,m
	; C = speed bits for port
	di
	ldax	d
	ani	not spbits
	ora	c
	stax	d
	;out	gpp	; just wait for next intr
	ei
	; A = port value
	lxi	d,speed
	jmp	done
show:
	ldax	d
	lxi	d,speed
	jmp	done
help:
	ldax	d
	lxi	d,usage
done:	; A = port value, DE = message
	push	psw
	mvi	c,print
	call	bdos
	pop	psw
	; convert speed bits into index...
	ani	spbits
	cpi	mhz10
	mvi	c,xmhz10
	jz	prtspd
	cpi	mhz8
	mvi	c,xmhz8
	jz	prtspd
	cpi	mhz4
	mvi	c,xmhz4
	jz	prtspd
; must be 2MHz...
	mvi	c,xmhz2
	;jmp	prtspd
prtspd:
	mov	l,c
	mvi	h,0
	dad	h
	dad	h	; *4
	lxi	b,spdtbl
	dad	b
	xchg
	mvi	c,print
	call	bdos
	lxi	d,spdnum
	mvi	c,print
	call	bdos
	jmp	cpm

spdval:
	db	mhz2	; xmhz2
	db	mhz4	; xmhz4
	db	mhz8	; xmhz8
	db	mhz10	; xmhz10 i.e. MAX

spdtbl:
	db	'2$  '	; xmhz2
	db	'4$  '	; xmhz4
	db	'8$  '	; xmhz8
	db	'MAX$';	; xmhz10

usage:	db	'Usage: SPDSBC {s} where s is 2, 4, 8 or M[AX] (MHz).',cr,lf
speed:	db	'You are running at $'
spdnum:	db	' MHz.',cr,lf,'$'

	ds	64
stack:	ds	0

	end
