VERS EQU '1 ' ; Aug 10, 1983   9:07  mjm  "Z37'3.ASM"
;*********************************************************
;	Disk I/O module for MMS CP/M 3.1
;	for the Zenith Z37 controller
;	Copyright (c) 1983 Magnolia Microsystems
;*********************************************************
	MACLIB Z80

	extrn	@dph,@rdrv,@side,@trk,@sect,@dma,@dbnk,@dstat,@intby
	extrn	@dtacb,@dircb,@scrbf,@rcnfg,@cmode,@tick0
	extrn	?bnksl,?timot,?getdp

;---------------------------------------------------------
;
;	Physical drives are assigned as follows:
;
;	46 - 1st Z37 drive
;	47 - 2nd Z37 drive
;	48 - 3rd Z37 drive
;	49 - 4th Z37 drive
;
;---------------------------------------------------------
;	Ports and Constants
;---------------------------------------------------------
;  PORT ASSIGNMENTS
FD$BASE EQU	078H		; BASE PORT ADDRESS
FD$CON	EQU	FD$BASE 	; DISK CONTROL PORT
FD$INT	EQU	FD$BASE+1	; INTERFACE MUX PORT
FD$CMD	EQU	FD$BASE+2	; 1797 COMMAND REGISTER
FD$STA	EQU	FD$BASE+2	;      STATUS REGISTER
FD$DAT	EQU	FD$BASE+3	;      DATA REGISTER
FD$SEC	EQU	FD$BASE+2	;      SECTOR REGISTER
FD$TRK	EQU	FD$BASE+3	;      TRACK REGISTER

;  INTERFACE MUX PORT FLAGS
FD$CD	EQU	0		; ACCESS C/D REGISTERS
FD$TS	EQU	1		; ACCESS T/S REGISTERS

;  COMMANDS
FDCRST	EQU	000H		; RESTORE
FDCSEK	EQU	010H		; SEEK
FDCSTP	EQU	020H		; STEP
FDCSTI	EQU	040H		; STEP IN
FDCSTO	EQU	060H		; STEP OUT
FDCRDS	EQU	080H		; READ SECTOR
FDCWRS	EQU	0A0H		; WRITE SECTOR
FDCRDA	EQU	0C0H		; READ ADDRESS
FDCRDT	EQU	0E0H		; READ TRACK
FDCWRT	EQU	0F0H		; WRITE TRACK
FDCFI	EQU	0D0H		; FORCE INTERRUPT

;  TYPE 1 COMMAND FLAGS
FDFUTR	EQU	00010000B	; UPDATE TRACK REGISTER
FDFHLB	EQU	00001000B	; HEAD LOAD AT BEGINNING
FDFVRF	EQU	00000100B	; VERIFY FLAGS

;  TYPE 1 COMMAND STEP RATE FLAGS
FDFS6	EQU	00000000B	; STEP RATE 6 MS
FDFS12	EQU	00000001B	;	   12
FDFS20	EQU	00000010B	;	   20
FDFS30	EQU	00000011B	;	   30

;  TYPE 2&3 COMMAND FLAGS
FDFMRF	EQU	00010000B	; MULTIPLE RECORD FLAG
FDFSLF	EQU	00001000B	; SECTOR LENGTH FLAG
FDFDLF	EQU	00000100B	; 30 MS DELAY
FDFSS1	EQU	00000010B	; SELECT SIDE 1
FDFDDM	EQU	00000001B	; DELETED DATA MARK

;  TYPE 4 COMMAND FLAGS
FDFINI	EQU	00000000B	; TERMINATE WITH NO INTERRUPT
FDFII0	EQU	00000001B	; NOT READY TO READY TRANSITION
FDFII1	EQU	00000010B	; READY TO NOT READY TRANSITION
FDFII2	EQU	00000100B	; INDEX PULSE
FDFII3	EQU	00001000B	; IMMEDIATE INTERRUPT

