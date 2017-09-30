vers equ '1 ' ; June 28, 1983  10:03  drm  "CHRIO3.ASM"
;********************************************************
;   Character I/O module for MMS CP/M plus		*
; Copyright (C) 1983 Magnolia Microsystems		*
;********************************************************
	maclib Z80

false	equ	0
true	equ	not false
 
int	equ	true	;Console input via interupts?
bufsiz	equ	16	;use only 2,4,8,16,32,64,128,256.
bufmsk	equ	bufsiz-1

RST3	equ	(3)*8

crt	equ	0e8h	;CONSOLE
lp	equ	0e0h	;PRINTER
dte	equ	0d8h	;MODEM
dce	equ	0d0h	;AUX

dev0	equ	200	;first device
ndev	equ	4	;number of devices

	extrn @ctbl

	cseg	;common memory, other parts in banked.
	dw	thread
	db	dev0,ndev

	jmp	init
	jmp	inst
	jmp	input
	jmp	outst
	jmp	output
	dw	string
	dw	chrtbl
	dw	xmodes

string: db	'Z89 ',0,'Standard and interupt I/O ',0,'v3.10'
	dw	vers
	db	'$'

xmodes: db	00110000b,00111111b,00000011b,crt
	db	00110000b,00111111b,10000011b,lp
	db	00110001b,00111111b,10000011b,dte
	db	00110000b,00111111b,10000011b,dce

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

interupt:
	sspd	ustk
	lxi	sp,istk
	push	psw
	push	b
	push	d
	push	h
	in	crt+5
	bit	4,a
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
	in	crt
	ani	01111111b
	stax	d
	pop	psw
	jnz	exit
gobl:	mov	a,m
	dcr	a
	ani	bufmsk
	mov	m,a
exit:	mvi	a,0101b
	out	crt+1
	pop	h
	pop	d
	pop	b
	pop	psw
	lspd	ustk
	ei
	ret

break:	in	crt
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
chrtbl: 	;initial values only, copied by BIOS to its table.
 if int
	db	'ICRT  ',00000111b,14 ;I/O, soft-baud, no protocal, 9600
 else
	db	'CRT   ',00000111b,14 ;I/O, soft-baud, no protocal, 9600
 endif
	db	'LPT   ',00000111b,14 ;... 9600
	db	'DTE   ',00000111b, 6 ;... 300 baud
	db	'DCE   ',00000111b,14 ;... 9600

getx:	mov	a,b	;B=device #, 0-15
	sui	dev0-200
	add	a	;*2
	add	a	;*4
	adi	3	;to point to port address
	mov	e,a
	mvi	d,0
	lxi	h,xmodes
	dad	d
	mov	a,m
	mov	e,a
	adi	5
	mov	c,a
	dcx	h
	ret		;HL => xmode(dev)+2 = line control register image

init:
 if int
	mov	a,b
	cpi	dev0-200
	cz	intcrt
 endif
	call	getx
	mov	c,e
	bit	7,m	;is INIT allowed ??
	rz
	push	h
	mov	a,b
	add	a
	add	a
	add	a	;*8
	mov l,a ! mvi h,0
	lxi d,@ctbl+7 ! dad d ! mov l,m ; get baud rate
	mvi h,0 ! dad h ! lxi d,speed$table ! dad d  ; point to counter entry
	mov e,m ! inx h ! mov d,m	; get and save count
	mov	a,c	;DE=baud rate divisor
	mov	b,a	;port base for INS8250 in question.
	adi	3
	mov	c,a	;+3 = access divisor latch bit
	mvi	a,10000000b
	outp	a	;access divisor latch
	mov	h,c
	mov	c,b	;+0 = lo byte of baud rate divisor
	outp	e
	inr	c
	outp	d	;send divisor to divisor latch
	mov	c,h	;get port+3 back into (C)
	pop	h	;point to BASE+3 initial value
	mov	a,m	;disable divisor latch access.
	ani	01111111b
	outp	a	;and setup # bits, parity, etc...
	inr	c	;+4 = modem control
	dcx	h	;next, handshake lines state
	mov	a,m
	ani	00001111b	;enable handshake lines
	outp	a
	inr	c	;+5 = line status
	inp	a	;clear any pending activity
	mov	a,c
	ani	11111000b	;reset port to base
	mov	c,a
	inp	a	;clear any input data
	inr	c	;+1 = interupt control
	xra	a
	outp	a	;disable chip interupts
	ret

input:
 if int
	mov	a,b
	cpi	dev0-200	;console?
	jz	inpint
 endif
inp0:	call	inst
	jrz	inp0			; wait for character ready
	mov	c,e			;get data register address
	inp	a			; get data
	ani	7Fh			; mask parity
	ret

inst:
 if int
	mov	a,b
	cpi	dev0-200
	jz	stsint
 endif
	call	getx			;
	inp	a			; read from status port
	ani	1			; isolate RxRdy
	rz				; return with zero
	ori	true
	ret

output: mov	a,c
	push	psw			; save character from <C>
outp0:	call	outst
	jrz	outp0			; wait for TxEmpty, HL->port
	mov	c,e			; get port address
	pop	psw
	outp	a			; send data
	ret

outst:	call	getx	; character output status
	dcx	h
	inr	c		; get port+6
	inp	a		; get handshake status
	xra	m 
	dcx	h		;
	ana	m		; [ZR] = ready
	ani	11110000b
	jrnz	nrdy
	dcr	c		; line status register (+5)
	inp	a
	ani	20h		; test xmit holding register empty
	rz			;
	ori	true
	ret			; return true if ready

nrdy:	xra	a
	ret

 if int
intcrt:
	pop	h
	call	icall	;do regular init routine.
	mvi	a,(JMP) ;now do special init.
	sta	RST3
	lxi	h,interupt
	shld	RST3+1
	xra	a
	sta	keypt0
	sta	keypt1
	mvi	a,0101b
	out	crt+1
	ret

icall:	pchl

inpint: call	stsint
	jz	inpint
	lxi	h,keypt1
	call	index
	ldax	d
	ret

stsint: lxi	h,keypt0
	lda	keypt1
	sub	m
	rz
	ori	true
	ret

 endif
speed$table:
	dw	0	;no baud rate
	dw	2304	;50 baud
	dw	1536	;75
	dw	1047	;110
	dw	856	;134.5
	dw	768	;150
	dw	384	;300
	dw	192	;600
	dw	96	;1200
	dw	64	;1800
	dw	48	;2400
	dw	32	;3600
	dw	24	;4800
	dw	16	;7200
	dw	12	;9600
	dw	6	;19200

	end
