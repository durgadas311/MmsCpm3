; Boot Module for WizNet
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	60,1	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'W'	; +10: Boot command letter
	db	-1	; +11: front panel key
	db	10010001b,10001100b,10011101b	; +12: FP display ("NET")
	db	'WizNet',0	; +15: mnemonic string

init:	ret

boot:	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