;  STATUS FLAGS
FDSNRD	EQU	10000000B	; NOT READY
FDSWPV	EQU	01000000B	; WRITE PROTECT VIOLATION
FDSHLD	EQU	00100000B	; HEAD IS LOADED
FDSRTE	EQU	00100000B	; RECORD TYPE
FDSWTF	EQU	00100000B	; WRITE FAULT
FDSSEK	EQU	00010000B	; SEEK ERROR
FDSRNF	EQU	00010000B	; RECORD NOT FOUND
FDSCRC	EQU	00001000B	; CRC ERROR
FDSTK0	EQU	00000100B	; FOUND TRACK 0
FDSLDT	EQU	00000100B	; LOST DATA
FDSIND	EQU	00000010B	; INDEX HOLE
FDSBSY	EQU	00000001B	; BUSY

;  INFO RETURNED BY A READ ADDRESS COMMAND
FDRATRK EQU	0		; TRACK
FDRASID EQU	1		; SIDE
FDRASEC EQU	2		; SECTOR
FDRASL	EQU	3		; SECTOR LENGTH
FDRACRC EQU	4		; 2 BYTE CRC
FDRAL	EQU	6		; LENGTH OF READ ADDRESS INFO

;  DISK HEADER SECTOR LENGTH VALUES
FDSL128 EQU	0		; SECTOR LENGTH 128
FDSL256 EQU	1		; SECTOR LENGTH 256
FDSL512 EQU	2		; SECTOR LENGTH 512
FDSL1K	EQU	3		; SECTOR LENGTH 1024

;  CONTROL REGISTER FLAGS
CONIRQ	EQU	00000001B	; ENABLE INT REQ
CONDRQ	EQU	00000010B	; ENABLE DRQ INT / DISABLE SYSTEM INT
CONMFM	EQU	00000100B	; ENABLE MFM
CONMO	EQU	00001000B	; MOTOR(S) ON
CONDS0	EQU	00010000B	; DRIVE 0
CONDS1	EQU	00100000B	; DRIVE 1
CONDS2	EQU	01000000B	; DRIVE 2
CONDS3	EQU	10000000B	; DRIVE 3

;  DISK PARAMETER ENTRY DESCRIPTION
DPHDPB	EQU	10		; DISK PARAMETER BLOCK ADDRESS

;  HEATH EXTENSIONS
DPEH37	EQU	01100000B	; H37
DPEHL	EQU	8		; LENGTH OF HEATH EXTENSION

;  DISK PARAMETER BLOCK
DPBL	EQU	15		; LENGTH OF DISK PARAMETER BLOCK

;  DISK LABEL DEFINITIONS
LABVER	EQU	0		; CURRENT FORM # FOR LABEL
LABBUF	EQU	0		; SLOT FOR JUMP INSTRUCTION AROUND LABEL
LABEL	EQU	LABBUF+4
LABTYP	EQU	LABEL+0 	; SLOT FOR LABEL TYPE
LABHTH	EQU	LABTYP+1	; SLOT FOR HEATH EXTENSIONS TO DPE
LABDPB	EQU	LABHTH+DPEHL	; SLOT FOR DISK PARAMETER BLOCK
LABCS	EQU	LABDPB+DPBL	; CHECKSUM
LABLEN	EQU	LABCS-LABEL+1	; LABEL LENGTH
zdpbl	equ	15
z207dev equ	001$00000b	; labe device type codes used to get format
z37dev	equ	011$00000b

;  MISCELLANEOUS VALUES
FDHDD	EQU	20
H37VEC	EQU	8*4		; LEVEL 4 INTERRUPT
DLYMO37 EQU	230		; MOTOR TURN OFF DELAY COUNTER
DLYH37	EQU	154		; DESELECT DELAY COUNTER

PORT	EQU	0F2H		; Z89 INTERRUPT CONTROL
PORT1	EQU	0E8H		; SERIAL PORT #1
PORT2	EQU	0E0H		; SERIAL PORT #2
PORT3	EQU	0D8H		; SERIAL PORT #3
PORT4	EQU	0D0H		; SERIAL PORT #4

driv0	equ	46		; first drive in system
ndriv	equ	4		; # of drives is system
DPHL	EQU	16		; LENGTH OF DISK PARAMETER HEADER
DPBL	EQU	15		; LENGTH OF DISK PARAMETER BLOCK
DPHDPB	EQU	10		; LOCATION OF DPB ADDRESS WITHIN DPH
MOD48RO EQU	00000100B	; 48 TPI DISK IN 96 TPI DRIVE (R/O)
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
DPEH37	EQU	60H		; I.D.

