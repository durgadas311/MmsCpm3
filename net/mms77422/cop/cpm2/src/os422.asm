VERS equ '0c' ; December 29, 1982  13:26  drm  "OS422.ASM"

	maclib	Z80

;*****************************************************
;**** BDOS interface, BIOS entry, and DMA	 *****
;**** handler for CP/M-422			 *****
;****  Copyright (C) 1982 Magnolia microsystems  *****
;*****************************************************

false	equ	0
true	equ	not false

CPM	equ	0	;warmboot entry for users
BDOS	equ	5	;BDOS entry for users

KHz	equ	4000	;clock speed in KiloHertz

;********************************************************
;*  I/O port base addresses
;********************************************************
sio	equ	000h	;z80-sio/0
dma	equ	080h	;AMD 9517
ctrl	equ	040h	;general control outputs

;********************************************************
;*  Control ports definitions
;********************************************************
MAP	equ	11111000b	;mask for memory mapping
ROMon	equ	000b	;code for EPROM on, bank 0
ROMoff	equ	001b	;EPROM off, bank 0
B156	equ	010b	;Bank 1, 56K
B148	equ	011b	;Bank 1, 48K
B256	equ	100b	;Bank 2, 56K
B248	equ	101b	;Bank 2, 48K
B356	equ	110b	;Bank 3, 56K
B348	equ	111b	;Bank 3, 48K
RED	equ	10000000b	;Red LED on
GREEN	equ	01000000b	;Green LED on
BOTH	equ	11000000b	;Both LEDs on
OFF	equ	00111111b	;mask to turn LEDs off.
ILAT	equ	00100000b	;latch control for IDLE status bit.

IDLE	equ	01000000b	;position of IDLE status bit.
TEST	equ	10000000b	;position of TEST status bit.

;********************************************************
;*  Z80-SIO equates
;********************************************************
Adat	equ	sio	;channel A data port
Bdat	equ	sio+1	;channel B data port
cmdA	equ	sio+2	;channel A command/status port
cmdB	equ	sio+3	;channel B command/status port

console equ	Bdat	;channel B is the RS-232 port for a console
constat equ	cmdB

;* ASCII character equates
bell	equ	7
bs	equ	8
tab	equ	9
lf	equ	10
cr	equ	13
esc	equ	27
del	equ	127

;********************************************************
;*	AMD 9517 equates
;********************************************************
ch0ba	equ	dma+0	;channel 0 base address
ch0wc	equ	dma+1	;channel 0 word count
ch1ba	equ	dma+2	;
ch1wc	equ	dma+3	;
ch2ba	equ	dma+4	;
ch2wc	equ	dma+5	;
ch3ba	equ	dma+6	;
ch3wc	equ	dma+7	;

dmacomd equ	dma+8	;command port
comd	equ	01110000b	;DACK/DREQ act.lo, Norm timing, Ext write,
				;Rotating priority, Controller enable.

dmastat equ	dma+8	;status port
dreq	equ	dma+9	;software data requests

mask	equ	dma+10	;individual channel mask bit access
dis	equ	100b	;disable DMA (set mask)

mode	equ	dma+11	;individual channel mode bit access
clrBP	equ	dma+12	;clear Byte Pointer flip-flop
clr	equ	dma+13	;clear DMA chip
temp	equ	dma+13	;read temporary register
maskall equ	dma+15	;write all mask bits (simultanious)


	cseg
	org	0
BDOS$1:
	jmp	BIOS$1	  ;serial number space (overwritten later)
	db	0,0,0

@BDOS:	JMP	ENTRY

	dw	0	;not valid
	dw	0
	dw	0
	dw	0

	db	0	;this makes the "ENTRY" address not xx11

ENTRY:
	sspd	ustk
	lxi	sp,bdostk
	lxi	h,exit
	push	h	;return address
	sded	info
	lxi	h,0
	shld	retin
	mov	a,c
	sta	func
	cpi	0E0H	;remote load-n-go function from CCP
	jz	ldngo
	cpi	NFUNCS
	rnc
	mov	e,c
	mvi	d,0
	lxi	h,FUNTAB
	dad	d
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

