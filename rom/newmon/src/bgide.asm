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

drv0	equ	70
ndrv	equ	2

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	drv0,ndrv	; +2,+3: phy drv base, num

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
	; stack: retL, retH, str0, str1, ...
	lxi	h,2
	dad	sp
	xchg		; DE=string
	lxi	h,0	; def seg/lun
	shld	l2156h+2
	shld	l2156h+4
	lda	AIO$UNI	; 0000000d
	rlc
	rlc
	rlc
	rlc		; 000d0000
	mov	l,a	; no overlap with segment
	mvi	a,drv0
	sta	l2034h	; pre-loader expects 70-78 for partn
	xra	a
	sta	AIO$UNI
	ldax	d
	inx	d
	cpi	0c3h	; JMP means no string present
	jrz	nostr
	call	trydig
	jrnc	gotdig
	call	tryltr
	rc
	ldax	d
	inx	d
	ora	a
	jrz	gotit
	call	trydig
	rc
	jr	chkend
gotdig:	ldax	d
	inx	d
	ora	a
	jrz	gotit
	call	tryltr
	rc
chkend:	ldax	d
	ora	a
	rnz	; max two chars
gotit:
nostr:	shld	l2156h	; l2156h[0]=DRV|27:24, l2156h[1]=23:16
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

trydig:
	cpi	'0'	; digit?
	rc	; error
	cpi	'9'+1	; max 9 partitions
	cmc
	rc	; error - or letter
	sui	'0'
	sta	AIO$UNI
	adi	drv0
	sta	l2034h	; pre-loader expects 70-78 for partn
	ret

tryltr:
	cpi	'A'
	rc	; error - or digit
	ani	5fh	; toupper
	sui	'A'	; 000sssss
	cpi	26
	cmc
	rc
	rlc
	rlc
	rlc		; sssss000
	mov	h,a	; no overlap with DRV
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
