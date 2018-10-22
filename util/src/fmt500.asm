;
; Hardware dependent routines for 77500
;
; April 5, 1984  8:10 mjm
;
; Link command: LINK FORMAT=FMTMAIN,FMT500,FMTDISP,FMTTBL[NC,NR]
;

	MACLIB	Z80
	$-MACRO

	public	setjmp,inithd,intoff,inton,str
	public	ctrlio,comnd,writt,rdcom,dskxit,getst
	public	restor,stepin,writrk,rdadr

	extrn	phydrv,sid,trk,mfm,stepr,modes,buffer,wdflag,vsectb,curmdl

false	equ	0
true	equ	not false

base	equ	0
cpm	equ	base
bdos	equ	base+5
dma	equ	base+80h
reta	equ	base+26h	; return address poke for Z37 intrq
pass	equ	base+3Eh	; LOCATION WHERE "DISK$CTLR" ADDRESS IS PASSED
msgout	equ	9
@intby	equ	100

; error codes

initerrcd	equ	0
setlabcd	equ	1
wrtprocd	equ	2
notrdycd	equ	3
hrdsectcd	equ	4
z17sftcd	equ	5
notsupcd	equ	6
badportcd	equ	7 
dterrcd 	equ	8
trk0ercd	equ	9 
dserrcd 	equ	10
drverrcd	equ	11
wterrcd 	equ	12
wmerrcd 	equ	13

; Ports and Constants
dmachip equ	000h	;AMD 9517
sti1	equ	010h	;MK3801 #1
sti2	equ	020h	;MK3801 #2
rtc	equ	030h	;real-time clock
fdc	equ	038h	;floppy disk controller
mmu	equ	040h	;memory management
fdcctl	equ	07fh	;floppy disk control bits

*********************************************************
**  Memory control ports definitions
*********************************************************
dma2	equ	mmu+3	;floppy disk channel

*********************************************************
**	AMD 9517 equates
*********************************************************
ch2ba	equ	dmachip+4	;channel 2 base address
ch2wc	equ	dmachip+5	;channel 2 word count

dmacomd equ	dmachip+8	;command port
comd	equ	01010000b	;DACK/DREQ act.lo, Norm timing, late write,

dmastat equ	dmachip+8	;status port
dreq	equ	dmachip+9	;software data requests

mask	equ	dmachip+10	;individual channel mask bit access
dis	equ	100b	;disable DMA (set mask)

mode	equ	dmachip+11	;individual channel mode bit access
clrBP	equ	dmachip+12	;clear Byte Pointer flip-flop

*********************************************************
**  STI (MK3801 Serial-Timer-Interupt)
*********************************************************
STI1IDR equ	STI1+0
STI1GPI equ	STI1+1
STI1IPB equ	STI1+2
STI1IPA equ	STI1+3
STI1ISB equ	STI1+4
STI1ISA equ	STI1+5
STI1IMB equ	STI1+6
STI1IMA equ	STI1+7
STI1PVR equ	STI1+8
STI1CAB equ	STI1+9
STI1TBD equ	STI1+10
STI1TAD equ	STI1+11
STI1UCR equ	STI1+12
STI1RSR equ	STI1+13
STI1TSR equ	STI1+14
STI1UDR equ	STI1+15

STISCR	equ	0
STITDD	equ	1
STITCD	equ	2
STIAER	equ	3
STIIEB	equ	4
STIIEA	equ	5
STIDDR	equ	6
STICCD	equ	7

*********************************************************
**  RTC (MC146818 Real-Time Clock)
*********************************************************
RTCDRD	equ	RTC+2
RTCDWR	equ	RTC+1
RTCADR	equ	RTC+3

RTCRAM	equ	14

dsk$ctrl	equ	rtcram+1	;FDC control port image
memtbl		equ	rtcram+2	;MMU image (8 bytes)

*********************************************************
**  FDC (WD1797-02 Floppy Disk Controller)
*********************************************************
FDCSTAT equ	FDC+0
FDCCOMD equ	FDC+0
FDCTRK	equ	FDC+1
FDCSEC	equ	FDC+2
FDCDATA equ	FDC+3

;
;	Machine type string, put in sign-on message
;

str:	db	'77500$'

;
;	setup jumps for type of controller - M316, Z37, etc.
;	Called only once at the start of format.
;	returns: [CY] if invalid phydrv
  
setjmp:
	mvi	a,true
	sta	wdflag
	lda	phydrv
	cpi	29
	jc	zrcy
	cpi	29+8
	jnc	zrcy
	lxi	h,m77500
	lxi	d,ctrlio
	lxi	b,numall
	ldir
	lhld	curmdl	; gets the motor$off byte address
	dcx	h	;
	mov	a,m	;number of devices
	add a ! add a ! add a	; *8
	mov	c,a	;
	mvi	b,0	;
	lxi	d,17	;
	dad	d	;modtbl
	mov	e,m	;
	inx	h	;
	mov	d,m	;
	xchg		;
	dad	b	;points to next byte after modtbl
	shld	mtoffa	;
	xra	a
	ret