false	equ	0
true	equ	not false
;-------------------------------------------------------
;	Start of relocatable disk I/O module.
;-------------------------------------------------------
	cseg

	dw	thread
	db	driv0,ndriv
	jmp	init$z37
	jmp	login$z37
	JMP	READ$Z37
	JMP	WRITE$Z37
	dw	string
	dw	dphtbl,modtbl

string: DB	'Z89-37',0,' Double Density Controller ',0,'v3.10'
	DW	VERS
	DB	'$'

modtbl: db	00000000b,00000001b,01011110b,00010000b ; drive 46 mms,dd,ss,st
	  db	11111110b,11100110b,10010000b,00000000b       
	db	00000000b,00000001b,01011110b,00010000b ; drive 47 mms,dd,ss,st
	  db	11111110b,11100110b,10010000b,00000000b
	db	00000000b,00000001b,01011110b,00010000b ; drive 48 mms,dd,ss,st
	  db	11111110b,11100110b,10010000b,00000000b
	db	00000000b,00000001b,01011110b,00010000b ; drive 49 mms,dd,ss,st
	  db	11111110b,11100110b,10010000b,00000000b

z37dpb: ds	17	; local dpb's for z37 "auto format select"
	ds	17
	ds	17
	ds	17

H37CTL	db	0		; H37 CONTROL REGISTER IMAGE
RDYFLG	db	0		; = FF if drive seclected and motor running

type$II$com:
	push	psw		; save command
	lda	@dbnk
	call	?bnksl		; select bank for disk transfer
	pop	psw		; restore controller command
	lhld	@dma		; DATA BUFFER ADDRESS
	MVI	C,FD$DAT	; DATA PORT TO REG. C
	CALL	IO$1024 	; TRANSFER THE SECTOR
	push	psw		; save statys of disk operation
	xra	a
	call	?bnksl		; reselect bank 0 (the one we were called from)
	pop	psw
	ret

IO$1024:
	OUT	FD$CMD		; send command to controller
	EI			; turn on interrupts
RW1	HLT			; WAIT FOR DRQ
FIX1	INI			; transfer byte (INI becomes OUTI for writes)
	JR	RW1		; loop until transfer complete.
				; RETURN DONE BY INTERRUPT ROUTINE
H37ISR: MVI	A,10
H37ISR1:DCR	A		; DELAY A WHILE TO LET STATUS SETTLE
	JRNZ	H37ISR1
	MVI	A,FD$CD 	; SELECT STATUS REGISTER
	OUT	FD$INT
	IN	FD$STA		; Clear interrupt request
	INX	SP		; TERMINATE SUB-ROUTINE by eliminating the
	INX	SP		; return address PUSHed by the interrupt.
	EI			; turn interrupts back on.
	RET			; end

motoff: LDA	H37CTL		; GET THE CURRENT VALUE OF THE CONTROL PORT
	ANI	0FFH-CONMO	; TURN OFF MOTOR
	STA	H37CTL
	OUT	FD$CON
	RET

desel:	LDA	H37CTL		; DESELECT THE DRIVE
	ANI	0FFH-CONDS0-CONDS1-CONDS2-CONDS3
	STA	H37CTL	  
	OUT	FD$CON
	XRA	A
	STA	RDYFLG		; FLAG DRIVE AS NOT READY
	pop	h
	xthl
	push	h	;HL=tic table entry at counter
	mvi	m,10		; wait 10 more seconds to turn motor off.
	inx	h
	lxi	b,motoff
	mov	m,c
	inx	h
	mov	m,b
	pop	h
	xthl
	pchl	;return

thread	equ	$

	dseg

dphtbl: dw	0,0,0,0,0,0,0,csv46,alv46,@dircb,@dtacb,0 
	db 0
	dw	0,0,0,0,0,0,0,csv47,alv47,@dircb,@dtacb,0 
	db 0
	dw	0,0,0,0,0,0,0,csv48,alv48,@dircb,@dtacb,0 
	db 0
	dw	0,0,0,0,0,0,0,csv49,alv49,@dircb,@dtacb,0  
	db 0

csv46:	ds	(256)/4 	; max dir entries: 256
csv47:	ds	(256)/4
csv48:	ds	(256)/4
csv49:	ds	(256)/4

