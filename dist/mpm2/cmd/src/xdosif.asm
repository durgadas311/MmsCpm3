	title	'MP/M II V2.0 Common/Banked XDOS I/F'
	name	'xdosif'
	dseg
@@xdsif:
	public	@@xdsif
	cseg
;xdosif:
@xdsif:
	public	@xdsif

;do;

;/*
;  Copyright (C) 1979, 1980,1981
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950
;
;  Revised:
;    14 Sept 81 by Thomas Rolander
;*/

	extrn	rlr
	extrn	xdos
	extrn	sysdat
	extrn	ProcAddressTable
	extrn	msegtbl
	extrn	xiosms

parsefilename:
	public	parsefilename
	;BC = .(.filename,.fcb)
	push	b
	call	getMX
	pop	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
	di
	shld	temp1
	xchg
	inx	h
	mov	c,m
	inx	h
	mov	h,m
	mov	l,c
	shld	temp2
	lxi	h,commonbuffer+4+80
	shld	commonbuffer+2
	lxi	h,commonbuffer+4
	shld	commonbuffer
	lxi	b,80
	call	move
	call	enterbnkxdos
	lxi	b,commonbuffer
	lxi	h,0000
	call	bnkxdos
	mov	a,h
	ora	l
	jz	savretcode
	inx	h
	mov	a,h
	ora	l
	dcx	h
	jz	savretcode
	lxi	d,commonbuffer+4
	mov	a,l
	sub	e
	mov	e,a
	mov	a,h
	sbb	d
	mov	d,a
	lhld	temp1
	dad	d
savretcode:
	shld	retcode
	call	exitbnkxdos
	lhld	temp2
	lxi	d,commonbuffer+4+80
	lxi	b,27
	call	move
	lhld	retcode
	push	h
	call	rlsMX		;also ei's
	pop	h
;	ei
	ret

;
; Common/Banked XDOS Utilities
;

move:	;BC = Count, DE = Source, HL = Destination	
	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	move
	ret

getmemseg:
	lhld	rlr
	lxi	d,0fh	;offset to memseg index
	dad	d
	mov	a,m
	ret

extbnkswt:
	di
	mov	m,a
	inr	a
	jz	extbnkswt1
	dcr	a
	add	a
	add	a
extbnkswt1:
	lxi	h,msegtbl
	add	l
	mov	c,a
	mvi	a,0
	adc	h
	mov	b,a
	jmp	xiosms
;	ret	

getMX:
	lxi	d,MXProcuqcb
	mvi	c,137
	jmp	xdos

rlsMX:
	lxi	d,MXProcuqcb
	mvi	c,139
	jmp	xdos

enterbnkxdos:
	pop	d
	lxi	h,0
	dad	sp
	lxi	sp,topofstack
	push	h
	push	d	;enterbnkxdos return address
	call	getmemseg
	sta	usermemseg
	xra	a
	call	extbnkswt
	ei
	ret

bnkxdos: ;HL = Proc # * 2
	lxi	d,ProcAddressTable
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl
;	ret

exitbnkxdos:
	call	getmemseg
	lda	usermemseg
	call	extbnkswt
	pop	d
	pop	h
	sphl
	push	d
	ret

;
; Common/Banked XDOS Data Segment
;

;  declare MXProc$cqcb structure (
;    cqueue,
;    buf (2) byte ) public
;    initial (0,'MXProc  ',0,1);
	public	MXProccqcb
MXProccqcb:
	dw	$-$	; ql
	db	'MXProc  '	; name
	dw	0	; msglen
	dw	1	; nmbmsgs
	dw	$-$	; dqph
	dw	$-$	; nqph
	dw	0	; msgin
	dw	0	; msgout
	dw	1	; msgcnt
	ds	2	; buf (2) byte

;  declare MXProc$uqcb userqcbhead public
;    initial (.MXProc$cqcb);
MXProcuqcb:
	dw	MXProccqcb	; pointer

;  declare common$buffer (128) byte initial (0);
commonbuffer:
	ds	128

;  declare common$stack (20) address initial (0c7c7h);
commonstack:
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h

userstkptr:
	ds	2
;  declare top$of$stack address at (.common$stack(21));
topofstack:


usermemseg:
	ds	1
retcode:
	ds	2
temp1:
	ds	2
temp2:
	ds	2


;end xdosif;
	END
