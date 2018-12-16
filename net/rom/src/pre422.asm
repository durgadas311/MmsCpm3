VERS set 35 ; (Dec 14, 2018 21:34)  drm  "PRE422.ASM"
******************* MONITOR EPROM ***********************
************ for the 77422 network controller ***********
	maclib	z80

;All nodes have equal responsibility. no Server/Requestor determination.

TRUE	equ	0ffh
FALSE	equ	000h

EPROM	equ	00000h	;start of EPROM
EPROML	equ	8*1024	;length of EPROM in bytes
RAM	equ	02000h	;start of RAM
RAML	equ	56*1024 ;length of RAM in bytes

*********************************************************
**  I/O port base addresses
*********************************************************
sio	equ	000h	;z80-sio/0
dma	equ	080h	;AMD 9517
ctrl	equ	040h	;general control outputs
myaddr	equ	040h	;node address and network sense
ch2rd	equ	0e0h	;read data from DMA channel 2 (clear ch2 dreq)

*********************************************************
**  Control ports definitions
*********************************************************
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

*********************************************************
**  Z80-SIO equates
*********************************************************
Adat	equ	sio	;channel A data port
Bdat	equ	sio+1	;channel B data port
cmdA	equ	sio+2	;channel A command/status port
cmdB	equ	sio+3	;channel B command/status port

console equ	Bdat	;channel B is the RS-232 port for a console
constat equ	cmdB

** ASCII character equates
bell	equ	7
bel	equ	bell
bs	equ	8
tab	equ	9
lf	equ	10
ffeed	equ	12	;form feed for printer
cr	equ	13
esc	equ	27
del	equ	127

*********************************************************
**	AMD 9517 equates
*********************************************************
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

*********************************************************
**	Network equates
*********************************************************

	org 0	;define relative positions of elements in network frame.
DEST	ds	1	;Destination I.D. address
CODE	ds	1	;Control Field (network function number)
SORC	ds	1	;Source I.D. address (my-address)
DATA	ds	0	;0-n characters of data

	org 0	;define relative positions of elements in host header.
ZCODE	ds	1
ZBC	ds	2
ZDE	ds	2
ZHL	ds	2
ZDATA	ds	0

; CODE field definitions.
CPNET	equ	000h
CPNRSP	equ	001h
CPMAIL	equ	002h
EXE422	equ	010h
EXEHST	equ	011h
RBOOT	equ	020h
NBOOT	equ	028h
NSTS	equ	030h
NRSP	equ	038h
EXEC	equ	060h	; +01 = load only
GDBG	equ	070h
TOKEN	equ	0d0h	;TOKEN-0, DATA = NET.TABLE
RESET	equ	0dfh	;reset other nodes ("I have token")
POLL	equ	0e0h	;Poll node for status
ACK	equ	0f0h	;Acknowledge transmission
NAK	equ	0f1h	;Error in transmission
BSY	equ	0f2h	;unable to preocess message at present time.

; Node Type Codes
TUNK	equ	010h
TDBG	equ	020h	; In monitor/debugger
TPSV	equ	030h	; Printer server
TNOS	equ	040h	; CP/NOS (diskless)
TRSV5	equ	050h
TRSV6	equ	060h
TFSV	equ	070h	; File server (e.g. MP/M on CP/NET)
TNET	equ	080h	; CP/NET client/resquestor
TCPM	equ	090h	; CP/M, on network
TDOS	equ	0a0h	; MS-DOS, on network
TCCD	equ	0b0h	; Concurrent DOS
TRSVC	equ	0c0h
TEXT1	equ	0d0h
TEXT2	equ	0e0h
TEXT3	equ	0f0h

	org 0	;define relative positions of CP/NET message items.
SEQ	ds	1	;added by MMS to handle retries
FMT	ds	1	;00 or 01
DID	ds	1	;destination of message
SID	ds	1	;source of message
FNC	ds	1	;CP/NET function code
SIZ	ds	1	;length of message, less 1
MSG	ds	0	;1-256 characters

