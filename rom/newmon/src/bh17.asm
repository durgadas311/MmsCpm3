; Boot Module for H17
	maclib	ram
	maclib	core
	maclib	z80

	org	01800h	; H17 Floppy ROM routines
	ds	1014
R$ABORT: ds	35	;00011011.11110110	033.366	R.ABORT
CLOCK:	ds	38	;00011100.00011001	034.031 CLOCK
R$READ:	ds	499	;00011100.00111111	034.077	R.READ
R$SDP:	ds	107	;			034.062 R.SDP
R$WHD:	ds	28	;00011110.10011101	036.235	R.WHD
R$WNH:	ds	161	;00011110.10111001	036.271	R.WNH
R$CONST: ds	88	;00011111.01011010	037.132	R.CONST

	org	1000h
first:	dw	last-first
	db	0,3	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'B'	; +10: Boot command letter
	db	0	; +11: front panel key
	db	7ch	; +12: port, 0 if variable
	db	10010010b,11110011b,11110001b	; +13: FP display ("H17")
	db	'H17',0	; +16: mnemonic string

init:	ret

boot:	mov	a,d
	add	e
	cpi	3
	rnc	; invalid Z17 drive
	in	0f2h
	ani	00000011b
	rnz		; no Z17 installed
	mvi	a,07ch
	sta	cport
	lxi	h,m$sdp
	shld	D$CONST+62
	mvi	a,10
	mov	b,a	; B = 10, one full revolution?
	call	take$A	; error after 10 seconds...
	call	m$sdp	; hacked R.SDP - setup dev parms (select drive)
bz17$0:
	call	R$WHD	; WHD - wait hole detect
	call	R$WNH	; WNH - wait no hole
	djnz	bz17$0	; essentially hang until user inserts a disk...
	call	R$ABORT	; R.ABORT - reset everything
	lxi	d,bootbf	; DMA address
	lxi	b,00900h	; B = 9 (num sectors), C = 0 (residual bytes to read)
	lxi	h,0		; track/sector number to start
	call	R$READ
	rc
	pop	h
	jmp	hxboot

; hack to support 3 drives on H17
m$sdp:
	mvi	a,10
	sta	DECNT
	lda	AIO$UNI
	push	psw	; 0,1,2
	adi	-2	;
	aci	3	; 1,2,4
	jmp	R$SDP+10	; hacked R.SDP for 3-drives

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
