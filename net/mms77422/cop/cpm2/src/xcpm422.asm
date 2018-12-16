VERS equ '0a' ; January 17, 1983  12:47  drm  "NETSTAT.ASM"

	maclib	Z80

;*****************************************************
;**** Program to exit from CP/M-422		 *****
;****  Copyright (C) 1983 Magnolia microsystems  *****
;*****************************************************

false	equ	0
true	equ	not false

cpm	equ	0
bdos	equ	5

cr	equ	13
lf	equ	10
bell	equ	7

conout	equ	2
msgout	equ	9
retver	equ	12

	org	100h

	jmp	start

	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack:	ds	0

signon: db	cr,lf,'XCPM422 v2.24'
	dw	VERS
	db	' (c) 1983 Magnolia Microsystems$'

swerr:	db	cr,lf,bell,'Must be running CP/M-422$'


start:	lxi	sp,stack
	lxi	d,signon
	mvi	c,msgout
	call	bdos
	lxi	d,swerr
	lhld	bdos+1
	mov	a,l
	ora	a
	jz	errxit
	inx	h
	mov	a,m	;get entry routine address lo-byte
	cpi	11H	;if dri's BDOS is running, it will be "11"
	jnz	re0
errxit: mvi	c,msgout
	call	bdos
	jmp	cpm
re0:
	lhld	cpm+1
	inx	h
	mov	e,m	;
	inx	h	;
	mov	d,m	;address of CP/M-422 warm-boot intercept
	push	d
	popix
	ldx	c,-1	; porta
	inr	c
	inr	c
	outp	a	;cause NMI (soft RESET) in 77422
	inr	c
	outp	a	;cause pending INT in 77422
	dcr	c
	dcr	c
re1:	inp	a	;wait for INT to be acknowledged
	ani	0001b
	jnz	re1
	ldx	d,-2	;
	ldx	e,-3	;old BIOS warm boot routine address
	mov	m,d
	dcx	h
	mov	m,e
;
; anything else?
;
	di
	jmp	cpm

	end

