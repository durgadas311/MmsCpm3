VERS equ '0e' ; January 17, 1983  12:51  drm  "OSZ89.ASM"

	maclib	Z80

;*****************************************************
;**** BDOS interface, BIOS entry, and DMA	 *****
;**** handler for CP/M-422, Z89 resident code.	 *****
;****  Copyright (C) 1983 Magnolia microsystems  *****
;*****************************************************

false	equ	0
true	equ	not false

CPM	equ	0	;warmboot entry for users
BDOS	equ	5	;BDOS entry for users
RST1	equ	(1)*8
clk	equ	RST1+3
ictl	equ	RST1+5
FCB	equ	5CH
DMA	equ	80H
TPA	equ	0100H

KHz	equ	2048	;clock speed in KiloHertz

cr	equ	13
lf	equ	10
;********************************************************
;*  I/O port base addresses
;********************************************************
;m422	equ	078h
port	equ	0f2h

;********************************************************
;*   77422 board ports
;********************************************************
;dat422  equ	 m422	 ;input/output
;intoff  equ	 m422+1  ;output only
;nmi	 equ	 m422+2  ;output only
;tick	 equ	 m422+3  ;output only
;sta422  equ	 m422+1  ;input only


	cseg
	org	0
BDOS$1:
CCPl:	dw	0	;replaced by serial number after start-up
CCPa:	dw	0
	dw	colds	;cold start address

@BDOS:	JMP	0	;address filled at start-up.

	dw	0	;for compatability only, not functional
	dw	0
	dw	0
	dw	0

FUNTAB: dw	wstart	;go directly to local warm-boot
	dw	putget	;read console, swap memory and go...
	dw	do	;write console, ...
	dw	putget	;read reader, ...
	dw	do	;write punch, ...
	dw	do	;write list, ...
	dw	dcio	;direct console I/O
	dw	putget	;get iobyte
	dw	do	;set iobyte
	dw	bufout	;buffered console output, special processing
	dw	bufin	;beffered console input, special processing
	dw	putget	;console input status

	dw	putget	;return version
	dw	do	;reset disk system
	dw	do	;select drive
	dw	pgF33	;open file, put and get FCB
	dw	pFCB	;close file, put FCB, get only error code
	dw	pFgD	;search first, put FCB and get DMA (+error code)
	dw	DMAgo	;search next, get DMA
	dw	pFCB	;delete file, put FCB and get only error code
	dw	pFgFD	;read sequential, put FCB, get DMA+FCB
	dw	pFDgF	;write sequential, put FCB+DMA, get FCB
	dw	pgF33	;make file entry
	dw	pFCB	;rename file
	dw	putget	;return login vector
	dw	putget	;return current drive
	dw	sdma	;set dma address (for local use only)
	dw	alloc	;return alloc vector address (actual alloc vector)
	dw	do	;write protect drive
	dw	putget	;get R/O vector
	dw	pFCB	;set file attributes
	dw	gDPB	;get DPB address (actual DPB)
	dw	putget	;set/get user number
	dw	pFgFD	;read random
	dw	pFDgF	;write random
	dw	pgFCB	;compute file size
	dw	pgFCB	;set random record number
	dw	do	;reset individual drives
	dw	go	;no function
	dw	go	;no function
	dw	pFDgF	;write random, zero fill
NFUNCS equ ($-FUNTAB)/2

bdosf:	lxi	h,0	;execute a BDOS function
	shld	retin
	lda	func
	cpi	0E0H	;77422 is instructing us to load a COM file and run...
	jz	ldngo
	cpi	NFUNCS
	rnc
	mov	c,a
	mvi	b,0
	lxi	h,FUNTAB
	dad	b
	dad	b
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

dcio:	lda	info
	rlc	;is bit 7 a "1" ?
	jrnc	do	;output, don't return any info
	jr	putget	;input/status, must return data

bufout: lxi	h,TPA
	lbcd	info	;normally this is the message address but we changed
	call	get422	;the rules. now its the message length.
	lxi	d,TPA
	mvi	c,9
	jmp	BDOS

bufin:	lda	info
	lxi	h,TPA
	mov	m,a
	inx	h
	mvi	m,0
	lxi	d,TPA
	mvi	c,10
	call	BDOS
	lxi	h,TPA+1
	mov	l,m
	mvi	h,0
	inx	h
	shld	retin
	call	put
	lxi	h,TPA+1
	lbcd	retin
	jmp	put422

getDMA: lxi	h,DMA	;
	lxi	b,128
	jmp	get422

getFCB: lxi	b,36
	lxi	h,FCB
	shld	info
	jmp	get422

