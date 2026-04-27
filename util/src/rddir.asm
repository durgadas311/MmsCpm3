; Program to read (matching) directory entries, tracing each BDOS call

cr	equ	13
lf	equ	10

cpm	equ	0
bdos	equ	5
deffcb	equ	5ch
defdma	equ	80h

conoutf	equ	2
openf	equ	15
readf	equ	20
closef	equ	16
firstf	equ	17
nextf	equ	18

	org	100h

	jmp	start

func:	db	0
retval:	dw	0

start:
	lda	deffcb+1
	cpi	' '
	rz
	lxi	sp,stack
	mvi	a,'?'
	sta	deffcb+12	; EX='?' for all
	lda	deffcb+16+1	; option?
	cpi	'?'
	jnz	noglob
	sta	deffcb+0
noglob:

	; dump initial state
	lxi	h,deffcb
	call	dodump

	mvi	a,firstf
loop:
	call	dofunc
	cpi	255
	jz	cpm
	mvi	a,nextf
	jmp	loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dofunc:
	sta	func
	mov	c,a
	lxi	d,deffcb
	call	bdos
	shld	retval
	ani	3
	rlc
	rlc
	rlc
	rlc
	rlc
	mov	e,a
	mvi	d,0
	lxi	h,defdma
	dad	d
	; now dump everything
dodump:	; HL = "FCB" to dump
	push	h
	lda	func
	call	hexout
	call	space
	lhld	retval
	call	hexadr
	mvi	a,':'
	call	conout
	pop	h
	call	dump16
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