zrcy:	mvi	a,drverrcd
	stc
	ret

;
;	This routines initializes variables that need to be done for 
;	every disk that is formated.  It is called before each disk
;	is formated.
;

inithd:
	ret

;
;	These routines turn off and on the serial port interrupts
;

intoff: 
	ret

inton:
	ret

;
;	The machine dependent routines' jump vector. Setup in setjmp.
;

ctrlio: 	jmp	$-$
comnd:		jmp	$-$
writt:		jmp	$-$
rdcom:		jmp	$-$
dskxit: 	jmp	$-$
getst:		jmp	$-$
numio	equ	$-ctrlio
restor: 	jmp	$-$
stepin: 	jmp	$-$
writrk: 	jmp	$-$
rdadr:		jmp	$-$
numall	equ	$-ctrlio

m77500: jmp	mmsset
	jmp	mmscom
	jmp	mmswrt
	jmp	mmsrdc
	jmp	m500axit
	jmp	m500stat
	jmp	wd$home
	jmp	wd$stepin
	jmp	wd$writt
	jmp	wd$rdadr


;	     H L D E x x
rdadrbuf: db 0,0,0,0,0,0

mmsrdc: lxi	h,rdadrbuf
	lxi	d,6-1
	call	mw0
	ani	10011111b
	rnz
	lxi	h,rdadrbuf
	mov	b,m 
	inx	h
	mov	c,m
	inx	h
	mov	d,m
	inx	h
	mov	e,m
	mov	l,c
	mov	h,b
	ret

mmswrt: 	;HL=buffer pointer
	lxi	d,-1	;max transfer: 65536 bytes
mw0:	mov	b,a		;write track: 111100x0
	ani	00100000b	; 1 if write
	rrc! rrc! rrc		;
	adi	010001$10b	; 010001$10 if read, 010010$10 if write
	out	mode		; (wr mem, rd I/O)   (rd mem, wr I/O)
	mvi	a,memtbl+(dma2-mmu)
	out	rtcadr
	mvi	a,1	;CP/M 3 TPA is bank 1, the bank we're in now.
	out	rtcdwr
	out	dma2
	out	clrbp
	mvi	c,ch2ba
	outp	l
	outp	h
	inr	c	;ch2wc
	outp	e
	outp	d
	mvi	a,2
	out	mask
	mov	a,b
	out	fdccomd
rd0:	in	fdcstat
	rrc
	jrnc	rd0
rd1:	in	fdcstat
	rrc
	jrc	rd1
	rlc
	ora	a	;reset carry
	push	psw
	mvi	a,2
	call	?stmsk
	out	clrbp
	mvi	c,ch2ba
	inp	l
	inp	h
	mvi	a,11010000b	;reset 1797 to TYPE$I status
	out	fdccomd 	;
	in	fdcstat 	;
	pop	psw
	ret

?stmsk: ori	100b
	mov	d,a
	lxi	b,(dmacomd)+(comd)*256
	mvi	a,comd+100b
	di	;--------------------------
	out	dmacomd
	mov	a,d
	out	mask
	outp	b
	ei	;--------------------------
	ret

mms$set:
	push	h
	push	b
	push	psw
	mvi	a,dsk$ctrl
	out	rtcadr
	LDA	phydrv		; get the RELATIVE drive number
	sui	29
	MOV	C,A		; relative drive number in (C) (rel. to driv0)
	ani	00000011b	;isolate significant drive select bits
	lhld	mfm
	inr	l
	dcr	l	;single density ?
	jrnz	se1
	ori	00100000b	;select single density data rate.
se1:	bit	2,c	; 5" ?
	jrz	se0
	ori	00011000b	; 34 pin cable, 5" data rates
se0:	ori	01000000b	; motor on
	out	rtcdwr
	out	fdcctl
	lhld	mtoffa
	mvi	m,0ffh	;stop any pending motor-off
	pop	psw
	pop	b
	pop	h
	ret

m500axit:
	mvi	a,dsk$ctrl
	out	rtcadr
	in	rtcdrd
	ani	10111111b
	out	rtcdwr
	out	fdcctl
	ret

mms$com:
	mov	b,a
	mvi	a,dsk$ctrl
	out	rtcadr
	in	rtcdrd
	ori	01000000b
	out	rtcdwr
	out	fdcctl
	mov	a,b
	di
	out	fdccomd
mc0:	in	fdcstat
	rar
	jrnc	mc0
	ei