alv46:	ds	(400)/4 	; max blocks: 395
alv47:	ds	(400)/4 	; (double bit)
alv48:	ds	(400)/4
alv49:	ds	(400)/4

**************************************************************************
;									 *
; INIT$Z37 -- SETS UP JUMP TO INTERRUPT ROUTINE IN PAGE 0 OF MEMORY	 *
;   AND JUMP TO Z37 MOTOR TIME OUT ROUTINE IN BIOS OVERLAY AREA 	 *
;*************************************************************************
 
INIT$Z37:
	MVI	A,(JMP) 	; INSTALL H37 INTERRUPT ROUTINE
	LXI	H,H37ISR
	STA	H37VEC
	SHLD	H37VEC+1
	RET

login$z37:
	pushix			; save IX
	lixd	@cmode
	inxix
	inxix
	sixd	mode		; save mode+2 for faster access to modes
	xra	a
	sta	selerr
	sta	rdyflg
	bitx	7,+1		; should we read track 0 sector 0 ?
	cnz	physel
	lda	selerr
	ora	a
	cz	physel3 	; check for half track if no selerr
	popix
	lda	selerr
	ora	a
	ret

;--------------------------------------------------------------------------
; PHYSICAL SELECT ROUTINE -- TO READ DISK LABEL, GET MODE AND DPB INFO,
;   AND CHECK FOR HALF-TRACK
;--------------------------------------------------------------------------

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
	MVI	A,5		; RESET RETRYS TO 5
	STA	RETRYS
	STA	MODFLG		; SET CHANGED MODE FLAG
				; IX=mode bytes
	ldx	a,+1		; TRY OTHER DENSITY
	XRI	00010000b
	stx	a,+1
	call	on$h37		; sets density according to mode byte
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
nf2	stx	b,-1
	stx	c,-2
	jmp	physel7
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
 
	lxi	h,z37dpb	; move dpb from label to module and set dph
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

;
; CHECK FOR HALF-TRACK
;
PHYSEL3:CALL	SELECT
	JRC	PHYSEL6 	; ERROR IF NOT READY
	CALL	HOME		;RESTORE HEAD TO TRACK 0
	JRC	PHYSEL6
	MVI	B,FDCSTI+FDFHLB ;STEP IN, NO UPDATE
	CALL	TYPE$I
	CALL	TYPE$I		;STEP IN TWICE
	MVI	A,FDCRDA	; READ ADDRESS
	CALL	PUT$I
	ANI	FDSRNF+FDSCRC
	JRNZ	PHYSEL6
	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC
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

PHYSEL5:
PHYSEL6:MVI	A,1
	STA	SELERR		; FLAG A SELECT ERROR
PHYSEL7:MVI	A,0FFH
	STA	SELOP		; SELECT OPERATION IS OVER
	JMP	DONE

setup$rw:
	mvi	a,21
	sta	retrys
	lhld	@cmode
	inx	h
	inx	h
	shld	mode
	ret

read$z37:
	call	setup$rw
READ:	CALL	ACCESS$R	; START DRIVE AND STEP TO PROPER TRACK
	JC	ERROR
	MVI	B,FDCRDS+FDFSLF ; READ COMMAND W/O SIDE SELECT
	MVI	A,0A2H		; INI INSTRUCTION (2ND BYTE)
	JR	TYPE$II

write$z37:
	call	setup$rw
WRITE:	LHLD	MODE		; CHECK FOR HALF TRACK R/O
	bit	5,m		; see in drive is DT
	jrz	ht0
	inx	h
	bit	5,m		; see if media is not DT
	jz	ERROR
ht0:	CALL	ACCESS$R	; ACCESS DRIVE FOR WRITE
	JC	ERROR
	LDA	@dstat		; GET DISK STATUS BYTE
	RAL
	RAL			; WRITE PROTECT BIT TO CARRY
	JC	ERROR		; WRITE PROTECT ERROR
	MVI	B,FDCWRS+FDFSLF ; WRITE COMMAND W/O SIDE SELECT
	MVI	A,0A3H		; OUTI INSTRUCTION (2ND BYTE)
TYPE$II:
	STA	FIX1+1		;setup physical routines for read/write
