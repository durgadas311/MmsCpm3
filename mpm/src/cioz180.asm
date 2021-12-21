;********************************************************
;   Character I/O module for MMS MP/M     		*
;   For Z180 ASC Ports                    		*
; Copyright (C) 1983 Magnolia Microsystems		*
;********************************************************
	maclib	z180
	maclib	cfgsys

false	equ	0
true	equ	not false

ctl0a	equ	iobase+00h
ctl0b	equ	iobase+02h
stat0	equ	iobase+04h
tdr0	equ	iobase+06h
rdr0	equ	iobase+08h
asxt0	equ	iobase+12h
ast0l	equ	iobase+1ah
ast0h	equ	iobase+1bh

ctl1a	equ	iobase+01h
ctl1b	equ	iobase+03h
stat1	equ	iobase+05h
tdr1	equ	iobase+07h
rdr1	equ	iobase+09h
asxt1	equ	iobase+13h
ast1l	equ	iobase+1ch
ast1h	equ	iobase+1dh

dev0	equ	200	;first device
ndev	set	2	;max number of devices
 if numser LT ndev
ndev	set	numser
 endif

	dseg	;common memory, other parts in banked.
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

string: db	'Z180 ',0,'ASCI Char I/O ',0,'v3.00'
	dw	vers
	db	'$'

; INS8250:      xxxx      yyyy MCR  z    LCR
xmodes: db	00110000b,00111111b,00000011b,ctl0a	; (already init)
	db	00110000b,00111111b,10000011b,ctl1a
; if (((MSR ^ yyyy) & xxxx) == 0) then ready for output

chrtbl: 	; CP/M 3 char I/O table
	db	'CRT   ',00000111b,14 ;I/O, soft-baud, no protocal, 9600
	db	'LPT   ',00000111b,14 ;... 9600

; It appears MP/M requires all of this in common memory
; B=device number, relative to 200.
input:
	call	getx
inp0:	call	inst0
	jrz	inp0			; wait for character ready
	mov	c,d			;get data register address
	inp	a			; get data
	ani	7Fh			; mask parity
	ret

; B=device number, relative to 200.
inst:
	call	getx			;
inst0:	inp	a			; read from status port
	ani	10000000b		; isolate RxRdy
	rz				; return with zero
	ori	true
	ret

; B=device number, relative to 200.
; C=char
output: mov	a,c
	push	psw			; save character from <C>
	call	getx
outp0:	call	outst0
	jrz	outp0			; wait for TxEmpty, HL->port
	mov	c,e			; get port address
	pop	psw
	outp	a			; send data
	ret

; B=device number, relative to 200.
outst:	call	getx	; character output status
outst0:	dcx	h
	; TODO: implement /CTS check (ASCI0 only)
	inp	a
	ani	02h		; test xmit holding register empty
	rz			;
	ori	true
	ret			; return true if ready

nrdy:	xra	a
	ret

; B=device number, relative to 200.
; Returns C=stat reg, E=TxD reg, D=RxD reg
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
	adi	stat0-ctl0a	; stat reg num
	mov	c,a
	adi	tdr0-stat0	; TxD
	mov	e,a
	adi	rdr0-tdr0	; RxD
	mov	d,a
	dcx	h
	mvi	b,0	; for Z180 internal I/O
	ret		;HL => xmode(dev)+2 = line control register image

thread	equ	$

	cseg	;banked memory.

; B=device number, relative to 200.
init:
	call	getx
	mov	c,e
	bit	7,m	;is INIT allowed ??
	rz
	; TODO: initialize as required
	ret

; TODO: Z180 ASCI speed table...
; Also, support 115200?
speed$table:
	dw	0	;no baud rate
	dw	0	;50 baud
	dw	0	;75
	dw	0	;110
	dw	0	;134.5
	dw	0	;150
	dw	0	;300
	dw	0	;600
	dw	0	;1200
	dw	0	;1800
	dw	0	;2400
	dw	0	;3600
	dw	0	;4800
	dw	0	;7200
	dw	0	;9600
	dw	0	;19200

	end
