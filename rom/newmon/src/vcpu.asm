; Stand-Alone Program to flash the ROM from an image on VDIP1 USB stick
VERN	equ	10h
	maclib	z180

CR	equ	13
LF	equ	10
BS	equ	8
BEL	equ	7
CTLC	equ	3

ticcnt	equ	201bh	; for vdip1.lib
ctl$F0	equ	2009h
ctl$F2	equ	2036h

	cseg
begin:
	lxi	sp,stack
	lxi	d,signon
	call	msgout
	call	cpu$type
	ora	a
	jrz	is$z80
	lxi	d,mz180
	jr	is$comm
is$z80:	lxi	d,mz80
is$comm:
	call	msgout
	call	crlf
done:
	lxi	d,press
	call	msgout
	call	conin
	call	crlf
	di
	xra	a
	out	0f2h
	mvi	a,0dfh	; reset state of FP
	out	0f0h
	jmp	0

cpu$type:
	lxi	b,0505h	; setup MLT B: 5*5=25 (19h)
	mvi	a,1	; setup NEG:   1=-1 (0ffh)
	mlt	b
	call	dump
	cpi	0ffh
	jrz	gz80
	mov	a,c
	ora	b
	cpi	25
	rz	; A is NZ...
cant:	lxi	d,mcant
	call	msgout
	jr	done
gz80:	mov	a,c
	ora	b
	sui	5
	rz
	jr	cant

signon:	db	CR,LF,'VCPU v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
	db	' - CPU type is: ',0
mz180:	db	'Z180',0
mz80:	db	'Z80',0
mcant:	db	' >>>can''t guess CPU type<<<',0
press:	db	'Press any key: ',0

dump:	push	psw
	call	hexout
	mvi	a,' '
	call	conout
	mov	a,b
	call	hexout
	mov	a,c
	call	hexout
	mvi	a,' '
	call	conout
	pop	psw
	ret

conin:	in	0edh
	ani	00000001b
	jrz	conin
	in	0e8h
	ani	01111111b
	ret

crlf:	mvi	a,CR
	call	conout
	mvi	a,LF
	jr	conout

hexout:	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	; jmp	conout
conout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

msgout:	ldax	d
	ora	a
	rz
	call	conout
	inx	d
	jr	msgout

	ds	128
stack:	ds	0
	end
