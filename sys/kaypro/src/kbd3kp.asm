vers equ '0e' ; December 23, 1985  21:40  drm  "KBD3KP.ASM"
;********************************************************
; KEYBOARD module for CP/M plus on the KAYPRO		*
; Copyright (C) 1985 Douglas Miller			*
;********************************************************
	maclib Z80

false	equ	0
true	equ	not false

dbase	equ	200	;base for all char I/O devices
dev0	equ	001	;first device, rel. to base
ndev	equ	1
 
int	equ	false	;Keyboard input via interupts?
bufsiz	equ	16	;use only 2,4,8,16,32,64,128,256.
bufmsk	equ	bufsiz-1

sio1	equ	004h	;z80-sio/0

keyb	equ	sio1+1	;CONSOLE keyboard

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

	extrn sio1vec

	cseg	;common memory, other parts in banked.
	dw	thread
	db	dbase+dev0,ndev

	jmp	intkey
	jmp	instkey
	jmp	inputkey
	jmp	outstkey
	jmp	outputkey
	dw	strkey
	dw	tblkey
	dw	modkey

strkey: db	'KAYPRO ',0,'Keyboard handler ',0,'v3.10'
	dw	vers
	db	'$'

modkey: db	00000000b,10000010b,00110100b,keyb

;primary conversion table for cursor and numberpad keys
;		--0-- --1-- --2-- --3-- --4--
keycnv: db	    0,ctrlP,ctrlU,    0,    0	; B
	db	ctrlV,ctrlW,ctrlY,ctrlQ,    0	; C
	db	ctrlR,ctrlO,ctrlF,ctrlB,    0	; D
	db	    0,ctrlA,ctrlN,ctrlG,ctrlT	; E
	db	    0,ctrlE,ctrlX,ctrlS,ctrlD	; F
;
;   * 0 . * *	     e = enter
;   1 2 3 e *	     u = up arrow
;   4 5 6 , *	     d = down
;   * 7 8 9 -	     l = left
;   * u d l r	     r = right
;

 if int
index:	lxi	d,keybd
	mov	a,e
	add	m
	mov	e,a
	push	psw
	mov	a,m
	inr	a
	ani	bufmsk
	mov	m,a
	pop	psw
	rnc
	inr	d
	ret

spclRx: sspd	ustk
	lxi	sp,istk
	push	psw
	mvi	a,00110000b	;error reset
	out	keyb+2
	pop	psw
	lspd	ustk
	ei
	reti

interupt:
	sspd	ustk
	lxi	sp,istk
	push	psw
	push	b
	push	d
	push	h
	xra	a
	out	keyb+2
	in	keyb+2
	bit	7,a
	jnz	break
	rrc
	jnc	exit
	lxi	h,keypt0
	lda	keypt1
	dcr	a
	ani	bufmsk
	cmp	m
	push	psw
	call	index
	in	keyb
	ani	01111111b
	stax	d
	pop	psw
	jnz	exit
gobl:	mov	a,m
	dcr	a
	ani	bufmsk
	mov	m,a
exit:	pop	h
	pop	d
	pop	b
	pop	psw
	lspd	ustk
	ei
	reti

break:	mvi	a,00010000b	;reset ext/status (& break)
	out	keyb+2
	in	keyb
	xra	a
	sta	keybd
	sta	keypt1
	inr	a
	sta	keypt0
	jmp	exit

ustk:	dw	0
	dw	0,0,0,0,0,0,0,0
istk:	ds	0

keypt0: db	0
keypt1: db	0
keybd:	ds	bufsiz
 endif

thread	equ	$

	dseg	;banked memory.
tblkey: 	;initial values only, copied by BIOS to its table.
 if int
	db	'IKEYBD',00001011b,6  ;I/O, hard-baud, no protocal, 300
 else				      ;serial
	db	'KEYBD ',00001011b,6  ;I/O, hard-baud, no protocal, 300
 endif				      ;serial

intkey:
 if int
	call	is1
	lxi	h,interupt
	shld	sio1vec+4
	lxi	h,spclRx
	shld	sio1vec+6
	xra	a
	sta	keypt0
	sta	keypt1
	mvi	a,1
	out	keyb+2
	mvi	a,00011100b	;int on receive character, sts eff vect.
	out	keyb+2
	ret
 endif
is1:	lxi	h,modkey+2
	bit	7,m
	rnz
	mov	a,m
	ani	00110000b	; --bb---- bits per char
	rlc			; -bb-----
	mov	e,a	; Tx image
	setb	3,e		; Tx Enable
	rlc			; bb------
	ori	00000001b	; Rx Enable
	mov	d,a	; Rx image
	mov	a,m
	ani	00001111b
	ori	01000000b	; 16x clock
	mov	b,a	; WR4 image
	dcx	h
	mov	a,m		;
	ani	10000010b	; DTR, RTS
	ora	e
	mov	e,a		; Tx control, with RTS/DTR
	inx	h
	inx	h
	mov	c,m
	inr	c
	inr	c
	mvi	a,4
	outp	a
	outp	b	; WR4
	inr	a
	outp	a
	outp	e	; WR5
	mvi	a,3
	outp	a
	outp	d	; WR3
	ret

inputkey:
inp1:	call	instkey
	jz	inp1
 if int
	lxi	h,keypt1
	call	index
	ldax	d
 else
	in	keyb			; get data
 endif
	ora	a
	rp
	sui	0B0H
	lxi	h,keycnv    ; first loc. is not used
	mov	m,a
	xra	a
	rrd
	mov	c,m
	add	c
	add	c
	add	c
	add	c
	add	c
	mov	c,a
	mvi	b,0
	dad	b
	mov	a,m
	ret

instkey:
 if int
	lxi	h,keypt0
	lda	keypt1
	sub	m
 else
	xra	a
	out	keyb+2
	in	keyb+2			; read from status port
	ani	1			; isolate RxRdy
 endif
	rz				; return with zero
	ori	true
	ret

outputkey:
outp0:	call	outstkey
	jrz	outp0			; wait for TxEmpty, HL->port
	mov	a,c
	out	keyb			; send data
	ret

outstkey:
	mvi	a,00010000b	;reset ext/status change
	out	keyb+2
	in	keyb+2
	ani	00000100b	; test xmit holding register empty
	rz			;
	ori	true
	ret			; return true if ready

	end
