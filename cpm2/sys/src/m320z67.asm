********** CP/M DISK I/O ROUTINES  **********
**********			   **********
VERS	EQU	'3 '	      ; 05/16/83  1:29 mjm "D320Z67.ASM"
*********************************************
	DW	MODLEN,BUFLEN

	TITLE	'SASI- DRIVER FOR MMS CP/M SASI BUS INTERFACE'
	MACLIB	Z80
	$-MACRO

BASE	EQU	0000H	;ORG FOR RELOC

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS  *****
*****					       *****
*****  50-58 RESERVED FOR SASI BUS DISKS       *****
*****					       *****
****************************************************

PAGE


***************************************************
**  PORTS AND CONSTANTS
***************************************************
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

RDBL	EQU	8	; COMMAND OP CODES
WRBL	EQU	10
INIT	EQU	12
FFMT	EQU	0C0H

DPHDPB	EQU	10
DPHL	EQU	16
DPBL	EQU	21
DDEFL	EQU	4
DPBMOD	EQU	15
CSTRNG	EQU	13
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
** LINKS TO REST OF SYSTEM
***************************************************

PATCH	EQU	BASE+1600H
MBASE	EQU	BASE		; MODULE BASE
COMBUF	EQU	BASE+0C000H	; COMMON BUFFER
BUFFER	EQU	BASE+0F000H	; MODULE BUFFER

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
PAGE



***************************************************
** OVERLAY MODULE INFORMATION ON BIOS
***************************************************

	ORG	PATCH
	DS	51		 ; BIOS JUMP TABLE

DISK$STAT	DB	0

		DS	8

MIXER:	DB	0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH
	DS	7		; LOGICAL-PHYSICAL DRIVE TABLE

DRIVE$BASE:
	DB	0,0		; DRIVE MODULE BASE TABLE
	DW	MBASE
	DS	28

CBIOS:	DS	3

NEWBAS	DS	2
NEWDSK	DS	1
NEWTRK	DS	1
NEWSEC	DS	1
HRDTRK	DS	2
DMAA	DS	2

***************************************************
PAGE



***************************************************
** START OF RELOCATABLE DISK I/O MODULE
*************************************************** 

	ORG	MBASE		; START OF MODULE

	JMP	SEL$SASI
	JMP	READ$SASI
	JMP	WRITE$SASI

;	TEXT
	DB	'77320',0,' SASI Interface for Z67 Controller ',0,'v2.24'
	DW	VERS
	DB	'$'

DPH0:	DW	0,0,0,0,DIRBUF,DPB0,CSV0,ALV0
DPH1:	DW	0,0,0,0,DIRBUF,DPB1,CSV1,ALV1
DPH2:	DW	0,0,0,0,DIRBUF,DPB2,CSV2,ALV2
DPH3:	DW	0,0,0,0,DIRBUF,DPB3,CSV3,ALV3
DPH4:	DW	0,0,0,0,DIRBUF,DPB4,CSV4,ALV4
DPH5:	DW	0,0,0,0,DIRBUF,DPB5,CSV5,ALV5
DPH6:	DW	0,0,0,0,DIRBUF,DPB6,CSV6,ALV6
DPH7:	DW	0,0,0,0,DIRBUF,DPB7,CSV7,ALV7
DPH8:	DW	0,0,0,0,DIRBUF,DPB8,CSV8,ALV8
	DW	0,0,0,0,0,DEFDPB	; EXTRA DPH FOR USE BY DRIVER ONLY
CNUM:	DB	0		; CONTROLLER NUMBER 0

;	SECTOR DEFINITION/TRANSLATION TABLE
;		--ADDRESS--,   FLAG BYTE
DDEFTBL:DB 00100000B,0,   0,   01000000B  ; Floppy disk
	DB	0,   0,   0,   0	; Winchester disk
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0 
;
;
; DISK PARAMETER BLOCKS -- DPB'S FOR HARD DISK CONTAIN DUMMY DATA. REAL DATA IS
;			   OBTAINED FROM MAGIC SECTOR ON INITIALIZATION OF
;			   PARTITION
;
DPB0:	DW	26		; SPT		dpb for floppy disk
	DB	3,7,0		; BSH,BLM,EXM	DON'T CHANGE.
	DW	243-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,2		; CKS,OFF
	DB	00000000B,00000111B,00101001B  ; MODE BYTES
	DB	11010000B,10011100B,11111000B  ; MODE MASKS

DPB1:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB2:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB3:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB4:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB5:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB6:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB7:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DPB8:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

DEFDPB: DW	26		; EXTRA DPB AND MODE BYTES TO BE USED ONLY
	DB	3,7,0		; BY DRIVER WHEN ACCESSING TRACK 0
	DW	243-1,128-1	; OF A ZENITH 8" DD DISK. TRACK 0 ON THESE
	DB	11000000B,0	; DISKS IS OF THE STANDARD SINGLE DENSITY
	DW	16,2		; FORMAT   DON'T CHANGE.
	DB	00000000B,00000111B