*********************************************************
**	EPROM code
*********************************************************
	org	EPROM

	jmp	start	; func 70h
	jmp	0	; func 71h
	jmp	0	; func 72h
	jmp	0	; func 73h
	jmp	0	; func 74h
	jmp	0	; func 75h
	jmp	0	; func 76h
	jmp	0	; func 77h
	jmp	0	; func 78h
	jmp	0	; func 79h
	jmp	0	; func 7ah
	jmp	0	; func 7bh
	jmp	0	; func 7ch
	jmp	0	; func 7dh
	jmp	0	; func 7eh
	jmp	debug	; func 7fh

FAIL9:	mvi	e,10100101b	; RED RED GRN GRN
	jr	f2
FAIL8:	mvi	e,00100001b	; OFF RED OFF GRN
	jr	f2
FAIL7:	mvi	e,11011110b	; ALL GRN ALL RED
	jr	f2
FAIL6:	mvi	e,00100111b	; OFF RED GRN ALL
	jr	f2
FAIL5:	mvi	e,00011011b	; OFF GRN RED ALL
	jr	f2
FAIL4:	mvi	e,01110111b	; GRN ALL GRN ALL
	jr	f2
FAIL3:	mvi	e,10111011b	; RED ALL RED ALL
	jr	f2
FAIL2:	mvi	e,10011001b	; RED GRN RED GRN
	jr	f2
FAIL:	mvi	e,11001100b	; ALL OFF ALL OFF
f2:	mov	a,e
	rlc
	rlc
	mov	e,a
	ani	BOTH
	out	ctrl
	lxi	b,(169)*256
f1:	dcr	c
	nop
	jrnz	f1
	dcr	b
	jrnz	f1
	jr	f2

 if $ ne 0066H
ds 'NMI position error'
 endif
NMI:			;interupt caused by Z89
	di	;reset interupt flip-flops
; re-start monitor...

start:
*********************************************************
**  Initialize the Z80
*********************************************************
	mvi	a,BOTH	      ;initial ctrl port image, both LEDs on
	out	ctrl
	lxi	sp,stack
	lxi	d,00000001b	;(D)=0 [NC], (E)=00000001b
	lxi	b,0	;two counters, 256 each
mt0:	lxi	h,RAM
	mov	a,e
	rrcr	d	;"prime" [CY] in bit 7 of D
	rlcr	d	;[CY] from bit 7 of D, into bit 0 of D
mt1:	mov	m,a
	inx	h
	ral		;use 9-bit rotate to produce non-binary pattern.
	djnz	mt1
	inr	b	;prime BC to count 256
	lxi	h,RAM
	rrcr	d	;[CY] from bit 0 D, into bit 7 of D
	mov	a,e
mt2:	cci	;compares A:(HL), HL=HL+1, BC=BC-1, preserves [CY]
	jnz	FAIL
	ral		;9-bit rotate
	jpe	mt2	;Parity bit set by "cci" per status of BC-1
	slar	e
	ralr	d	;[CY] into bit 0 of D, [CY] from bit 7 (previous value)
	jnc	mt0
; the critical page of memory (stack) has now been tested.

	mvi	a,BOTH+ROMon	;initial ctrl port image, both LEDs on
	sta	ctl$image	;set ctrl port image (keep EPROM)
	lxi	h,intvec	;copy initial interupt vectors into RAM
	lxi	d,vector
	lxi	b,numvec
	ldir
	im2			;vectored interupt mode for Z80

*********************************************************
**  AM 9517 Initialization...
*********************************************************
	out	clr	;reset the 9517 (masks all channels)
	mvi	a,comd		;default (standard) command byte
	out	dmacomd 	;enable controller
	mvi	a,010001$00b	;channel 0: currently in receive mode
	out	mode
	mvi	a,010000$01b	;channel 1: not currently connected
	out	mode
	mvi	a,010001$10b	;channel 2: write memory, read I/O
	out	mode
	mvi	a,010010$11b	;channel 3: read memory, write I/O
	out	mode
	mvi	a,1111b 	;mark all DMA channels inactive
	sta	eops
; Leave all DMA channels masked untill we need them.
	lxi	b,0	;64K counter (65536)
