; Boot Module for SDCard(s) on H8xSPI
	maclib	ram
	maclib	core
	maclib	z80

drv0	equ	80
ndrv	equ	2

spi	equ	40h	; same board as WizNet

spi?dat	equ	spi+0
spi?ctl	equ	spi+1
spi?sts	equ	spi+1

SD0SCS	equ	0100b	; SCS for SDCard 0
SD1SCS	equ	1000b	; SCS for SDCard 1

CMDST	equ	01000000b	; command start bits

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	drv0,ndrv	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'S'	; +10: Boot command letter
	db	7	; +11: front panel key
	db	42h	; +12: port, 0 if variable
	db	10100100b,11000010b,11001110b	; +13: FP display ("Sdc")
	db	'SDCard',0	; +16: mnemonic string

; should do card init sequence... but don't know LUN...
init:
	xra	a	; NC
	ret

boot:
	; Partition is passed to bootloader, but we need
	; segment offset before we can start.
	; stack: retL, retH, str0, str1, ...
	lxi	h,2
	dad	sp	; HL=string (maybe)
	call	cardsetup
	rc
	call	cardinit
	rc
	; init for reading...
	lhld	l2156h
	shld	cmd17+1
	lhld	l2156h+2
	shld	cmd17+3
	lxi	h,bootbf
	shld	dma
	mvi	a,10	; 10 sectors to read
	sta	cnt
boot0:
	lhld	dma
	call	read
	rc
	call	incr
	lxi	h,cnt
	dcr	m
	jrnz	boot0
	jmp	hwboot

; HL=string
cardsetup:
	xchg		; DE=string
	lxi	h,0	; def segment
	shld	l2156h+2
	shld	l2156h+4
	lda	AIO$UNI	; 0000000d = 0/1
	inr	a	; 01b/10b
	rlc
	rlc		; = SD0SCS/SD1SCS
	sta	scs
	mvi	a,drv0
	sta	l2034h	; pre-loader expects 80-88 for partn
	ldax	d
	inx	d
	cpi	0c3h	; JMP means no string present
	jrz	nostr
	ora	a	; check for "", too
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
	stc
	rnz	; max two chars
gotit:
nostr:	shld	l2156h	; l2156h[0]=31:24, l2156h[1]=23:16... (32-bit LBA)
	xra	a
	ret

; perform SDCard power-on initialization
; returns CY on error
cardinit:
	; waive 1mS delay... we are well past that...
	call	run74	; must cycle >= 74 clocks
	; CMD0 - enter SPI mode
	lxi	h,cmd0
	mvi	d,1
	mvi	e,1	; turn off SCS
	call	sdcmd
	rc
	lda	cmd0+6	; R1
	cpi	00000001b	; IDLE bit set?
	stc
	rnz
	lxi	h,cmd8
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	sdcmd
	rc
	lda	cmd8+6
	cpi	00000001b	; no error, IDLE bit still set
	jrz	ok8
	bit	2,a	; Illegal Command
	stc
	rz
	; CMD8 not recognized, SD1 card... (not supported?)
	mvi	a,0
	sta	acmd41+1
ok8:
	lxi	h,5	; small number of errors allowed
cdi0:	; this could take a long time...  need timeout...
	push	h
	lxi	h,acmd41
	mvi	d,1
	call	doacmd
	pop	h
	rc
	lda	acmd41+6
	cpi	00000000b	; READY?
	jrz	cdi1
	ani	01111110b	; any errors?
	jrz	cdi0		; loop infinitely if just "BUSY"
	dcx	h
	mov	a,h
	ora	l
	jrnz	cdi0
	stc	; timeout - error
	ret
cdi1:	; done with init
	; now try CMD58 if applicable
	lda	acmd41+1
	ora	a
	rz	; no more init for SDC1... return NC
	; SDC2... get CMD58
	lxi	h,cmd58
	mvi	d,5
	mvi	e,1	; turn off SCS
	call	sdcmd
	rc
	lda	cmd58+7 ; OCR 31:24
	bit	7,a	; power-up status
	stc
	rz	; card failed to power-up
	bit	6,a	; SDSC?
	jrz	sdhc
	xra	a
	ret

sdhc:	lxi	h,nosc
	call	msgout
	stc
	ret

nosc:	db	'SDSC not supported',13,10,0

