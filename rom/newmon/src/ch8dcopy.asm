; Bootstrap for the H8DCopy utility.
; Uses the "LP" Serial Port, 0E0H / 340Q
sport	equ	0e0h
RBR	equ	sport+0
DLL	equ	sport+0
DLH	equ	sport+1
IER	equ	sport+1
LCR	equ	sport+3
MCR	equ	sport+4
LSR	equ	sport+5
BAUD	equ	000ch	; 9600, high byte must be 00.

	maclib	ram
	maclib	core
	maclib	z80

CR	equ	13
LF	equ	10
BEL	equ	7
CTLC	equ	3

bootadr	equ	2300H
bootend	equ	2329H
utilend	equ	265BH

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'h'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'H8D Utility Bootstrap',0	; +16: mnemonic string

init:	; H17 must be installed, or this makes no sense.
	; but we check later, for display purposes.
	xra	a
	ret

error:	lxi	h,errmsg
	call	msgout
	ret

exec:
	lxi	h,signon
	call	msgout
	in	0f2h
	ani	00000011b
	jrnz	error
	; TODO: print message?
	lxi	h,stmsg
	call	msgout
	; would be nice to re-use this from h8core, but it's
	; pretty much carved in stone anyway.
	; H17 initialization:
	di
	xra	a
	out	07fh
	lxi	h,01f5ah	; H17 floppy ROM template
	lxi	d,02048h	; RAM location of data
	lxi	b,88		; length of "R$CONST"
	ldir
	mov	l,e		; next section filled with 0...
	mov	h,d
	inx	d
	mvi	c,30
	mov	m,a
	ldir	; fill l20a0h...
	mvi	a,7
	lxi	h,intvec	; vector area
h17ini0:
	mvi	m,0c3h
	inx	h
	mvi	m,LOW nulint
	inx	h
	mvi	m,HIGH nulint
	inx	h
	dcr	a
	jrnz	h17ini0
	; H17 "front" should be propped-up.
	lxi	h,bootstrap
	lxi	d,bootadr
	lxi	b,bootlen
	ldir
	jmp	bootadr

nulint:	ei
	ret

; wait for Rx data on sport, while checking for user abort
check:	in	0edh
	rrc
	jrnc	chk0
	in	0e8h
	cpi	CTLC
	jrnz	chk0
	pop	h	; discard local return adr
abort:	call	crlf
	ret	; return (safely?) to monitor
chk0:	in	LSR
	rar
	jrnc	check
	ret

signon:	db	' H8D Utility bootstrap',CR,LF,0
stmsg:	db	'Using serial port '
	db	(sport SHR 6)+'0'
	db	((sport SHR 3) AND 7)+'0'
	db	(sport AND 7)+'0'
	db	'Q at 9600 baud',CR,LF
	db	'Start the H8D Utility on host.',CR,LF
	db	'Ctl-C to quit ',0
errmsg:	db	BEL,'No H17 installed (dipswitch set?)',CR,LF,0

; --------- bootstrap code --------
; This code is moved to 2300H and must end with the PCHL at 2329H
; WARNING: The booted code peeks into this code to get the port
; address.
;	org	bootadr
bootstrap:
	xra	a
	out	LCR
	out	IER
	out	MCR
	dcr	a	; want 80H but FF is OK
	out	LCR
	mvi	a,LOW BAUD
	out	DLL
	xra	a
	out	DLH
	mvi	a,00000111b	; 8 bits, 2 stop
	out	LCR
	in	LSR
	in	RBR
	lxi	h,(bs1-bootstrap)+bootadr
	lxi	d,utilend-1
bs1:	in	LSR	; filler
	rar		; filler
	call	check	; WAS: jnc (bs1-bootstrap)+bootadr
	; returns when char available...
	in	RBR
	stax	d
	dcx	d
 if (($-bootstrap)+bootadr <> bootend)
	.error 'bootstrap phase error'
 endif
	pchl
bootlen	equ	$-bootstrap
; ----- end of bootstrap code -----

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
