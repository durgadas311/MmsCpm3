vers equ '2 ' ; January 26, 1984  17:02  drm  "DRIVES.ASM"

	maclib Z80

; Program to display logical/physical drive relationships for CP/M 3
; also to work on MP/M-II on 77500

cpm	equ	0
 
conout	equ	2
msgout	equ	9
retver	equ	12

cr	equ	13
lf	equ	10

	cseg
base:	jmp	start

bdos	equ	base-100h+5

signon: db	cr,lf,'DRIVES v3.10'
	dw	vers
	db	'  (c) Magnolia Microsystems',cr,lf,'$'
str0:	db	': = ($'
verr:	db	cr,lf,'Must have MMS CP/M 3$'

vererr: lxi	d,verr
	mvi	c,msgout
	call	bdos
	jmp	xit

thread: dw	0
lptbl:	dw	0

lpsetup:
	db	0,0,0	;physical drive number, string address for drive A:
	db	0,0,0	; drive B:
	db	0,0,0	; C:
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0
	db	0,0,0	; P:

start:	sspd	savstk
	lxi	sp,stack
	lxi	d,signon
	mvi	c,msgout
	call	bdos
	mvi	c,retver
	call	bdos
	mov	a,l
	sui	30h
	cpi	16
	jnc	vererr
	mov	a,h
	lhld	cpm+1
	cpi	1	;MP/M?
	jrnz	st0
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
st0:	mvi	l,65h	;lptbl
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	mov	c,m	;thread
	inx	h
	mov	b,m
	sbcd	thread
	sded	lptbl

	lhld	lptbl
	lxi	d,lpsetup
	mvi	b,16
su0:	mov	a,m
	stax	d
	inx	h
	inx	d
	inx	d
	inx	d
	djnz	su0

	lhld	thread
su2:	mov	e,m
	inx	h
	mov	d,m
	inx	h
	mov	a,d
	ora	e
	jz	su1
	push	d
	mov	a,m	;first device
	cpi	200
	jnc	su3	;disk I/O only, no character I/O.
	mov	b,a
	inx	h
	mov	c,m	;number of devices
	lxi	d,13	;
	dad	d	;point to string address
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,lpsetup
	xchg
	push	h
	mvi	l,16

su6:	ldax	d	;physical drive number of logical drive.
	inx	d
	sub	b
	cmp	c	;in range?
	jnc	su4	;
	xthl
	xchg
	mov	m,e	;put string address in setup table
	inx	h
	mov	m,d
	inx	h
	xchg
	xthl
su5:	dcr	l
	jnz	su6
	pop	h	;discard
	jmp	su3

su4:	inx	d
	inx	d
	jmp	su5

su3:	pop	h
	jmp	su2

su1:	lxi	h,lpsetup	;now print out list of drives
	mvi	b,16

su9:	mov	a,m
	cpi	255	;drive not available
	jz	nxtone
	call	crlf
	mvi	a,16
	sub	b	;make 0,1,2,3,4... for A,B,C,...
	adi	'A'
	call	chrout
	lxi	d,str0
	call	strout
	mov	a,m	;physical drive number
	call	decout
	mvi	a,')'
	call	chrout
	mvi	a,3+1+1
	sub	c	;
	mov	c,a
	dcr	c
	jz	su7
su8:	mvi	a,' '
	call	chrout
	dcr	c
	jnz	su8
su7:	inx	h
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	mov	a,e
	ora	d
	jrz	su10
	call	strout
su10:	djnz	su9

	call	crlf
xit:	lspd	savstk
	ret

nxtone: inx	h
	inx	h
	inx	h
	jmp	su10

	ds	32
stack:	ds	0

savstk: ds	2

crlf:	mvi	a,cr
	call	chrout
	mvi	a,lf
chrout: push	b
	push	d
	push	h
	mov	e,a
	mvi	c,conout
	call	bdos
	pop	h
	pop	d
	pop	b
	ret

strout: push	b
	push	h
	mvi	c,msgout
	call	bdos
	pop	h
	pop	b
	ret

decout: push	b
	push	h
	lxi	b,0	;for leading zero deletion, output count
	mvi	e,100
	call	divout
	mvi	e,10
	call	divout
	call	dv1	;always display one's digit.
	pop	h
	mov	a,c
	pop	b
	mov	c,a	;number of characters outputed in C
	ret

divout: mvi	d,0
dv0:	inr	d
	sub	e
	jnc	dv0
	add	e
	dcr	d
	mov	l,a	;remainder in L, temp.
	bit	0,b	;leading zero?
	jnz	dv1
	mov	a,d
	ora	a
	jz	dv2
dv1:	setb	0,b
	inr	c
	adi	'0'
	call	chrout
dv2:	mov	a,l
	ret

	end
