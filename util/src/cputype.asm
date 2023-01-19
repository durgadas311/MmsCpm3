; determine CPU type and print result

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5

fprint	equ	9

	org	100h
	mvi	a,2
	inr	a
	jpe	intel	; 8080/8085
	; zilog Z80/Z180
	mvi	a,1
	db	0edh,4ch	; MLT B or *NEG
	cpi	0ffh
	lxi	d,mZ80
	jz	gotit
	lxi	d,mZ180
gotit:	mvi	c,fprint
	call	bdos
	lxi	d,crlf
	mvi	c,fprint
	call	bdos
	jmp	cpm

intel:	lxi	h,1
	db	10h	; ARHL or *NOP
	mov	a,h
	ora	l
	lxi	d,m8080
	jnz	gotit
	lxi	d,m8085
	jmp	gotit

m8080:	db	'i8080$'
m8085:	db	'i8085$'
mZ80:	db	'Z80$'
mZ180:	db	'Z180$'
crlf:	db	CR,LF,'$'

	end
