VERS EQU '3 ' ; Oct 7, 2017 15:45 drm "M320'3.ASM"
*************************************************************************

	TITLE	'SASI- DRIVER FOR MMS CP/M 3 SASI BUS INTERFACE'
	MACLIB	Z80
	$*MACRO

	extrn	@dph,@rdrv,@side,@trk,@sect,@dma,@dbnk,@dstat,@intby
	extrn	@dtacb,@dircb,@scrbf,@rcnfg,@cmode,@lptbl,@login
	extrn	?bnksl,?halloc

**************************************************************************
; Configure the number of partitions (numparX) on each LUN in your system
;  and if the LUN is removable (true) or not (false).
**************************************************************************

false	equ	0
true	equ	not false

; Logical Unit 0 characteristics

numpar0 equ	8		; number of partitions on LUN
remov0	equ	false		; LUN removable if TRUE

; Logical Unit 1 characteristics

numpar1 equ	0		; number of partitions on LUN
remov1	equ	false		; LUN removable if TRUE

; Logical Unit 2 characteristics

numpar2 equ	0		; number of partitions on LUN
remov2	equ	false		; LUN removable if TRUE

; Logical Unit 3 characteristics

numpar3 equ	0		; number of partitions on LUN
remov3	equ	false		; LUN removable if TRUE

ndev	equ	numpar0+numpar1+numpar2+numpar3
dev0	equ	50

*************************************************************************
**  PORTS AND CONSTANTS
*************************************************************************

GPIO	EQU	0F2H		; SWITCH 501

ACK	EQU	00000001B
INT	EQU	00000010B
PER	EQU	00000100B
BUSY	EQU	00001000B
CMND	EQU	00010000B
MSG	EQU	00100000B
POUT	EQU	01000000B
REQ	EQU	10000000B

RUN	EQU	00000000B
SWRS	EQU	00010000B
INTE	EQU	00100000B
SEL	EQU	01000000B

RECAL	EQU	1
RDBL	EQU	8	; COMMAND OP CODES
WRBL	EQU	10
INIT	EQU	12

dpbl	equ	17	; length of CP/M 3.0 dpb
alvl	equ	512	; size of allocation vector
csvl	equ	256	; size of check sum vector
modlen	equ	8	; length of each mode byte table entry
datlen	equ	19	; length of each lun data entry
bcode	equ	16	; offset in lun data of the blk code
initflg equ	16	;    "   "   "   "   of lun initialization flag
parstr	equ	17	;    "   "   "   "   of partition start of lun
numpar	equ	18	;    "   "   "   "   of the number of partitions

CSTRNG	EQU	13	; Offsets of data in magic sector
NPART	EQU	19
CBYTE	EQU	4
DDATA	EQU	5
DCTYPE	EQU	3
SECTBL	EQU	20
DDPB	EQU	47

WRALL	EQU	0	; WRITE TO ALLOCATED
WRDIR	EQU	1	; WRITE TO DIRECTORY
WRUNA	EQU	2	; WRITE TO UNALLOCATED
READOP	EQU	3	; READ OPERATION

***************************************************
	cseg

	dw	thread
driv0	db	dev0,ndev
	jmp	init$sasi
	jmp	login
	JMP	READ$SASI
	JMP	WRITE$SASI
	dw	string
	dw	dphtbl,modtbl

string: db	'77320 ',0,'SASI Interface ('
	db	ndev+'0'
	db	' partitions) ',0,'v3.10'
	dw	VERS,'$'

; Mode byte table for SASI driver

modtbl:
drv	set	0
	rept	numpar0
	if	remov0
	db	1001$0000b+drv,000$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,000$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar1
	if	remov1
	db	1001$0000b+drv,001$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,001$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar2
	if	remov2
	db	1001$0000b+drv,010$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,010$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

drv	set	0
	rept	numpar3
	if	remov3
	db	1001$0000b+drv,011$00000b,00000000b,00000000b
	else
	db	1000$0000b+drv,011$00000b,00000000b,00000000b
	endif
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

; Disk parameter tables

dpb:
	rept	ndev
	ds	dpbl
	endm

	$-MACRO