PAGE

SKEW1:	DB	1,7,13,19,25,5,11,17,23,3,9,15,21
	DB	2,8,14,20,26,6,12,18,24,4,10,16,22

SKEW2:	DB	1,2,19,20,37,38,3,4,21,22,39,40
	DB	5,6,23,24,41,42,7,8,25,26,43,44
	DB	9,10,27,28,45,46,11,12,29,30,47,48
	DB	13,14,31,32,49,50,15,16,33,34,51,52
	DB	17,18,35,36


;	SELECT DISK CODE
;
SEL$SASI:
	LDA	PNDWRT		; CLEAR ANY PENDING WRITE
	ORA	A
	CNZ	WR$SEC
	CALL	INIT$SASI	; INITIALIZE DRIVER
	JNZ	ERREXT
	LDA	DRIV0		; CALCULATE DRIVE NUMBER RELATIVE TO 0
	MOV	D,A
	LDA	NEWDSK
	SUB	D     
	LXI	H,DDEFTBL
	MOV	C,A		; NOW POINT TO THE CORRECT
	MVI	B,0		; ENTRY IN THE SECTOR
	DAD	B		; OFFSET TABLE
	DAD	B
	DAD	B
	DAD	B
	SHLD	SECPTR
	MOV	A,M
	ANI	11100000B
	STA	LUN		; SAVE LOGICAL UNIT NUMBER BITS
	MOV	B,C
SEL0:	PUSH	B		; SAVE RELATIVE DRIVE NUMBER FOR LATER
	INR	B
	LXI	H,DPH0-DPHL	; POINT TO DPH TABLE
	LXI	D,DPHL		; LENGTH OF DPH's
SEL1:	DAD	D
	DJNZ	SEL1		; CALCULATE POINTER TO REQUESTED DPH
	SHLD	CURDPH
	LXI	D,DPHDPB
	DAD	D		; POINT TO ADDRESS OF DPB
	CALL	HLIHL		; DPB ADDRESS IN HL
	SHLD	CURDPB		; SAVE IT
	LXI	D,DPBMOD
	DAD	D
	SHLD	MODE
	CALL	CHK$INIT	; INITIALIZE DRIVE IF NECESSARY
	LHLD	CURDPB
	INX	H
	INX	H
	INX	H
	MOV	A,M		; GET BLOCK MASK
	STA	BLKMSK		; USED FOR UNALLOCATED RECORD COUNT
	LXI	D,10
	DAD	D
	MOV	A,M		; GET TRACK OFFSET
	STA	OFFSET
	INX	H
	INX	H		; POINT TO MODE BYTE 1
	MOV	A,M
	ANI	3		; ISOLATE SECTOR SIZE BITS
	STA	BLCODE		; SAVE AS DEBLOCKING CODE
RETSEL: POP	B		; RELATIVE DRIVE NUMBER TO REG. C
	LXI	D,DPH0		; D.P.H. 0 TO REG. DE
	RET			; RETURN TO BDOS

ERREXT: MVI	A,1
	STA	SELERR
	JR	RETSEL


;
;	DRIVER INITIALIZATION CODE
;
INIT$SASI:
	LDA	INIT$FLAG	; NEED TO INITIALIZE ?
	ORA	A
	RZ
	LXI	H,DRIVE$BASE	; SEARCH DRIVE$BASE FOR FIRST
	LDA	NEWDSK		; AND LAST PHYSICAL DRIVE NUMBERS
LPDSK	CMP	M
	INX	H
	JRC	NXTDSK
	CMP	M
	JRC	GOTDSK
NXTDSK	INX	H
	INX	H
	INX	H
	JMP	LPDSK
GOTDSK	MOV	A,M
	STA	DRIV$LAST
	DCX	H
	MOV	A,M
	STA	DRIV0	 
							  
	LXI	H,PATCH 	; GET LOGIN VECTOR ADDRESS FROM BIOS
	LXI	D,0D89H
	ORA	A
	DSBC	D
	CALL	HLIHL
	INX	H
	CALL	HLIHL		
	SHLD	LVECADD

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
	XRA	A
	STA	INIT$FLAG	; FLAG DRIVER AS INITIALIZED
	STA	SELERR		; NO SELECT ERRORS (YET)
	RET

CHK$INIT:
	LHLD	SECPTR
	INX	H
	INX	H
	INX	H		; POINT TO FLAG BYTE
	MOV	A,M
	STA	FLAGS		; SAVE FOR USE BY INIT$HARD
	BIT	6,A
	JNZ    INIT$FLOPPY
	CALL	LOGIN
	RNZ
	BIT	7,A		; CHECK INITIALIZATION BIT
	RNZ

