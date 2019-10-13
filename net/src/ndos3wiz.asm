; Initialization code for NDOS3 on WIZ850io
; Checks for duplicate NDOS3, then initializes WIZ850io
;
	maclib	z80

	extrn	wizcfg
	extrn	cpnsetup
	public	nvbuf

cr	equ	13
lf	equ	10

; System page-0 constants
cpm	equ	0
bdos	equ	5

; BDOS functions
print	equ	9
; NDOS functions
cfgtbl	equ	69

; RSX is already linked-in, but might be a duplicate

	cseg
	lxi	sp,stack

	lixd	bdos+1	; this should be our NDOS3
	sixd	us
	jmp	dup0
dup1:
	ldx	a,+18	; LOADER3?
	cpi	0ffh
	jz	ldr3
	call	chkdup
	lxi	d,dupmsg
	jz	rm$us	; duplicate NDOS3, remove "us"
dup0:
	ldx	l,+4	; next RSX...
	ldx	h,+5	;
	push	h
	popix
	jmp	dup1

; DE = message to print
rm$us:
	lixd	us
	mvix	0ffh,+8	; set remove flag
	; also short-circuit it
	ldx	l,+4	; next RSX...
	ldx	h,+5	;
	stx	l,+1	; by-pass duplicate
	stx	h,+2	;
	; report what happened
	mvi	c,print
	call	bdos
	jmp	cpm

; hit LOADER3 RSX, no dup found...
ldr3:
	call	wizcfg
	jrc	wizerr
	; This will also cold-start NDOS...
	; hopefully, no bad effects.
	mvi	c,cfgtbl
	call	bdos
	; HL=cfgtbl (check error?)
	lxi	d,nvbuf+288	; 64 bytes for cfgtbl template
	call	cpnsetup
	jmp	cpm
wizerr:
	call	nocfg	; report error, but continue...
	jmp	cpm	; let RSX init itself

chkdup:	pushix
	pop	h
	lxi	d,10	; offset of name
	dad	d
	lxi	d,ndos3
	lxi	b,8
chk0:	ldax	d
	cmp	m
	rnz
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	chk0
	ret	; ZR = match

nocfg:	lxi	d,ncfg
	mvi	c,print
	jmp	bdos

	dseg
us:	dw	0	; our copy of NDOS3 (remove if dup)

dupmsg:	db	'NDOS3 already loaded',cr,lf,'$'
ndos3:	db	'NDOS3   '
ncfg:	db	'NVRAM not configured',cr,lf,'$'

	ds	64
stack:	ds	0

nvbuf:	ds	512

	end