;
;	ACTUAL READ-WRITE OF DATA
;
SASIRW: 			; THIS ROUTINE IS FOR READING AND WRITING
	LDA	CMBFR
	SUI	RDBL		; IS COMMAND A READ ?
	MVI	A,0B2H		; INIR FOR READS
	JRZ	NREAD
	MVI	A,0B3H		; OUTIR FOR WRITES
NREAD:	STA	HERE+1
	LDA	BASE$PORT
	push	psw
	lda	@dbnk
	call	?bnksl
	pop	psw
	lhld	@dma		; data buffer address
	MOV	C,A		; DATA PORT ADDRESS TO REG. C
NXTSEC: INR	C		; INCREMENT TO CONTROL PORT
SASICK: INP	A		; FIRST CHECK FOR DRIVE READY
	STA	@dstat		; STORE STATUS
	ANI	(CMND OR BUSY OR REQ OR POUT)
	CPI	(CMND OR BUSY OR REQ)  ; IF POUT DROPS,
	jrz	done		;  WE ARE INTO STATUS PHASE
	ANI	(CMND OR BUSY OR REQ)
	CPI	(BUSY OR REQ)	; WHEN CMND DROPS, SEEK IS COMPLETE, AND WE ARE
	JRNZ	SASICK		;  READY FOR DATA TRANSFER
	DCR	C		; DATA PORT ADDRESS TO REG. C
	MVI	B,128
HERE:	INIR			; CHANGED TO OUTIR FOR WRITE
	JR	NXTSEC
done:	xra	a
	call	?bnksl		; re-select bank 0
	xra	a
	ret

thread	equ	$

	dseg
	$*MACRO

CNUM:	DB	0

; Disk parameter headers for the SASI driver

ncsv	set	0
drv	set	0

dphtbl:
	rept	numpar0
	dw	0,0,0,0,0,0,dpb+(drv*dpbl)
	if	remov0
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar1
	dw	0,0,0,0,0,0,dpb+(drv*dpbl)
	if	remov1
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar2
	dw	0,0,0,0,0,0,dpb+(drv*dpbl)
	if	remov2
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

	rept	numpar3
	dw	0,0,0,0,0,0,dpb+(drv*dpbl)
	if	remov3
	dw	csv+(ncsv*csvl)
ncsv	set	ncsv+1
	else
	dw	0
	endif
	dw	alv+(drv*alvl),@dircb,@dtacb,0
	db	0
drv	set	drv+1
	endm

; Allocation vectors

alv:
	rept	ndev
	ds	alvl
	endm

; Check sum vectors for removable media

csv:
	rept	ncsv
	ds	csvl
	endm

	$-MACRO

;
;	DRIVER INITIALIZATION CODE
;

init$sasi:
	call	initdata
	MVI	B,7CH
	IN	GPIO		; READ SWITCH 501
	ANI	00000011B	; WHAT'S PORT 7C SET FOR ?
	CPI	00000010B	;  IF Z67, THEN THIS IS IT
	JRZ	GOTPRT
	MVI	B,78H
	IN	GPIO		; READ SWITCH 501
	ANI	00001100B	; WHAT'S PORT 78 SET FOR ?
	CPI	00001000B	;  IF Z67, THEN THIS IS IT
	RNZ
GOTPRT: MOV	A,B
	STA	BASE$PORT	; SAVE BASE PORT ADDRESS
	RET

login:	call	getptr		; set dataptr & ix to current lun data
	bitx	7,+initflg	; CHECK INITIALIZATION BIT in lundata	
	jz	init$hard	; if = 0 read in magic sector

	lda	@rdrv		; See if loging in a drive that doesn't
	subx	+parstr 	;  exist on the magic sector of the drive
	cmpx	+numpar
	jnc	init$err

	lda	driv0
	addx	+parstr 	; b= starting physical drive number
	mov	b,a		; c= # of partitions on logical unit
	ldx	c,+numpar	
	LXI	H,0		; SEARCH MIXER TABLE FOR ANY
	MVI	E,16		; LOGGED IN PARTITIONS FOR THE CURRENT LUN.
	LXIX	@lptbl+15