INIT$HARD:
	MVI	A,0FFH		
	STA	HSTDSK		
	MVI	A,RDBL		; OP CODE TO READ A SECTOR
	STA	CMBFR
	XRA	A		; SECTOR 0
	STA	CMBFR+1
	STA	CMBFR+2
	STA	CMBFR+3
	INR	A
	STA	CMBFR+4 	; READ 1 SECTOR
	CALL	GETCON		; WAKE UP CONTROLLER
	CZ	OUTCOM		; OUTPUT READ COMMAND
	CZ	SASIRW		; READ IN SECTOR
	CZ	CHK$STAT	; CHECK STATUS OF READ
	JNZ	INIT$ERR

	LDA	HSTBUF+NPART	; COMPARE # OF PART. DRIVER & MAGIC SECTOR
	LXI	H,PARTLUN
	CMP	M
	JNC	KEEPPAR 	; USE THE SMALLEST ONE
	MOV	M,A
KEEPPAR:LDA	DRIV0
	MOV	D,A
	LDA	STRLUN
	SUB	D
	STA	STRLUN		; SAVE RELATIVE START OF LUN	  
	INR	A
	MOV	B,A
	LXI	H,DPB0-DPBL	; CALCULATE START OF DPB IN DRIVER
	LXI	D,DPBL
NXTDPB	DAD	D
	DJNZ	NXTDPB
	PUSH	H

	LDA	PARTLUN
	MOV	B,A
	LXI	H,0		; CALCULATE TOTAL LENGTH OF DPB'S TO BE MOVED 
	LXI	D,DPBL
NXTLEN	DAD	D
	DJNZ	NXTLEN
	MOV	B,H		; PUT LENGTH IN BC
	MOV	C,L
	POP	D		; PUT TO ADDRESS IN DE
	LXI	H,HSTBUF+DDPB	; PUT FROM ADDRESS IN HL
	LDIR
	
	LXI	H,DDEFTBL	; CALCULATE START IN DDEFTBL
	LDA	STRLUN
	SLAR	A		; MULT BY 2
	SLAR	A		; MULT BY 4
	MOV	E,A
	MVI	D,0
	DAD	D
	PUSH	H		; SAVE FOR SET INIT. BITS
	XCHG			; TO ADDRES IN DE
	LXI	H,HSTBUF+SECTBL ; FROM ADDRESS
	LDA	PARTLUN
	MOV	B,A		
NXTDEF	PUSH	B		; MOVE PARTITION ADDRESS TABLE INTO DRIVER
	LDAX	D		; DE = DDEFTBL
	ORA	M		; HL = HSTBUF+SECTBL (MAGIC SECTOR)
	MOV	M,A
	LXI	B,3
	LDIR
	INX	D		; DDEFTBL IS 4 BYTES WIDE
	POP	B
	DJNZ	NXTDEF

	CALL	INIT$DRIVE
	JRNZ	INIT$ERR	; ERROR ON PHYSICAL INITIALIZATION

	POP	H		; SET INITIALIZATION BITS
	INX	H
	INX	H
	INX	H
	LXI	D,DDEFL  
	LDA	PARTLUN
	MOV	B,A
NXTFLG	SETB	7,M
	DAD	D
	DJNZ	NXTFLG
	RET

INIT$FLOPPY:
	XRA	A
	LHLD	MODE		; POINT TO MODE BYTE 1
	BIT	5,M
	JRZ	SSIDE		; CHECK SIDED BIT
	INR	A
SSIDE:	INX	H		; POINT TO MODE BYTE 2
	LXI	D,SKEW1 	; SKEW TABLE FOR SINGLE DENSITY
	BIT	6,M
	JRZ	SDEN		; CHECK DENSITY BIT
	ADI	6		; ACC. NOW CONTAINS TRACK FORMAT CODE
	LXI	D,SKEW2 	; SKEW TABLE FOR SINGLE DENSITY
SDEN:	LHLD	CURDPH
	MOV	M,E		; PUT SKEW TABLE ADDRESS INTO D.P.H.
	INX	H
	MOV	M,D
	LXI	H,FFCMD+5
	MOV	M,A		; PUT TRACK FORMAT INTO COMMAND
	CALL	LOGIN
	RNZ
; CHECK FOR SS/DS MISMATCH
	LDA	FFCMD+5
	PUSH	PSW		; SAVE TRACK FORMAT CODE
	ORI	1		; MAKE DOUBLE SIDED
	STA	FFCMD+5
	CALL	INIT$DRIVE	; INITIALIZE DRIVE AS DOUBLE SIDED
	CALL	WAKE$UP
	LXI	H,RDSD1 	; COMMAND TO READ SECTOR ON SIDE 1
	CZ	OUTCM0
	CZ	READ0		; READ THE SECTOR
	CZ	CHK$STAT
	MVI	C,1
	JRZ	DSID		; NO ERRORS => DOUBLE SIDED DISK
	MVI	C,0
