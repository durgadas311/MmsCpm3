; July 12, 1984 07:44 drm
;
; Format display dependent routines
;
; Link commmand: LINK FORMAT=FMTMAIN,FMTZ89, or FMT500,FMTDISP,FMTTBL[NC,NR]
;  Note: FMTMAIN must be linked first and FMTTBL last.
;

	public	putchr,getchr,putlne,getlne
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
;	Turns on cursor
;
curact:
	exx
	exaf
	lxi	d,con
	call	putlne
	exx
	exaf
	ret

con:	db	esc,'y5$'

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

coff: db	esc,'x5$'

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

cls:	db	esc,'E$'

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

ceop:	db	esc,'J$'

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

ceol:	db	esc,'K$'

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

putlne:	mvi	c,msgout
	call	bdos
	ret

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

cursor:	push	d
	lxi	d,'  '
	dad	d
	pop	d
	mvi	a,esc
	call	putchr
	mvi	a,'Y'
	call	putchr
	mov	a,l
	call	putchr
	mov	a,h
	jmp	putchr

putchr:	push	h
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

	end
