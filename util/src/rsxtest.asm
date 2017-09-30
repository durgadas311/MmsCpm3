	maclib z80

LF	EQU	0AH		;LINE FEED
CR	EQU	0DH		;CARRIAGE RETURN
;
BDOS	EQU	5		;BDOS ENTRY
;
;  EQUATIONS OF DOS FUNCTION
;
CBUFPR	EQU	9		;BUFFER PRINT
CGETVR	EQU	12		;GET VERSION NUMBER
;

;	RSX Prefix
serial: db	0,0,0,0,0,0
start:	jmp	COLDST	; This gets changed, but we have init to do.
next:	jmp	0
prev:	dw	0
remove: db	0	; 0ffh for remove
nonbank:
	db	0
rsxnam: db	'RSXTEST '
loader: db	0,0,0

CSTUP:	DB	'RSXTEST initialization complete. TPA='
CST0:	DB	'0000 VER='
CST1:	DB	'0000',CR,LF,'$'

VERSION: dw	0

	ds	1536	; This is only to test having an RSX cross
			; the common memory boundary.

puthex:
	push	psw
	rrc
	rrc
	rrc
	rrc
	call	hexdig
	pop	psw
hexdig: ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	mov	m,a
	inx	h
	ret

hexadr:
	mov	a,d
	call	puthex
	mov	a,e
	call	puthex
	ret

COLDST:
	lxi	h,BDOSE
	shld	start+1
	xra	a
	sta	remove
	push	b
	push	d
	mvi	c,CGETVR
	call	next
	shld	VERSION
	xchg
	lxi	h,cst1
	call	hexadr
	lxi	d,start
	lxi	h,cst0
	call	hexadr
	lxi	d,CSTUP
	mvi	c,CBUFPR
	call	next
	pop	d
	pop	b
;
;  FUNCTION DECODING BODY
;
BDOSE:
	LXI	H,0
	MOV	A,C
	cpi	59
	jz	ldfunc
	cpi	60
	jz	rsxfun
	jmp	next		;pass along to next/BDOS
;
; DEBUG messages
ldfmsg: db	'Func '
ldfm0:	db	'59$'
ldfrmv: db	' [REMOVE]$'
ldfnul: db	' [NULL]$'
ldfend: db	13,10,'$'

; This tracks (CCP) calls to BDOS Function 59 LOAD OVERLAY.
; It is this call where LOADER.RSX decides to remove RSXs,
; so the hope is that we detect the event of our own removal.
;
ldfunc: ; LOAD OVERLAY (and RSX remove)
	push	b
	push	d
	mov	a,c
	lxi	h,ldfm0
	call	puthex
	lxi	d,ldfmsg
	mvi	c,CBUFPR
	call	next
	lda	remove
	ora	a
	jz	ldf1
	lxi	d,ldfrmv
	mvi	c,CBUFPR
	call	next
ldf1:
	pop	d
	push	d
	mov	a,d
	ora	l
	jnz	ldf2
	lxi	d,ldfnul
	mvi	c,CBUFPR
	call	next
ldf2:
	lxi	d,ldfend
	mvi	c,CBUFPR
	call	next
	pop	d
	pop	b
	jmp	next

; An example of how to process BDOS Func 60 RSX Func 113
; and remove one's self.
rsxfun:
	mov	l,e
	mov	h,d
	mov	a,m
	inx	h
	cpi	113	; Check for RSX Func 113
	jnz	next
	mov	a,m
	inx	h
	cpi	1	; Check param count to be sure
	jnz	next
	push	d
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,rsxnam
	lxi	b,8
rsxf0:			; Compare paramter to our name
	ldax	d
	cmp	m
	jnz	rsxf1
	inx	d
	inx	h
	dcr	c
	jnz	rsxf0
rsxf1:
	pop	d
	jnz	next
	xra	a	; Names match, remove ourself
	dcr	a
	sta	remove
	jmp	ldfunc	; In a real-life case, this would be 'next'
			; But here we want to trace this event with a message.

	end