DSID:	POP	PSW		; GET ORIGINAL CODE BACK
	STA	FFCMD+5 	; PUT IT BACK INTO COMMAND
	ANI	1		; ISOLATE SIDE BIT
	XRA	C
	JRNZ	INIT$ERR	; ERROR IF DISK DOESN'T MATCH MODE

	CALL	INIT$DRIVE
	RZ

INIT$ERR:
	POP	D		; CLEAR STACK
	JMP	ERREXT

LOGIN:	LXIX	DDEFTBL
	LDA	DRIV0		; GET PHYSICAL DRIVE NUMBER
	MOV	B,A
	LDA	DRIV$LAST	; GET TOTAL NUMBER OF PARTITIONS
	SUB	B
	MOV	H,A
	LDA	LUN		; PUT LUN IN L REG
	MOV	L,A
	LXI	D,4		; INCREMENT FOR DDEFTAB       
STLOOP	LDX	A,+0		; GET STARTING PHYSICAL DRIVE NUMBER
	ANI	11100000B	; OF CURRENT LUN.
	CMP	L
	JRZ	GOT$START
	DADX	D
	INR	B
	DCR	H
	JNZ	STLOOP
	POP	D
	JMP	INIT$ERR
GOT$START:
	MVI	C,0		; GET NUMBER OF PARTITIONS IN LUN
ENDLOOP:			
	DADX	D
	INR	C
	LDX	A,+0
	ANI	11100000B
	CMP	L
	JRNZ	GOT$END 	; B = STARTING PHYSICAL DRIVE NUMBER OF LUN
	DCR	H
	JNZ	ENDLOOP 	; C = NUMBER OF PARTITION IN THE CURRENT LUN
GOT$END:
	MOV	A,C
	STA	PARTLUN 	; SAVE FOR INIT$HARD
	MOV	A,B
	STA	STRLUN

	LXI	H,0		; SEARCH MIXER TABLE FOR ANY
	MVI	E,16		; LOGGED IN PARTITIONS FOR THE CURRENT LUN.
	LXIX	MIXER+15
MLOOP	LDX	A,+0
	SUB	B
	CMP	C		; SET CY IF IN RANGE  (C>x>B)
	DADC	H
	DCXIX	
	DCR	E
	JRNZ	MLOOP
	XCHG			; PUT LOGIN MASK IN DE
	LHLD	LVECADD 	; GET LOGIN VECTOR'S ADDRESS
	MOV	A,M		; COMPARE LSB FIRST
	ANA	E
	RNZ			; RETURN IF ONE OR MORE PARTITIONS ARE LOGIN.
	INX	H
	MOV	A,M		; THEN COMPARE MSB
	ANA	D
	RET

PAGE

READ$SASI:
	LDA	PNDWRT		; SECTOR WAITING TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC
	MVI	A,READOP	; FLAG A READ OPERATION
	JR	RWOPER

WRITE$SASI:
	MOV	A,C

RWOPER: STA	WRTYPE		; SAVE WRITE TYPE
	LDA	SELERR
	ORA	A
	RNZ
	LDA	NEWTRK
	ORA	A		; ARE WE ON TRACK 0 ?
	JRNZ	NOTZ8DD
	LHLD	MODE  
	INX	H
	MOV	A,M		; MODE BYTE 2
	ANI	01100000B	; ISOLATE THE TWO DENSITY BITS
	CPI	01000000B	; IS IT DD WITH TRACK 0 SD ?
	JRNZ	NOTZ8DD
	MVI	B,9		; THEN WE MUST RESELECT DISK AS 8" DD
	PUSH	D		; SAVE REG. D
	CALL	SEL0
	POP	D		; RESTORE REG. D
	LXI	H,RESEL 	; RESELECT DISK WHEN DONE WITH I/O OPERATION
	PUSH	H
NOTZ8DD:LDA	NEWDSK
	STA	REQDSK
	LHLD	HRDTRK
	SHLD	REQTRK
	MVI	C,0		; CALCULATE PHYSICAL SECTOR
	LDA	BLCODE		; PHYSICAL SECTOR SIZE CODE
	ORA	A		; TEST FOR ZERO
	MOV	B,A
	LDA	NEWSEC
	STA	REQSEC		; INITIAL GUESS IS 128 BYTE SECTORS
	JRZ	DBLOK3		; 128 BYTE SECTORS ?
