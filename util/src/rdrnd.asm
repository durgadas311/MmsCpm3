; Program to rand read a file, tracing each BDOS call

cr	equ	13
lf	equ	10

cpm	equ	0
bdos	equ	5
deffcb	equ	5ch
defdma	equ	80h

conoutf	equ	2
openf	equ	15
readf	equ	20
rreadf	equ	33
closef	equ	16

	org	100h

	jmp	start

func:	db	0
retval:	dw	0

start:
	lda	deffcb+1
	cpi	' '
	rz
	lxi	sp,stack

	; dump initial state
	call	dodump

	mvi	a,openf
	call	dofunc
	cpi	255
	jz	cpm
	xra	a
	sta	deffcb+32
	; zero RR
	sta	deffcb+33
	sta	deffcb+34
	sta	deffcb+35

loop:	mvi	a,rreadf
	call	dofunc
	ora	a
	jnz	done
	call	nextrr
	jmp	loop

done:	mvi	a,closef
	call	dofunc

	jmp	cpm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nextrr:	lxi	h,deffcb+33
	inr	m
	rnz
	inx	h
	inr	m
	rnz
	inx	h
	inr	m
	ret

dofunc:
	sta	func
	mov	c,a
	lxi	d,deffcb
	call	bdos
	shld	retval
	; now dump everything
dodump:
	lda	func
	call	hexout
	call	space
	lhld	retval
	call	hexadr
	mvi	a,':'
	call	conout
	lxi	h,deffcb
	call	dump16
	call	space
	mvi	a,'-'
	call	conout
	call	space
	lxi	d,16
	dad	d
	mov	a,m
	call	hexout
	call	crlf
	; same as 'retmon' in BDOS
	lhld	retval
	mov	a,l
	mov	b,h
	ret

dump16:	mvi	e,16
dmp16:	call	space
	mov	a,m
	inx	h
	call	hexout
	dcr	e
	jnz	dmp16
	ret

space:	mvi	a,' '
	jmp	conout

crlf:	mvi	a,cr
	call	conout
	mvi	a,lf
	jmp	conout

hexadr:	mov	a,h
	call	hexout
	mov	a,l
hexout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexnib
	pop	psw
hexnib:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
conout:	push	b
	push	d
	push	h
	mov	e,a
	mvi	c,conoutf
	call	bdos
	pop	h
	pop	d
	pop	b
	ret

	ds	64
stack:	ds	0

	end
