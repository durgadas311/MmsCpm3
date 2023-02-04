; determine CPU type and print result
; standalone version
	maclib core

CR	equ	13
LF	equ	10

	cseg
	mvi	a,2
	inr	a
	jpe	intel	; 8080/8085
	; zilog Z80/Z180
	mvi	a,1
	db	0edh,4ch	; MLT B or *NEG
	cpi	0ffh
	lxi	h,mZ80
	jz	gotit
	lxi	h,mZ180
gotit:	push	h
	lxi	h,signon
	call	msgout
	pop	h
	call	msgout
	call	crlf
	lhld	retmon
	pchl

intel:	lxi	h,1
	db	10h	; ARHL or *NOP
	mov	a,h
	ora	l
	lxi	h,m8080
	jnz	gotit
	lxi	h,m8085
	jmp	gotit

signon:	db	'CPU is ',0
m8080:	db	'i8080',0
m8085:	db	'i8085',0
mZ80:	db	'Z80',0
mZ180:	db	'Z180',0

	end
