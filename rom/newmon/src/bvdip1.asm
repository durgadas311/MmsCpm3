; Boot Module for VDIP1 (USB thumb drive)
; TODO: make port variable?

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
	db	0b0h	; +12: port, 0 if variable
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

dir:	db	'dir',CR	; DEBUG only
defbt:	db	'defboot.sys',0
prompt:	db	'D:\>',CR
rdf:	db	'rdf ',0,0,0,128,CR
opr:	db	'opr ',0
clf:	db	'clf',CR

; copy HL to DE, until NUL
strcpy:
	mov	a,m
	stax	d
	ora	a
	rz
	inx	h
	inx	d
	jr	strcpy

; compare DE to HL, until CR on either
strcmp:
	ldax	d
	cmp	m
	rnz
	cpi	CR
	rz
	inx	h
	inx	d
	jr	strcmp

; send command, wait for prompt or error
; HL=command string, CR term
vdcmd:	
	call	vdmsg
	call	vdinp
	lxi	h,vdbuf
	lxi	d,prompt
	call	strcmp
	rz	; OK
	; error, always?
	stc
	ret

; read record (128 bytes) from file, into HL
; returns CY if error
vdrd:	push	h
	lxi	h,rdf
	call	vdmsg
	pop	h
	call	vdinb
	call	vdinp
	lxi	h,vdbuf
	lxi	d,prompt
	call	strcmp
	rz
	stc
	ret

sync:	mvi	b,5
	mvi	a,'E'
	call	vdout
	mvi	a,CR
	call	vdout
	call	vdinp	; line to vdbuf
	rc
	lda	vdbuf
	cpi	'E'
	jrnz	sync0
	lda	vdbuf+1
	cpi	CR
	rz
sync0:	djnz	sync
	stc
	ret

; get rid of any characters waiting... flush input
runout:
	call	vdinz	; short timeout...
	rc		; done - nothing more to drain
	jr	runout

; receive chars until CR, into vdbuf
; returns HL->[CR] (if NC)
vdinp:	lxi	h,vdbuf
vdi2:	call	vdinc
	rc
	mov	m,a
	cpi	CR
	rz
	inx	h
	jr	vdi2

; short-timeout input - for draining
vdinz:
	mvi	b,10		; 20mS timeout
	push	h
	lxi	h,ticcnt	; use 2mS increments
	mov	c,m
	jr	vdi0

; avoid hung situations
vdinc:
	mvi	b,6		; 2.5-3 second timeout
	push	h
	lxi	h,ticcnt+1	; hi byte ticks at 512mS
	mov	c,m		; current tick...
vdi0:	in	0b2h
	ani	00001000b	; Rx ready
	jrnz	vdi1
	mov	a,m
	cmp	c
	jrz	vdi0
	mov	c,a
	djnz	vdi0
	pop	h
	stc
	ret
vdi1:	in	0b1h
	pop	h
	ret

; HL=buffer, length always 128
vdinb:	mvi	b,128
vdb0:	in	0b2h
	ani	00001000b	; Rx ready
	jrz	vdb0
	in	0b1h
	mov	m,a
	inx	h
	djnz	vdb0
	ret

; HL=message, terminated by CR
vdout:	push	psw
	in	0b2h
	ani	00000100b	; Tx ready
	jrz	vdout
	pop	psw
	out	0b1h
	ret

; HL=message, terminated by CR
vdmsg:
	in	0b2h
	ani	00000100b	; Tx ready
	jrz	vdmsg
	mov	a,m
	out	0b1h
	cpi	CR	; CR
	rz
	inx	h
	jr	vdmsg

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