MLOOP	LDX	A,+0
	SUB	B
	CMP	C		; SET CY IF IN RANGE  (C>x>B)
	DADC	H
	DCXIX	
	DCR	E
	JRNZ	MLOOP
	XCHG			; PUT LOGIN MASK IN DE
	lxi	h,@login	; GET LOGIN VECTOR'S ADDRESS
	MOV	A,M		; COMPARE LSB FIRST
	ANA	E
	jnz	endlog		; RETURN IF ONE OR MORE PARTITIONS ARE LOGIN.
	INX	H
	MOV	A,M		; THEN COMPARE MSB
	ANA	D
	jnz	endlog

	lhld	@cmode		; GET ADDRESS OF CURRENT MODE BYTES
	bit	4,m		; IS IT REMOVABLE MEDIA ?
	jnz	init$hard	;  MUST INITIALIZE
	call	init$drive
	jnz	init$err
endlog:
	; TODO: removable requires MAX size?
	; Note: computation not needed if already set
	lhld	@dph
	lxi	d,12	; offset of DPH.DPB
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,7	; offset of DPB.DRM
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a	; HL=DRM
	inx	h
	; TODO: check overflow? must be < 8192
	dad	h
	dad	h	; HL*=4: HASH size
	mov	c,l
	mov	b,h
	call	?halloc
	xra	a
	ret

INIT$HARD:
	call	getcon		; restore head
	lxi	h,rcmnd
	xra	a
	sta	rcmnd+5
	cz	outcm0
	cz	chk$stat
	jnz	init$err
	MVI	A,RDBL		; OP CODE TO READ A SECTOR
	STA	CMBFR
	XRA	A		; SECTOR 0
	STA	CMBFR+1
	STA	CMBFR+2
	STA	CMBFR+3
	sta	@dbnk		; set disk bank = 0
	INR	A
	STA	CMBFR+4 	; READ 1 SECTOR
	lxi	h,@scrbf	; use bios scratch buffer for magic sector
	shld	@dma
	CALL	GETCON		; WAKE UP CONTROLLER
	CZ	OUTCOM		; OUTPUT READ COMMAND
	CZ	SASIRW		; READ IN SECTOR
	CZ	CHK$STAT	; CHECK STATUS OF READ
	JNZ	INIT$ERR

	lda	@scrbf+NPART	; COMPARE # OF PART. DRIVER & MAGIC SECTOR
	lixd	dataptr
	cmpx	+numpar
	jnc	usemag		; USE THE SMALLEST ONE
	stx	a,+numpar
usemag:
	ldx	b,+parstr	; Calculate start of dpb for current lun
	inr	b
	lxi	h,dpb-dpbl
	lxi	d,dpbl
dpbloop dad	d
	djnz	dpbloop

	xchg			; put to address in de
	lxi	h,@scrbf+DDPB	; PUT FROM ADDRESS IN HL
	ldx	a,+numpar	; Put number of partitions to be moved on stack
movdpblp:
	push	psw
	lxi	b,dpbl-2	; Put length of dpb in BC minus psh & psm bytes
	ldir			; move dpb
	mov	a,m		; Get old 2.2 mode byte 1 from magic sector
	ani	00000011b	; mask - leave phyiscal sector size
	stax	d		; 16th byte in cpm 3 dpb is block code (psh)
	inx	d	
	cpi	2
	jrc	gotit
	inr	a
	cpi	4
	jrc	gotit
	mvi	a,7
gotit:	stax	d		; 17th byte in cpm 3 dpb (phm)
	inx	d		; Next dpb
	lxi	b,6		; Skip over old mode bytes in magic sector
	dad	b
	pop	psw		; dec partition count
	dcr	a
	jnz	movdpblp

	dcx	d		; pointer back to psh
	dcx	d
	ldax	d
	stx	a,+bcode	; put bk code in lun data

	ldx	b,+parstr	; partition start
	inr	b
	lxi	d,modlen
	lxi	h,modtbl-modlen
