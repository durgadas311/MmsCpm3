; Boot Module for H47
	maclib	ram
	maclib	core
	maclib	setup

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	5,4	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'D'	; +10: Boot command letter
	db	1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	10010010b,10110010b,11110001b	; +13: FP display ("H47")
	db	'H47',0	; +16: mnemonic string

init:
	lda	susave+h47pt
	cpi	0ffh
	jnz	init1
	mvi	c,01b
	call	getport	; no return on error
	jnz	init0	; not fatal, if caller gets port later
	mov	a,b
init1:	sta	cport
init0:
	; 'JMP' already in place
	lxi	h,z47$dati
	shld	h47$dati+1
	lxi	h,z47$dato
	shld	h47$dato+1
	lxi	h,z47$cmdo
	shld	h47$cmdo+1
	xra	a	; NC
	ret

boot:
	lda	AIO$UNI
	rrc		; u000000u
	rrc		; uu000000
	rrc		; 0uu00000
	inr	a	; 0uu00001
	mov	e,a
	mvi	a,5
	call	take$A	; error out after 5 seconds...
	mvi	a,2
	call	outport0
	mvi	a,2
	call	z47$cmdo
	mov	a,e
	call	z47$dato
	call	z47$dati
	ani	00ch
	rrc
	rrc
	inr	a
	mov	b,a
	mvi	a,1
bz47$0:
	add	a
	dcr     b           ; ...
	jnz     bz47$0      ; djnz	bz47$0
	rar
	mov	b,a
	lxi	h,bootbf
	push	b
	call	z47$read
	pop	b
	inr	e
	call	z47$read
	call	inport0
	ani	001h
	rnz
	jmp	hwboot

z47$dato:
	mvi	d,080h	; TR - date transfer request
	jmp	z47$out0
z47$cmdo:
	mvi	d,020h	; DONE
z47$out0:
	stc
	push	psw
z47$wt0:
	call	inport0
	ana	d
	jz	z47$wt0
	pop	psw
	jmp	z47$out1
outport0:
	ora	a
z47$out1:
	push	b
	mov	b,a
	lda	cport
	aci	0
	mov	c,a
	mov	a,b
	call    outp    ; outp	a
	pop	b
	ret

inport0:
	ora	a	; NC
inportx:	; input from cport+CY
	push	b
	lda	cport
	aci	0
	mov	c,a
	call    inp      ; inp	a
	pop	b
	ret

z47$dati:
	call	inport0
	rlc	; TR
	jnc	z47$dati
	jmp	inportx	; CY=1, input cport+1

z47$read:
	mvi	a,7	; read thru buffer command
	call	z47$cmdo
	xra	a
	call	z47$dato	; params
	mov	a,e
	call	z47$dato	; params
z47$rd0:
	mvi	c,128
z47$rd1:
	call	z47$dati
	mov	m,a
	inx	h
	dcr	c
	jnz	z47$rd1
	dcr	b
	jnz	z47$rd0
	ret

inp:	mov	a,c
	sta	inp0+1
inp0:	in	0
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
