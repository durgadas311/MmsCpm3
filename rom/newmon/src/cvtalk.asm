; VTALK to VDIP1
	maclib	ram
	maclib	core
	maclib	setup
	maclib	z80

CR	equ	13
LF	equ	10
CTLC	equ	3
DEL	equ	127

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'v'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'VDIP1 Talk',0	; +16: mnemonic string

init:
	lda	susave+vdipt
	cpi	0ffh
	jrnz	init0
	mvi	a,0d8h
init0:	sta	cport
	xra	a	; NC
	ret

exec:
	lxi	h,signon
	call	msgout
	call	waitcr
	lxi	h,ready
	call	msgout
	lda	cport
	adi	2
	mov	c,a
loop:
	in	0edh
	rrc
	jrnc	nokey
	in	0e8h	; char from user
	cpi	CTLC
	jrz	done
	call	vdpout
	call	chrout
	cpi	CR
	jrnz	nokey
	mvi	a,LF
	call	chrout
	mvi	a,0ffh
	sta	pend
nokey:
	inp	a	; vd$sts
	ani	00001000b	; FIFO data ready
	jrz	loop
	; VDIP1 char ready
	lda	pend
	ora	a
	jrz	nocr
	call	crlf
	xra	a
	sta	pend
nocr:
	dcr	c
	inp	a	; get VDIP1 data
	inr	c
	cpi	CR
	jrz	vdcr
	call	chrout
	jr	loop
vdcr:	mvi	a,0ffh
	sta	pend
	jr	loop
done:
	call	crlf
	ret

vdpout:	push	psw
vdpo0:	inp	a
	ani	00000100b	; Tx space avail
	jrz	vdpo0
	pop	psw
	dcr	c
	outp	a
	inr	c
	ret

chrout:	lhld	conout
	pchl

waitcr:
	call	conin
	cpi	CR
	rz
	cpi	DEL
	jrnz	waitcr	; TODO: beep?
	pop	h
	ret

pend:	db	0	; CR/LF pending?

signon:	db	' VDIP1 talk',0
ready:	db	CR,LF,'Ready.',CR,LF,0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
