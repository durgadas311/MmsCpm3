VERS	EQU   '2 '  ; May 28, 2018 12:29 drm "ldrb320.asm"

	MACLIB	Z80
	$-MACRO

	extrn cboot,btend,loader

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****	   50 - 58 Sasi drives		      *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************

?PORT	EQU	0F2H

BASE$PORT EQU	2150H		; PORT ADDRESS SAVE BY BOOT PROM
BLCODE	EQU	2483H		; DEBLOCK CODE
LSP	EQU	2484H		; LOGICAL SECTORS PER PHYSICAL
				; (PASSED BY BOOT LOADER)
SYSADR	EQU	2377H		; ADDRESS OF WHERE THE COMMAND BUFFER
				; SHOULD BE FOR BOOT LOADER TO PUT PARTITION
				; ADDRESS IN.
DAT	EQU	78H		 
CONT	EQU	79H

REQ	EQU	10000000B
POUT	EQU	01000000B
MSG	EQU	00100000B
CMND	EQU	00010000B
BUSY	EQU	00001000B

RUN	EQU	00000000B
SWRS	EQU	00010000B
SEL	EQU	01000000B


***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	org	2280H
boot:	jmp	around

sysend: dw	btend
systrt: dw	loader
drive:	db	0	;boot drive - calculated at run time
btmode: db	0	;not used by this hard disk loader
	db	50	;first drive
	db	78	;number of drives - includes all controller numbers

around: pop	h	;ADDRESS OF ERROR ROUTINE
	lxi	sp,?stack
	push	h

*****************************************
* Start of unique routine for booting 
*****************************************

	lxi	h,btend
	lxi	d,loader
	ora	a
	dsbc	d		;length of system in bytes
	shld	syssiz
	lxi	d,100h		;add boot module size
	dad	d
	mvi	b,7
	lda	blcode
	cpi	3
	jnz	noinc
	inr	b
noinc	add	b
div0	srlr	h
	rarr	l
	dcr	a
	jrnz	div0
	inr	l		; PHYSICAL SECTORS TO BE BOOTED (rounded up)
	lxix	cmbfr+4
	stx	l,+0

LOAD:	LDA	BASE$PORT
	MOV	C,A
	INR	C		; CONTROL PORT TO REG. C

GETCON: MVI	B,0
GETCN1: INP	A
	ANI	BUSY
	JRZ	GETCN2
	DJNZ	GETCN1
	RET
GETCN2: MVI	A,SEL
	OUTP	A
	MVI	B,0
GETCN3: INP	A
	ANI	BUSY
	JRNZ	GETCN4
	DJNZ	GETCN3
	RET
GETCN4: MVI	A,RUN
	OUTP	A

	DCR	C		; DATA PORT BACK TO REG. C

OUTCOM: LXI	H,CMBFR 	; OUTPUT THE COMMAND
	MVI	B,6
OUTCM1: PUSH	B
	INR	C		; CONTROL PORT
	MVI	B,0		; SET LOOP COUNTER
OUTLOP:	INP	A
	ANI	(REQ OR CMND OR POUT OR BUSY)
	CPI	(REQ OR CMND OR POUT OR BUSY)
	JRZ	OUTOK
	DJNZ	OUTLOP
	RET
OUTOK:	POP	B
	OUTI
	JNZ	OUTCM1

SASI$RW:LXI	H,3000H 	; READ IN SECTORS STARTING AT THIS ADDRESS
NXTSEC: INR	C		; CONTROL PORT
SASICK: INP	A
	ANI	(CMND OR BUSY OR REQ OR POUT)
	CPI	(CMND OR BUSY OR REQ)	; IF POUT DROPS,
	JRZ	CHK$STAT		; WE ARE INTO STATUS PHASE
	ANI	(CMND OR BUSY OR REQ)
	CPI	(BUSY OR REQ)	; WHEN CMND DROPS, SEEK IS COMPLETE, AND
	JRNZ	SASICK		;  WE ARE READY TO READ IN A SECTOR
	DCR	C		; DATA PORT
	LDA	LSP 
MORE:	MVI	B,128
	INIR
	DCR	A
	JRNZ	MORE
WAIT:	DCR	A
	JRNZ	WAIT
	JR	NXTSEC		; SEE IF THER'S ANOTHER SECTOR TO READ IN

CHK$STAT:			; CHECK STATUS OF READ
	LXI	H,STAT
	JR	CHK02
CHKNXT: INP	A
	MOV	M,A
CHK01:	INR	C		; CONTROL PORT
CHK02:	INP	A		; INPUT FROM CONTROL PORT
	DCR	C		; DATA PORT
	ANI	(MSG OR REQ OR CMND OR POUT)
	CPI	(REQ OR CMND)
	JRZ	CHKNXT
	CPI	(MSG OR REQ OR CMND)
	JRNZ	CHK01
	INP	A
	MOV	A,M
	ANI	3
	RNZ

DONE:	DI
	mvi	a,10011111b	; H8 2mS off, display blank
	out	0f0h	; H89 NMI here should be OK
	LXI	H,?CODE ;SEQUENCE TO MOVE MEMORY-MAP
	MVI	B,?CODE$LEN	;NUMBER OF BYTES IN SEQUENCE
	MVI	C,?PORT ;I/O PORT TO SEND SEQUENCE
	OUTIR
	lxi	h,3000h+256
	lxi	d,loader
	lbcd	syssiz
	ldir
	jmp	cboot

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$10B	;changes memory if "-FA" also
?CODE$LEN	EQU	$-?CODE

	ORG	SYSADR-1
CMBFR:	DB	8,0,0,0,0,0
STAT:	DB	0
syssiz	dw	0

	REPT	256-($-BOOT)-1
	DB	0
	ENDM

?stack: equ	$+128

	END
