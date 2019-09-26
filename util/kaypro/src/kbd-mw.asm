;********************************************************
; KEYBOARD map replacer for CP/M plus on the KAYPRO		*
; Copyright (C) 2019 Douglas Miller <durgadas311@gmail.com>	*
;********************************************************
	maclib Z80

false	equ	0
true	equ	not false

cpm	equ	0000h
bdos	equ	0005h

print	equ	9
version	equ	12

dbase	equ	200	;base for all char I/O devices
dev0	equ	001	;first device, rel. to base
ndev	equ	1
 
ctrlA	equ	1
ctrlB	equ	2
ctrlD	equ	4
ctrlE	equ	5
ctrlF	equ	6
ctrlG	equ	7
lf	equ	10
cr	equ	13
ctrlN	equ	14
ctrlO	equ	15
ctrlP	equ	16
ctrlQ	equ	17
ctrlR	equ	18
ctrlS	equ	19
ctrlT	equ	20
ctrlU	equ	21
ctrlV	equ	22
ctrlW	equ	23
ctrlX	equ	24
ctrlY	equ	25
cls	equ	26

; Offsets
thread	equ	063h	; rel. to WBOOT entry
strkey	equ	013h	; rel. to module start
keycnv	equ	03fh	; rel. to module start

	org 0100h
	jmp	start

mapnam:	db	'Magic Wand$'

;primary conversion table for cursor and numberpad keys
;		--0-- --1-- --2-- --3-- --4--
newcnv: db	    0,ctrlP,ctrlU,    0,    0	; B
	db	ctrlV,ctrlW,ctrlY,ctrlQ,    0	; C
	db	ctrlR,ctrlO,ctrlF,ctrlB,    0	; D
	db	    0,ctrlA,ctrlN,ctrlG,ctrlT	; E
	db	    0,ctrlE,ctrlX,ctrlS,ctrlD	; F
cnvlen	equ	$-newcnv
;
;   * 0 . * *	     e = enter
;   1 2 3 e *	     u = up arrow
;   4 5 6 , *	     d = down
;   * 7 8 9 -	     l = left
;   * u d l r	     r = right
;

errmsg:	db	cr,lf,'No keyboard driver found$'
reqmsg:	db	cr,lf,'Requires CP/M 3$'
patmsg:	db	' patched for $'
crlf:	db	cr,lf,'$'

start:
	mvi	c,version
	call	bdos
	mov 	a,l
	cpi	30
	jc	req3
	; TODO: look for Kaypro CP/M 3 by DRM
	lhld	cpm+1
	lxi	d,thread
	dad	d
loop:	mov	e,m
	inx	h
	mov	d,m	; DE = next
	inx	h
	mov	a,m	; dev0
	sui	dbase+dev0
	jz	found
	mov	a,e
	ora	d
	jz	none
	xchg
	jmp	loop

none:	lxi	d,errmsg
err0:	mvi	c,print
	call	bdos
	jmp	cpm
req3:	lxi	d,reqmsg
	jmp	err0

; HL=module+2
found:
	push	h
	lxi	d,crlf
	mvi	c,print
	call	bdos
	pop	d	; DE=module+2
	lxi	h,strkey-2
	dad	d
	push	h	; adr of adr of string
	lxi	h,keycnv-2
	dad	d
	lxi	d,newcnv
	lxi	b,cnvlen
	xchg
	; cross your fingers...
	ldir
	pop	h	; adr of adr of string
	mov	e,m
	inx	h
	mov	d,m	; DE=module ID string
	mvi	c,print
	call	bdos
	lxi	d,patmsg
	mvi	c,print
	call	bdos
	lxi	d,mapnam
	mvi	c,print
	call	bdos
	jmp	cpm

	end
