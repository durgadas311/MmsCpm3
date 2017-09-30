vers equ '1 ' ; August 10, 1983   9:51	mjm  "M316'3.ASM"
;*********************************************************
;	Disk I/O module for MMS CP/M 3.1
;	Copyright (c) 1983 Magnolia Microsystems
;*********************************************************

	MACLIB Z80
	$-MACRO

	extrn @dph,@rdrv,@side,@trk,@sect,@dma,@dbnk,@dstat,@intby
	extrn @dtacb,@dircb,@scrbf,@rcnfg,@cmode
	extrn ?bnksl,?getdp


; Ports and Constants
CTRL	EQU	038H		; EXTERNAL DISK CONTROL
WD1797	EQU	03CH		; CONTROLLER CHIP ADDRESS
STAT	EQU	WD1797		; STATUS REGISTER
TRACK	EQU	WD1797+1	; TRACK REGISTER
SECTOR	EQU	WD1797+2	; SECTOR REGISTER
DATA	EQU	WD1797+3	; DATA REGISTER
PORT	EQU	0F2H		; Z89 INTERRUPT CONTROL
PORT1	EQU	0E8H		; SERIAL PORT #1
PORT2	EQU	0E0H		; SERIAL PORT #2
PORT3	EQU	0D8H		; SERIAL PORT #3
PORT4	EQU	0D0H		; SERIAL PORT #4

dev0	equ	29		; first drive in system
ndev	equ	8		; # of drives is system
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
zdpbl	equ	15
z207dev equ	001$00000b	; label device type codes used to get format 
z37dev	equ	011$00000b	 
z47dev	equ	100$00000b
z67dev	equ	110$00000b
 
;--------- Start of Code-producing Source --------------

	cseg		;put only whats necessary in common memory...

	dw	thread
	db	dev0,ndev
	jmp	init
	jmp	login
	jmp	read$316
	jmp	write$316
	dw	string
	dw	dphtbl,modtbl

string: DB	'77316 ',0,'MMS Double Density Controller ',0,'v3.10'
	dw	vers
	db	'$'

modtbl:
 DB   00000000b,00000001b,11011010b,00011100b ; drive 29 MMS,DD,SS,8"
   db 11111110b,00011010b,10110000b,00100000b
 DB   00000000b,00000001b,11011010b,00011100b ; drive 30 MMS,DD,SS,8"
   db 11111110b,00011010b,10110000b,00100000b
 DB   00000000b,00000001b,11011010b,00011100b ; drive 31 MMS,DD,SS,8"
   db 11111110b,00011010b,10110000b,00100000b
 DB   00000000b,00000001b,11011010b,00011100b ; drive 32 MMS,DD,SS,8"
   db 11111110b,00011010b,10110000b,00100000b
 DB   00000000b,00000001b,01011110B,00011100B ; drive 33 MMS,DD,SS,ST,5"
   db 11111110b,11100110b,10010000b,00000000b
 DB   00000000b,00000001b,01011110B,00011100B ; drive 34 MMS,DD,SS,ST,5"
   db 11111110b,11100110b,10010000b,00000000b
 DB   00000000b,00000001b,01011110B,00011100B ; drive 35 MMS,DD,SS,ST,5"
   db 11111110b,11100110b,10010000b,00000000b
 DB   00000000b,00000001b,01011110B,00011100B ; drive 36 MMS,DD,SS,ST,5"
   db 11111110b,11100110b,10010000b,00000000b

zdpb	ds	17		; space for dpb for zenith formats 
	ds	17		; that use a label
	ds	17
	ds	17
	ds	17
	ds	17
	ds	17
	ds	17

; do actual transfers from common memory.

IO$1024:
	OUT	STAT		; send command to controller
	EI			; turn on interrupts
RW1	HLT			; WAIT FOR DRQ
FIX1	INI			; transfer byte (INI becomes OUTI for writes)
	JR	RW1		; loop until transfer complete.


RD$8DD:
	PUSH	PSW		; SAVE COMMAND
	LDA	CTRL$IMAGE
	ANI	11011111B	; set BURST MODE for hi-speed transfer
	OUT	CTRL
	POP	PSW		; restore disk command
	OUT	STAT		; GIVE COMMAND TO CONTROLLER
	EI
	HLT
