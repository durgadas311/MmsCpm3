; March 19, 1985  21:13  drm  "PRNTKP1.ASM"

; Printer module for KayPro / Juki.

@us	equ	31
@rs	equ	30
@esc	equ	27
@cr	equ	13
@ff	equ	12
@lf	equ	10

	org	400h
	JMP	0
prtchr: JMP	$-$
prtmsg: JMP	$-$

	DB	81H
	db	120
	db	120
	db	48	; vertical increments
L040D	DB	48	; down increments
L040E	DB	48	; up increments
	db	48
	db	6	;
L0411	DB	0	; current column spacing index
L0412	DB	0	; current line psacing index
	db	12	;
	db	12	;
	db	8	;

	JMP	init
	JMP	setCSI
	JMP	setLSI
	JMP	prtCR
	JMP	prtLF
	JMP	prtNLF
	JMP	prtFF
	JMP	no$op
	JMP	prtBWD
	JMP	prtFWD

	DB	'KayPro custom   '
	db	'KP'

reset	DB	@esc,'S',@esc,@rs,9,0  ; printer: norm CPI, 6 LPI
CSIcmd	DB	@esc,@us,0	; set column spacing command
CSIoff	DB	1		; offset for spacing index
LSIcmd	DB	@esc,@rs,0	; set line spacing command
LSIoff	DB	1		; offset for spacing index
CR	DB	@cr,80H,0	; carriage-return, with delay
FF	DB	@ff,80H,0	; form-feed, with delay
LF	DB	@lf,80H,0	; line-feed, with delay
NLF	DB	@esc,@lf,80H,0	; negative line feed command
BWDcmd	DB	@esc,'6',0	; print backward command
FWDcmd	DB	@esc,'5',0	; print foreward command

prtCR:	LXI	D,CR
	jmp	prtmsg

prtNLF: LXI	D,NLF
	MOV	C,A
	LDA	L040E
	JMP	vert0

prtLF:	LXI	D,LF
	MOV	C,A
	LDA	L040D
vert0:	CMP	C
	JNC	vert1
	MOV	B,A
	PUSH	B
	MOV	C,B
	PUSH	D
	CALL	vert1
	POP	D
	POP	B
	MOV	A,C
	SUB	B
	MOV	C,A
	MOV	A,B
	JMP	vert0

vert1:	PUSH	D
	LDA	L0412
	CMP	C
	CNZ	setLSI
	POP	D
	jmp	prtmsg

setLSI: PUSH	B
	LXI	D,LSIcmd
	CALL	prtmsg
	POP	B
	MOV	A,C
	STA	L0412
	LDA	LSIoff
	ADD	C
	MOV	B,A
	jmp	prtchr

setCSI: PUSH	B
	LXI	D,CSIcmd
	CALL	prtmsg
	POP	B
	MOV	A,C
	STA	L0411
	LDA	CSIoff
	ADD	C
	MOV	B,A
	jmp	prtchr

prtFF:	LXI	D,FF
	jmp	prtmsg

init:	lda	iflag
	ora	a
	cz	istart
	call	prtCR	;clear backward print, in case.
	LXI	D,reset
	jmp	prtmsg

prtBWD: LXI	D,BWDcmd
	jmp	prtmsg

prtFWD: LXI	D,FWDcmd
	jmp	prtmsg

no$op:	RET

 if $ gt 500H
ds 'overflow into tables'
 endif

	org	500h
; table of widths for proportional wheel
proptbl:
	DB	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db	10, 6, 8,12,10,16,14, 4, 6, 6,10,10, 6, 8, 6, 8
	db	10,10,10,10,10,10,10,10,10,10, 6, 6,12,10,12,10
	db	16,14,12,14,14,12,12,14,14, 6,10,14,12,16,14,14
	db	12,14,14,10,12,14,12,16,14,14,12,10,10,10,10,10
	db	 6,10,10,10,10,10, 8,10,10, 6, 6,10, 6,16,10,10
	DB	10,10, 8, 8, 8,10,10,14,10,10,10, 6,10,10,10,10

; conversion table for proportional wheel
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	' !"#$%&''()*+,-./0123456789:;<=>?'
	db	'@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'
	db	'`abcdefghijklmnopqrstuvwxyz{|}~',7FH

 if $ gt 600H
ds 'overflow module'
 endif

@@ set $

	org	380h	;tail end of TERM module (hopefully not used)
iflag:	db	0
pflag:	db	0
tbladr: dw	0

istart: cma		;init, 1st call
	sta	iflag
	lhld	prtchr+1
	xchg
	lxi	h,prtch1
	shld	prtchr+1
	xchg
	lxi	b,patch0
	mov	a,m
	mvi	m,(JMP)
	stax	d
	inx	h
	inx	d
	mov	a,m
	mov	m,c
	stax	d
	inx	h
	inx	d
	mov	a,m
	mov	m,b
	stax	d
	inx	h
	shld	patch+1
	ret

prtch1: NOP ! NOP ! NOP
patch:	jmp	$-$

patch0:
	lda	pflag
	ora	a
	jnz	propfill
	mov	a,b
	cpi	0f0h
	jnz	prtch1
	lxi	h,proptbl
	shld	tbladr
	mvi	a,128
	sta	pflag
	ret

propfill:
	lhld	tbladr
	mov	m,b
	inx	h
	shld	tbladr
	lda	pflag
	dcr	a
	sta	pflag
	ret

 if $ gt 400H
ds 'overflow patch'
 endif

	org @@
	end

