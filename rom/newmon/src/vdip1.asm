; util routines for accessing VDIP1
; caller must define 'vdbuf' as input buffer,
; and 'vdip1' as base port.
	maclib	z80

	public	strcpy,strcmp
	public	vdcmd,vdend,vdrd,vdmsg,vdout,sync,runout
	extrn	vdbuf

vdip1	equ	0d8h	; base port

CR	equ	13

vd$dat	equ	vdip1+1
vd$sts	equ	vdip1+2

vd$txe	equ	00000100b	; Tx ready
vd$rxr	equ	00001000b	; Rx data ready

ticcnt	equ	201bh

	cseg

;****** must be kept in-sync with vdip1.lib ******;
; util routines for accessing VDIP1
; caller must define 'vdbuf' as input buffer,
; and 'vdip1' as base port.

vdip1	equ	0d8h	; base port

vd$dat	equ	vdip1+1
vd$sts	equ	vdip1+2

vd$txe	equ	00000100b	; Tx ready
vd$rxr	equ	00001000b	; Rx data ready

prompt:	db	'D:\>',CR
rdf:	db	'rdf ',0,0,0,128,CR

; copy HL to DE, until NUL
strcpy:
	mov	a,m
	stax	d
	ora	a
	rz
	inx	h
	inx	d
	jr	strcpy

; compare DE to HL, until CR or NUL
strcmp:
	ldax	d
	cmp	m
	rnz
	ora	a
	rz
	cpi	CR
	rz
	inx	h
	inx	d
	jr	strcmp

; send command, wait for prompt or error
; HL=command string, CR term
vdcmd:	
	call	vdmsg
vdend:
	call	vdinp
	lxi	h,vdbuf
	lxi	d,prompt
	call	strcmp
	rz	; OK
	; error, always?
	stc
	ret

; read record (128 bytes) from file, into HL
; returns CY if error, else HL at "next" addr
vdrd:	push	h
	lxi	h,rdf
	call	vdmsg
	pop	h
	call	vdinb
	push	h
	call	vdinp
	lxi	h,vdbuf
	lxi	d,prompt
	call	strcmp
	pop	h	; "next" buffer addr
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

;;;;;;;; everything else is private ;;;;;;;;;

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
vdi0:	in	vd$sts
	ani	vd$rxr
	jrnz	vdi1
	mov	a,m
	cmp	c
	jrz	vdi0
	mov	c,a
	djnz	vdi0
	pop	h
	stc
	ret
vdi1:	in	vd$dat
	pop	h
	ret

; get read data.
; HL=buffer, length always 128
vdinb:	mvi	b,128
vdb0:	in	vd$sts
	ani	vd$rxr
	jrz	vdb0
	in	vd$dat
	mov	m,a
	inx	h
	djnz	vdb0
	ret

; send char to VDIP1
; A=char
vdout:	push	psw
vdo0:	in	vd$sts
	ani	vd$txe
	jrz	vdo0
	pop	psw
	out	vd$dat
	ret

; HL=message, terminated by CR
vdmsg:
	in	vd$sts
	ani	vd$txe
	jrz	vdmsg
	mov	a,m
	out	vd$dat
	cpi	CR	; CR
	rz
	inx	h
	jr	vdmsg
; end of library

	end