putF33: lxi	b,33
	jr	pf0

putFCB: lxi	b,36
pf0:	lxi	h,FCB
	jmp	put422

do:	lded	info
	lda	func
	mov	c,a
	call	BDOS
	shld	retin
	ret

putget: call	do
	jmp	put

pgF33:	call	pFCB
	jr	putF33

pgFCB:	call	pFCB
	jr	putFCB

pFCB:	call	getFCB
	jr	putget

pFgD:	call	pFCB
putDMA: lxi	h,DMA
	lxi	b,128
	jmp	put422

pFgFD:	call	pgF33
	lda	retin
	ora	a
	rnz
	jmp	putDMA

pFDgF:	call	getFCB
	call	getDMA
	call	putget
	jr	putF33

DMAgo:	call	putget
	jmp	putDMA

gDPB:	call	do
	lhld	retin
	lxi	b,21
	jmp	put422

sdma:
alloc:
go:	ret

ldngo:	lxi	sp,stack
	lda	info	;default disk and user #
	sta	4
	lxi	h,50H
	lxi	b,(100H-50H)
	call	get422
	lxi	h,50H	;COM file FCB to load.
	lxi	d,comfcb
	lxi	b,12
	ldir
	mov	l,e
	mov	h,d
	inx	d
	mvi	m,0
	lxi	b,21-1
	ldir		;fill rest of FCB with 00
	lxi	h,rstart	;return point
	push	h
	lxi	d,comfcb
	mvi	c,15	;open file
	call	bdos
	cpi	255	;this error should have already been checked.
	rz
	lxi	d,TPA
lg0:	lxi	h,128
	dad	d
	shld	loada
	lxi	b,BDOS$1
	ora	a
	dsbc	b
	rnc		;program might overrun system...
	mvi	c,26	;set DMA address
	call	bdos
	lxi	d,comfcb
	mvi	c,20	;read sequential
	call	bdos
	ora	a
	lded	loada
	jz	lg0
	lxi	d,DMA
	mvi	c,26	;set DMA address
	call	bdos
	call	crlf
	jmp	TPA	;start user's program

loada:	dw	0

comfcb: db	0,'command COM',0,0,0,0
	dw	0,0,0,0,0,0,0,0
	db	0,0,0,0

	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack:	ds	0

signon: db	cr,lf,'OSZ89 v2.29'
	dw	VERS
	db	'$'

;The Cold Start routine
colds:	lxi	sp,stack
	mov	a,c	;a gift from the loader:
	sta	porta	;the port base address of the 77422 board.
	lxi	d,signon
	mvi	c,9	;type message on console
	call	bdos
	lxi	d,wstart
	lhld	CPM+1
	shld	@BIOSa
	dcx	h
	mov	m,d	;fill old Cold-Start vector
	dcx	h
	mov	m,e
	inx	h
	inx	h
	inx	h
	mov	c,m	;save old warm-start vector
	mov	m,e	;and fill Warm-Start vector
	inx	h
	mov	b,m
	mov	m,d
	sbcd	wbiosa
	lhld	BDOS+1
	shld	@BDOS+1
	lhld	RST1+1
	shld	chain+1
	lhld	CCPa
	shld	CCPadr
	lhld	CCPl
	shld	CCPlen
	jr	ws00

wbiosa: dw	0
porta:	db	0	;port base address
;The warm-start routine
wstart: lxi	sp,stack	;a user's program, executing locally, has
	mvi	a,0f0h
	sta	func
	lxi	h,0		;terminated.
rstart: shld	retin
	lda	4
	sta	info
	call	put
ws00:	di
	mvi	a,(JMP)
	sta	CPM
	sta	BDOS
	sta	RST1
	lhld	@BIOSa
	shld	CPM+1
	lxi	H,@BDOS
	shld	BDOS+1
	lxi	h,TIC
	shld	RST1+1
	xra	a
	sta	clk
	lxi	h,ictl
	mov	a,m
	ori	00000010b
	mov	m,a
	out	port
	ei
	lhld	@BDOS+1 ;put serial number in front of system
	mvi	l,0
	lxi	d,BDOS$1
	lxi	b,6
	ldir
	lxi	d,DMA
	mvi	c,26	;BDOS setdma function code
	call	BDOS
ws0:	lxi	h,func
	lxi	b,7	;7 bytes will be transfered
	call	get422	;wait for 77422 to send a packet (command)
	lxi	h,ws0
	push	h	;setup to loop by use of "RET" instructions
	lda	func
	cpi	0f0h	;from F0 to FF are direct BIOS calls.
	jc	bdosf	;execute BDOS functions
