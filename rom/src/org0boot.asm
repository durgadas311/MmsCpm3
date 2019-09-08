	maclib	z80

?h8pt	equ	0f0h
?port	equ	0f2h

	org	3000h
boot:	jmp	around

entry:	dw	0	; set by server net boot

around:
	di
	mvi	a,09fh	; 2ms off, blank fp on H8
	out	?h8pt	; H89 NMI should be innocuous

	; In case this is a MMS77318, use full un-lock
	lxi	h,?code		;sequence to move memory-map
	mvi	b,?code$len	;number of bytes in sequence
	mvi	c,?port		;I/O port to send sequence
	outir
	dcx	h
	mov	a,m
	sta	000dh	; for CP/M

	lhld	entry
	pchl

?code	db	0000$01$00b
	db	0000$11$00b
	db	0000$01$00b
	db	0000$10$00b
	db	0000$11$00b
	db	0000$10$00b
	db	0010$00$00b	;changes memory if "-FA" also
?code$len equ	$-?code

	rept	128-($-boot)
	db	0
	endm

	end