FUNTAB: dw	@BIOS	;go directly to local warm-boot
	dw	putget	;read console, swap memory and go...
	dw	put	;write console, ...
	dw	putget	;read reader, ...
	dw	put	;write punch, ...
	dw	put	;write list, ...
	dw	dcio	;direct console I/O
	dw	putget	;get iobyte
	dw	put	;set iobyte
	dw	bufout	;buffered console output, special processing
	dw	bufin	;beffered console input, special processing
	dw	putget	;console input status

	dw	putget	;return version
	dw	put	;reset disk system
	dw	put	;select drive
	dw	pgF33	;open file, put and get FCB (33 byte)
	dw	pFCB	;close file, put FCB, get only error code
	dw	pFgD	;search first, put FCB and get DMA (+error code)
	dw	DMAgo	;search next, get DMA
	dw	pFCB	;delete file, put FCB and get only error code
	dw	pFgFD	;read sequential, put FCB, get DMA+FCB(33 byte)
	dw	pFDgF	;write sequential, put FCB+DMA, get FCB(33 byte)
	dw	pgF33	;make file entry
	dw	pFCB	;rename file
	dw	putget	;return login vector
	dw	putget	;return current drive
	dw	sdma	;set dma address (for local use only)
	dw	alloc	;return alloc vector address (actual alloc vector)
	dw	put	;write protect drive
	dw	putget	;get R/O vector
	dw	pFCB	;set file attributes
	dw	gDPB	;get DPB address (actual DPB)
	dw	putget	;set/get user number
	dw	pFgFD	;read random (return 33 byte FCB)
	dw	pFDgF	;write random (return 33 byte FCB)
	dw	pgFCB	;compute file size (36 byte FCB)
	dw	pgFCB	;set random record number (36 byte FCB)
	dw	put	;reset individual drives
	dw	go	;no function
	dw	go	;no function
	dw	pFDgF	;write random, zero fill (36 byte FCB)
NFUNCS equ ($-FUNTAB)/2

dcio:	lda	info
	rlc	;is bit 7 a "1" ?
	jnc	put	;output, don't wait for return frame.
	jr	putget

bufout: 
	lhld	info
	lxi	b,0	;search through all of RAM for '$'
	mvi	a,'$'	;to detrmine length of string to print.
	ccir
	lded	info
	ora	a
	dsbc	d	;(HL) = length
	shld	info
	push	d	;save message address
	call	put	;send func,info (info is message length)
	pop	h	;(HL) = Address
	lded	info	;(DE) = length
	jmp	put89 ;send string to Z89 (and then to console/printer)

bufin:	lhld	info
	mov	e,m	;get max length of buffer
	inx	h
	push	h
	mvi	d,0
	sded	info	;
	call	putget	;send func,info (info=max number of chacters)
			;get back actual length of input.
	lded	retin	;total number of characters (input+count)
	pop	h	;(HL) = Buffer address
	jmp	get89	;

sdma:	lhld	info
	shld	dmaa
	ret

putFCB: call	put
	lxi	d,36
	lhld	info
	jmp	put89

putget: call	put
get:	call	getf
	lda	func	;was the BDOS function terminated by a "^C" (jmp 0)
	cpi	0f0h	;if it was, there will be no more data returned.
	rnz
	jmp	wstart

pFCB:	call	putFCB
	jr	get

pFgD:	call	pFCB
	jmp	getDMA

pFgFD:	call	pgF33
	lda	retin
	ora	a
	rnz
	jmp	getDMA

pgFCB:	call	putFCB
	jr	getFCB

pFDgF:	call	putFCB
	call	putDMA
	jr	getF33

pgF33:	call	putFCB
getF33: lxi	d,33
	jr	gf0

getFCB: lxi	d,36
gf0:	push	d
	lhld	info	;user's FCB address (will be destroyed by "get")
	push	h
	call	get
	pop	h
	pop	d
	jmp	get89