RD1	INI
	JNZ	RD1
RD2	INI
	JNZ	RD2
RD3	INI
	JNZ	RD3
RD4	INI
	JNZ	RD4
	JR	$-1

WR$8DD: PUSH	PSW		; SAVE COMMAND
	LDA	CTRL$IMAGE
	ANI	11011111B	; SET BURST MODE FOR HI-SPEED TRANSFER
	MOV	E,A
	POP	PSW		; restore controller command.
	DCR	B		; SET UP FOR 254 BYTES
	DCR	B
	MOV	D,M		; first byte of sector
	INX	H
	OUT	STAT		; send command to controller
	EI
	HLT			; First DRQ comes immediately.
	OUTP	D		; output from CPU register to save time
	MOV	A,E
	OUT	CTRL		; SETUP FOR BURST MODE
	MOV	A,M		; SECOND BYTE OF SECTOR
	EI			; prepare for 2nd DRQ
	HLT
	OUTP	A
	INX	H
WR1	OUTI
	JNZ	WR1
WR2	OUTI
	JNZ	WR2
WR3	OUTI
	JNZ	WR3
WR4	OUTI
	JNZ	WR4
	JR	$-1


TYPE$II$COM:
	push	psw	;save command
	lda	@dbnk
	call	?bnksl	;select bank for disk transfer
	pop	psw	;restore controller command
	LXI	B,(0)*256+(DATA) ; SETUP FOR 256 BYTES
	lhld	@dma		 ; DATA BUFFER ADDRESS
	call	call$de
	push	psw	;save status of disk operation
	xra	a
	call	?bnksl	;re-select bank 0 (thats where we were called from)
	pop	psw
	ret

call$de:PUSH	D		 ; put 'DE' on stack.
	RET		;

CTRL$IMAGE: DB	0		; IMAGE OF CONTROL PORT

thread	equ	$	;must be last statement in "cseg"

	dseg		;put most everything in banked memory...

dphtbl: dw 0,0,0,0,0,0,0,csv29,alv29,@dircb,@dtacb,0		;hash buffers
	db 0	;(hash buffer bank number)			;are allocated
	dw 0,0,0,0,0,0,0,csv30,alv30,@dircb,@dtacb,0		;by main BIOS
	db 0							;during LOGIN.
	dw 0,0,0,0,0,0,0,csv31,alv31,@dircb,@dtacb,0
	db 0
	dw 0,0,0,0,0,0,0,csv32,alv32,@dircb,@dtacb,0
	db 0
	dw 0,0,0,0,0,0,0,csv33,alv33,@dircb,@dtacb,0
	db 0
	dw 0,0,0,0,0,0,0,csv34,alv34,@dircb,@dtacb,0
	db 0
	dw 0,0,0,0,0,0,0,csv35,alv35,@dircb,@dtacb,0
	db 0
	dw 0,0,0,0,0,0,0,csv36,alv36,@dircb,@dtacb,0
	db 0

csv29:	ds	(256)/4    ;max dir entries: 256
csv30:	ds	(256)/4
csv31:	ds	(256)/4
csv32:	ds	(256)/4
csv33:	ds	(256)/4
csv34:	ds	(256)/4
csv35:	ds	(256)/4
csv36:	ds	(256)/4

alv29:	ds	(608)/4    ;max dsk blocks: 608
alv30:	ds	(608)/4
alv31:	ds	(608)/4
alv32:	ds	(608)/4
alv33:	ds	(400)/4    ;max dsk blocks: 400
alv34:	ds	(400)/4
alv35:	ds	(400)/4
alv36:	ds	(400)/4

init:	LXI	H,INTRQ$ROUTINE ; load interrupt routine into page-zero
	LXI	D,(6)*8 	; as Restart 6. (absolute address)
	LXI	B,LEN$IR	;
	LDIR			; block transfer
	IN	STAT		; CLEAR WD-1797 from power-on (or whatever)
	RET

login:	pushix		;save IX
	lixd	@cmode
	inxix
	inxix
	sixd	mode	;save mode+2 for faster access to modes
	XRA	A
	STA	SELERR		; NO SELECT ERROR (YET)
	bitx	7,+1		; SHOULD WE READ TRACK 0 SECTOR 0 ?
	CNZ	PHYSEL
	bitx	7,+0		; IS IT A 5.25" DISK ?
	jrnz	eight
	lda	selerr		; was there a select error
	ora	a
	CZ	PHYSEL3 	; CHECK FOR HALF TRACK: must update DPB.
