; Test Command module - 'X'
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'X'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Test',0	; +16: mnemonic string

init:
	lxi	h,inimsg
	call	msgout
	xra	a	; NC
	ret

exec:
	lxi	h,savmsg
	call	msgout
	ret

savmsg:	db	'Run',0
inimsg:	db	'Init',0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
