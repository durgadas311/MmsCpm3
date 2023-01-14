; Boot Module for H67
	maclib	ram
	maclib	core
	maclib	setup

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
	jnz	init1
	mvi	c,10b
	call	getport	; no return on error
	jnz	init0	; not fatal, if caller gets port later
	mov	a,b
init1:	sta	cport
init0:	xra	a	; NC
	ret

boot:
	lda	cport
	inr	a
	mov	c,a
	xra	a
	call	outp
	lxi	h,0		; zero-out command buffer
	shld	cmdbuf
	shld	cmdbuf+2
	shld	cmdbuf+4
	shld	l2156h	; zero-out ...
	shld	l2156h+2
	sta	l2156h+4
	lda	AIO$UNI	; set LUN in cmdbuf
	rrc		;
	rrc		;
	rrc		;
	sta	cmdbuf+1;
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
	jc	bsasi0
	mvi	e,1	; Recalibrate (Home)
	call	sasi$cmd
	rc
	lxi	h,0800ah	; 10 sectors, retry 8
	shld	cmdbuf+4
	mvi	e,8	; Read
	call	sasi$cmd
	rc
	pop	h	; DEVIANT: leave ghost of error return on stack
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
	call	inp
	ani	00001000b
	cmp	b
	jz	sscmd1
	dcx	h
	mov	a,l
	ora	h
	jnz	sscmd0
	dcr	e
	jnz	sscmd0
	stc
	ret
sscmd1:
	mov	a,b
	xri	00001000b	; wait for BUSY
	jz	sscmd2		; got BUSY...
	mov	b,a
	dcr	c
	xra	a
	call	outp
	inr	c
	inr	c
	mov	a,d
	call	outp	; controller number
	dcr	c
	mvi	a,040h	; SELECT
	call	outp
	jmp	sscmd0	; wait for BUSY now...

sscmd2:
	mvi	a,002h	; enable INTR
	call	outp
	lxi	h,cmdbuf
sscmd3:
	call	inp
	mov	b,a
	ora	a
	jp	sscmd3	; !REQ
	mvi	a,10000b	; CMD
	ana	b
	jz	sscmd4
	mvi	a,01000000b	; MSG
	ana	b
	jz	sscmd6
	dcr	c
	call	outi	; output command byte
	inr	c
	jmp	sscmd3

sscmd4:
	lxi	h,bootbf
sscmd5:
	call	inp
	ora	a
	jp	sscmd5	; !REQ
	ani	10000b	; CMD - indicates data done
	jnz	sscmd6
	dcr	c
	call	ini	; input data byte
	inr	c
	jmp	sscmd5
sscmd6:
	call	inp
	ani	0d0h	; REQ, OUT, CMD
	cpi	090h	; must be REQ, CMD
	jnz	sscmd6	; wait for it...
	dcr	c
	call	inp	; result 0
	mov	l,a
	inr	c
sscmd7:
	call	inp	; status
	mov	h,a
	ani	0e0h	; REG, OUT, MSG
	cpi	0a0h	; must be REQ, MSG
	jnz	sscmd7
	shld	resbuf	; command results
	dcr	c
	call	inp	; last data byte
	inr	c
	ei
	ora	a
	stc
	rnz		; error
	mvi	a,1	; SASI error bit
	ana	l
	rnz
	mvi	a,2	; or other error?
	ana	l
	rnz
	mvi	a,2	; ACK
	ana	h	; ACK
	rnz
	xra	a	; success
	ret

ini:	mov	a,c
	sta	ini0+1
ini0:	in	0
	mov	m,a
	inx	h
	ret

inp:	mov	a,c
	sta	inp0+1
inp0:	in	0
	ret

outi:	mov	a,c
	sta	outi0+1
	mov	a,m
outi0:	out	0
	inx	h
	ret

outp:	push	psw
	mov	a,c
	sta	outp0+1
	pop	psw
outp0:	out	0
	ret

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