DBLOK1: SRLR	A		; DIVIDE ACCUMULATOR BY 2
	RARR	C		; SAVE OVERFLOW BITS
	DJNZ	DBLOK1		; AND CONTINUE IF BLOCKING STILL <> 0
	STA	REQSEC		; SAVE IT
	LDA	BLCODE		; CALCULATE BLKSEC
	MOV	B,A		; FOR LOOPING
DBLOK2: RLCR	C		; NOW RESTORE THE OVERFLOW BY
	DJNZ	DBLOK2		;  ROTATING IT RIGHT
DBLOK3: MOV	A,C
	STA	BLKSEC		; STORE IT
	MVI	A,0FFH
	STA	RD$FLAG 	; FLAG A PRE-READ
	LDA	WRTYPE
	RAR			; CARRY IS SET ON WRDIR AND READOP
	JRC	ALLOC		; NO NEED TO CHECK FOR UNALLOCATED RECORDS
	RAR			; CARRY IS SET ON WRUNA
	JRNC	CHKUNA
	SDED	URECORD 	; SET UNALLOCATED RECORD #
	DCR	A
	STA	UNALLOC 	; FLAG WRITING OF AN UNALLOCATED BLOCK
CHKUNA: LDA	UNALLOC 	; ARE WE WRITING AN UNALLOCATED BLOCK ?
	ORA	A
	JRZ	ALLOC
	LHLD	URECORD 	; IS REQUESTED RECORD SAME AS EXPECTED
	DSBC	D		;  SAME AS EXPECTED UNALLOCATED RECORD ?
	JRNZ	ALLOC		; IF NOT, THEN DONE WITH UNALLOCATED BLOCK
	XRA	A		; CLEAR PRE-READ FLAG
	STA	RD$FLAG
	INX	D		; INCREMENT TO NEXT EXPECTED UNALLOCATED RECORD
	SDED	URECORD
	LDA	BLKMSK
	ANA	E		; IS IT THE START OF A NEW BLOCK ?
	JRNZ	CHKSEC
ALLOC:	XRA	A		; NO LONGER WRITING AN UNALLOCATED BLOCK
	STA	UNALLOC

;*****************************************************************************
; CHKSEC: THIS SUBROUTINE COMPARES THE REQUESTED DISK TRACK AND SECTOR	     ;
;	  TO THE DISK,TRACK AND SECTOR CURRENTLY IN THE BUFFER. 	     ;
;	  OUTPUT: ZERO FLAG SET IF SAME, RESET IF DIFFERENT		     ;
;									     ;
CHKSEC: ANA	A		; CLEAR CARRY FOR DSBC			     ;
	LHLD	REQTRK							     ;
	LDED	OFFSET							     ;
	DSBC	D							     ;
	JRNZ	CHKBUF							     ;
	LDA	NEWSEC							     ;
	ORA	A		; FIRST SECTOR OF DIRECTORY ?		     ;
	JRZ	SET$PRE$RD						     ;
CHKBUF: LXI	H,REQDSK						     ;
	LXI	D,HSTDSK						     ;
	MVI	B,4							     ;
CHKBUF1:LDAX	D							     ;
	CMP	M							     ;
	JRNZ	READIT							     ;
	INX	H							     ;
	INX	D							     ;
	DJNZ	CHKBUF1 						     ;
	JR	NOREAD		;  THEN NO NEED TO PRE-READ		     ;
;*****************************************************************************

SET$PRE$RD:			; SET PRE READ FLAG FOR READING 
	MVI	A,0FFH		; DIRECTORY SO A PHY READ IS DONE
	STA	RD$FLAG

READIT: LDA	PNDWRT		; IS THERE A SECTOR THAT NEEDS TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC		; WRITE IT
	LXI	D,HSTDSK	; SET UP NEW BUFFER PARAMETERS
	LXI	H,REQDSK
	LXI	B,4
	LDIR
	LDA	RD$FLAG 	; DO WE NEED TO PRE-READ ?
	ORA	A
	CNZ	RD$SEC		; READ THE SECTOR
NOREAD: LXI	H,HSTBUF	; POINT TO START OF SECTOR BUFFER
	LXI	B,128
	LDA	BLKSEC		; POINT TO LOCATION OF CORRECT LOGICAL SECTOR
MOVIT1: DCR	A
	JM	MOVIT2
	DAD	B
	JR	MOVIT1
MOVIT2: LDED	DMAA		; POINT TO DMA
	LDA	WRTYPE		; IS IT A READ OR A WRITE
	CPI	READOP
	JRZ	MOVIT3
	XCHG			; SWITCH DIRECTION OF MOVE FOR WRITE
	MVI	A,1		; FLAG A PENDING WRITE
	STA	PNDWRT