DMAgo:	call	putget
	jmp	getDMA

gDPB:	call	put
	lxi	h,DPB
	shld	retin
	lxi	d,21
	jmp	get89

alloc:
go:	ret

exit:	lhld	retin
	mov	a,l
	mov	b,h
	lspd	ustk
	ret

ldngo:	lda	4	;default disk and user #
	sta	info
	call	put
	lxi	h,50H	;start of pertinant page-0 information
	lxi	d,(100H-50H)
	call	put89
	call	getf	;wait for program to terminate.
	lda	info
	sta	4
	ret

	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bdostk: ds 0

	dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
stack:	ds 0

DPB:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

@@ set (($-BDOS$1) and 0ffh)
 if @@ ne 0
 rept 100h-@@
 db 0
 endm
 endif

BIOS$1:
	jmp	cstart		;cold start
@BIOS:	jmp	wstart		;warm start
	jmp	CS		;console status
	jmp	CI		;console character in
	jmp	CO		;console character out
	jmp	PO		;list character out
	jmp	punch		;punch not implemented in MP/M
	jmp	reader		;reader not implemented in MP/M
	jmp	home		;move head to home
	jmp	seldsk		;select disk
	jmp	settrk		;set track number
	jmp	setsec		;set sector number
	jmp	stdma		;set dma address
	jmp	read		;read disk
	jmp	write		;write disk
	jmp	PS		;list status
	jmp	sectrn		;sector translate

;modes for DMA chip.
modes:	db	01000000b	;channel 0: use for Memory-to-Memory ?
	db	01000001b	;channel 1: use for Memory-to-Memory ?
	db	01000110b	;channel 2: I/O to Mem, Single mode
	db	01001011b	;channel 3: Mem to I/O, Single mode

;In CP/M 2.24 the Cold Start routine is responsible for initializing the system
;and transfering to the CCP.
cstart:
	lxi	sp,stack
	mvi	a,ROMoff	;LEDs off, EPROM off.
	sta	image
	out	ctrl

;*  AM 9517 Re-initialization...
	mvi	a,comd+100b	;disable controller
	out	dmacomd
	mvi	a,1111b 	;make sure all channels are masked
	out	maskall
	mvi	a,comd		;default (standard) command byte
	out	dmacomd 	;enable controller
	lxi	h,modes
	lxi	b,(mode)+(4)*256
	outir
; Leave all DMA channels masked untill we need them.

	lxi	h,tick
	mov	a,h
	stai
	ei

	call	wb0	;continue in WBOOT routine
	push	h	;save execution address of CCP
	lxi	d,signon
	mvi	c,9	;BDOS function 9: print buffer to console
	call	bdos	;print signon message at console.
	mvi	a,00H	;default disk/user number
	sta	4	;set default drive/user in RAM
	jr	wm0	;jump to CCP.

signon: db	cr,lf,bell,'MMS CP/M-422 version 2.29'
	dw	VERS
	db	'$'

;The warm-start routine is responsible for insuring that the CCP
;is restored.
wstart: lxi	sp,stack
	call	wb0
	inx	h
	inx	h
	inx	h	;CCP+3 = warm start CCP
	push	h	;jmp to CCP+3
wm0:	lda	4
	mov	c,a
	ret	;startup CCP

wb0:	xra	a	;0=warm boot code. causes CCP to be transfered.
	call	goBIOS	;(BC) = CCP422 length
	push	h	;(HL) = CCP422 address
	mov	e,c
	mov	d,b	;(DE) = CCP422 length
	call	get89
	lxi	h,BDOS$1	;get serial number
	lxi	d,6
	call	get89
	mvi	a,09	;mms version number for CP/M-422
	sta	BDOS$1+2
	mvi	a,(JMP)
	sta	CPM
	sta	BDOS
	lxi	h,@BIOS 
	shld	CPM+1
	lxi	h,@BDOS
	shld	BDOS+1
	mvi	c,7	;BDOS function 7: get IOBYTE value.
	call	bdos
	sta	3	;set IOBYTE on this side.
	pop	h	;(HL) = CCP address
	ret

