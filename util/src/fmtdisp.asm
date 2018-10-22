; July 12, 1984 07:44 drm
;
; Format display dependent routines
;
; Link commmand: LINK FORMAT=FMTMAIN,FMTZ89, or FMT500,FMTDISP,FMTTBL[NC,NR]
;  Note: FMTMAIN must be linked first and FMTTBL last.
;

	public	putchr,getchr,putlne,getlne,termid,initial,deinit
	public	clrscr,clrend,clrlne,curact,curoff,cursor,prtmsg

	MACLIB Z80
	$-MACRO

false	equ	000h
true	equ	0FFh
ff	equ	0ffh

base	equ	0
cpm	equ	base
bdos	equ	base+5
dma	equ	base+80H

const	equ	2		; BIOS function numbers
bconin	equ	3
conout	equ	4
home	equ	8
seldsk	equ	9
settrk	equ	10
setsec	equ	11
setdma	equ	12
reads	equ	13
writes	equ	14
sectrn	equ	16
search	equ	90	      

conin	equ	1		; BDOS function number
conot	equ	2
msgout	equ	9
linein	equ	10
getver	equ	12	
open	equ	15
close	equ	16
read	equ	20
stdma	equ	26
getdsk	equ	25
restt	equ	37
seterr	equ	45
cbios	equ	50
sdirlab equ	100
setcmod equ	109

ctrlC	equ	3
esc	equ	27
cr	equ	13
lf	equ	10
bell	equ	7
bs	equ	8

;
; Initialize Terminal-dependant stuff
;
initial:
	exx
	exaf
	lxi	d,termfcb
	mvi	c,open
	call	bdos
	cpi	255
	jz	notcb
	lxi	d,termctrl
	mvi	c,stdma
	call	bdos
	lxi	d,termfcb
	mvi	c,read
	call	bdos
	ora	a
	jnz	badtcb
	lxi	d,termctrl+128
	mvi	c,stdma
	call	bdos
	lxi	d,termfcb
	mvi	c,read
	call	bdos
	ora	a
	jnz	badtcb
	lxi	d,termctrl+128+128
	mvi	c,stdma
	call	bdos
	lxi	d,termfcb
	mvi	c,read
	call	bdos
	ora	a
	jnz	badtcb
	lxi	d,tinit
	call	putlne
	exaf
	exx
	ret

termfcb: db	1,'TERMINALSYS',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0,0,0,0

notcb:	lxi	d,ntcb
	jmp	tcberr
badtcb: lxi	d,btcb
tcberr: call	putlne
	jmp	cpm

ntcb:	db	cr,lf,'Terminal control file not on drive A:',0
btcb:	db	cr,lf,'Terminal control file incomplete',0

deinit: push	d
	lxi	d,tdeinit
	call	putlne
	pop	d
	ret

termid: push	d
	lxi	d,id
	call	putlne
	pop	d
	ret

;
;	Turns on cursor
;

curact: exx
	exaf
	lxi	d,con
	call	putlne
	exx
	exaf
	ret

;
;	Turns the cursor off
;

curoff: exx
	exaf
	lxi	d,coff
	call	putlne
	exx
	exaf
	ret

;
;	Clears screen
;

clrscr: exx
	exaf
	lxi	d,cls
	call	putlne
	exx
	exaf
	ret

;
;	Clears to end of screen
;

clrend: exx
	exaf
	lxi	d,ceop
	call	putlne
	exx
	exaf
	ret

;
;	Clears to end of line
;

clrlne: exx
	exaf
	lxi	d,ceol
	call	putlne
	exx
	exaf
	ret

;
;	Positions cursor in H and L and prints the string pointed by DE
;

prtmsg: 
	call	cursor
	call	putlne
	ret

;
;	Prints the string pointed to by DE
;

putlne:
	ldax	d
	cpi	'$'
	rz
	ora	a
	rz
	inx	d
	jp	pl0
	ani	01111111b
	jz	putlne
	mov	b,a
pl1:	xra	a
	call	putchr
	dcr	b
	jnz	pl1
	jmp	putlne
pl0:	call	putchr
	jmp	putlne

;
;	Gets a line from console - puts in buffer pointed to by DE
;

getlne:
	ldax	d   
	mov	b,a	 ; get mx in b
	inx	d
	push	d	 ; put address of char cnt in HL
	pop	h
	mvi	m,0
	inx	d
