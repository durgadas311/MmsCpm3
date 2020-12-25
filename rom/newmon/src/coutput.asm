; Command module for I/O port output

	maclib	core
	maclib	ram
	maclib	z80

CR	equ	13
LF	equ	10
BS	equ	8
CTLC	equ	3
BEL	equ	7
ESC	equ	27
DEL	equ	127

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'O'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Output X V',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

exec:
	lxi	h,signon
	call	msgout
	call	parshx
	rc
	mov	a,d
	sta	port
	mvi	a,' '
	call	chrout
	call	parshx
	rc
	mov	a,d
	sta	value
	call	waitcr
	rc
	call	crlf
	lda	port
	mov	c,a
	mvi	b,0	; for Z180?
	lda	value
	outp	a
show:
	lxi	h,prefx
	call	msgout
	lda	port
	call	hexout
	lxi	h,prefx2
	call	msgout
	lda	value
	call	hexout
	ret

fin:	jmp	crlf

hexout:
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	ho0
	pop	psw
ho0:
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	jmp	chrout

; Parse a 8-bit hex value.
; Returns CY if abort, else D=value
parshx:	lxi	d,0	; D=0, E=0
ph0:	call	hexdig
	jrc	ph1	; might be CR...
	mov	c,a
	mov	a,d
	rlc
	rlc
	rlc
	rlc
	add	c	; A=(D<<4)+val
	mov	d,a
	inr	e
	mov	a,e
	cpi	2
	jrc	ph0
	ret	; NC
ph1:	cpi	CR
	jrz	ph2
	cpi	DEL
	stc
	rz
phe:	mvi	a,BEL
	call	chrout
	jr	ph0
ph2:	mov	a,e	; CR pressed
	ora	a
	jrz	phe	; must enter at least one digit
	ret

; Get a hex digit value
hexdig:	call	hexin
	rc	; A=char
	call	chrout	; preserves A (all)
	sui	'0'
	cpi	10
	cmc
	rnc	; 0-9
	sui	'A'-'9'-1
	ora	a	; NC
	ret

; Get a single hex character.
; Returns A=char (toupper), CY if error
hexin:
	call	conin
hexchk:
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rnc
	cpi	DEL
	stc
	rz
	cpi	'A'
	rc
	ani	05fh	; toupper
	cpi	'A'
	rc
	cpi	'F'+1
	cmc
	ret

; wait for CR or DEL (cancel)
waitcr:	call	conin
	cpi	DEL
	stc
	rz
	cpi	CR
	rz
	mvi	a,BEL
	call	chrout
	jr	waitcr

chrout:	lhld	conout
	pchl

signon:	db	'utput ',0
prefx:	db	'OUT ',0
prefx2:	db	': ',0
port:	db	0
value:	db	0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