CS:	mvi	a,1	;test console input status
	jr	goBIOS

CI:	mvi	a,2	;input from console
	jr	goBIOS

CO:	mvi	a,3	;output to console
	jr	pBIOS  ;;send only, don't wait for return info.

PO:	mvi	a,4	;output to list device
	jr	goBIOS

punch:	mvi	a,5	;output to punch device
	jr	goBIOS

reader: mvi	a,6	;input from reader device
	jr	goBIOS

home:	mvi	a,7	;home disk routine (set track to 0)
	jr	goBIOS

settrk: mvi	a,9	;set track number
	jr	goBIOS

setsec: mvi	a,10	;set sector number
	jr	goBIOS

@@ set (($-BIOS$1+1) and 0ffh)
 if @@ ne 0
 rept 100h-@@
 db 0
 endm
 endif

tick:	dw	tic	;must be at xxFF

seldsk: mvi	a,8	;select drive: find module for drive number.
	call	goBIOS
	mov	a,h	;check for select error (no more returned data)
	ora	l
	rz
	lxi	h,dph
	shld	rHL
	lxi	d,16
	call	get89
	lxi	h,bdpb
	shld	dph@dpb
	lxi	d,21
	call	get89
	jr	reg

stdma:	sbcd	dmaa	;set DMA address
	ret

read:	mvi	a,12	;read sector from disk
	call	goBIOS
	call	getDMA
	jr	reg

write:	mvi	a,13	;write sector to disk
	call	pBIOS
	call	putDMA
	jr	gBIOS

PS:	mvi	a,14	;test list output status
	jr	goBIOS

sectrn: mvi	a,15	;logical to physical sector translation
;	jmp	goBIOS	
;
goBIOS: call	pBIOS
gBIOS:	call	getf
reg:	lda	func
	lbcd	rBC
	lded	rDE
	lhld	rHL
	ret

pBIOS:	ori	11110000b
	sta	func
	sbcd	rBC
	sded	rDE
	shld	rHL
put:	lxi	h,func
	lxi	d,7
	jr	put89

putDMA: lhld	dmaa
	lxi	d,128
;	jmp	put89
;
put89:		;send a message to the Z89
;				;(HL) = Base address
	lxi	b,(ch3ba)+(1000b)*256	     ;(C)=ch3ba, (B)=1000b
	jr	gp89

getf:	lxi	h,func
	lxi	d,7
	jr	get89

getDMA: lhld	dmaa
	lxi	d,128
;	jmp	get89
;
get89:		;wait for a message from the Z89
;				;(HL) = Base address
	lxi	b,(ch2ba)+(0100b)*256	    ;(C)=ch2ba, (B)=0100b
gp89:	dcx	d		;(DE) = Word count (-1)
	mov	a,c
	call	setdma		;setup to receive from Z89
	sui	ch0ba
	rrc		;convert ch2ba/ch3ba to 2/3
	out	mask	;un-mask channel
g89:	in	dmastat
	ana	b		;check eop (2 or 3)
	jrz	g89	;wait for Z89 to send message
	ret

setdma: out	clrBP
	outp	l
	outp	h
	inr	c
	outp	e
	outp	d
	ret

tic:	push	h
	lhld	11
	inx	h
	shld	11
	out	0e0h	;reset interupt
	pop	h
	ei
	reti

image:	db	0

func:	db	0
rBC:	dw	0
rDE:	dw	0
rHL:	dw	0

info	equ	rBC
retin	equ	rHL

ustk:	dw	0
dmaa:	dw	0080H	;default DMA address

dph:	dw	0,0,0,0,0
dph@dpb:    dw	0,0,0

bdpb:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	ds	0	;prints address on listing (only function)

@@ set (($-BIOS$1+3) and 0ffh)
 if @@ ne 0
 rept 100h-@@
 db 0
 endm
 endif

SCRATCH DB	0	;to simulate ESC-sequence patch in Z89
	DW	SCRATCH

	end

