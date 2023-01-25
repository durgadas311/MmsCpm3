; Command module for RESET system

	maclib	core
	maclib	core80
	maclib	ram

CR	equ	13
LF	equ	10
BEL	equ	7
DEL	equ	127

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'r'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'RESET System',0	; +16: mnemonic string

init:	xra	a	; NC
	ret

exec:
	lxi	h,signon
	call	msgout
	call	waitcr
	rc
	call	crlf
	call	condrain ; ensure all conout drained
	out	36h

	; delay a little (probably only for simulator),
	; if RESET doesn't happen then print message.
	xra	a
dly:	dcr	a
	jnz	dly

	lxi	h,fail
	call	msgout
	ret

condrain:
	in	0edh
	ani	01100000b
	cpi	01100000b
	jnz	condrain
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
	jmp	waitcr

chrout:	lhld	conout
	pchl

signon:	db	'ESET System',0
fail:	db	CR,LF,'RESET failed?',CR,LF,0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