mc1:	in	fdcstat
	rar
	jrc	mc1
	in	fdcstat
	ret

m500stat:			; test drive for ready.
	in	sti1pvr
	ori	sticcd		; indirect register 7, timer C,D control
	out	sti1pvr
	in	sti1idr
	mov	b,a
	ani	11111000b	;timer D stopped.
	out	sti1idr
	in	sti1cab
	mov	c,a
	ani	0000$1111b
	out	sti1cab 	;timer A stopped.
fb8:	mvi	a,5
	out	sti1tad 	;5 seconds
; Temp fix for MK3801 STI rev G bug
	in	sti1tad
	cpi	5
	jrnz	fb8
;----------------------------------
	mvi	a,11011111b
	out	sti1ipa
	mov	a,c
	out	sti1cab 	;timer A start.
	mov	a,b
	out	sti1idr 	;timer D start.
	mvi	a,dsk$ctrl
	out	rtcadr
	in	rtcdrd
	bit	4,a		;8"/5.25"
	jrnz	fb1
;This is done to reset the side select bit before a drive ready test
	ori	00001000b	;set 34/50 to 34 pin cable (to force a ready
	out	fdcctl		; signal to the WD1797 on 8") temporarly
	mvi	a,1100$0000b	;do read address to clear side select
	out	fdccomd
	mvi	b,10		;wait 20us = (8mc * 10)/4mhz
wa1:	djnz	wa1
	mvi	a,1101$0000b	;terminate read address
	out	fdccomd 
	in	fdcdata
nbsy:	in	fdcstat 	;wait for not busy
	ani	0000$0001b
	jnz	nbsy
	mvi	a,1101$0000b	;terminate to set type$I status
	out	fdccomd 
	in	fdcdata
	in	fdcstat
	mvi	a,dsk$ctrl	;get old control byte
	out	rtcadr
	in	rtcdrd
	out	fdcctl		;restore control port
;--------------------------------------------------------------
fb2:	in	fdcstat 	;8" ready test
	ora	a	;test HI bit.
	rp
	in	sti1ipa
	ani	00100000b
	jrz	fb2
	in	fdcstat 	;drive not ready after 5 sec
	ret

fb1:	mvi	a,11110111b	;5" ready test; reset INDEX sense
	out	sti1ipb
fb4:	in	sti1ipb 	;look for INDEX leading edge
	ani	00001000b
	jrnz	fb5
	in	sti1ipa 	;allow for timeout if no INDEX
	ani	00100000b
	jrz	fb4
	in	fdcstat
	ori	10000000b	;set not-ready
	ret
fb5:	mvi	a,11110111b
	out	sti1ipb 	;reset INDEX sense
	mvi	a,11111110b
	out	sti1ipa 	;reset timer B count-out
	mvi	a,0
	out	sti1tbd
fb6:	in	sti1ipb
	ani	00001000b
	jrnz	fb7
	in	sti1ipa
	bit	0,a		;counter overflow?
	jrnz	fb1
	ani	00100000b
	jrz	fb6
	in	fdcstat
	ori	10000000b	;set not-ready
	ret
fb7:	in	sti1tbd
	neg
	sui	194	;194-206 milliseconds per revolution
	cpi	12
	jrnc	fb5
	in	fdcstat
	ret


mtoffa: dw	0

********************* END Hardware Dependent Code ***********************

WD$HOME:
	MVI	B,6		;6 STEP-IN'S FIRST
RESTLP: PUSH	B		;SAVE COUNTER
	CALL	STEP$IN
	POP	B
	DJNZ	RESTLP
	LDA	STEPR
	ORI	00001000B	; RESTORE command + steprate
	JMP	COMND

WD$STEPIN:			; issue a step command with direction set to IN
	LDA	STEPR
	ORI	01011000B	; STEP-IN command + steprate
	JMP	COMND		; do as restore command

WD$WRITT:			; write track for 8" SD and 5" DD
	LDA	SID		; side number
	ANI	00000001B
	RLC
	ORI	11110000B	; write track command + side bit
	JMP	WRITT

WD$RDADR:
	MOV	C,A
	MVI	B,10		; retry counter
RA0:	PUSH	B
	MOV	A,C
	ANI	1		; side number
	RLC
	ORI	11000000B	; read-address command
	CALL	RDCOM		; L register contains side number read
	POP	B
	BIT	4,A		; rnf
	JNZ	RA2
	BIT	3,A		; crc
	JZ	RA1
	DCR	B		; retry on crc error
	JNZ	RA0
RA2:	XRA	A		; sets [ZR]
	STC			; set status of [CY]
	RET
RA1:	MOV	A,C		; get side number
	CMP	l		; compare to side from disk
	RET			; [NZ] if side numbers don't match

