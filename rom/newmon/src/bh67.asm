; Boot Module for H67
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	3,2	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'E'	; +10: Boot command letter
	db	2	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	10010010b,10000100b,11110001b	; +13: FP display ("H67")
	db	'H67',0	; +16: mnemonic string

init:	ret

boot:	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