modloop dad	d
	djnz	modloop

	xchg
	lxi	h,@scrbf+SECTBL ; FROM ADDRESS
	ldx	b,+numpar
nxtdef	push	b		; MOVE PARTITION ADDRESS TABLE INTO DRIVER
	inx	d		; skip over first mode byte
	ldax	d		; DE = modtbl
	ora	m		; HL = @scrbf+SECTBL (MAGIC SECTOR)
	mov	m,a
	lxi	b,3		; length of partition address
	ldir
	inx	d		; skip over mask bytes (4) in modtbl
	inx	d
	inx	d
	inx	d
	pop	b
	djnz	nxtdef

	lded	dataptr 	; put dataptr in de
	LXI	H,@scrbf+DCTYPE ; GET L.U.N. SPECIFIC DATA FROM MAGIC SECTOR
	LXI	B,16		; PUT IT INTO SPACE RESERVED FOR THIS L.U.N.
	LDIR

	call	init$drive	; Send initialization code
	jrnz	init$err

	lixd	dataptr
	setx	7,+initflg	; Set initialization bit
	jmp	endlog

INIT$ERR:
	mvi	a,0ffh		; error flag to bios
	ret

INIT$DRIVE:
	LHLD	DATAPTR 	; SEE IF IT'S XEBEC
	MOV	A,M
	ANI	11100000B
	JRNZ	NOTXBC		; SKIP IF NOT
	CALL	GETCON		; GET CONTROLLER'S ATTENTION
	LXI	H,ICMND 	; INITIALIZATION COMMAND STRING
	CZ	OUTCM0		; OUTPUT COMMAND
	RNZ
	LHLD	DATAPTR 	; DRIVE CHARACTERISTIC DATA
	INX	H
	INX	H
	MVI	B,8		; 8 BYTES LONG
	MVI	E,(REQ OR POUT OR BUSY)
	CALL	OUTCM1		; OUTPUT THE DATA
	CZ	CHK$STAT	;  AND CHECK STATUS
	JMP	ENDINIT
NOTXBC: LHLD	DATAPTR
	LXI	D,10		; NOW DO "ASSIGN DRIVE TYPE" COMMAND
	DAD	D		;  ( FOR DATA PERIPHERALS DONTROLLERS )
	PUSH	H
	CALL	GETCON		; GET CONTROLLER'S ATTENTION
	POP	H
	CZ	OUTCM0		; SEND THE COMMAND
	CZ	CHK$STAT
ENDINIT CALL	GETCON		; restore head
	LXI	H,RCMND
	lixd	dataptr
	ldx	a,+1
	sta	rcmnd+5
	CZ	OUTCM0
	CZ	CHK$STAT
	RET

;	READ - WRITE ROUTINES
;
;	READ A PHYSICAL SECTOR CODE
;
READ$SASI:
	MVI	A,RDBL		; READ COMMAND CODE
	JR	DO$RW		; COMMON READ-WRITE ROUTINE
;
;	WRITE A PHYSICAL SECTOR CODE
;
WRITE$SASI:
	MVI	A,WRBL		; WRITE COMMAND CODE
;
;	COMMON READ-WRITE CODE
;
DO$RW:	STA	CMBFR		; COMMAND BUFFER OP CODE
	call	getptr		; Set dataptr and ix to current lun data
	CALL	SET$SEC 	; CALCULATE AND INSTALL ACTUAL SECTOR
	CALL	WAKE$UP 	; SETUP CONTROLLER
	CZ	OUTCOM		; AND OUTPUT THE COMMAND
	CZ	SASIRW		; DO READ OR WRITE
	CZ	CHK$STAT	; CHECK THE BUS RESPONSE
	jrnz	error
	RET

error:	mvi	a,1
	ret

;	CALCULATE THE REQUESTED SECTOR
;
SET$SEC:
	LHLD	@trk		; GET REQUESTED TRACK
	DAD	H		; *2
	DAD	H		; *4
	DAD	H		; *8
	DAD	H		; *16
	DAD	H		; *32
	DAD	H		; *64 (64 SECTORS/TRACK)
	PUSH	H
	LHLD	@cmode
	inx	h		; second byte
	mov	a,m
	ani	00011111b	; mask off lun bits
	mov	c,a
	INX	H
	MOV	D,M
	INX	H
	MOV	E,M
	POP	H
	DAD	D		; ADD IN PARTITION OFFSET
	JRNC	NOCAR0		; CARRY FROM DAD (IF ANY) GOES INTO
	INR	C		;  HIGH ORDER BYTE OF SECTOR NUMBER
