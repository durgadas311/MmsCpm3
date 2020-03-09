; Boot Module for H67
	maclib	ram
	maclib	core
	maclib	setup
	maclib	z80

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	3,2	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'E'	; +10: Boot command letter
	db	2	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	10010010b,10000100b,11110001b	; +13: FP display ("H67")
	db	'H67',0	; +16: mnemonic string

init:
	lda	susave+h67pt
	cpi	0ffh
	jrnz	init1
	mvi	c,10b
	call	getport	; no return on error
	jrnz	init0	; not fatal, if caller gets port later
	mov	a,b
init1:	sta	cport
init0:	xra	a	; NC
	ret

boot:
	lda	AIO$UNI
	rrc
	rrc
	rrc
	sta	cmdbuf+1
	lda	cport
	inr	a
	mov	c,a
	xra	a
	outp	a
	lxi	h,0		; zero-out command buffer
	shld	cmdbuf
	shld	cmdbuf+2
	shld	cmdbuf+4
	shld	l2156h	; zero-out ...
	shld	l2156h+2
	sta	l2156h+4
	mvi	d,0	; controller number
	mvi	a,4	; delay 8mS, also NZ
	ora	a
	ei
bsasi0:
	rz
	call	delay
	mvi	e,0	; Test Drive Ready
	call	sasi$cmd
	mvi	a,255	; longer delay on retry...
	jrc	bsasi0
	mvi	e,1	; Recalibrate (Home)
	call	sasi$cmd
	rc
	lxi	h,0800ah	; 10 sectors, retry 8
	shld	cmdbuf+4
	mvi	e,8	; Read
	call	sasi$cmd
	rc
	pop	h
	jmp	hwboot

; send SASI read command, get results
sasi$cmd:
	di
	mov	a,e
	sta	cmdbuf
	mvi	b,0	; wait for "not BUSY" first
	mvi	e,6	;
	lxi	h,0	; 0x060000 loop/timeout count
sscmd0:
	inp	a
	ani	00001000b
	cmp	b
	jrz	sscmd1
	dcx	h
	mov	a,l
	ora	h
	jrnz	sscmd0
	dcr	e
	jrnz	sscmd0
	stc
	ret
sscmd1:
	mov	a,b
	xri	00001000b	; wait for BUSY
	jrz	sscmd2		; got BUSY...
	mov	b,a
	dcr	c
	xra	a
	outp	a
	inr	c
	inr	c
	outp	d	; controller number
	dcr	c
	mvi	a,040h	; SELECT
	outp	a
	jr	sscmd0	; wait for BUSY now...

sscmd2:
	mvi	a,002h	; enable INTR
	outp	a
	lxi	h,cmdbuf
sscmd3:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd3
	bit	4,a	; CMD
	jrz	sscmd4
	bit	6,a	; MSG
	jrz	sscmd6
	dcr	c
	outi		; output command byte
	inr	c
	jr	sscmd3

sscmd4:
	lxi	h,bootbf
sscmd5:
	inp	a
	bit	7,a	; REQ
	jrz	sscmd5
	bit	4,a	; CMD - indicates data done
	jrnz	sscmd6
	dcr	c
	ini		; input data byte
	inr	c
	jr	sscmd5
sscmd6:
	inp	a
	ani	0d0h	; REQ, OUT, CMD
	cpi	090h	; must be REQ, CMD
	jrnz	sscmd6	; wait for it...
	dcr	c
	inp	l	; result 0
	inr	c
sscmd7:
	inp	h	; status
	mov	a,h
	ani	0e0h	; REG, OUT, MSG
	cpi	0a0h	; must be REQ, MSG
	jrnz	sscmd7
	shld	resbuf	; command results
	dcr	c
	inp	a	; last data byte
	inr	c
	ei
	ora	a
	stc
	rnz		; error
	bit	0,l	; SASI error bit
	rnz
	bit	1,l	; or other error?
	rnz
	bit	1,h	; ACK
	rnz
	xra	a	; success
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
