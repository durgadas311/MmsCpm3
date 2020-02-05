; Boot Module for VDIP1 (USB thumb drive)
; TODO: make port variable?

	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	41,1	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'V'	; +10: Boot command letter
	db	6	; +11: front panel key
	db	0b0h	; +12: port, 0 if variable
	db	10000011b,10100100b,10000110b	; +13: FP display ("USb")
	db	'VDIP1',0	; +16: mnemonic string

defbt:	db	'defboot',0	; default boot file

init:
	xra	a	; NC
	ret

boot:	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