NOCAR0: lixd	dataptr 	; get block code (psh)
	ldx	a,+bcode
	ani	00000011b
	mov	b,a
	ORA	A
	JRZ	NODIV
NXDIV:	SRAR	C
	RARR	H
	RARR	L
	DJNZ	NXDIV
NODIV:	LDA	@sect		; GET REQUESTED SECTOR
	MOV	E,A
	MVI	D,0
	DAD	D		; ADD IT IN
	JRNC	NOCAR1
	INR	C
NOCAR1: MOV	A,C
	STA	CMBFR+1 	; MOVE TO COMMAND BUFFER
	MOV	A,H
	STA	CMBFR+2 	; MOVE REST OF SECTOR NUMBER TO COMMAND BUFFER
	MOV	A,L
	STA	CMBFR+3
	MVI	A,1		; TRANSFER 1 SECTOR
	STA	CMBFR+4
	ldx	a,+1		; GET CONTROL BYTE
	STA	CMBFR+5 	; PUT INTO COMMAND BUFFER
	RET

WAKE$UP:CALL	GETCON
	RZ
	CALL	INIT$DRIVE
	RNZ
	CALL	GETCON
	RET

;	GET THE BUS' ATTENTION
;
GETCON:
	LDA	BASE$PORT
	MOV	C,A
	INR	C		; CONTROL PORT ADDRESS TO REG. C
	mvi	a,RUN
	outp	a		; clear sel bit
	MVI	B,0		; TIMER COUNTER
GETCN1: DCR	C
	XRA	A
	OUTP	A		; CLEAR DATA REGISTER
	LDA	CNUM		; GET CONTROLLER NUMBER
	INR	C		; AND SEND IT TO THE CARD
	INR	C		; -SENC- PORT
	OUTP	A
	DCR	C		; CONTROL PORT
	INP	A		; READ CONTROL PORT
	ANI	BUSY
	JRZ	GETCN2
	DJNZ	GETCN1
	DCR	B		; RESET PSW/Z TO INDICATE ERROR
	RET
GETCN2:
	MVI	A,SEL
	OUTP	A		; WAKE UP CONTROLER
	MVI	B,0
GETCN3:
	INP	A
	ANI	BUSY
	JRNZ	GETCN4
	DJNZ	GETCN3
	DCR	B		; RESET PSW/Z TO INDICATE ERROR
	RET
GETCN4:
	MVI	A,RUN
	OUTP	A
	XRA	A		; NO ERROR
	RET

; OUTCOM: OUTPUT A COMMAND TO THE DRIVE
;
OUTCOM: LXI	H,CMBFR
OUTCM0: INX	H
	mov	a,m		; Clear lun bits in command buffer
	ani	00011111b
	mov	m,a
	LDA	LUN		; OR L.U.N. BITS INTO COMMAND
	ORA	M
	MOV	M,A
	DCX	H
	MVI	B,6		; COMMAND IS 6 BYTES LONG
	LDA	BASE$PORT
	MOV	C,A		; DATA PORT TO REG. C
	INR	A
	MOV	D,A		; CONTROL PORT TO REG. D
	MVI	E,(REQ OR CMND OR POUT OR BUSY)
OUTCM1: PUSH	B
	MVI	B,16		; SET LOOP COUNTER
	MOV	C,D		; CONTROL PORT ADDRESS TO REG. C
OUTLOP: INP	A
	ANI	(REQ OR CMND OR POUT OR BUSY)
	CMP	E
	JRZ	OUTOK
	DJNZ	OUTLOP
	DCR	B
	POP	B
	RET
OUTOK:	POP	B		; RETURNS DATA PORT ADDRESS TO REG. C
	OUTI			; OUTPUT COMMAND BYTE
	JNZ	OUTCM1
	XRA	A
	RET