MOVIT3: LDIR			; MOVE IT
	LDA	WRTYPE		; CHECK FOR DIRECTORY WRITE
	DCR	A
	CZ	WR$SEC		; WRITE THE SECTOR IF IT IS
	XRA	A		; FLAG NO ERROR
	RET			; RETURN TO BDOS

WR$SEC: MVI	A,WRBL		; READ COMMAND OP CODE
	CALL	DO$RW		; WRITE A PHYSICAL SECTOR
	MVI	A,0
	STA	PNDWRT		; FLAG NO PENDING WRITE
	RZ			; RETURN IF WRITE WAS SUCCESSFUL
	LDA	WRTYPE
	CPI	READOP		; IGNORE ERROR IF THIS IS A READ OPERATION
	RZ
	JR	RWERR

RD$SEC: MVI	A,RDBL		; WRITE COMMAND OP CODE
	CALL	DO$RW		; WRITE A PHYSICAL SECTOR
	RZ			; RETURN IF SUCCESSFUL
	MVI	A,0FFH		; FLAG BUFFER AS UNKNOWN
	STA	HSTDSK
RWERR:	POP	D		; THROW AWAY TOP OF STACK
	MVI	A,1		; SIGNAL ERROR TO BDOS
	ORA	A
	RET			; RETURN TO BDOS

RESEL:	PUSH	PSW		; SAVE STATUS IF I/O OPERATION
	CALL	SEL$SASI	; SET UP CORRECT DISK PARAMETERS AGAIN
	POP	PSW		; RECALL STATUS OF I/O OPERATION FOR BDOS
	RET			; RETURN TO BDOS


;
;	COMMON READ-WRITE CODE
;
DO$RW:	STA	CMBFR		; COMMAND BUFFER OP CODE
	CALL	SET$SEC 	; CALCULATE AND INSTALL ACTUAL SECTOR
DO$IT:	CALL	WAKE$UP 	; WAKE UP THE CONTROLLER
	CZ	OUTCOM		; OUTPUT THE COMMAND
	CZ	SASIRW		; DO READ OR WRITE
	CZ	CHK$STAT	; CHECK THE BUS RESPONSE
	RET

INIT$DRIVE:
	LDA	FLAGS
	ORI	01000000B	; CHECK FOR FLOPPY
	RZ			; DONE IF HARD DISK
	CALL	GETCON		; GET CONTROLLER'S ATTENTION
	LXI	H,FFCMD 	; DEFINE FLOPPY FORMAT COMMAND
	CZ	OUTCM0		; SEND THE COMMAND
	CZ	CHK$STAT
	RET

PAGE



;	CALCULATE THE REQUESTED SECTOR
;
SET$SEC:
	LHLD	CURDPB
	MOV	B,M		; SECTORS PER TRACK
	LXI	H,0
	LDED	HSTTRK		; REQUESTED TRACK
MULT:	DAD	D		; MULTIPLY TO GET TRACK OFFSET
	DJNZ	MULT
	PUSH	H
	LHLD	SECPTR		; GET PARTITION OFFSET FROM TABLE
	MOV	C,M
	INX	H
	MOV	D,M
	INX	H
	MOV	E,M
	POP	H
	DAD	D		; ADD IN TRACK OFFSET
	JRNC	NOCAR0		; CARRY FROM DAD (IF ANY) GOES INTO
	INR	C		;  HIGH ORDER BYTE OF SECTOR NUMBER
NOCAR0: LDA	BLCODE
	MOV	B,A
	ORA	A
	MOV	A,C
	JRZ	NODIV
	ANI	00011111B	; ELIMINATE L.U.N. BITS FROM DIVISION
	MOV	C,A
NXDIV:	SRAR	C
	RARR	H
	RARR	L
	DJNZ	NXDIV
NODIV:	LDA	HSTSEC		; GET REQUESTED SECTOR
	MOV	E,A
	MVI	D,0
	DAD	D		; ADD IT IN
	JRNC	NOCAR1
	INR	C
NOCAR1: XCHG			; SECTOR NUMBER NOW IN C-D-E
	LXI	H,CMBFR+1	; MOVE IT TO COMMAND BUFFER
	LDA	LUN		; OR IN L.U.N. BITS
	ORA	C
	MOV	M,A
	INX	H
	MOV	M,D
	INX	H
	MOV	M,E
	INX	H
	MVI	M,1		; TRANSFER 1 SECTOR
	INX	H
	MVI	M,0		; CONTROL BYTE IS 0
	RET
PAGE

HLIHL:	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
	RET

WAKE$UP:CALL	GETCON
	RZ
	CALL	INIT$DRIVE
	RNZ
	CALL	GETCON
	RET


;
;	GET THE BUS' ATTENTION
;
GETCON:
	LDA	BASE$PORT
	MOV	C,A
	INR	C		; CONTROL PORT ADDRESS TO REG. C
	MVI	B,0		; TIMER COUNTER
	MVI	A,RUN
	OUTP	A		; CLEAR SEL BIT
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