getlne1:push	h
	push	d
	push	b
	mvi	a,bconin
	call	biosc
	pop	b
	pop	d
	pop	h
	cpi	bs
	jnz	getlne2 	;jump if not bs
	mov	a,m		
	ora	a
	jz	getlne1
	dcx	d
	inr	b
	dcr	m
	mvi	a,bs
	call	putchr
	mvi	a,' '
	call	putchr
	mvi	a,bs
	call	putchr
	jmp	getlne1
getlne2:
	cpi	cr		; exit if cr
	jz	getlne5
	cpi	ctrlC		; test for ctrl-C
	jnz	getlne3
	mov	a,m		; see if first character
	ora	a
	jnz	getlne1
	mvi	a,ctrlC
	stax	d		; put ^C in buffer
	inr	m
	jmp	getlne5 	; exit if 1st char
getlne3:
	cpi	' '		; don't allow control characters in buffer
	jc	getlne1
	dcr	b		; see if line is full
	jnz	getlne4
	inr	b
	mvi	a,bell
	call	putchr
	jmp	getlne1
getlne4:
	stax	d
	inx	d
	inr	m
	call	putchr
	jmp	getlne1
getlne5:
	ret

;
;	Positions the cursor to the column in H and the line in L
;

cursor: push	d
	push	b
	lxi	d,cpos
cloop:	ldax	d
	inx	d
	ora	a
	jz	cxit
	cpi	80h
	jc	cnrm
	cpi	82h
	jnc	cr0	;send nulls to terminal
	ani	1
	ldax	d
	inx	d
	jz	clne
	mov	c,h	;column
	jmp	ccol
clne:	mov	c,l
ccol:	cpi	0ffh	;ansi?
	jz	cansi
	add	c
cnrm:	call	putchr
	jmp	cloop

cr0:	ani	01111111b
	mov	b,a
cr1:	xra	a
	call	putchr
	dcr	b
	jnz	cr1
	jmp	cloop

cansi:	mov	a,c
	mvi	b,0
	inr	a	;ANSI uses 1-n, 0 same as 1.
ca0:	sui	100
	inr	b
	jnc	ca0
	adi	100
	dcr	b
	jz	ca1
	mov	c,a
	mov	a,b
	adi	'0'
	call	putchr
	mov	a,c
ca1:	mvi	c,0
ca3:	sui	10
	inr	c
	jnc	ca3
	adi	10
	dcr	c
	jnz	ca4
	dcr	b
	jm	ca5
ca4:	mov	b,a
	mov	a,c
	adi	'0'
	call	putchr
	mov	a,b
ca5:	adi	'0'
	jmp	cnrm

cxit:	pop	b
	pop	d
	ret

;
;	Outputs a character in A register to the console
;

putchr: push	h
	push	d
	push	b
	pushix
	mov	c,a
	mvi	a,conout
	call	biosc
	popix
	pop	b
	pop	d
	pop	h
	ret

;
;	Inputs a character from the console into A reg
;

getchr: push	h
	push	d
	push	b
	pushix
	mvi	c,conin
	call	bdos
	popix
	pop	b
	pop	d
	pop	h
	ret

;
;	Call BIOS through BDOS
;

biosc:				; setup BIOS parameter block
	sta	biospb		; BIOS function number
	sbcd	biospb+2	; BC register
	sded	biospb+4	; DE register
	shld	biospb+6	; HL register
	mvi	c,cbios
	lxi	d,biospb	; call BIOS through BDOS
	jmp	bdos

biospb: db	0,0
	dw	0,0,0

termctrl:
id:	ds	12
cls:	ds	8
chome:	ds	8
left:	ds	8
right:	ds	8
up:	ds	8
down:	ds	8
ceop:	ds	8
ceol:	ds	8
revvid: ds	8
nrmvid: ds	8
coff:	ds	8
con:	ds	8
cpos:	ds	12
tinit:	ds	12
tdeinit:ds	12
	ds	28
khome:	ds	4
kleft:	ds	4
kright: ds	4
kup:	ds	4
kdown:	ds	4
f1:	ds	4
f2:	ds	4
f3:	ds	4
f4:	ds	4
f5:	ds	4
f6:	ds	4
f7:	ds	4
f8:	ds	4
f9:	ds	4
f10:	ds	4
f11:	ds	4
f12:	ds	4
f1name: ds	12
f2name: ds	12
f3name: ds	12
f4name: ds	12
f5name: ds	12
f6name: ds	12
f7name: ds	12
f8name: ds	12
f9name: ds	12
f10name:ds	12
f11name:ds	12
f12name:ds	12 -1
	db	0

	end
