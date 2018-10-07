;vers equ '0d' ; December 13, 1983  12:14  drm  "RDTRK.ASM"

;****  Program to display a track from a disk on the H37 	****
;****  Diskette may be any density,size,tpi,side 		****
;	    * Copyright (C) 1983 Magnolia Microsystems *

	maclib	z80

cpm	EQU	0
bdos	EQU	5
fcb	EQU	5CH
defdma	EQU	80H
int4	equ	4*8

conio	equ	6	;direct console I/O

ctrlc	equ	3
bel	equ	7
lf	equ	10
cr	equ	13
esc	equ	27

CRUP	equ	'A'+128
CRDN	equ	'B'+128
HOME	equ	'H'+128
RED	equ	'Q'+128
f1	equ	'S'+128
f2	equ	'T'+128
f3	equ	'U'+128
f4	equ	'V'+128
f5	equ	'W'+128

; H37 port assignments
port	equ	78h

fdcstat equ	port+2	; mux=0
fdccomd equ	port+2	; mux=0
fdcdata equ	port+3	; mux=0
fdcsect equ	port+2	; mux=1
fdctrak equ	port+3	; mux=1
fdcctl	equ	port+0
fdcmux	equ	port+1

INTRQEN	equ	00000001b
DRQEN	equ	00000010b
DDEN	equ	00000100b
MOTOR	equ	00001000b
DS0	equ	00010000b
DS1	equ	00100000b
DS2	equ	01000000b
DS3	equ	10000000b

	ORG	100H
	JMP	START

inits:
 db ESC,'E',ESC,'x6',ESC,'x5'
 db ESC,'Y, '
 db 'push "-" = shift left one bit           ----- RDTRK v3.2'
 db '0 '
 db							      ' -----',cr,lf
 db '     "+" = shift right one bit          READING Drive 29   5.25"',cr,lf
 db '     "L" = roll left one byte             MFM   Track 00  Side 0',cr,lf
 db '     "R" = roll right one byte',cr,lf
 db '    HOME = beginning of buffer        [shift] = end of buffer',cr,lf
 db '   <RED> = read a track',cr,lf
 db '    <UP> = shift up one line          [shift] = up one page',cr,lf
 db '  <DOWN> = shift down one line        [shift] = down one page',cr,lf
 db '     f1  = toggle recording density       f2  = toggle side',cr,lf
 db '     f3  = increment track                f4  = decrement track',cr,lf
 db '     f5  = advance drive number',cr,lf
 db 0

setdd	db	ESC,'Y.J','MFM',0
setsd	db	ESC,'Y.J',' FM',0
setrk	db	ESC,'Y.V',0
setss	db	ESC,'Y._',0
set5	db	ESC,'Y-[','5.25',0
set8	db	ESC,'Y-[','   8',0
setpd	db	ESC,'Y-V',0

sethex	db	esc,'H',0

xitmsg: db	ESC,'E',ESC,'y6',ESC,'y5',0

bitr	db	ESC,'Y*Z','Bit: ',0
errm	db	ESC,'Y* ','Error: ',bel,0
nodisk	db	'Drive not ready.',0
clrerr	db	ESC,'Y* ','                        ',0

;** Return 8 bits from memory starting at address POINTER bit BITTER
get$bits:
	MVI	C,8	;give only 8 bits
	LHLD	pointer ;point to buffer
	LDA	bitter	;test number of bits left in current byte
	MOV	B,A
	MVI	A,0	;start with 0 then shift bits in.
	mov	e,m
	mvi	a,8
	sub	b
	inr	a
xb0	dcr	a
	jz	xb1
	rlcr	e
	jmp	xb0
xb1	xra	a
bit0	RLCR	e	;put bit into carry
	RAL		;put from carry into (A)
	DCR	B	;count a bit taken from this byte
	Jnz	bit1	;get another byte if at end of this byte
	mvi	b,8
	inx	h
	mov	e,m
bit1	DCR	C	;count a bit from requested number
	JNZ	bit0	;loop if we need more
savret	PUSH	PSW	;else save (A)
	MOV	A,B
	STA	bitter	;store number of bits left in current byte
	SHLD	pointer ;store buffer pointer
	POP	PSW	;restore retrieved bits
	ORA	A	;reset carry (for sure)
	RET	;return bits

binout	push	b
	mvi	c,8
bo0	rlc
	call	dbit
	dcr	c
	jnz	bo0
	pop	b
	ret
dbit	push	psw
	ani	1
	ori	'0'
	call	chrout
	pop	psw
	ret

; 2-digit number output
centout: mvi	b,1
	mov	l,a
	mvi	h,0
	cpi	99
	jc	dig2
	mvi	l,99
	jmp	dig2
decout:
	MVI	B,0	;FOR LEADING-ZERO BLANKING
	LXI	D,10000
	CALL	decdig
	LXI	D,1000
	CALL	decdig
	LXI	D,100
	CALL	decdig
