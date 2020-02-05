; Command module for Cassette tape load/store
	maclib	ram
	maclib	core
	maclib	z80

	org	1000h
first:	dw	last-first
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	cass	; +7: action entry

	db	-1	; +10: Command letter
	db	88h	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Cassette',0	; +16: mnemonic string

init:
	lxi	h,inimsg
	call	msgout
	ret

cass:
	lda	lstcmd
	cpi	88h	; load key
	jrz	load
save:
	lxi	h,savmsg
	call	msgout
	ret
	;
load:
	lxi	h,lodmsg
	call	msgout
	ret

savmsg:	db	13,10,'Save',0
lodmsg:	db	13,10,'Load',0
inimsg:	db	13,10,'Cassette',0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
