vers equ '1 ' ; July 19, 1983	9:48  mjm  "LDRBZ37.ASM"

; Boot module for Z37 controller, MMS formats, CP/M 3 loader

	MACLIB Z80

	extrn cboot,btend,loader

************** Select Boot mode from: *****************
**  0 = 5.25" DD SS ST (MMS 512 byte sectors) Drive 46
**  1 = 5.25" DD DS ST ( '' )                       46
**  2 = 5.25" DD SS DT ( '' )                       46
**  3 = 5.25" DD DS DT ( '' )                       46
*******************************************************

SPT	EQU	9	; 9 (512 BYTE) SECTORS ON 5.25" DD
secmsk	equ	01ffh
secshf	equ	9
drv0	equ	46
ndrv	equ	4

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****  46 = FIRST Z37 5.25" DRIVE             *****
*****  47 = SECOND Z37 5.25" DRIVE            *****
*****  48 = THIRD Z37 5.25" DRIVE             *****
*****  49 = FOURTH Z37 5.25" DRIVE            *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************
UIVEC	EQU	201FH		; INTERRUPT VECTORS BASE ADDRESS
Z37	EQU	078H
ICL	EQU	Z37+0		; DISK CONTROL PORT
ACL	EQU	Z37+1		; INTERFACE MUX PORT
COMD	EQU	Z37+2		; 1797 COMMAND REGISTER
STAT	EQU	Z37+2		; STATUS REGISTER
SECT	EQU	Z37+2		; SECTOR REGISTER
DATA	EQU	Z37+3		; DATA REGISTER

?H8PT	  EQU	0F0H
?PORT	  EQU	0F2H
***************************************************

***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	ORG	2280H
BOOT:	JMP	AROUND

sysend: dw	btend
systrt: dw	loader
drive:	db	drv0		; boot drive
btmode: db	1		; default boot mode DD,DS,ST
	db	drv0
	db	ndrv

AROUND: POP	H	; ERROR ROUTINE ADDRESS
	LXI	SP,?STACK
	PUSH	H

***************************************************
*** START OF UNIQUE ROUTINE FOR BOOTING
***************************************************
	LDA	DRIVE
	SUI	drv0		; BOOT ONLY FROM Z37 DRIVES
	CPI	ndrv		; MAX. 4 DRIVES ON Z37
	RNC
	MOV	C,A
	MVI	A,8
LOOP:	ADD	A
	DCR	C
	JP	LOOP
	ORI	00001111B	; TURN ON MOTOR, INTRQ, DRQ, DDEN
	OUT	ICL		; SEND TO CONTROL REGISTER

	lxi	h,btend
	lxi	d,loader
	ora	a
	dsbc	d
	shld	syssiz
	lxi	d,secmsk+0100h		; include boot routine
	dad	d
	mvi	a,secshf
div0:	srlr	h
	rarr	l
	dcr	a
	jrnz	div0
	mov	d,l	;number of sectors to load

	LXI	H,INTRQ
	SHLD	UIVEC+9+1	; SET RST4 ROUTINE.
	LXI	B,DATA		; C = INPUT DATA PORT  B=0
	LXI	H,3000h 	;
	MVI	A,00001011B	; RESTORE HEAD TO TRACK 0
STEP:	DI			; DO STEP BY POLLING BUSY (NOT BY INTRQ)
	OUT	COMD		; SEND STEP COMMAND
WB:	IN	STAT		; WAIT FOR BUSY
	RRC
	JRNC	WB
WNB:	IN	STAT		; THEN WAIT FOR NOT BUSY
	RRC
	JRC	WNB
	IN	STAT		; INSURE INTRQ IS CLEARED
	EI
	MVI	A,1
	OUT	ACL		; ENABLE 1797 TRACK/SECTOR REGISTERS
	XRA	A
	OUT	SECT		; START AT SECTOR 0 (BEFORE INCREMENT)
	MVI	E,SPT		; SET COUNTER FOR SECTORS-PER-TRACK
RDSEC:	MVI	A,1
	OUT	ACL		; ENABLE TRACK/SECTOR REGISTERS
	IN	SECT
	INR	A		; SECTOR # +1
	OUT	SECT
	XRA	A		; SELECT COMMAND/DATA REGISTERS
	OUT	ACL
	MVI	A,10001000B	; READ RECORD, SIDE 0
	OUT	COMD		; ISSUE COMMAND
	EI
RDLOOP: HLT
	INI			; INPUT BYTE
	JR	RDLOOP		; LOOP UNTIL INTERRUPT
INTRTN: ANI	10011111B	; SET PSW/Z TO INDICATE ERROR STATUS
	JRZ	OK		; ALL'S WELL IF ZERO
	LDA	ERRF		; SEE IF THIS IS THE SECOND TRY
	ORA	A
	JRNZ	XIT
	CMA
	STA	ERRF		; ALLOW RETRY ONLY ONCE
	MVI	A,01001011B	; STEP-IN WITHOUT UPDATE (FOR 80 TRK DRIVE)
	JR	STEP
XIT:	XRA	A
	OUT	ICL		; MOTOR OFF AND DESELECT
	RST	0		; RETURN TO MONITOR
OK:	CMA
	STA	ERRF		; PREVENT FURTHER RETRY ON THIS TRACK
	DCR	D		; COUNT A SECTOR READ
	JRZ	DONE		; STOP IF ALL SECTORS READ
	DCR	E		; COUNT ONE SECTOR ON THIS TRACK
	JRNZ	RDSEC		; LOOP IF MORE ON THIS TRACK
	XRA	A
	STA	ERRF		; RESET FLAG FOR NEW TRACK
	MVI	A,01011011B	; STEP-IN WITH UPDATE
	JR	STEP		; STEP-IN AND START NEW TRACK
DONE:	MVI	A,00001000B	; DESELECT DRIVE
	OUT	ICL   
	di
	mvi	a,09fh	; 2ms off, blank fp on H8
	out	?h8pt	; H89 NMI should be innocuous
	LXI	H,?CODE 	; SEQUENCE TO MOVE MEMORY-MAP
	MVI	B,?CODE$LEN	; NUMBER OF BYTES IN SEQUENCE
	MVI	C,?PORT 	; I/O PORT TO SEND SEQUENCE
	OUTIR
	lxi	h,3000h+0100h
	lxi	d,loader
	lbcd	syssiz
	ldir
	JMP	CBOOT

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$10B	; FOR "-FA" MACHINES
?CODE$LEN	EQU	$-?CODE

ERRF	DB	0	;ERROR FLAG FOR CONTROL OF 80 TRACK SITUATION:
;IF A 40-TRACK DISK IS BEING BOOTED ON AN 80-TRACK DRIVE EACH TRACK
;REQUIRES TWO STEPS, ONLY UPDATING TRACK REGISTER ON ONE.

INTRQ:	IN	STAT		; TURN OFF INTRQ
	INX	SP		; DISCARD RETURN ADDRESS
	INX	SP
	EI
	JMP	INTRTN		; JUMP BACK TO READ LOOP

syssiz: dw	0

	rept 256-($-BOOT)
	db	0
	endm

?STACK: EQU	$+128

	END
