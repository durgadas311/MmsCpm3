; Boot Module for H17
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	0,3	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'B'	; +10: Boot command letter
	db	0	; +11: front panel key
	db	10010010b,11110011b,11110001b	; +12: FP display ("H17")
	db	'H17',0	; +15: mnemonic string

init:	ret

boot:	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