dig2:	LXI	D,10
	CALL	decdig
	MOV	A,L
	JR	dec

decdig	MVI	C,0
declp	INR	C
	ORA	A
	DSBC	D
	JNC	declp
	DAD	D
	DCR	C
	JNZ	notz
	BIT	0,B	;TEST LEADING-ZERO BLANK BIT
	jz	space
notz	SETB	0,B
	MOV	A,C
dec	ORI	'0'
	jmp	chrout


hexout	PUSH	PSW	;display (A) in HEX
	RLC
	RLC
	RLC
	RLC	;put HI digit in LO position
	CALL	nible	;print LO digit in HEX
	POP	PSW	;restore LO digit
nible	ANI	0FH	;isolate LO digit
	ADI	90H	;algorithm to convert digit to ASCII
	DAA
	ACI	40H
	DAA	;(A) = ASCII hex digit

chrout	PUSH	B	;send (A) to console
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,conio
	CALL	bdos
	POP	H
	POP	D
	POP	B
	XRA	A
	RET

msgout	ldax	d
	ora	a
	rz
	call	chrout
	inx	d
	jmp	msgout


space:	push	psw
	MVI	A,' '	;send an ASCII blank to console
	call	chrout
	pop	psw
	ret

crlf	MVI	A,cr	;send CR LF to console
	CALL	chrout
	MVI	A,lf
	JMP	chrout

chrin	push	h
	push	d
	push	b
	mvi	b,0
chri0	push b
	mvi	e,0ffh	;code for input
	mvi	c,conio
	call	bdos
	pop b
	ora	a
	jz	chri0	; wait for char recv
	cpi	ESC
	jnz	noesc
	mvi	b,80h
	jmp	chri0
noesc	cpi	'a'
	jc	noup
	cpi	'z'+1
	jnc	noup
	sui	'a'-'A'
noup	ora	b
	pop	b
	pop	d
	pop	h
	ret

disp:	lxi	d,setrk
	call	msgout
	lda	track
	call	centout
	lxi	d,setss
	call	msgout
	lda	side
	call	nible
	lxi	d,setpd
	call	msgout
	; h/w setup...
	lda	control
	; get drive number...
	call	centout
	lxi	d,set5
	call	msgout
	lda	control
	ani	DDEN
	lxi	d,setdd
	jnz	nosd
	lxi	d,setsd
nosd	call	msgout
	ret

nlin	equ	10	;number of lines to display
bpl	equ	24	;number of bytes on a line
pagsiz	equ	nlin*bpl

updhex	lxi	d,bitr
	call	msgout
	lda	bits
	call	nible
	lxi	d,sethex
	call	msgout
	call	setpt
	mvi	e,nlin	;number of lines.
hex1	push	d
	lhld	pointer
	lxi	d,-buffr
	dad	d
	call	decout
	mvi	a,':'
	call	chrout
	mvi	d,bpl	;number of bytes on a line
hex0	call	get$bits
	call	space
	call	hexout
	dcr	d
	jnz	hex0
	call	crlf
	pop	d
	dcr	e
	jnz	hex1
	ret

comnds:
	db	'L'
	dw	left
	db	'R'
	dw	right
	db	'+'
	dw	shft$right
	db	'-'
	dw	shft$left
	db	CRUP
	dw	upline
	db	CRDN
	dw	dnline
	db	HOME
	dw	settop
	db	'5'
	dw	setbot
	db	'2'
	dw	dnpage
	db	'8'
	dw	uppage
	db	f1
	dw	setden
	db	f2
	dw	setsid
	db	f3
	dw	settrk
	db	f4
	dw	baktrk
	db	f5
	dw	setdsk
	db	RED
	dw	readt
	db	ctrlc
	dw	exit
	db	0

start:
	LXI	SP,stack
	; get device driver information... or not?
	lxi	d,inits
	call	msgout
	mvi	a,DS0+MOTOR
	sta	control
	out	fdcctl
	xra	a
	sta	drive
	sta	side
	sta	track
	in	fdcstat	;reset 1797 from possible power-up.
	lxi	h,buffr
	lxi	d,buffr+1
	lxi	b,pagsiz-1
	mvi	m,0
	ldir
	xchg
	shld	bufsiz
	call	disp
settop: lxi	h,buffr
	shld	point
	MVI	A,8
	STA	bits
	call	updhex
command:
	lxi	sp,stack
	lxi	h,command
	push	h
ci0	call	chrin
	push	psw
	lxi	d,clrerr
	call	msgout
	pop	psw
	lxi	h,comnds
	mov	b,a
cl0	mov	a,m
	inx	h
	cmp	b
	jz	gotcom
	inx	h
	inx	h
	ora	a
	jnz	cl0
	mvi	a,bel
	call	chrout
	jmp	ci0
