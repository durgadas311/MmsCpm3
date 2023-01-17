; Boot Module for VDIP1 (USB thumb drive)
; TODO: make port variable?

vdip1	equ	0d8h	; assume part of Z80-DUART

	maclib	ram
	maclib	core
	maclib	z80

CR	equ	13
bbuf:	equ	2280h
vdbuf	equ	2300h
vdscr	equ	2380h

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

sfx:	db	'.sys'
sfxlen	equ	$-sfx

init:
	call	runout
	call	sync
	ret	; pass/fail based on CY

boot:
	lxi	h,opr
	lxi	d,vdbuf
	call	strcpy
	lxi	h,bbuf	; possible string here
	mov	a,m
	cpi	0c3h	; JMP means no string
	jrz	boot5
	ora	a	; check for "", too
	jrz	boot5
	; else, A=str len
	mov	c,a
	mvi	b,0
	inx	h
xx0:	mov	a,m
	stax	d
	ora	a
	jrz	xx1
	cpi	' '	; possible command options follow
	jrz	xx1
	sui	'.'	; 00:(A=='.')
	sui	1	; CY:==, NC:<>
	sbb	a	; FF:=='.', 00:<>'.'
	ora	b	; B=true if any '.' seen
	mov	b,a
	inx	h
	inx	d
	dcr	c
	jrnz	xx0
xx1:	inr	b
	jrz	boot6	; saw a '.', don't append '.sys'
	lxi	h,sfx
	lxi	b,sfxlen
	ldir
	jr	boot6
boot5:	lxi	h,defbt
	call	strcpy
boot6:	mvi	a,CR
	stax	d
	lxi	h,vdbuf
	call	vdcmd	; open file
	rc	; no cleanup at this point
	lxi	h,vdscr
	call	vdrd
	jrc	bootx
	; TODO: get load parameters..
	lhld	vdscr
	shld	memtop
	lhld	vdscr+2
	shld	bnktop
	lhld	vdscr+4
	shld	entry
	lda	vdscr+16	; ORG0 flag - don't care?
	sta	copy
	lxi	h,vdscr
	call	vdrd
	jrc	bootx
	lxi	d,vdscr	; load message
	call	print
	lda	comlen
	ora	a
	jrz	boot1
	mov	d,a
	lda	memtop
	call	loadit
	rc
boot1:	lda	bnklen
	ora	a
	jrz	boot2
	mov	d,a
	lda	bnktop
	call	loadit
	rc
boot2:	; ready to go?
	call	bootx	; close file
	; cleanup clocks...
	di
	mvi	a,10011111b	; H8 2mS off, display blank
	sta	ctl$F0
	out	0f0h
	; already at ORG0... H89 2mS already off?
	lhld	entry
	pchl

bootx:	; exit boot on error, must close file
	lxi	h,clf
	call	vdcmd
	ret

; A=top page (might be 0 for 64K)
; D=num pages
loadit:	mov	h,a
	mvi	l,0	; HL=top address
	ora	a
	ralr	d	; num records
load0:
	lxi	b,-128
	dad	b
	push	h
	push	d
	call	vdrd
	pop	d
	pop	h
	rc		; error
	dcr	d
	jrnz	load0
	ora	a	; NC
	ret

clf:	db	'clf',CR
defbt:	db	'defboot.sys',0	; default boot file
opr:	db	'opr ',0	; command segment

memtop:	db	0
comlen:	db	0
bnktop:	db	0
bnklen:	db	0
entry:	dw	0
; don't care about cfgtbl?
copy:	db	0	; 'C' if ORG0 required

; BDOS-style print function
; DE=message, '$' terminated
print:	ldax	d
	cpi	'$'
	rz
	call	outcon
	inx	d
	jr	print

outcon:	lhld	conout
	pchl

	maclib	vdip1

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
