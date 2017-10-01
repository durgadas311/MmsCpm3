; Program to print TPA space available, in K-bytes

	org	100h
	lxi	d,0
	lhld	6
	mov	a,h
	rrc
	rrc
	ani	03fh
loop1:
	cpi	10
	jc	lt10
	sui	10
	mov	d,a
	mov	a,e
	adi	10h
	daa
	mov	e,a
	mov	a,d
	jmp	loop1
lt10:	add	e
	daa
	push	h
	call	hexout
	pop	h
	mov	a,h
	ani	03h
	mov	h,a
	mvi	a,0
	jz	zero
loop2:
	adi	25h
	daa
	dcr	h
	jnz	loop2
	push	psw
	mvi	e,'.'
	mvi	c,2
	call	5
	pop	psw
	call	hexout
zero:
	lxi	d,kmsg
	mvi	c,9
	call	5
	jmp	0

hexout:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
hexdig: ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	mov	e,a
	mvi	c,2
	jmp	5

kmsg:	db	'K TPA',13,10,'$'

	end
