;	title	'BIOS for CP/NOS 1.2'
;	Character-only functions
;	Modified for H89/H8, Douglas Miller <durgadas311@gmail.com>
;
;	Version 1.1 October, 1981
;	Version 1.2 Beta Test, 08-23-82
;
vers	equ	12	;version 1.2
;
;	Copyright (c) 1980, 1981, 1982
;	Digital Research
;	Box 579, Pacific Grove
;	California, 93950
;
;	perform following functions
;	boot	cold start
;	wboot	(not used under CP/NOS)
;	const	console status
;		reg-a = 00 if no character ready
;		reg-a = ff if character ready
;	conin	console character in (result in reg-a)
;	conout	console character out (char in reg-c)
;	list	list out (char in reg-c)
;

; Note new cold-boot sequence.
;	1. Arrive first here at 'cboote'.
;	2. Initialize BIOS and page 0 (for NDOS)
;	3. Jump to NDOS cold-boot entry.
;	4. NDOS initializes:
;		4.1. Calls SNIOS init
;		4.2. Calls BDOS init
;		4.3. Intercepts WBOOT
;		4.4. Loads CCP.SPR and jumps to it (every WBOOT)

	org	0
base	equ	$
ndos$pg	equ	base+0f900h
bdos$pg	equ	base+0fd00h

ndoscb	equ	ndos$pg+3	; NDOS cold-boot
ndose	equ	ndos$pg+6
bdose	equ	bdos$pg+6

;	jump vector for indiviual routines
; Cold boot arrives here first...
cboote:	jmp	boot
wboote:	jmp	error
	jmp	const
	jmp	conin
	jmp	conout
	jmp	list
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	error
	jmp	listst	;list status
	jmp	error
;
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
;
buff	equ	0080h	;default buffer
;
signon:	;signon message: xxk cp/m vers y.y
	db	cr,lf,lf
	db	'64'	;memory size
	db	'k CP/NOS vers '
	db	vers/10+'0','.',vers mod 10+'0'
	db	0
;
boot:	;print signon message and go to NDOS
;
;	device initialization  -  as required
;
	lxi	sp,buff+0080h
	lxi	h,signon
	call	prmsg	;print message
	mvi	a,jmp
	sta	0000h
	sta	0005h
	lxi	h,ndose
	shld	0006h
	xra	a
	sta	0004h
	lxi	h,wboote	; for NDOS init
	shld	0001h
	jmp	ndoscb ;go to NDOS initialization
;
;
; TODO: support device redirection?
; TODO: use MMS console driver?
; Console port is assumed already initialized
; TODO: customize printer port?
;
console	equ	0e8h
printer	equ	0e0h

const:	;console status to reg-a
	in	console+5
	ani	1
	rz
	mvi	a,0ffh
	ret
;
conin:	;console character to reg-a
	call	const
	jz	conin
	in	console
	ani	7fh	;remove parity bit
	ret
;
conout:	;console character from c to console out
	call	conost
	jz	conout
	mov	a,c
	out	console
	ret
;
conost:
	in	console+5
	ani	00100000b	; TxHE
	rz
	mvi	a,0ffh
	ret
;
list:	;list device out
	call	listst
	jz	list
	mov	a,c
	out	printer
	ret
;
listst:
	in	printer+5
	ani	00100000b	; TxHE
	rz
	mvi	a,0ffh
	ret
;
;	utility subroutines
error:
	lxi	h,0ffffh
	mov	a,h
	ret

prmsg:	;print message at h,l to 0
	mov	a,m
	ora	a	;zero?
	rz
;	more to print
	push	h
	mov	c,a
	call	conout
	pop	h
	inx	h
	jmp	prmsg
;

	end