id1:	in	dmastat ;check if dreq2 is active (must be cleared)
	ani	0100$0000b
	jz	id0
	in	ch2rd	;read a byte to clear dreq2
	dcx	b
	mov	a,b
	ora	c
	jnz	id1	;keep checking untill its stays cleared or 64K input.
	in	dmastat
	ani	0100$0000b
	jnz	FAIL2	;failure if still DREQing
id0:
*********************************************************
**  Initialize the SIO (MK3884)
*********************************************************
	lxi	h,initB 	;initialize channel B first.
	lxi	b,(cmdB)+(lenB+2)*256	;port and length of transfer
	outir
	lxi	h,initB+2
	lxi	d,sioB
	lxi	b,lenB
	ldir		;initialize RAM image of sio B registers
	lxi	h,async
	lxi	b,(asyncl)*256+(cmdA)
	outir		;temporarely setup ch A as async, 6 data bits

; This cps-measuring code is probably bogus.
; 1 char at 500Kbps will be 64 CPU cycles (4MHz).
; That will be at most one pass through the loop,
; yielding a count of 79+82=161 cycles. This means
; that 'ltime' will always be 0. That results in
; the delay loops doing 256 interations, which is
; excessive (although not fatal).
	mvi	b,10	; max 10 chars to fill Tx FIFO
id2:	xra	a
	out	Adat
	out	cmdA
	in	cmdA
	ani	00000100b
	jz	id3
	djnz	id2
	jmp	FAIL3
id3:	mov	b,a	; zero, i.e. 256 loops max to TxBE
	lxi	d,cycles
	lxi	h,79	; first pass, min cycles
id4:
	out	cmdA
	in	cmdA
	ani	00000100b	;  8
	jnz	gt0		; 11
	djnz	id4
	jmp	FAIL3
gt0:	xra	a		;  5
	out	Adat		; 12
				;...
gt1:	xra	a		;  5
	out	cmdA		; 12
	in	cmdA		; 12
	ani	00000100b	;  8
	jnz	gt2		; 11 ...?
	dad	d		; 12
	jc	FAIL3		; 11
	jmp	gt1		; 11
				;---
; at 500Kbps, 1 char == 64 cycles (4MHz)
cycles	equ	82		; 82
gt2:
	shld	ctime	;number of CPU cycles per character.
			;note: measurement was made at 16x normal rate.
	mov	a,h	; divide by 256 = 1x clock /16 (16 cycles in delay routine)
	sta	ltime	;loop counter for one character (1 loop=16 cycles)
	lxi	h,initA
	lxi	d,sioA
	lxi	b,lenA
	ldir		;initialize RAM image of sio A registers
	in	myaddr
	cma
	ani	00111111b
	sta	maddr
	lxi	h,sioA		;send string of commands to SIO
	lxi	b,(cmdA)+(lenA)*256   ;channel A
	outir

	mvi	a,vector/256
	stai			;initialize (I) register now.

*********************************************************
**  Start up...
*********************************************************
	lxi	h,endlst
	mvi	m,255
	lxi	h,0
	shld	prtpt0
	shld	prtpt1
	call	LEDoff		;turn the LED off to indicate we got here...
	ei			;start everything (anything?)

	lxi	h,ch2hdr	;setup to receive command from Z89
	lxi	d,hdrsiz
	mvi	c,ch2ba
	call	setdma		;setup to receive from Z89
	mvi	a,2
	out	mask	;un-mask channel 2 (Z89-to-77422)
	mvi	a,true
	sta	from89
	mvi	a,false	;Clear to Zeros...
	sta	to89	;
	sta	nstat	;
	sta	pflag	;
	sta	retry	;

	lxi	h,ch3bf
	shld	ch0addr
	lxi	h,netbf
	shld	altaddr
	lxi	h,eops
	res	2,m	;