; increment LBA in cmd17, and DMA
incr:
	lhld	dma
	inr	h	; +256
	inr	h	; +512
	shld	dma
	lxi	h,cmd17+4
	inr	m
	rnz
	dcx	h
	inr	m
	rnz
	dcx	h
	inr	m
	rnz
	dcx	h
	inr	m
	ret

; read LBA stored in cmd17...
; HL=buffer
; returns CY on error
read:
	push	h
	lxi	h,cmd17
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	sdcmd
	pop	h
	jrc	badblk	; turn off SCS
	lda	cmd17+6
	ora	a
	jrnz	badblk	; turn off SCS
	call	sdblk	; turns off SCS
	ret	; CY=error
badblk:
	xra	a
	out	spi?ctl	; SCS off
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
	rlc		; sssss000 = 256M/512B
	mov	h,a	;
	ret

scs:	db	SD0SCS
dma:	dw	0
cnt:	db	0

; command is always 6 bytes.
; CRC is ignored, but "end bit" must be "1".
; This explains the problems seen with "Samsung 32Pro",
cmd0:	db	CMDST+0,0,0,0,0,95h
	db	0
cmd8:	db	CMDST+8,0,0,01h,0aah,87h
	db	0,0,0,0,0
cmd55:	db	CMDST+55,0,0,0,0,1
	db	0
acmd41:	db	CMDST+41,40h,0,0,0,1
	db	0
cmd58:	db	CMDST+58,0,0,0,0,1
	db	0,0,0,0,0
cmd17:	db	CMDST+17,0,0,0,0,1
	db	0

; run-out at least 74 clock cycles... with SCS off...
run74:	mvi	b,10	; 80 cycles
	mvi	c,spi?dat
run740:	inp	a
	djnz	run740
	ret

; E=dump flag, always turns off SCS
doacmd:
	push	h
	push	d
	lxi	h,cmd55
	mvi	d,1
	mvi	e,0	; do not turn off SCS
	call	sdcmd
	; ignore results? CMD55 never gives error?
	pop	d
	pop	h
	mvi	e,1
	call	sdcmd
	push	psw
	; for some reason, this is required (at least for ACMD41)
	; when certain cards (Flexon) are in-socket during power up.
	; If the card is re-seated after power up, this is not needed.
	; Unclear if this is a MT011 anomaly or universal.
	in	spi?dat
	in	spi?dat
	pop	psw
	ret

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success), HL=idle length, DE=gap length
sdcmd:
	lda	scs
	out	spi?ctl	; SCS on
	mvi	c,spi?dat
	; wait for idle
	; TODO: timeout this loop
	push	h	; save command+response buffer
	lxi	h,256	; idle timeout
sdcmd0:	inp	a
	cpi	0ffh
	jrz	sdcmd1
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd0
	; timeout - error
	pop	h
	stc
	ret
sdcmd1:	pop	h	; command buffer back
	mvi	b,6
	outir
	inp	a	; prime the pump
	push	h	; points to response area...
	lxi	h,256	; gap timeout
sdcmd2:	inp	a
	cpi	0ffh
	jrnz	sdcmd3
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd2
	pop	h
	stc
	ret
sdcmd3:	pop	h	; response buffer back
	mov	b,d
	mov	m,a
	inx	h
	dcr	b
	jrz	sdcmd4
	inir	; rest of response
sdcmd4:	mov	a,e	; SCS flag
	ora	a
	rz
	xra	a
	out	spi?ctl	; SCS off
	ret	; NC

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; HL=buffer
; return CY on error (A=error), SCS always off
sdblk:
	lda	scs
	out	spi?ctl	; SCS on
	mvi	c,spi?dat
	; wait for packet header (or error)
	; TODO: timeout this loop
	lxi	d,256	; gap timeout
sdblk0:	inp	a
	cpi	0ffh
	jrnz	sdblk1
	dcx	d
	mov	a,d
	ora	e
	jrnz	sdblk0
	stc
	jr	sdblk2
sdblk1:	
	cpi	11111110b	; data start
	stc	; else must be error
	jrnz	sdblk2
	mvi	b,0	; 256 bytes at a time
	inir
	inir
	inp	a	; CRC 1
	inp	a	; CRC 2
	xra	a	; NC
sdblk2:	push	psw
	xra	a
	out	spi?ctl	; SCS off
	pop	psw
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
