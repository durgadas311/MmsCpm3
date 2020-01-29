; Boot Module for VDIP1 (USB thumb drive)
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	41,1	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'V'	; +10: Boot command letter
	db	-1	; +11: front panel key
	db	10000011b,10100100b,10000110b	; +12: FP display ("USb")
	db	'VDIP1',0	; +15: mnemonic string

init:	ret

boot:	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
