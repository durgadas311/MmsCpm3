vers equ '1 ' ; January 26, 1984  17:01  drm  "MODULES.ASM"

	maclib Z80

; Program to display modules currently installed for CP/M 3 and MP/M-II

cpm	equ	0

conout	equ	2
msgout	equ	9
retver	equ	12

cr	equ	13
lf	equ	10

	org	100h
base:	jmp	start

bdos	equ	base-100H+5

signon: db	cr,lf,'MODULES v3.10'
	dw	vers
	db	'  (c) Magnolia Microsystems',cr,lf,lf,'$'
verr:	db	cr,lf,'Must have MMS CP/M 3 or MP/M$'

vererr: lxi	d,verr
	mvi	c,msgout
	call	bdos
	jmp	xit

thread: dw	0
memstr: dw	0
rtcstr: dw	0

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
	cpi	1	;MP/M ?
	jrnz	st0
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
st0:	mvi	l,67h	;thread
	mov	c,m
	inx	h
	mov	b,m
	sbcd	thread
	mvi	l,84h	;memstr
	mov	c,m
	inx	h
	mov	b,m
	inx	h
	sbcd	memstr
	mov	c,m
	inx	h
	mov	b,m
	sbcd	rtcstr

	lhld	thread
su2:	mov	e,m
	inx	h	; +1
	mov	d,m
	inx	h	; +2
	mov	a,d
	ora	e
	jz	done
	push	d
	lxi	d,13h-2	; chario str is at +13h
	mov	a,m
	cpi	200
	jrnc	su3
	mvi	e,10h-2	; diskio str is at +10h
su3:	dad	d	;point to string address
	mov	e,m
	inx	h
	mov	d,m
	call	strout
	call	crlf
	pop	h
	jmp	su2
done:
	lda	cpm+2	; compare page for sanity
	lhld	memstr
	cmp	h	; should be carry
	jnc	nomem
	xchg
	call	strout
	call	crlf
nomem:
	lda	cpm+2	; compare page for sanity
	lhld	rtcstr
	cmp	h	; should be carry
	jnc	nortc
	xchg
	call	strout
	call	crlf
nortc:

xit:	lspd	savstk
	ret

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

	end
