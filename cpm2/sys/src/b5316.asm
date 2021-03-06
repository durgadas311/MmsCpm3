

; May 20 1982	LWF
********** CP/M LINKABLE BOOT ROUTINE **********
********** 5.25" MMS CONTROLLER BOOT  **********

	TITLE	'BOOT5 --- FDC 5.25" boot module v2.240'

	DW	MODLEN,(-1)

BASE	EQU	0000H	;ORG FOR RELOC

	MACLIB Z80
	$-MACRO

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****  33 = FIRST 5.25" DRIVE                 *****
*****  34 = SECOND 5.25" DRIVE                *****
*****  35 = THIRD 5.25" DRIVE                 *****
*****  36 = FOURTH 5.25" DRIVE                *****
*****					      *****
***************************************************
page



***************************************************
**  PORTS AND CONSTANTS
***************************************************
CTRL	EQU	38H
WD1797	EQU	3CH
STAT	EQU	WD1797+0
TRACK	EQU	WD1797+1
SECTOR	EQU	WD1797+2
DATA	EQU	WD1797+3
SPT	EQU	9		; 9 (512 BYTE) SECTORS ON 5.25"DD

?PORT	  EQU	0F2H

?AUX	  EQU	0D0H
?PRINTER  EQU	0E0H
?MODEM	  EQU	0D8H

?LINE$CTL EQU	00000011B	; NO PARITY, 1 STOP BIT, 8 DATA BITS
?MOD$CTL  EQU	00001111B	; SET ALL CONTROL LINES TO 'READY'

?S19200 EQU	6	; 19,200 BAUD
?S9600	EQU	12	;  9,600 BAUD
?S4800	EQU	24	;  4,800 BAUD
?S2400	EQU	48	;  2,400 BAUD
?S1200	EQU	96	;  1,200 BAUD
?S600	EQU	192	;    600 BAUD
?S300	EQU	384	;    300 BAUD
?S150	EQU	768	;    150 BAUD
?S110	EQU	1047	;    110 BAUD
***************************************************

***************************************************
** LINKS TO REST OF SYSTEM
***************************************************
@BIOS	EQU	BASE+1600H
@BDOS	EQU	@BIOS-0E00H
***************************************************

***************************************************
** PAGE ZERO ASSIGNMENTS
***************************************************
	ORG	0
?CPM		DS	3
?DEV$STAT	DS	1
?LOGIN$DSK	DS	1
?BDOS		DS	3
?RST1		DS	3
?CLOCK		DS	2
?INT$BYTE	DS	1
?CTL$BYTE	DS	1
		DS	77
?FCB		DS	36
?DMA		DS	128
?TPA		DS	0
***************************************************
page



***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 

	ORG	2280H

BOOT:	JMP	AROUND

SECTRS	DB	0		; NUMBER OF SECTORS TO BOOT, FROM MOVCPM.COM
				; PATCHED DURING EXECUTION OF MOVCPM
DRIVE	DB	33		; ALSO PATCHED BY ASSIGN PROGRAM

AROUND:
	POP	H		; ERROR ROUTINE ADDRESS
	LXI	SP,?STACK
	PUSH	H

***************************************************
*** START OF UNIQUE ROUTINE FOR BOOTING
***************************************************

	LDA	DRIVE
	SUI	33		; BOOT ONLY FROM 5.25" DRIVES
	RC
	CPI	4		; MAX. 4 DRIVES ONLY
	RNC
	ORI	00101100B	; TURN ON MOTOR, INTRQ, DRQ, DDEN
	STA	DRIVE
	OUT	CTRL		; SEND TO CONTROL REGISTER
	LDA	SECTRS		; MAINTAIN FAST BOOTING,
	ADI	00000101B	; ROUND UP (INCLUDE BOOT SECTORS)
	ANI	11111100B	; INTEGER DIVISION
	RRC
	RRC			; BY 4
	MOV	E,A		; NUMBER OF SECTORS TO READ
	LXI	B,DATA		; C = INPUT DATA PORT  B=0
	LXI	H,@BDOS-256	; -256 FOR BOOT
	MVI	A,00001011B	; RESTORE HEAD TO TRACK 0
LOOP0:	CALL	COMMAND 	; STEP DRIVE
	IN	STAT
	ANI	10011001B
	RNZ
	MVI	D,1