RETRY:						     
	PUSH	B		; save registers
	PUSH	D
 IF 0	;this is not needed with Z89-37 hardware.
	lxi	h,@intby	; get interrupt byte
	mov	a,m
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
 ENDIF
	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	LDA	@sect		; MAKE SECTOR 1,2,3,...,SPT
	INR	A
	OUT	FD$SEC		; SEND SECTOR NUMBER TO CONTROLLER
	LDA	SIDE		; get the side select bits
	ORA	B		; merge COMMAND and SIDE SELECT bits
	MOV	B,A
	LDA	H37CTL		; TURN ON DRQ AND IRQ
	ORI	CONDRQ+CONIRQ
	OUT	FD$CON
	MVI	A,FD$CD 	; ACCESS C/D REGS.
	OUT	FD$INT
	MOV	A,B		; GET COMMAND BACK IN ACC.
	call	type$II$com	; transfer the sector
	STA	@dstat		; save status of transfer
	LDA	H37CTL	  
	OUT	FD$CON		; TURN OFF INTERRUPTS
	MVI	A,FDCFI
	OUT	FD$CMD		; FORCE TYPE I STATUS
 IF 0	;this is not needed for Z89-37 hardware.
	push	h		; save address of last byte transferred
	lxi	h,@intby	; get interrupt byte
	mov	a,m
	ori	00000010b
	mov	m,a
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
	pop	h		; address of last byte transferred
 ENDIF
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
	mvi	a,0		; signal "no error" to BDOS
	JRZ	DONE		; DONE IF CORRECT
	JR	TRYAGN		; RETRY IF INCORRECT
IOERR:	POP	D
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

;-------------------------------------------------------------------------
; ERROR: RESET PSW/Z TO INDICATE ERROR AND FALL THROUGH TO DONE
; DONE:  SET DELAY VALUES FOR DESELECT AND MOTOR TURN OFF
;-------------------------------------------------------------------------
ERROR:	XRA	A		; PSW/Z MUST BE RESET TO INDICATE ERROR
	INR	A
DONE:	PUSH	PSW		; SAVE ERROR STATUS
	LDA	SELOP		; CHECK FOR SELECT OPERATION
	ORA	A
	JRZ	RETRN
	LXI	d,desel 	; set up to time out the drive select lines
	mvi	c,4		; wait 4 seconds to turn select off.
	mvi	b,driv0 	; our I.D. to BIOS
	call	?timot		; setup time-out.
RETRN:	POP	PSW		; RECALL ERROR STATUS
	RET


;----------------------------------------------------------------------------
; ACCESS$R: PREPARE DRIVE TO READ A SECTOR
;	    - SELECT DRIVE
;	    - SEEK TO DESIRED TRACK
;----------------------------------------------------------------------------
ACCESS$R:
	lhld	mode
	mov	a,m
	ani	11b
	sta	blcode		; get physical sector size

	mov	c,m		; mode byte 2
	inx	h
	mov	a,m		; mode byte 3
	cma			; get "NOT MDT...
	ana	c		; ... AND DDT"
	ani	00100000b	; flag is in bit 5
	rrc			; put it in bit 4
	sta	htflag		; half track flag

	CALL	SELECT		; SELECT DRIVE
	RC			; ERROR IF DRIVE NOT READY
seek:	LXI	H,SEKERR	; initialize seek error counters
	MVI	M,4		; 4 ERRORS ON SEEK IS FATAL
	INX	H
	MVI	M,10		; RESTORE once, then 9 errors are fatal
	lda	@side
	rlc
	sta	side
	lda	@trk
	mov	c,a
RETRS:	MOV	A,C		; get track number back
	ORA	A		; FORCES "RESTORE" IF "seek to track 0"
	JZ	HOME		;RESTORE HEAD TO TRACK 0
	lda	htflag
	mov	h,a		; get half-track flag in h
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	IN	FD$TRK		; GET CURRENT HEAD POSITION,
	SUB	C		;SEE HOW FAR WE WANT TO GO.
	RZ			       ; IF ZERO TRACKS TO STEP, WERE FINISHED
	MVI	B,FDCSTO+FDFHLB+FDFUTR ; ASSUME STEP-OUT + UPDATE + HEADLOAD
	JRNC	STOUT		       ; ASSUMPTION WAS CORRECT...
	MVI	B,FDCSTI+FDFHLB+FDFUTR ; ELSE MUST BE STEP-IN
	NEG			       ; AND NUMBER OF TRACKS WOULD BE NEGATIVE