;	CHECK STATUS OF READ OR WRITE
;
CHK$STAT:			; THIS ROUTINE CHECKS WHAT'S UP
	LXI	H,STAT		; STATUS BUFFER
	LDA	BASE$PORT
	MOV	D,A		; DATA PORT ADDRESS STORED IN REG. D
	INR	A
	MOV	E,A		; CONTROL PORT ADDRESS STORED IN REG. E
	JR	CHK01
CHKNXT: MOV	C,D		; INPUT FROM DATA PORT
	INP	A
	MOV	M,A		; SAVE IN MEMORY
CHK01:	MOV	C,E		; INPUT FROM CONTROL PORT
	INP	A
	ANI	(MSG OR REQ OR CMND OR POUT)
	CPI	(REQ OR CMND)
	JRZ	CHKNXT
	CPI	(MSG OR REQ OR CMND)
	JRNZ	CHK01
	MOV	C,D		; INPUT FROM DATA PORT
	INP	A		; GET FINAL BYTE
	MOV	A,M		; AND THROW IT AWAY, GET STATUS
	ANI	03		; EITHER BIT SET IS AN ERROR
	RET

get$ptr:
	lhld	@cmode
	inx	h		; Mode byte #1
	mov	a,m
	ani	01100000b	; Isolate logical unit number bits
	sta	lun
	lxix	lundata
	ora	a		; if lun zero then exit
	jrz	endptr
	rlc
	rlc
	rlc			; move them down
	mov	b,a
	lxi	d,datlen
lunloop dadx	d
	djnz	lunloop
endptr	sixd	dataptr 	; set up pointer to current lun data
	ret

initdata:
	lxix	modtbl		; START OF MODE BYTE TABLE
	lxi	b,modlen
	lxiy	lundata 	; start of lundata
	lxi	d,datlen
	ldx	a,+1
	ani	01100000b
	mov	h,a
	lda	driv0+1 	; Get total number of partitions

iloop1	push	psw		; Put on stack
	ldx	a,+1
	ani	01100000b
	cmp	h		; see if equal to previous lun
	jz	nxtlun		; if equal next mode byte entry
	mov	h,a		; save new lun
	ldy	a,+numpar	; add number partitions and old part. start
	addy	+parstr 	;  equals new partition start.
	dady	d		; next lun data entry
	sty	a,+parstr
nxtlun	inry	+numpar 	; inc # of partitions
	dadx	b		; next mode byte table entry
	pop	psw		; check if end of partitions
	dcr	a
	jnz	iloop1
	ret

;
;	DATA BUFFERS AND STORAGE
;

; 16 bytes of data are pull from each logical unit
; from the magic sector, 3 bytes for system use.

LUNDATA:
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; BYTE 0		: DRIVE/CONTROLLER CODE
; BYTE 1		: CONTROL BYTE
; BYTES 2 - 9		: DRIVE CHARACTERISTIC DATA
; BYTES 10 - 15 	: ASSIGN DRIVE TYPE COMMAND

; BYTE 16 - BITS 1,0	: BLK CODE Set in init$hard 0=128,1=256,2=512,3=1024
;	  - BIT  7	: LOGICAL UNIT INITIALZATION FLAG (Set in init$hard)
; BYTE 17		: STARTING PARTITION # OF THE LUN (Set in findstr)
; BYTE 18		: NUMBER OF PARTITIONS ON THE LUN (Set in findstr)

DATAPTR:DW	0		; POINTER TO LUNDATA FOR THIS L.U.N.
LUN:	DB	0		; CURRENT LUN  (Set when getptr is called)

CMBFR:	DB	0,0,0,0,0,0	; COMMAND BUFFER
ICMND:	DB	INIT,0,0,0,0,0	; INITIALIZE DRIVE CHARACTERISTICS COMMAND
RCMND:	DB	RECAL,0,0,0,0,0 ; Restore head command buffer
BASE$PORT:
	DB	0		; BASE PORT ADDRESS (Set in init$sasi)
STAT:	DB	0

	END