PAGE



;
; OUTCOM: OUTPUT A COMMAND TO THE DRIVE
;
OUTCOM: LXI	H,CMBFR
OUTCM0: MVI	B,6		; COMMAND IS 6 BYTES LONG
	LDA	BASE$PORT
	MOV	C,A		; DATA PORT TO REG. C
OUTCM1: PUSH	B
	MVI	B,16		; SET LOOP COUNTER
	INR	C		; CONTROL PORT ADDRESS TO REG. C
OUTLOP: INP	A
	ANI	(REQ OR CMND OR POUT OR BUSY)
	CPI	(REQ OR CMND OR POUT OR BUSY)
	JRZ	OUTOK
	DJNZ	OUTLOP
	DCR	B
	POP	B
	RET
OUTOK:	POP	B		; RETURNS DATA PORT ADDRESS TO REG. C
	OUTI			; OUTPUT COMMAND BYTE
	JRNZ	OUTCM1
	RET
;
;	ACTUAL READ-WRITE OF DATA
;
SASIRW: 			; THIS ROUTINE IS FOR READING AND WRITING
	LDA	CMBFR
	SUI	RDBL		; IS COMMAND A READ ?
READ0	MVI	A,0B2H		; INIR FOR READS
	JRZ	NREAD
	MVI	A,0B3H		; OUTIR FOR WRITES
NREAD:	STA	HERE+1
	LXI	H,HSTBUF	; AND WRITING DATA
	LDA	BASE$PORT
	MOV	C,A		; DATA PORT ADDRESS TO REG. C
NXTSEC: INR	C		; INCREMENT TO CONTROL PORT
SASICK: INP	A		; FIRST CHECK FOR DRIVE READY
	ANI	(CMND OR BUSY OR REQ OR POUT)
	CPI	(CMND OR BUSY OR REQ)  ; IF POUT DROPS,
	RZ			       ;  WE ARE INTO STATUS PHASE
	ANI	(CMND OR BUSY OR REQ)
	CPI	(BUSY OR REQ)	; WHEN CMND DROPS, SEEK IS COMPLETE, AND WE ARE
	JRNZ	SASICK		;  READY FOR DATA TRANSFER
	DCR	C		; DATA PORT ADDRESS TO REG. C
	MVI	B,128
HERE:	INIR			; CHANGED TO OUTIR FOR WRITE
	JR	NXTSEC

PAGE



;	CHECK STATUS OF READ OR WRITE
;
CHK$STAT:			; THIS ROUTINE CHECKS WHAT'S UP
	LDA	BASE$PORT
	MOV	D,A		; DATA PORT ADDRESS STORED IN REG. D
	INR	A
	MOV	E,A		; CONTROL PORT ADDRESS STORED IN REG. E
	JR	CHK01
CHKNXT: MOV	C,D		; INPUT FROM DATA PORT
	INP	A
	MOV	B,A		; SAVE IN B REGISTER
CHK01:	MOV	C,E		; INPUT FROM CONTROL PORT
	INP	A
	ANI	(MSG OR REQ OR CMND OR POUT)
	CPI	(REQ OR CMND)
	JRZ	CHKNXT
	CPI	(MSG OR REQ OR CMND)
	JRNZ	CHK01
	MOV	C,D		; INPUT FROM DATA PORT
	INP	A		; GET FINAL BYTE
	MOV	A,B		; AND THROW IT AWAY, GET STATUS
	ANI	03		; EITHER BIT SET IS AN ERROR
	RET

****************************************************************

;
;	DATA BUFFERS AND STORAGE
;
LUN:	DB	0		; LOGICAL UNIT NUMBER
CMBFR:	DB	0,0,0,0,0,0	; COMMAND BUFFER
FFCMD:	DB	FFMT,20H,0,0,0,0  ; DEFINE FLOPPY DISK TRACK FORMAT COMMAND
				;					 STRING
RDSD1:	DB	RDBL,20H,0,26,1,0 ; READ A SECTOR ON SIDE 1 OF FLOPPY DISK
SECPTR	DW	0		; POINTER TO CURRENT SECTOR TABLE ENTRY
SELERR	DB	0		; SELECT ERROR FLAG
FLAGS:	DB	0		; BIT 7 = INITIALIZATION FLAG,
				; BIT 6 = FLOPPY DISK FLAG
				; BIT 5 = REMOVABLE MEDIA FLAG
				; BIT 4 (SPARE)
				; BITS 0-3 = PARTITION NUMBER,
BASE$PORT:
	DB	0		; BASE PORT ADDRESS
INIT$FLAG:
	DB	1		; INITIALIZATION FLAG