STOUT:	MOV	L,A		; COUNTER FOR STEPPING
SEEK5:	BIT	4,H		; CHECK FOR 48 TPI DISK IN 96 TPI DRIVE
	JRZ	NOTHT
	RES	4,B		; SELECT NO-UPDATE
	CALL	TYPE$I		; STEP HEAD
	ANI	FDSTK0		; DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
NOTHT:	SETB	4,B		; SELECT UPDATE TO TRACK-REG
	CALL	TYPE$I		; STEP HEAD
	ANI	FDSTK0		; DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	DCR	L
	JRNZ	SEEK5
	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC		; SAVE CURRENT SECTOR NUMBER
	MOV	L,A
	CALL	READ$ADDR	; GET ACTUAL TRACK UNDER HEAD (IN SECTOR REG)
	MVI	A,FD$TS 	; SECLECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC		; GET TRACK NUMBER FROM MEDIA
	MOV	H,A
	MOV	A,L
	OUT	FD$SEC		; RESTORE SECTOR NUMBER
	LDA	@dstat		; GET TRUE ERROR STATUS OF READ-ADDRESS
	ANI	FDSRNF+FDSCRC	; CRC ERROR + REC-NOT-FOUND
	MOV	A,H		; ACTUAL TRACK FROM READ-ADDRESS
	LXI	H,SEKERR	; POINT TO ERROR COUNTERS
	JRNZ	RESTR0
	CMP	C		; (C) MUST STILL BE VALID DEST. TRACK
	RZ	;NO ERRORS
RTS00:	DCR	M		; SHOULD WE KEEP TRYING ?
	STC
	RZ			; NO, WE'VE TRYED TOO MUCH
	MOV	B,A
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	MOV	A,B
	OUT	FD$TRK		; re-define head position accordingly
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
	JMP	RETRS		; RETRY SEEK

;----------------------------------------------------------------------------
; STEPIN: STEP IN ONE TRACK
;----------------------------------------------------------------------------
STEPIN: lxi	h,htflag
	BIT	4,M		; CHECK HALF TRACK BIT
	MVI	B,FDC$STI+FDFHLB; STEP IN WITHOUT UPDATE
	CNZ	TYPE$I		; STEP A SECOND TIME (W/O UPDATE) FOR HALF-TRK
	MVI	B,FDC$STI+FDFHLB+FDFUTR; STEP IN AND UPDATE TRACK REGISTER
	JR	TYPE$I

;----------------------------------------------------------------------------
; HOME: POSITION HEAD AT TRACK ZERO...
;----------------------------------------------------------------------------
HOME:	MVI	A,FD$CD 	; SELECT STATUS REGISTER
	OUT	FD$INT
	IN	FD$STA		; GET STATUS
	MOV	B,A
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	MOV	A,B
	ANI	FDSTK0		;TEST TRACK ZERO SENSOR,
	JRNZ	@TRK0		;SKIP ROUTINE IF WE'RE ALREADY AT TRACK 0.
	IN	FD$TRK		;DOES THE SYSTEM THINK WE'RE AT TRACK 0 ??
	ORA	A
	JRNZ	HOME1	;IF IT DOESN'T, ITS PROBEBLY ALRIGHT TO GIVE "RESTORE"
	MVI	L,6 ;(6 TRKS)	;ELSE WE COULD BE IN "NEGATIVE TRACKS" SO...
	MVI	B,FDCSTI+FDFHLB ;WE MUST STEP-IN A FEW TRACKS, LOOKING FOR THE
HOME0:	CALL	TYPE$I		;TRACK ZERO SIGNAL.
	ANI	FDSTK0
	JRNZ	@TRK0
	DCR	L
	JRNZ	HOME0
HOME1:	MVI	B,FDCRST+FDFHLB ;RESTORE COMMAND, WITH HEADLOAD
	CALL	TYPE$I
	XRI	FDSTK0		;TEST TRACK-0 SIGNAL
	RAR
	RAR
	RAR	;[CY] = 1 IF NOT AT TRACK 0
@TRK0:	MVI	A,0
	OUT	FD$TRK		;MAKE SURE EVERYONE KNOWS WERE AT TRACK 0
	RET

