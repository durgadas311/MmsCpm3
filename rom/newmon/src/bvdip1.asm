; Boot Module for VDIP1 (USB thumb drive)
; TODO: make port variable?

vdip1	equ	0d8h	; assume part of Z80-DUART

	maclib	ram
	maclib	core
	maclib	z80

CR	equ	13
vdbuf	equ	2280h
vdscr	equ	2300h

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	41,1	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'V'	; +10: Boot command letter
	db	6	; +11: front panel key
	db	vdip1	; +12: port, 0 if variable
	db	10000011b,10100100b,10000110b	; +13: FP display ("USb")
	db	'VDIP1',0	; +16: mnemonic string

init:
	call	runout
	call	sync
	ret	; pass/fail based on CY

boot:
	lxi	h,opr
	lxi	d,vdbuf
	call	strcpy
	lxi	h,defbt
	call	strcpy
	mvi	a,CR
	stax	d
	lxi	h,vdbuf
	call	vdcmd	; open file
	rc	; no cleanup at this point
	lxi	h,vdscr
	call	vdrd
	jrc	bootx
	; TODO: get load parameters..
	lxi	h,vdscr
	call	vdrd
	jrc	bootx
	lxi	h,vdscr	; load message
	call	msgout	; TODO: strip '$'
	;
bootx:	; exit boot on error, must close file
	lxi	h,clf
	call	vdcmd
	ret

rdf:	db	'rdf ',0,0,0,128,CR
clf:	db	'clf',CR
defbt:	db	'defboot.sys',0	; default boot file
opr:	db	'opr ',0	; command segment

	maclib	vdip1

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