gotcom: mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

setbot: lhld	bufsiz
	lxi	d,-pagsiz
	dad	d
	shld	point
	mvi	a,8
	sta	bits
	jmp	updhex

shft$right:
	lda	bits
	inr	a
	sta	bits
	cpi	8+1
	jc	updhex
	mvi	a,1
	sta	bits
right:	lhld	point
	dcx	h
	shld	point
	jmp	chkup

shft$left:
	lda	bits
	dcr	a
	sta	bits
	jnz	updhex
	mvi	a,8
	sta	bits
left:	lhld	point
	inx	h
	jmp	chkdn

dnpage: lhld	point
	lxi	d,+pagsiz
	dad	d
	jmp	chkdn
dnline: lhld	point
	lxi	d,+bpl
	dad	d
chkdn	xchg
	lhld	bufsiz
	lxi	b,-pagsiz
	dad	b
	ora	a
	dsbc	d
	jc	setbot
	sded	point
	jmp	updhex

uppage: lhld	point
	lxi	d,-pagsiz
	dad	d
	jmp	chkup
upline: lhld	point
	lxi	d,-bpl
	dad	d
chkup	lxi	d,buffr
	xchg
	ora	a
	dsbc	d
	jz	upok
	jnc	settop
upok	sded	point
	jmp	updhex

setpt	lhld	point
	shld	pointer
	lda	bits
	sta	bitter
	ret

setden: lda	control
	xri	DDEN	;toggle dden bit
	sta	control
	out	fdcctl
	jmp	disp

setsid	lda	side
	xri	00000001b
	sta	side
	jmp	disp

settrk	lda	track
	inr	a
	cpi	100
	jnc	command
	sta	track
	jmp	disp

baktrk	lda	track
	dcr	a
	jm	command
	sta	track
	jmp	disp

setdsk: lda	drive
	inr	a
	ani	00000011b
	sta	drive
	mov	b,a
	mvi	a,DS0
	jz	sd1
sd0:	rlc
	djnz	sd0
sd1:
	mov	b,a
	lda	control
	ani	00001111b
	ora	b
	sta	control
	out	fdcctl
	jmp	disp

readt:	call	unload
	call	loadh
	call	chkrdy
	jc	nodsk
	call	recal
	call	seek
	call	rdtr
	shld	bufsiz
	mvi	m,0	;makes bit-shifts cleaner
	mov	b,a
	ani	10000111b	; NRDY, CRC, LOSTD, BUSY
	jz	settop
	lxi	d,errm
	call	msgout
	mov	a,b
	call	binout
	jmp	settop

nodsk:	lxi	d,errm
	call	msgout
	lxi	d,nodisk
	call	msgout
	jmp	settop

gettrk:	mvi	a,1
	out	fdcmux
	in	fdctrak
	push	psw
	xra	a
	out	fdcmux
	pop	psw
	ret

unload: call	gettrk
	out	fdcdata
	mvi	a,00010011b	;seek to current track & unload head.
	out	fdccomd
docom:
ul0	in	fdcstat
	rrc
	jnc	ul0
ul1	in	fdcstat
	rrc
	jc	ul1
	ret

loadh:	call	gettrk
	out	fdcdata
	mvi	a,00011011b
	out	fdccomd
	jr	docom

recal:	mvi	a,00001011b
	out	fdccomd
	jr	docom

seek:	lda	track
	out	fdcdata
	mvi	a,00011011b
	out	fdccomd
	jr	docom

intrq:
	in	fdcstat
	pop	h
	push	psw
	lda	control
	out	fdcctl
	lhld	sav4
	shld	int4
	lhld	sav4+2
	shld	int4+2
	pop	psw
	ei
	ret

rdtr:	; INTRQ returns to caller, with fdcstat in A
	di
	lhld	int4
	shld	sav4
	lhld	int4+2
	shld	sav4+2
	mvi	a,0C3H
	sta	int4
	lxi	h,intrq
	shld	int4
	lda	control
	ori	DRQEN+INTRQEN
	out	fdcctl
	lxi	h,buffr
	mvi	c,fdcdata
	lda	side
	rlc
	ori	11100000b	; read track
	out	fdccomd
	ei
rd0:	hlt
	ini
	jmp	rd0

chkrdy:
; test drive for ready.
	stc
	ret

exit:	lxi	d,xitmsg
	call	msgout
	xra	a
	out	fdcctl
	jmp	cpm

@eops:	db	0

point	DW	0
bits	DB	0

pointer DW	0	;buffer pointer
bitter	DW	0	;counter for bits left in byte

bufsiz	dw	0

control	db	0
drive	db	0
side	db	0
track	db	0

	DS	64
stack	DS	0

sav4:	ds	4

	db	0	;makes bit-shifts cleaner
buffr:	END