eight:	popix
	lda	selerr	;return error code, error during configuration.
	ora	a
	RET

PHYSEL: 
	lxi	h,0		;
	shld	@trk		; TRACK 0
	shld	@sect		; SECTOR 0
	lxi	h,@scrbf	;use BIOS scratch buffer to read Z37 label.
	shld	@dma	;we must also make sure that bank 0 is selected.
	xra	a
	sta	@dbnk	;set disk bank=0 (the bank we're in now)
	sta	@side	;side=0
	STA	SELOP		; FLAG A SELECT OPERATION
	STA	MODFLG		; RESET CHANGED MODE FLAG
	MVI	A,5		; 5 RETRYS FOR A SELECT OPERATION
	STA	RETRYS
	CALL	READ		; TRY READING LABEL AT DENSITY
				; CURRENTLY INDICATED IN TABLES
	JZ	PHYSEL1 	; BR IF SUCCESSFUL
	bitx	7,+0
	jnz	physel6 	; if 8" error out
	MVI	A,5		; RESET RETRYS TO 5
	STA	RETRYS
	STA	MODFLG		; SET CHANGED MODE FLAG
			; IX=mode bytes
	ldx	a,+1		; TRY OTHER DENSITY
	XRI	00010000b
	stx	a,+1
	CALL	READ		; TRY TO READ LABEL
	jrz	physel1 	
	ldx	a,+1
	xri	00010000b	; return mode bytes to former state
	stx	a,+1
	jmp	physel6 	; jmp to error
PHYSEL1:XRA	A		; ZERO ACCUM.
	MVI	B,LABLEN	; GET LENGTH OF LABEL
	LXI	H,@scrbf+LABEL
CHKLAB1:ADD	M
	INX	H
	DJNZ	CHKLAB1
	INR	A
	JRZ	PHYSEL2 	; BR IF CORRECT CHECKSUM
	LDA	MODFLG
	ORA	A		; MODE BEEN CHANGED ?
	jz	physel7 	; NO KEEPING OLD MODE BYTES
	ldx	a,+1
	xri	00010000b	; return mode bytes to former state
	stx	a,+1
	jmp	physel6 	; jmp to error

;
;  EXTRACT MODE INFORMATION FROM LABEL
;
PHYSEL2:
	LXI	H,@scrbf+LABHTH ; DE POINTS TO HEATH EXTENSION IN LABEL
	ldx	b,-1		; keep old format 
	ldx	c,-2
	mvix	0,-1
	mvix	0,-2
	mov	a,m
	ani	1110$0000b
	cpi	z207dev 	; z100 formats
	jrnz	nf1
	setx	0,-2;		; set mode byte
	jr	setmode
nf1:	cpi	z37dev	       
	jrnz	nf2
	bit	2,m		; check for extended density
	jrz	gf1
	setx	4,-1		; z37x
	jr	setmode
gf1:	lda	@scrbf+labhth+2 ; get cpm sectors per physical sector
	cpi	4		; see if 512 byte sectors - if so set to z100
	jrnz	gf0		; this is in here because the Z100 puts the
	setx	0,-2		; device type code in the label on 5"
	jr	setmode
gf0:	setx	3,-1		; z37
	jr	setmode
nf2:	cpi	z47dev	
	jrnz	nf3
	bit	2,m		; check for extended density
	jrz	gf2
	setx	6,-1		; z47x
	jr	setmode
gf2:	setx	5,-1
	jr	setmode
nf3:	cpi	z67dev
	jrz	f1		; keep old mode if device type not valid
	stx	b,-1
	stx	c,-2
	jmp	physel7
f1:	setx	7,-1		; z67
setmode:
	mov	a,m		; get flag byte
	bit	3,a		; track density bit
	jrz	gs0
	setx	5,+0		; set drive and media to dt
	setx	5,+1
	jr	gs2 
gs0:	resx	5,+0
	resx	5,+1
gs2:	bit	1,a		; density bit
	jrz	gs1
	setx	4,+1
	jr	gs3
gs1:	resx	4,+1
gs3:	bit	0,a
	jrz	gs4		; sides bit
	setx	6,+1
	jr	gs6
gs4:	resx	6,+1
gs6:
	lhld	@cmode
	call	?getdp		; setup mode bytes
	jnz	physel6 	; error if format doesnt exists
	push	b		; save XLAT table pointer
 
	lxi	h,zdpb		; move dpb from label to module and set dph
	lxi	d,17
	lda	@rdrv	 
gdpb2:	ora	a
	jrz	gdpb1
	dad	d
	dcr	a
	jr	gdpb2
gdpb1:	liyd	@dph		; set dpb and xlat addr in dph
	pop	b
	sty	c,+0
	sty	b,+1
	sty	l,+12
	sty	h,+13
	xchg
	lxi	b,zdpbl 	; 15
	lxi	h,@scrbf+labdpb
	ldir			; move dpb 

	xchg			; hl points to psh byte (15)
	lda	@scrbf+labhth+2 ; cpm sectors per physical sector
	mov	b,a		; save a copy
	mvi	c,0
pshlp	srlr	a		; rolate LSB into [cy]
	jc	psh1
	inr	c
	jr	pshlp
psh1	mov	m,c		; set PSH byte
	ldx	a,+0
	ani	1111$1100b	; mask off old sector size
	ora	c		; or sector size into mode byte
	stx	a,+0	

	inx	h		; mode pointer to PSM
	dcr	b
	mov	m,b		; put in dpb
	JR	PHYSEL7

PHYSEL6:MVI	A,1
	STA	SELERR		; FLAG A SELECT ERROR
PHYSEL7:MVI	A,0FFH
	STA	SELOP		; SELECT OPERATION IS OVER
	RET

PHYSEL3:CALL	SELECT
	CALL	CHKRDY
	JRC	PHYSEL6 	; ERROR IF NOT READY
	CALL	HOME		;RESTORE HEAD TO TRACK 0
	JRC	PHYSEL6
	MVI	B,01001000B	;STEP IN, NO UPDATE
	CALL	TYPE$I
	CALL	TYPE$I		;STEP IN TWICE
	MVI	A,11000000B	; READ ADDRESS, side 0
	CALL	PUT$I
	ANI	00011000B SHL 1 ;check for FDC error.
	JRNZ	PHYSEL6
	IN	SECTOR
	CPI	2
	JRZ	PHYSEL4
	CPI	1
	JRNZ	PHYSEL6
	lhld	mode
	setb	5,m	;make drive "DT"
	inx	h
	bit	5,m	;test for 40 track already
	jz	physel4
	res	5,m	;make disk "ST" and reconfigure
	mvi	a,0ffh
	sta	@rcnfg	;set "re-configure" flag so BIOS will get new DPB/XLAT
PHYSEL4:
	CALL	HOME  
	JRC	PHYSEL6
	JR	PHYSEL7

setup$rw:
	MVI	A,21		; 21 RETRYS FOR A READ/WRITE OPERATION
	STA	RETRYS
	lhld	@cmode
	inx	h
	inx	h
	shld	mode
	ret

read$316:
	call	setup$rw
READ:	CALL	ACCESS$R	; START DRIVE AND STEP TO PROPER TRACK
	JRC	ERROR
	CALL	IO$COMBO	; Read in the sector to the proper buffer.
	JRZ	NOT8DDR
	LXI	D,RD$8DD
NOT8DDR:MVI	B,10001000B	; READ COMMAND W/O SIDE SELECT
	MVI	A,0A2H		; INI INSTRUCTION (2ND BYTE)
	JR	TYPE$II

ERROR:	XRA	A		; PSW/Z MUST BE RESET TO INDICATE ERROR
	INR	A
	RET

write$316:
	call	setup$rw
WRITE:	LHLD	MODE		; CHECK FOR HALF TRACK R/O
	bit	5,m	;see if drive is DT.
	jrz	ht0
	inx	h
	bit	5,m	;see if media is not DT.
	jrz	ERROR		; R/O ERROR
ht0:	CALL	ACCESS$R	; ACCESS DRIVE FOR WRITE
	JRC	ERROR
	in	stat		; GET DISK STATUS BYTE
	RAL
	RAL			; WRITE PROTECT BIT TO CARRY
	JRC	ERROR		; WRITE PROTECT ERROR
	CALL	IO$COMBO
	JRZ	NOT8DDW
	LXI	D,WR$8DD	; WRITE ROUTINE FOR 8" DD
NOT8DDW:MVI	B,10101000B	; WRITE COMMAND W/O SIDE SELECT
	MVI	A,0A3H		; OUTI INSTRUCTION (2ND BYTE)

TYPE$II:
	STA	FIX1+1		;setup physical routines for read/write
RETRY:						     
	PUSH	B		; save registers
	PUSH	D
	lxi	h,@intby
	mov	a,m		; get interrupt byte
	ANI	11111101B	; Turn 2 millisecond clock off
	mov	m,a
	OUT	PORT		; to prevent interupts from causing lost-data

	DI
	LXI	H,SERIAL	; TURN OFF INTERRUPTS FROM SERIAL PORTS
	IN	PORT1+1
	MOV	M,A
	INX	H
	IN	PORT2+1
	MOV	M,A
	INX	H
	IN	PORT3+1
	MOV	M,A
	INX	H
	IN	PORT4+1
	MOV	M,A
	XRA	A
	OUT	PORT1+1
	OUT	PORT2+1
	OUT	PORT3+1
	OUT	PORT4+1
	EI

	LDA	SIDE		; get the side select bits
	ORA	B		; merge COMMAND and SIDE SELECT bits
	CALL	TYPE$II$COM	; execute disk transfer routine set by 'DE'.
	STA	@dstat		; save status of transfer
	LDA	CTRL$IMAGE
	OUT	CTRL		; BURST MODE OFF.
	lxi	d,@intby
	ldax	d		; get interrupt byte
	ori	00000010b
	stax	d
	OUT	PORT		; CLOCK ON AGAIN

	DI
	LXI	D,SERIAL	; RESTORE SERIAL PORT INTERRUPTS
	LDAX	D
	OUT	PORT1+1
	INX	D
	LDAX	D
	OUT	PORT2+1
	INX	D
	LDAX	D
	OUT	PORT3+1
	INX	D
	LDAX	D
	OUT	PORT4+1
	EI

	XRA	A		; CLEAR CARRY FOR DSBC
	lded	@dma 
	DSBC	D		; HL NOW CONTAINS # OF BYTES TRANSFERRED
	LDA	@dstat		; check for successful transfer
	ANI	10111111B
	JRNZ	IOERR		; RETRY IF ERROR
	LDA	SELOP		; IS THIS A SELECT OPERATION ?
	ORA	A
	JRZ	POPRET		; THEN DON'T CHECK SECTOR SIZE
	LDA	BLCODE		; CHECK IF CORRECT NUMBER OF BYTES TRANSFERRED
	CPI	3
	JRNZ	NOTED		; BLCODE=3 => 1024 BYTE SECTOR EXPECTED
	INR	A		; INCREMENT BECAUSE (H) FOR 1024 IS 4
NOTED:	CMP	H		; COMPARE TO EXPECTED SIZE
POPRET: POP	D
	POP	B
	mvi	a,0	;signal "no error" to BDOS.
	RZ			; RETURN IF CORRECT
	JR	TRYAGN		; RETRY IF INCORRECT
IOERR:	CM	CHKRDY		; IF DISK WAS NOT READY, WAIT FOR READY SIGNAL
	POP	D
	POP	B
	JC	ERROR		; ERROR IF NO READY SIGNAL
TRYAGN: LXI	H,RETRYS	; decrement retry count
	DCR	M
	JZ	ERROR		; NO MORE RETRIES
	MOV	A,M
	CPI	10
	JNC	RETRY		; LESS THAN TEN RETRYS LEFT => STEP HEAD
	LDA	SELOP
	ORA	A
	JZ	RETRY		; DO NOT STEP HEAD IF SELECT OPERATION
	PUSH	B		; SAVE REGISTERS
	PUSH	D
	CALL	STEPIN		; STEP IN COMMAND
	CALL	SEEK		; SEEK WILL REPOSITION HEAD
	POP	D		; RESTORE REGISTERS
	POP	B
	JMP	RETRY		; TRY AGAIN

IO$COMBO:
	LDA	@sect		; GET SECTOR NUMBER
	INR	A		; MAKE IT 1,2,3,...,SPT
	OUT	SECTOR		; give to controller
	LXI	D,IO$1024	; I/O ROUTINE FOR ALL BUT 8" DD
	lda	flag$8dd
	ora	a
	ret		;[ZR] if not 8"DD


SELECT:
	LHLD	MODE		; point to drive mode byte table
	LDA	@rdrv		; get the RELATIVE drive number
	MOV	C,A		; relative drive number in (C) (rel. to driv0)
	mvi	a,0	;assume not 8"DD
	bit	7,m	;check for 8"
	INX	H		; POINT TO MODE BYTE 2
	jrz	se0
	bit	4,m	;and DD
	jrz	se0
	mvi	a,0ffh	;set 8"DD flag
se0:	sta	flag$8dd
	MOV	A,M
	ANI	00010000B	; ISOLATE DENSITY BIT
	XRI	00010000B	; REVERSE IT (CONTROLLER WANTS 1 FOR SDEN.)
	rlc
	rlc
	ORA	C		; OR IN DRIVE SELECT CODE
	ORI	00101000B	; BURST MODE OFF, interrupt line enabled
	STA	CTRL$IMAGE	; save image for subsequent outputs
	dcx	h
	MOV	A,M
	ANI	00001100B	; setup steprate bits for seek-restore commands
	rrc
	rrc
	STA	STEPRA		; RATE FOR SUBSEQUENT SEEK/RESTORE
	LXI	H,LOGDSK	; save position (track) of current drive
	MOV	A,M
	SUB	C		; CURRENT DRIVE SAME AS REQUESTED DRIVE ?
	PUSH	PSW		; SAVE RESULT ON STACK
	MOV	E,M		; in 'trks' array addressed by contents of
	MOV	M,C		; location 'logdsk'.
	MVI	B,0
	MOV	D,B
	LXI	H,TRKS
	DAD	D
	IN	TRACK
	MOV	M,A		; SAVE CURRENT TRACK #
	LXI	H,TRKS		; identify position (track) of requested drive
	DAD	B		; from 'trks' array addressed by new 'logdsk'.
	POP	PSW
	MOV	C,A		; RETURN RESULT OF ABOVE SUB C TO REG. C
	MOV	A,M
	OUT	TRACK		; set track number
	OUT	DATA		; SEEK TO same TRACK CAUSES
	MVI	A,00011011B	; HEAD-LOAD ONLY
	DI	;MUST NOT BE DISTRACTED
	OUT	STAT		; ISSUE COMMAND, HEAD WILL LOAD IN 15uS
	DAD	D		; 5.371 uS
	LDA	CTRL$IMAGE	; +6.348 =11.719 uS
	OUT	CTRL		; +5.371 = 17.090 uS, HEAD IS LOADED BY NOW
	EI			; COMMAND WILL FINISH IN ABOUT 30 uS
	JR $-1			; "RET" DONE BY INTRQ ROUTINE

ACCESS$R:
	lhld	mode
	mov	a,m
	ani	11b
	sta	blcode		;get physical sector size

	mov	c,m		; mode byte 2
	inx	h
	mov	a,m		; mode byte 3
	cma			; get "NOT MDT...
	ana	c		; ... AND DDT"
	ani	00100000b	; flag is in bit 5
	sta	htflag		; half track flag

	CALL	SELECT
	MOV	A,C		; ARE WE SELECTING A DIFFERENT
	ORA	A		; DRIVE FROM BEFORE ?
	JRZ	SEEK
	LXI	D,33000 	; MUST WAIT 400 MS
WAIT:	DCX	D		; - do call to main BIOS to delay
	MOV	A,D		;   for 400 milliseconds.
	ORA	E		;
	JRNZ	WAIT		;
;
SEEK:
	lda	@trk
	ora	a	;see if we're on physical track 0
	jrnz	xf0
	lhld	mode
	inx	h
	lda	@side
	ora	a	;see which side we're on.
	jrnz	xf1
	bit	3,m	;check TRK-0,SID-0 density bit.
	jrz	xf0
	xra	a
	sta	blcode	;select 128 bytes/sector
	lxi	h,ctrl$image
	setb	6,m	;select SD media
	sta	flag$8dd	;also reset 8"DD flag
	jr	xf0
xf1:	bit	2,m	;check TRK-0,SID-1 format (may be 256 bytes/sector)
	jrz	xf0
	mvi	a,1
	sta	blcode	;select 256 bytes/sector
			;leave 8"DD as is.
xf0:	LXI	H,SEKERR	; initialize seek error counters
	MVI	M,4		; 4 ERRORS ON SEEK IS FATAL
	INX	H
	MVI	M,10		; RESTORE once, then 9 errors are fatal
	lda	@side
	rlc
	sta	side
	lda	@trk
	mov	c,a
RETRS:	CALL	CHKRDY		; MAKE SURE DRIVE IS READY
	RC			; quit if drive is not ready
	MOV	A,C		; get track number back
	ORA	A		; FORCES "RESTORE" IF "seek to track 0"
	jz	HOME		;RESTORE HEAD TO TRACK 0
	lda	htflag
	mov	h,a		; get half-track flat in h
	IN	TRACK		;CURRENT HEAD POSITION,
	SUB	C		;SEE HOW FAR WE WANT TO GO.
	RZ			;IF ZERO TRACKS TO STEP, WERE FINISHED
	MVI	B,01111000B	;ASSUME STEP-OUT + UPDATE + HEADLOAD
	JRNC	STOUT	;ASSUMPTION WAS CORRECT...
	MVI	B,01011000B	;ELSE MUST BE STEP-IN
	NEG		;AND NUMBER OF TRACKS WOULD BE NEGATIVE
STOUT:	MOV	L,A		;COUNTER FOR STEPING
SEEK5:	BIT	5,H		; CHECK FOR 48 TPI DISK IN 96 TPI DRIVE
	JRZ	NOTHT
	RES	4,B	;SELECT NO-UPDATE
	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
NOTHT:	SETB	4,B	;SELECT UPDATE TO TRACK-REG
	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	DCR	L
	JRNZ	SEEK5
	IN	SECTOR		;SAVE CURRENT SECTOR NUMBER
	MOV	L,A
	CALL	READ$ADDR	; GET ACTUAL TRACK UNDER HEAD (IN SECTOR REG)
	IN	SECTOR		;GET TRACK NUMBER FROM MEDIA
	MOV	H,A
	MOV	A,L
	OUT	SECTOR		;RESTORE SECTOR NUMBER
	LDA	@dstat		;GET TRUE ERROR STATUS OF READ-ADDRESS
	RLC
	RC			;DRIVE NOT READY
	ANI	00011000B SHL 1 ; CRC ERROR + REC-NOT-FOUND
	MOV	A,H		; ACTUAL TRACK FROM READ-ADDRESS
	LXI	H,SEKERR	;POINT TO ERROR COUNTERS
	JRNZ	RESTR0
	CMP	C		; (C) MUST STILL BE VALID DEST. TRACK
	RZ	;NO ERRORS
RTS00:	DCR	M		; SHOULD WE KEEP TRYING ?
	STC
	RZ			;NO, WE'VE TRYED TOO MUCH
	OUT	TRACK		; re-define head position accordingly
	JR	RETRS		; RETRY SEEK

TRK0ERR:
	XRA	A
	LXI	H,SEKERR
	JR	RTS00

RESTR0: INX	H		; RESTORE ERROR COUNT
	DCR	M
	STC
	RZ			; If count 0, return with Carry set.
	MOV	A,M
	CPI	9
	JRNC	RESTR1		; RESTORE ONLY FIRST TIME
	CALL	STEPIN		; OTHERWISE STEP HEAD IN 1 TRACK
	JR	RETRS
RESTR1: 			; RESTORE HEAD TO TRACK 0
	MVI	A,00000011B
	STA	STEPRA		; RETRY WITH MAXIMUM STEP RATE
	CALL	HOME
	JR	RETRS		; RETRY SEEK

STEPIN: lxi	h,htflag
	INX	H
	BIT	5,M		; CHECK HALF TRACK BIT
	MVI	B,01001000B	; STEP IN WITHOUT UPDATE
	CNZ	TYPE$I		; STEP A SECOND TIME (W/O UPDATE) FOR HALF-TRK
	MVI	B,01011000B	; STEP IN AND UPDATE TRACK REGISTER
	JR	TYPE$I

HOME:		;POSITION HEAD AT TRACK ZERO...
	IN	STAT
	ANI	00000100B	;TEST TRACK ZERO SENSOR,
	JRNZ	@TRK0		;SKIP ROUTINE IF WE'RE ALREADY AT TRACK 0.
	IN	TRACK		;DOES THE SYSTEM THINK WE'RE AT TRACK 0 ??
	ORA	A
	JRNZ	HOME1	;IF IT DOESN'T, ITS PROBEBLY ALRIGHT TO GIVE "RESTORE"
	MVI	L,6 ;(6 TRKS)	;ELSE WE COULD BE IN "NEGATIVE TRACKS" SO...
	MVI	B,01001000B	;WE MUST STEP-IN A FEW TRACKS, LOOKING FOR THE
HOME0:	CALL	TYPE$I		;TRACK ZERO SIGNAL.
	ANI	00000100B SHL 1 ;"SHL 1" BECAUSE CHKRDY DOES AN "RLC"
	JRNZ	@TRK0
	DCR	L
	JRNZ	HOME0
HOME1:	MVI	B,00001000B	;RESTORE COMMAND, WITH HEADLOAD
	CALL	TYPE$I
	XRI	00000100B SHL 1 ;TEST TRACK-0 SIGNAL
	RAR
	RAR
	RAR
	RAR	;[CY] = 1 IF NOT AT TRACK 0
@TRK0:	MVI	A,0
	OUT	TRACK		;MAKE SURE EVERYONE KNOWS WERE AT TRACK 0
	RET

;
READ$ADDR:
	LDA	SIDE
	ORI	11000100B	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	JR	PUT$I		; IGNORE DATA (AND DATA-LOST ERROR)

;
TYPE$I:
	LDA	STEPRA		; STEP-RATE BITS
	ORA	B		; MERGE COMMAND
PUT$I	DI			; prevent interrupt routines
	OUT	STAT		; SEND command TO CONTROLLER
WB:	IN	STAT		; WAIT FOR BUSY SIGNAL
	RAR			; TO COME UP
	JRNC	WB
WNB:	IN	STAT		; poll controller for function-complete
	RAR			; Busy?
	JRC	WNB		; wait until not busy.
	RAL
	STA	@dstat		;SAVE TYPE$II (III) STATUS FOR ERROR DETECTION.
	MVI	A,11010000B	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	STAT
	EI			; re-enable interrupts.
	IN	DATA		; FALL THROUGH TO CHKRDY
	
;
CHKRDY:
	LXI	D,56000 	; WAIT NO MORE THAN 1.6 SECOND FOR READY 
CHKR0:	
	IN	STAT		; read disk status
	RLC			; shift 'NOT READY' bit into Carry
	RNC			; stop if drive is ready 
	DCX	D		; count loops	 
	MOV	A,D	
	ORA	E		; Test for end of loops
	JRNZ	CHKR0		; loop again if not
	IN	STAT		; one last chance for drive to be ready  
	RLC			; Y if NOTRDY	
	RET			; End

INTRQ$ROUTINE:
	IN	STAT		; Clear interrupt request
	INX	SP		; TERMINATE SUB-ROUTINE by eliminating the
	INX	SP		; return address PUSHed by the interrupt.
	EI			; turn interrupts back on.
	RET			; end
LEN$IR	EQU	$-INTRQ$ROUTINE ; length of routine to transfer.

flag$8dd: db	0
STEPRA	DB	0		; STEP RATE CODE 
RETRYS	DB	0
SEKERR	DB	0,0		; SEEK,RESTORE ERROR COUNTS
MODE	DW	0		; POINTER TO MODE BYTE
LOGDSK	DB	8		; CURRENT DRIVE SELECTED BY THIS MODULE
SIDE	DB	0		; SIDE SELECT BIT FOR COMMANDS
BLCODE	DB	0
SELERR: DB	0
SELOP:	DB	0FFH
SERIAL: DB	0,0,0,0
MODFLG: DB	0
TRKS:	DB	255,255,255,255,255,255,255,255,0	
htflag: db	0

	END