; Do direct BIOS calls....
	ani	00001111b
	jrz	wboot	;transfer CCP and re-init
	push	psw	;save code for later examinations...
	cpi	13	;write function requires handling of DMA buffer...
	jrnz	ws2
	lxi	h,DMA
	lxi	b,128
	call	get422	;get sector from 77422
ws2:	lxi	h,ws1
	push	h	;setup return address for BIOS routines.
	mov	c,a	;BIOS jmp-vector number (1-15, excl 11)
	add	a	;*2
	add	c	;*3
	mov	c,a
	mvi	b,0
	lhld	@BIOSa
	dad	b
	push	h	;save address where we can conviently jump to it...
	lda	func
	lbcd	rBC
	lded	rDE
	lhld	rHL
	ret		;do BIOS call
ws1:	sta	func	;return here after doing BIOS routine
	sbcd	rBC
	sded	rDE
	shld	rHL
	pop	psw    ;;
	cpi	3      ;;console output - no return frame
	rz	       ;;
	push	psw    ;;
	call	put	;send results to 77422
	pop	psw	;function code
	cpi	8	;select disk requires special handling
	jrz	seldsk
	cpi	12	;read function requires handling of DMA buffer...
	rnz
	lxi	h,DMA
	lxi	b,128
	jr	put422	;send sector to 77422

seldsk: lhld	rHL
	mov	a,h
	ora	l	;if select error, don't send back any data
	rz
	lxi	b,16
	call	put422
	lhld	rHL
	lxi	d,+10
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg		;DPB address
	lxi	b,21
	jr	put422

wboot:	mvi	a,0E3H
	sta	func
	lhld	CCPlen
	shld	rBC
	lhld	CCPadr
	shld	rHL
	call	put	;tell 77422 that we're sending it the CCP...
	lxi	h,@CCP
	lbcd	CCPlen 
	call	put422
	lxi	h,BDOS$1	;send serial number accross also.
	lxi	b,6
	jr	put422	;send CCP to 77422 board

put:	lxi	h,func
	lxi	b,7
;	jmp	put422
; Word count cannot be 0.  This channel requires fixed message length !
put422: mov	a,c	;must split word count into byte-size counters.
	ora	a	;this requires some fancy foot-work.
	mov	e,b	;(E) will be the "page counter"
	jrz	pu3
	inr	e
pu3:	mov	b,c	;(B) is the byte counter (initially the remainder)
	lda	porta
	mov	c,a
	inr	c
pu0:	inp	a
	ani	0100b	;check channel 2 for idle
	jrz	pu0
	dcr	c
	mov	a,m
	inx	h
	outp	a	;send first byte
	inr	c
pu1:	inp	a
	ani	0100b
	jrz	pu1
	dcr	c
	dcr	b	;update (B) for first byte output
	jrz	pu4	;
pu2:	outir
pu4:	dcr	e
	jrnz	pu2
	ret

; byte count (BC) must be greater than 1.
get422:
	mov	a,c	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,b
	jrz	ge6
	inr	e
ge6:	mov	b,c
	lda	porta
	mov	c,a
	inr	c
ge0:	inp	a
	ani	1000b	;check channel 2 for idle
	jrz	ge0
	dcr	c
ge2:	inir		;get the rest of the characters.
	dcr	e
	jrnz	ge2
ge7:	inr	c	; status port
ge4:	inp	a
	bit	1,a	; INT?
	jrnz	ge5
	ani	1000b	;check channel 2 for idle
	jrz	ge4
	dcr	c
	inp	a	;at this point we have all the characters we want but
	jr	ge7	;the 77422 still has more to send so we must continue
			;to take characters until we see DONE

ge5:	outp	a	;clear interrupt
	ret

crlf:	mvi	e,cr
	call	conout
	mvi	e,lf
conout: mvi	c,2	;bdos conout function code
	jmp	bdos

TIC:	push	psw
	push	b
	lda	porta
	adi	3	;tick interupt is +3
	mov	c,a
	outp	a	;cause interupt in 77422
	pop	b
	pop	psw
chain:	jmp	0

func:	db	0	;function code or register (A)
rBC:	dw	0	;parameter or registers (BC)
rDE:	dw	0	;registers (DE)
rHL:	dw	0	;return info or registers (HL)

info	equ	rBC
retin	equ	rHL

CCPlen: dw	0
CCPadr: dw	0
@BIOSa: dw	0

	ds	0	;prints address on listing (only function)

@@ set (($-BDOS$1) and 0FFH)
 if @@ ne 0
 rept 100H-@@
 db 0
 endm
 endif

@CCP:	end