;---------------------------------------------------------------------------
; READ$ADDR: READ A SECTOR HEADER OFF THE REQUESTED SIDE
;---------------------------------------------------------------------------
READ$ADDR:
	LDA	SIDE
	ORI	FDCRDA+FDFDLF	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	JR	PUT$I		; IGNORE DATA (AND DATA-LOST ERROR)

;************************************************************************
; TYPE$I -- Send a Type I (Seek/Restore) Command To The Controller	*
; PUT$I -- Entry That Ignores Steprate Bits				*
;************************************************************************
TYPE$I: LDA	STEPRA
	ORA	B
PUT$I:	MOV	B,A
	MVI	A,FD$CD 	; SELECT COMMAND/STATUS PORT
	OUT	FD$INT
	MOV	A,B
	DI			; prevent interrupt routines
	OUT	FD$CMD		; SEND command TO CONTROLLER
WB:	IN	FD$STA		; WAIT FOR BUSY SIGNAL
	RAR			; TO COME UP
	JRNC	WB
WNB:	IN	FD$STA		; poll controller for function-complete
	RAR			; Busy?
	JRC	WNB		; wait until not busy.
	RAL
	STA	@dstat		;SAVE TYPE$II (III) STATUS FOR ERROR DETECTION.
	MVI	A,FDCFI 	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	FD$CMD 
	EI			; re-enable interrupts.
	IN	FD$DAT
	IN	FD$STA		; MUST RETURN WITH STATUS IN ACC.
	RET

;---------------------------------------------------------------------------
; SELECT: TURN ON MOTOR, SET UP STEP RATE, SET UP CORRENT TRACK NUMBER
;---------------------------------------------------------------------------
SELECT: LHLD	MODE		; point to drive mode byte table
	LDA	@rdrv
	MOV	C,A
	MOV	A,M
	ANI	00001100B	; setup steprate bits for seek-restore commands
	rrc
	rrc
	STA	STEPRA		; RATE FOR SUBSEQUENT SEEK/RESTORE
	LXI	H,LOGDSK	; save position (track) of current drive
	MOV	E,M		; in 'trks' array addressed by contents of
	MOV	M,C		; location 'logdsk'.
	MVI	B,0
	MOV	D,B
	LXI	H,TRKS
	DAD	D
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	IN	FD$TRK
	MOV	M,A		; SAVE CURRENT TRACK #
	LXI	H,TRKS		; identify position (track) of requested drive
	DAD	B		; from 'trks' array addressed by new 'logdsk'.
	MOV	A,M
	OUT	FD$TRK		; set track number
	mov	a,c
	cmp	e		; if current drive (e) and requested drive (a)
	jnz	do$chk		; not equal do check ready.
	LDA	RDYFLG		; NEED TO CHECK FOR READY ? (to see if drive
	ORA	A		; has been deselected).
	jnz	no$chk
do$chk	call	CHKRDY
	RC			; ERROR IF NOT READY
no$chk	MVI	A,0FFH
	STA	RDYFLG		; FLAG DRIVE AS READY
	RET

;************************************************************************
; CHKRDY -- Check for drive ready					*
;************************************************************************
CHKRDY: CALL	ON$H37		; TURN ON DRIVE
	CALL	WAIT		; WAIT 'TIL UP TO SPEED
	MVI	A,FD$CD 	; ACCESS C/D REGS
	OUT	FD$INT
	MVI	A,FDCFI+FDFINI	; FORCE TYPE I STATUS
	OUT	FD$CMD
	MVI	A,10
RDYH37B:
	DCR	A		; DELAY A WHILE TO LET CONTROLLER SETTLE
	JRNZ	RDYH37B
	EI
	LXI	H,@tick0+1	; GET TIME VALUE
	mov	a,m
	sui	20
	jrz	rdyh37b1
	jrnc	rdyh37b2
rdyh37b1:
	adi	50
rdyh37b2:
	MOV	B,A		; (B) = TIME VALUE
	MVI	C,0		; (C) = HOLE COUNTER
	MOV	D,C		; (D) = INIT HOLE STATUS TO NO HOLE
