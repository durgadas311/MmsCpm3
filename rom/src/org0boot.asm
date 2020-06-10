	maclib	z80

?h8pt	equ	0f0h
?port	equ	0f2h
ctl$F2	equ	2036h

	org	3000h
boot:	jmp	around

entry:	dw	0	; set by server net boot

around:
	di
	mvi	a,09fh	; 2ms off, blank fp on H8
	out	?h8pt	; H89 NMI should be innocuous
	lxi	h,ctl$F2
	mov	a,m
	ani	11111101b	; clock off
	out	?port
	ani	00100000b	; ORG0 already?
	jrnz	done2
	; In case this is a MMS77318, use full un-lock
	lxi	h,?code		;sequence to move memory-map
	mvi	b,?code$len	;number of bytes in sequence
	mvi	c,?port		;I/O port to send sequence
	outir
	dcx	h
done2:	mov	a,m
	sta	000dh	; for CP/M
	lxi	h,0040h
	lxi	b,16
	mov	d,h
	mov	e,l
	mvi	m,0
	inx	d
	dcx	b
	ldir

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
