vers equ '0 ' ; Nov 14, 2021  13:47  drm  "CIO8250.ASM"
;********************************************************
;   Character I/O module for MMS MP/M     		*
;   For INS8250 UARTS as in H89           		*
; Copyright (C) 1983 Magnolia Microsystems		*
;********************************************************
	maclib	z80
	maclib	cfgsys

false	equ	0
true	equ	not false

crt	equ	0e8h	;CONSOLE
lp	equ	0e0h	;PRINTER
dte	equ	0d8h	;MODEM
dce	equ	0d0h	;AUX

dev0	equ	200	;first device
ndev	set	4	;max number of devices
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

string: db	'Z89 ',0,'Char I/O ',0,'v3.00'
	dw	vers
	db	'$'

; INS8250:      xxxx      yyyy MCR  z    LCR
xmodes: db	00110000b,00111111b,00000011b,crt	; (already init)
	db	00110000b,00111111b,10000011b,lp
	db	00110000b,00111111b,10000011b,dce	; ("aux")
	db	00110001b,00111111b,10000011b,dte	; ("modem")
; if (((MSR ^ yyyy) & xxxx) == 0) then ready for output

chrtbl: 	; CP/M 3 char I/O table
	db	'CRT   ',00000111b,14 ;I/O, soft-baud, no protocal, 9600
	db	'LPT   ',00000111b,14 ;... 9600
	db	'DCE   ',00000111b,14 ;... 9600 ("aux")
	db	'DTE   ',00000111b,14 ;... 9600 baud ("modem")

; It appears MP/M requires all of this in common memory
; B=device number, relative to 200.
input:
	call	getx
inp0:	call	inst0
	jrz	inp0			; wait for character ready
	mov	c,e			;get data register address
	inp	a			; get data
	ani	7Fh			; mask parity
	ret

; B=device number, relative to 200.
inst:
	call	getx			;
inst0:	inp	a			; read from status port
	ani	1			; isolate RxRdy
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
	mov	c,e			; get THR port address
	pop	psw
	outp	a			; send data
	ret

; On entry, B=device number, relative to 200.
outst:	call	getx	; character output status
	; must preserve BC,DE (getx results) in all exit paths
outst0:	inr	c		; get port+6
	inp	a		; get handshake status
	dcr	c		; line status register (+5)
	xra	d
	ana	b		; [ZR] = ready
	ani	11110000b
	jrnz	nrdy
	inp	a
	ani	20h		; test xmit holding register empty
	rz			;
	ori	true
	ret			; return true if ready

nrdy:	xra	a
	ret

; B=device number, relative to 200.
; Returns: C=LSR, E=RBR/THR, D=XOR-mask, B=AND-mask (MSR)
getx:	mov	a,b	;B=device #, 0-15
	sui	dev0-200
	add	a	;*2
	add	a	;*4
	adi	3	;to point to port address
	mov	e,a
	mvi	d,0
	lxi	h,xmodes
	dad	d
	mov	a,m	; port base
	mov	e,a
	adi	5
	mov	c,a
	dcx	h	; LCR (only used for init)
	dcx	h	; MCR-XOR
	mov	d,m	; XOR bits
	dcx	h	; MCR-AND
	mov	b,m	; AND bits
	ret		;HL => xmode(dev)+0

thread	equ	$

	cseg	;banked memory.

; B=device number, relative to 200.
init:
	push	b
	call	getx
	pop	b
	mov	c,e	; port base
	inx	h
	inx	h	; back to LCR for init
	bit	7,m	;is INIT allowed ??
	rz
	push	h
	mov	a,b
	add	a
	add	a
	add	a	;*8
	mov l,a ! mvi h,0
	lxi d,chrtbl+7 ! dad d ! mov l,m ; get baud rate
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

; INS8250 BAUD based on 1.8432MHz crystal
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