RDYH37C:
	IN	FD$STA		; GET HOLE STATUS
	ANI	FDSIND
	CMP	D		; CHECK IF CHANGE IN STATUS
	JRZ	RDYH37D 	; BR IF NO CHANGE
	MOV	D,A		; SAVE NEW STATUS
	INR	C		; COUNT TRANSITION
	MVI	A,FDHDD
RDYH37C1:
	DCR	A
	JRNZ	RDYH37C1
RDYH37D:
	MOV	A,B		; CHECK IF TIME UP
	CMP	M
	JRNZ	RDYH37C 	; BR IF NOT
	MOV	A,C		; TIME UP -- CHECK # OF HOLES
	CPI	1*2
	RC			; IF < 1 THEN ERROR
	CPI	3*2+1		; IF <=3 THEN OK
	CMC
	RET 

;------------------------------------------------------------------
; TURN ON MOTOR, SELECT DRIVE, AND SET SETTLE DELAY COUNTER
;------------------------------------------------------------------
ON$H37:
	mvi	c,0	;clear counter
	mvi	b,driv0 ;our I.D. in case we already have an entry.
	call	?timot		; stop timing out of motor and drive select
	LDA	@rdrv
	MVI	B,4
	MVI	C,CONDS0	; START WITH DRIVE 0 BIT POSITION
DRVL:	DCR	A
	JM	GDRIVE
	RLCR	C		; DRIVE SELECT CODE IN REG. C
	DJNZ	DRVL
	MVI	C,0		; NO DRIVE SELECTED
GDRIVE: LHLD	MODE
	INX	H
	MOV	A,M
	ANI	00010000b
	JRZ	ONH37A		; BR IF SINGLE
	MVI	A,CONMFM	; SET DOUBLE DENSITY CONTROL FLAG
ONH37A: ORA	C		; OR IN UNIT SELECT
	ORI	CONMO		; OR THE MOTOR ON
	OUT	FD$CON
	MOV	B,A
	LXI	H,H37CTL	; GET CURRENT VALUE OF THE CONTROL PROT
	MOV	A,M
	ANI	CONMO		; IF THE MOTOR WAS ON
	JRNZ	ONH37B		; THEN WE DON'T HAVE TO WAIT FOR IT TO COME UP
	MVI	A,(1000+3)/4+1	; NORMAL TIMING (APPROX 1 SECOND)
	JR	ONH37C
ONH37B	MOV	A,M		; GET THE OLD VALUE OF THE CONTROL PORT
	ANI	CONDS0+CONDS1+CONDS2+CONDS3	; CHECK SELECT DRIVE(S)
	ANA	B		; CHECK TO SEE IF SAME HEAD ALREADY DOWN
	MVI	A,0
	JRNZ	ONH37C		; YES, ALREADY LOADED, NO DELAY
	MVI	A,(50+3)/4+1	; MUST DELAY FOR HEAD LOAD
ONH37C: STA	DLYW
	MOV	M,B		; SET NEW VALUE OF CONTROL PORT
	RET

HLIHL:	MOV	A,M		; LOAD HL INDIRECT THRU HL
	INX	H
	MOV	H,M
	MOV	L,A
	RET


WAIT:	LDA	@tick0
	RAR			; IS IT EVEN, MAKING 4MS BIG TICKS ?
	JRC	WAIT
	LXI	H,DLYW		; CHECK WAIT TIMER
	MOV	A,M		;  AND DECREMENT IF IT IS NOT ALREADY ZERO
	ORA	A
	RZ
	DCR	M
	JR	WAIT


;-------------------------------------------------------------------------
; MISCELLANEOUS STORAGE
;-------------------------------------------------------------------------
DLYW:	DB	0
STEPRA	DB	0		; STEP RATE CODE 
RETRYS	DB	0
SEKERR	DB	0,0		; SEEK,RESTORE ERROR COUNTS
MODE	DW	0		; POINTER TO MODE BYTE
SIDE	DB	0		; SIDE SELECT BIT FOR COMMANDS
SELERR: DB	0
SELOP:	DB	0FFH
SERIAL: DB	0,0,0,0
MODFLG: DB	0
LOGDSK: DB	4
BLCODE: DB	0
htflag: db	0
;----------------------------------------------------
;	Current head positions for each drive
;----------------------------------------------------
TRKS:	DB	255,255,255,255,0	

	end
ent head positions for each drive
;----------------