DRIV0	DB	0		; FIRST PHYSICAL DRIVE NUMBER
DRIV$LAST:			; LAST PHYSICAL DRIVE NUMBER
	DB	0
STRLUN	DB	0		; RELATIVE PARTITION NUMBER OF CURRENT LUN
PARTLUN DB	0		; NUMBER OF PARTITIONS IN CURRENT LUN
LVECADD DW	0		; ADDRESS OF LOGIN VECTOR (WHEN INITIALIZED)

;
; DEBLOCKING VARIABLES
;
PNDWRT	DB	0		; PENDING WRITE FLAG
RD$FLAG:DB	0		; FLAG FOR PRE-READ
HSTDSK	DB	0FFH
HSTTRK	DW	0
HSTSEC	DB	0
REQDSK	DB	0
REQTRK	DW	0
REQSEC	DB	0
BLCODE: DB	0		; SECTOR SIZE CODE (0=128,1=256,2=512,3=1024)
BLKSEC: DB	0		; LOCATION OF LOGICAL SECTOR WITHIN PHYSICAL
WRTYPE	DB	0
UNALLOC DB	0
URECORD DW	0
CURDPB	DW	0		; ADDRESS OF CURRENT DISK PARAMETER BLOCK
CURDPH	DW	0		; ADDRESS OF CURRENT DISK PARAMETER HEADER
MODE:	DW	0
BLKMSK	DB	0		; BLOCK MASK
OFFSET	DB	0

	REPT	(($+0FFH) AND 0FF00H)-$
	DB	0FFH
	ENDM
PAGE

MODLEN	EQU	$-MBASE
 DB 00100100B,10000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00001010B,10100000B,00001010B,10100000B,00001010B,10100000B,00001010B,10100000B
 DB 00001010B,10100000B,00001010B,10100000B,00001010B,10100000B,00001010B,10100000B
 DB 00001010B,10100000B,00000010B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00100010B,01001001B,00010001B,00000000B,01000001B
 DB 00000100B,00000010B,00000100B,10000001B,00100100B,00001000B,00001000B,00001000B
 DB 10000010B,00010000B,10010000B,00000000B,10001000B,01001000B,00000100B,01001000B
 DB 00000000B,00000000B,00010001B,00100010B,00000100B,00100100B,00000010B,00010001B
 DB 00100100B,01001001B,00100100B,10010010B,00100010B,00100010B,00010000B,00000100B
 DB 00000000B,00000100B,00100100B,00000000B,00100100B,00000000B,00000010B,00000000B
 DB 00100000B,00000100B,00000010B,00000001B,00100000B,10001000B,10000010B,01001001B
 DB 00100100B,10000000B,00100000B,00100001B,00010010B,00100001B,00000000B,00000000B
 DB 00100010B,00000000B,00000001B,00010001B,00000000B,10000000B,00000000B,10000000B
 DB 00100010B,00000010B,01000010B,00001000B,00000000B,00100010B,00100100B,10010000B
 DB 10000100B,10000000B,00010010B,00000001B,00001001B,00000000B,01000100B,10000010B
 DB 00000010B,00010010B,00000100B,01000100B,00001000B,00100100B,00000000B,00000010B
 DB 01000100B,10010000B,00010001B,00100000B,10001000B,00010010B,00000000B,10000100B
 DB 01000000B,10000100B,01000000B,00010000B,01000000B,00100001B,00100100B,10010010B
 DB 00100000B,10010010B,01000100B,00000100B,00001000B,00000000B,01000000B,00000000B
 DB 00001000B,00000001B,00100000B,00000000B,00000001B,00010001B,00010000B,00000000B
 DB 00100000B,00000000B,00000000B,00000000B,00000000B,00100001B,00000000B,00000000B
 DB 00000000B,00100000B,00000100B,10010000B,00000000B,00000000B,00001000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
; PUT BITMAP HERE
PAGE



********************************************************
** COMMON BUFFERS
********************************************************
	ORG	COMBUF
	DS	20
	DS	64
	DS	2
DIRBUF	DS	128
********************************************************

********************************************************
** BUFFERS
********************************************************
	ORG	BUFFER
HSTBUF: DS	256
CSV0:	DS	64	; FOR FLOPPY DISK
ALV0:	DS	62	;  "    "      "
CSV1:	DS	0
ALV1:	DS	0
CSV2:	DS	0
ALV2:	DS	0
CSV3:	DS	0
ALV3:	DS	0
CSV4:	DS	0
ALV4:	DS	0
CSV5:	DS	0
ALV5:	DS	0
CSV6:	DS	0
ALV6:	DS	0
CSV7:	DS	0
ALV7:	DS	0
CSV8:	DS	0
ALV8:	DS	0
**********************************************************
BUFLEN	EQU	$-BUFFER
	END


