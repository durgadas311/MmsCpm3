; Boot Module for GIDE
	maclib	ram
	maclib	core
	maclib	z80

GIDE$BA	equ	80h		; GIDE base port
GIDE$DA	equ	GIDE$BA+8	; GIDE data port
GIDE$ER	equ	GIDE$BA+9	; GIDE error register (read)
GIDE$FR	equ	GIDE$BA+9	; GIDE feature register (write)
GIDE$SC	equ	GIDE$BA+10	; GIDE sector count
GIDE$SE	equ	GIDE$BA+11	; GIDE sector number
GIDE$CL	equ	GIDE$BA+12	; GIDE cylinder low
GIDE$CH	equ	GIDE$BA+13	; GIDE cylinder high
GIDE$DH	equ	GIDE$BA+14	; GIDE drive/head
GIDE$CS	equ	GIDE$BA+15	; GIDE command/status

	org	1000h
first:	dw	last-first
	db	70,9	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'X'	; +10: Boot command letter
	db	4	; +11: front panel key
	db	80h	; +12: port, 0 if variable
	db	11110011b,11000010b,10001100b	; +13: FP display ("IdE")
	db	'GIDE',0	; +16: mnemonic string

init:	xra	a	; NC
	ret

boot:
	; Partition is passed to bootloader, but we need
	; segment offset before we can start.
	pop	d	; error return address
	pop	b	; possible string
	push	b
	push	d
	; parse a single letter
	; TODO: parse LUN or segment, both optional
	lxi	h,0	; def segment off
	shld	l2156h+2
	shld	l2156h+4
	mov	a,c
	cpi	0c3h	; JMP means no string present
	jrz	nostr
	mov	a,b
	ora	a	; limit to 1 char?
	rnz
	mov	a,c
	ani	5fh
	sui	'A'	; 000sssss = segment ID
	rc
	rlc
	rlc
	rlc		; sssss000 = segoff: 0000 sssss000 00000000 00000000
	mov	h,a	; swap for little endian SHLD/LHLD
nostr:	shld	l2156h	; l2156h[0]=27:24, l2156h[1]=23:16
	xra	a
	out	GIDE$FR	; needed after power-on?
	mov	a,l
	ori	11100000b	; LBA mode + std "1" bits
	out	GIDE$DH	; LBA 27:4, drive 0, LBA mode
	mov	a,h
	out	GIDE$CH	; LBA 23:16
	xra	a
	out	GIDE$CL	; LBA 15:8
	out	GIDE$SE	; LBA 7:0
	mvi	a,10
	out	GIDE$SC	; 10 sectors (standard boot length)
	mvi	a,20h	; READ SECTORS
	out	GIDE$CS
	lxi	h,bootbf
	mvi	c,GIDE$DA
	mvi	e,10
	mvi	b,0	; should always be 0 after inir
bgide0:
	in	GIDE$CS
	bit	7,a	; busy
	jrnz	bgide0
	bit	0,a	; error
	rnz
	bit	6,a	; ready
	rz
	bit	3,a	; DRQ
	jrz	bgide0
	inir	; 256 bytes
	inir	; 512 bytes
	dcr	e
	jrnz	bgide0
	; final status check?
	pop	h	; adj stack for possible string
	jmp	hwboot

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
