vers equ '0c' ; December 21, 1985  15:57  drm  "PAR3KP.ASM"
;********************************************************
; Parallel Port Printer module for the KAYPRO		*
; Copyright (C) 1985 Douglas Miller			*
;********************************************************
	maclib Z80

false	equ	0
true	equ	not false

dev0	equ	206
ndev	equ	1

port	equ	018h	;parallel printer port
sysctl	equ	014h	;status/ctrl bits

	extrn @ctbl,@vect

	cseg	;common memory, other parts in banked.
	dw	thread
	db	dev0,ndev

	jmp	init
	jmp	nullst
	jmp	nullin
	jmp	outst
	jmp	output
	dw	strcnt
	dw	tblcnt
	dw	modcnt

strcnt: db	'KAYPRO ',0,'Parallel Printer ',0,'v3.10'
	dw	vers
	db	'$'

modcnt: db	00000000b,00000000b,10000000b,port
 

thread	equ	$

	dseg	;banked memory.
tblcnt: 	;initial value only, copied by BIOS to its table.
	db	'LPT   ',00000010b,0  ;Output, no baud, no protocal

init:
	ret

nullin: mvi	a,1ah
	ret

output:
outp0:	call	outst
	jrz	outp0			; wait for not busy
	mov	a,c
	out	port			; send data
	di
	in	sysctl
	ani	10110111b
	out	sysctl
	ori	00001000b
	out	sysctl
	ei
	ret

outst:
	in	sysctl
	xri	01000000b
	ani	01000000b
	rz
nullst: ori	true
	ret			; return true if ready

	end
