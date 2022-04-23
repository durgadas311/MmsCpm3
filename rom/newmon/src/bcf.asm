; Boot Module for CF - unit select via port CF$BA
	maclib	ram
	maclib	core
	maclib	z80

CF$BA	equ	80h		; CF base port
CF$DA	equ	CF$BA+8	; CF data port
CF$ER	equ	CF$BA+9	; CF error register (read)
CF$FR	equ	CF$BA+9	; CF feature register (write)
CF$SC	equ	CF$BA+10	; CF sector count
CF$SE	equ	CF$BA+11	; CF sector number
CF$CL	equ	CF$BA+12	; CF cylinder low
CF$CH	equ	CF$BA+13	; CF cylinder high
CF$DH	equ	CF$BA+14	; CF drive/head
CF$CS	equ	CF$BA+15	; CF command/status

CMD$FEA	equ	0efh	; Set Features command

F$8BIT	equ	001h	; enable 8-bit transfer
F$NOWC	equ	082h	; disable write-cache

drv0	equ	70
ndrv	equ	2

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	drv0,ndrv	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'F'	; +10: Boot command letter
	db	4	; +11: front panel key
	db	80h	; +12: port, 0 if variable
	db	10001101b,10011100b,11111111b	; +13: FP display ("CF ")
	db	'CF',0	; +16: mnemonic string

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
	mvi	l,0	; each socket wired as master (drive 0)
	mvi	a,drv0
	sta	l2034h	; pre-loader expects 70-78 for partn
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
	lda	AIO$UNI	; 0000000d - 0/1
	adi	1	; 01b/10b
	out	CF$BA	; select CF card
	xra	a
	out	CF$FR	; needed after power-on?
	; select 8-bit mode
	mvi	a,F$8BIT
	out	CF$FR
	mvi	a,CMD$FEA
	out	CF$CS
	call	waitcf
	rc
	; disable write-cache
	mvi	a,F$NOWC
	out	CF$FR
	mvi	a,CMD$FEA
	out	CF$CS
	call	waitcf
	rc
	mov	a,l
	ori	11100000b	; LBA mode + std "1" bits
	out	CF$DH	; LBA 27:4, drive 0, LBA mode
	mov	a,h
	out	CF$CH	; LBA 23:16
	xra	a
	out	CF$CL	; LBA 15:8
	out	CF$SE	; LBA 7:0
	mvi	a,10
	out	CF$SC	; 10 sectors (standard boot length)
	mvi	a,20h	; READ SECTORS
	out	CF$CS
	lxi	h,bootbf
	mvi	c,CF$DA
	mvi	e,10
	mvi	b,0	; should always be 0 after inir
bcf0:
	call	waitcf
	rc
	bit	3,a	; DRQ
	jrz	bcf0
	inir	; 256 bytes
	inir	; 512 bytes
	dcr	e
	jrnz	bcf0
	xra	a
	out	CF$BA	; deselect drive
	; final status check?
	pop	h	; adj stack for possible string
	jmp	hwboot

waitcf:
	in	CF$CS
	bit	7,a	; busy
	jrnz	waitcf
	bit	0,a	; error
	jrnz	cferr
	bit	6,a	; ready
	jrz	cferr
	ora	a	; NC
	ret

cferr:
	xra	a
	out	CF$BA	; deselect drive
	stc
	ret

trydig:
	cpi	'0'	; digit?
	rc	; error
	cpi	'9'+1	; max 9 partitions
	cmc
	rc	; error - or letter
	sui	'0'
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