SECL0:	PUSH	H		; SAVE MEMORY ADDRESS
	MOV	A,D
	OUT	SECTOR
	MVI	A,10001000B	; READ SINGLE SECTOR
	CALL	READ$REC
	ANI	10111111B	; SET PSW/Z TO INDICATE ERROR STATUS
	JRZ	OK		; ALL'S WELL IF ZERO
	POP	H
	LDA	ERRF		; SEE IF THIS IS THE SECOND TRY
	ORA	A
	RNZ			; RETURN TO MONITOR PROM
	CMA
	STA	ERRF		; ALLOW RETRY ONLY ONCE
	MVI	A,01001011B	; STEP-IN WITHOUT UPDATE (FOR 80 TRK DRIVE)
	JR	LOOP0
OK:	XTHL			; NEW MEMORY ADDRESS
	POP	H
	CMA
	STA	ERRF		; PREVENT FURTHER RETRY ON THIS TRACK
	DCR	E		; COUNT A SECTOR READ
	JRZ	DONE		; STOP IF ALL SECTORS READ
	INR	D		; COUNT ONE SECTOR ON THIS TRACK
	MOV	A,D
	CPI	SPT+1
	JRC	SECL0		; LOOP IF MORE ON THIS TRACK
	XRA	A
	STA	ERRF		; RESET FLAG FOR NEW TRACK
	MVI	A,01011011B	; STEP-IN WITH UPDATE
	JR	LOOP0		; GO READ SECTOR ZERO OF NEXT TRACK
DONE:

***************************************************
** START OF SYSTEM INITIALIZATION
*************************************************** 
	DI
* INITIALIZE I/O, ETC
	XRA	A
	OUT	?AUX+4
	OUT	?PRINTER+4
	OUT	?MODEM+4
	MVI	A,?LINE$CTL
	ORI	10000000B	; ENABLE DIVISOR LATCH
	OUT	?AUX+3
	OUT	?PRINTER+3
	OUT	?MODEM+3
* BAUD RATE SETUP:
	LXI	H,?S9600	; AUX SERIAL @ 9600 BAUD
	MOV	A,L
	OUT	?AUX
	MOV	A,H
	OUT	?AUX+1
	LXI	H,?S9600	; PRINTER @ 9600 BAUD
	MOV	A,L
	OUT	?PRINTER
	MOV	A,H
	OUT	?PRINTER+1
	LXI	H,?S300 	; MODEM (PAPER TAPE) @ 300 BAUD
	MOV	A,L
	OUT	?MODEM
	MOV	A,H
	OUT	?MODEM+1
* NOW GET PORTS READY FOR I/O
	MVI	A,?LINE$CTL	; NOW DE-SELECT DIVISOR LATCH
	OUT	?AUX+3
	OUT	?PRINTER+3
	OUT	?MODEM+3
	MVI	A,?MOD$CTL	; SIGNAL 'READY'
	OUT	?AUX+4
	OUT	?PRINTER+4
	OUT	?MODEM+4
	IN	?AUX+5		; RESET ANY STRAY ACTIVITY
	IN	?PRINTER+5
	IN	?MODEM+5
	IN	?AUX
	IN	?PRINTER
	IN	?MODEM
* END OF I/O INITIALIZATION
	LXI	H,?CODE 	; SEQUENCE TO MOVE MEMORY-MAP
	MVI	B,?CODE$LEN	; NUMBER OF BYTES IN SEQUENCE
	MVI	C,?PORT 	; I/O PORT TO SEND SEQUENCE
	OUTIR
	JMP	@BIOS
?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$10B	; FOR "-FA" MACHINES
?CODE$LEN	EQU	$-?CODE

ERRF:	DB	0	; ERROR FLAG FOR CONTROL OF 80 TRACK SITUATION.
			; IF A 40-TRACK DISK IS BOOTED IN AN 80-TRACK
			; DRIVE, EACH TRACK REQUIRES TWO STEPS, BUT
			; THE TRACK REGISTER IS UPDATED ONLY ONCE.
COMMAND:
	OUT	STAT
	EI
	JR $-1

READ$REC:
	OUT	STAT
	EI
RD0	HLT
	INI
	JNZ	RD0
RD1	HLT
	INI
	JNZ	RD1
	JR $-1

	REPT	256-($-BOOT)-1
	DB	0
	ENDM

RETRY:				; LOCATION HAS DUAL-FUNCTION
ID	DB	7		; BOOT ROUTINE IDENTIFICATION
MODLEN	EQU	$-BOOT		; MUST BE 256 BYTES
?STACK: EQU	$+128

 DB 00000000B,00000000B,00000000B,00000000B,00000000B,01000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00001000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
	END