;			;receiver setup later...at START$NET entry.
	lxi	h,hstbf
	shld	ch2alt
	lxi	h,ch2bf
	shld	ch2pri
	lxi	h,srvtbl
	lxi	d,srvtbl+1
	lxi	b,64-1
	mvi	m,0
	ldir	;initialize net$table to all zeros (all nodes off-line)
	lxi	h,SEQtbl
	lxi	d,SEQtbl+1
	lxi	b,64-1
	mvi	m,080h
	ldir
	lda	maddr	; 0,1,2...63
	mov	e,a
	mvi	d,0
	lxi	h,srvtbl
	dad	d
	shld	nxsrva
	sta	nxsrvn
	mvi	m,TUNK	; node type not yet known
	inr	a	; 1,2,3...64
	add	a	; 2,4,6...128
	mov	h,a	;
	mvi	l,0	; 512,1024,1536...32768
	shld	deadct0 ; multiplied by approx 238 usec for dead-timeout.

	in	ctrl
	ani	10000000b
	xri	10000000b
	rrc
	rrc
	ori	010h	; either TPSV or TUNK
	sta	ntype
	mvi	a,0	;Clear to zeros
	sta	nxt$sp	;

	lda	maddr
	lxix	TOKEN0msg
	mvix	TOKEN,CODE
	stx	a,SORC
	lxix	POLLmsg
	mvix	POLL,CODE
	stx	a,SORC
	lxix	ACKmsg
	mvix	ACK,CODE
	stx	a,SORC
	lxix	NAKmsg
	mvix	NAK,CODE
	stx	a,SORC
	lxix	ACKmsg	; redundant...
	mvix	ACK,CODE ;
	stx	a,SORC	;
	lxix	BSYmsg
	mvix	BSY,CODE
	stx	a,SORC
	lxix	RESmsg		;setup reset message.
	mvix	RESET,CODE
	stx	a,SORC
	mvix	0FFH,DEST	;set destination as "global"
	lxix	PAKmsg
	mvix	0,DATA+SEQ	;SEQuence number, for retries.
	mvix	01h,CODE
	mvix	01h,DATA+FMT	;FMT
	mvix	05h,DATA+FNC	;FNC
	mvix	1-1,DATA+SIZ	;SIZ
	mvix	  0,DATA+MSG	;MSG
	stx	a,SORC
	stx	a,DATA+SID	;SID

	lxix	rsphdr
	mvix	NRSP,ZCODE
	mvix	0,ZBC
	mvix	0,ZBC+1
	lxix	stshdr
	mvix	NSTS,ZCODE
	mvix	0,ZDE+1
	lda	maddr
	stx	a,ZDE
	lxi	h,64+1
	stx	l,ZBC
	stx	h,ZBC+1
	mvi	a,false	;Clear to zeros
	sta	stsflg	;
	sta	rspflg	;
	sta	retflg	;
	sta	cpnflg	;
	sta	outflg	;
	sta	didsts	;
	sta	didrsp	;
	sta	didalt	;
	sta	dbgflg	;
	mvi	a,255
	sta	prtflg	;mark printer as "available"

	jmp	start$net

** Initialization string for SIO channel A
initA:	db	0,00011000b	;reset channel
	db	4,00100000b	;1x clock, SDLC, no parity
	db	1,00000000b	;leave RDY and interupts disabled
	db	6,11111111b	;Address byte (set to node address before init) 
	db	7,01111110b	;flag byte (for receive)
	db	5,01100001b	;Tx 8 bits,SDLC CRC, RTS/DTR off, Tx Disabled
	db	3,11001000b	;receive 8 bits, CRC, RxDisabled

** setup port as 6 bit asyncronous (to simulate 8 bit SDLC timing)
async:	db	0,00011000b	;reset channel
	db	4,01000100b	;16x clock, 1 stop bit, no parity
	db	1,00000000b	;leave RDY and interupts disabled
	db	5,01001010b	;Tx Enable, 6 bits, RTS on, DTR off
	db	3,11000000b	;receive 8 bits, RxDisabled
asyncl	equ	$-async

** Initialization string for SIO channel B
initB:	db	0,00011000b	;reset channel
	db	2,vector mod 256 ;interupt vector address
	db	4,10000100b	;32x clock, 1 stop bit, no parity (ASYNC)
	db	1,00011110b	;status effects vector, TxE and RxA interupts
	db	5,11101010b	;Tx 8 bits, enable, set RTS/DTR on
	db	3,11100001b	;receive 8 bits, enable, auto enables.


;-------- end of PRE422.ASM ---------

