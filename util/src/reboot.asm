; This program can be used to "return to monitor", a.k.a. reboot.
; Tries to shutdown everything it knows about.
	maclib	z80

CR	equ	13
LF	equ	10

cpm	equ	0
bdos	equ	5

print	equ	9
getver	equ	12
dreset	equ	13
netcfg	equ	69

rb$stub	equ	0F000h	; out of the way of everything...

mmu	equ	0	; H8-512K MMU base port

	org	100h
start:
	mvi	c,getver
	call	bdos
	mov	a,h
	ani	02h
	jrz	nocpn

	; try to shutdown CP/NET and network
	mov	a,l
	cpi	30h
	jrc	cpn12

	; CP/NET 3, remove RSX to shutdown
	call	rsxrm
	jr	nocpn

cpn12:	; CP/NET 1.2 - check for compatible SNIOS
	mvi	c,netcfg
	call	bdos
	push	h
	popix
	; check for at least 6 JMPs...
	ldx	c,-3
	ldx	b,-6
	ldx	e,-9
	ldx	d,-12
	ldx	l,-15
	ldx	h,-18
	mov	a,c
	ana	b
	ana	e
	ana	d
	ana	l
	ana	h
	cpi	0c3h	;JMP?
	jrnz	nocpn
	mov	a,c
	ora	b
	ora	e
	ora	d
	ora	l
	ora	h
	cpi	0c3h	;JMP?
	jrnz	nocpn
	ldx	l,-2
	ldx	h,-1
	call	callhl
nocpn:
	; TODO: anything needed for CP/M?
	; TODO: anything for the hardware?
	lxi	d,rb$msg
	mvi	c,print
	call	bdos
	mvi	c,dreset
	call	bdos
	di
	lxi	h,reboot
	lxi	d,rb$stub
	lxi	b,rebootlen
	ldir
	jmp	rb$stub

callhl:	pchl

rb$msg:	db	'Reboot',CR,LF,'$'

; copied into high memory...
; should be position-independent.
; interrupts must be off - long before calling
reboot:
	xra	a
	out	mmu	; disable MMU "MAP"
	out	0f2h	; ORG0 off, MEM1 off, ...
	out	0f3h	; H89-2mS off
	jmp	0000h
rebootlen equ	$-reboot

rsxrm:	lxi	d,rsxpb
	mvi	c,60
	call	bdos
	ret

ndos3:	db	'NDOS3   '
rsxpb:	db	113
	db	1
	dw	ndos3

	end
