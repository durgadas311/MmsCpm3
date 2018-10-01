;  July 16, 1982  13:46  klf  "M316.ASM"
**********************************************************
;	Disk I/O module for MMS CP/M 2.24
;	on the Heath/Zenith 89
;	for the MMS DD controller
;	Copyright (c) 1981 Magnolia Microsystems
;*********************************************************
	DW	modlen,buflen

BASE	EQU	0000H		; ORG FOR RELOCATION
				; alternate 0 and 100h.

	MACLIB Z80
	$-MACRO
;---------------------------------------------------------
;
;	Physical drives are assigned as follows:
;
;	29 - 1st 8" drive
;	30 - 2nd 8" drive
;	31 - 3rd 8" drive
;	32 - 4th 8" drive
;	33 - 1st 5" drive
;	34 - 2nd 5" drive
;	35 - 3rd 5" drive
;	36 - 4th 5" drive
;
;---------------------------------------------------------
;	Ports and Constants
;---------------------------------------------------------
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

driv0	equ	29		; first drive in system
ndriv	equ	8		; # of drives is system
DPHL	EQU	16		; LENGTH OF DISK PARAMETER HEADER
DPBL	EQU	15		; LENGTH OF DISK PARAMETER BLOCK
DPHDPB	EQU	10		; LOCATION OF DPB ADDRESS WITHIN DPH
MOD48RO EQU	00000100B	; 48 TPI DISK IN 96 TPI DRIVE (R/O)
MODEDD	EQU	01000000B	; DOUBLE DENSITY
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
DPEH37	EQU	60H		; I.D.
;--------------------------------------------------------
;	Links to rest of system
;--------------------------------------------------------
PATCH	EQU	BASE+1600H	; Points linker to BIOS overlay operation
MBASE	EQU	BASE		; Base address for module (0h or 0100h)
COMBUF	EQU	BASE+0C000H	; points linker to Common Buffer area
BUFFER	EQU	BASE+0F000H	; points linker to Module buffer area

;-------------------------------------------------------
;	Standard CP/M page-zero assignments
;-------------------------------------------------------
	ORG	0
?CPM		DS	3	; Jump to warm boot routine in BIOS
?DEV$STAT	DS	1	; Iobyte
?LOGIN$DSK	DS	1	; High nybble = user #, low = Drive
?BDOS		DS	3	; Jump to BDOS call 5 routines.
?RST1		DS	3	; Clock servicing routine vector
?CLOCK		DS	2	; Timer values
?INT$BYTE	DS	1
?CTL$BYTE	DS	1
		DS	1
?RST2		DS	8
?RST3		DS	8
?RST4		DS	8
?RST5		DS	8
?RST6		DS	8	; Interrupt routine for DD board
?RST7		DS	8
		DS	28
?FCB		DS	36
?DMA		DS	128
?TPA		DS	0

;-------------------------------------------------------
;	Overlay module information on BIOS
;-------------------------------------------------------
	ORG	PATCH
	DS	51		;JUMP TABLE
DSK$STAT:
	DS	1		; FDC status byte from last disk I/O
STEPR:	DS	1		; MIMI-FLOPPY STEP-RATE
SIDED:	DS	3		; CONFIG CONTROL FOR DRIVES
	DS	4		; FOR EIGHT-INCH REMEX
MIXER:
xxx	set	driv0
	rept	ndriv
	db	xxx
xxx	set	xxx+1
	endm
	DS	16-ndriv
DRIVE$BASE:
	DB	driv0,driv0+ndriv ; first drive, last drive+1
	DW	MBASE		; start of module
	DS	28

TIME$OUT:
	DS	3
NEWBAS	DS	2
NEWDSK	DS	1
NEWTRK	DS	1
NEWSEC	DS	1
HRDTRK	DS	2
DMAA	DS	2

;-------------------------------------------------------
;	Start of relocatable disk I/O module.
;-------------------------------------------------------
	ORG	MBASE		; START OF MODULE

	JMP	SEL$COMBO
	JMP	READ$COMBO
	JMP	WRITE$COMBO

	DB	'77316 ',0,'MMS Double Density Controller ',0,'2.243$'
DPH:
	DW	0,0,0,0,DIRBUF,DPB29,CSV29,ALV29
	DW	0,0,0,0,DIRBUF,DPB30,CSV30,ALV30
	DW	0,0,0,0,DIRBUF,DPB31,CSV31,ALV31
	DW	0,0,0,0,DIRBUF,DPB32,CSV32,ALV32
	DW	0,0,0,0,DIRBUF,DPB33,CSV33,ALV33
	DW	0,0,0,0,DIRBUF,DPB34,CSV34,ALV34
	DW	0,0,0,0,DIRBUF,DPB35,CSV35,ALV35
	DW	0,0,0,0,DIRBUF,DPB36,CSV36,ALV36
	DW	0,0,0,0,0,DEFDPB	; EXTRA DPH FOR USE BY DRIVER ONLY

DPB29:	DW	64		; SECTORS PER TRACK
	DB	4,15,0		; BSH,BSM,EXM
	DW	300-1,192-1	; DSM-1,DRM-1
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF
	DB	00000010B,01100110B,00000000B	; MODE BYTES
	DB	11010000B,10011100B,00000000B	; MODE MASKS

DPB30:	DW	64		; SECTORS PER TRACK
	DB	4,15,0		; BSH,BSM,EXM
	DW	300-1,192-1	; DSM-1,DRM-1
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF
	DB	00000010B,01100110B,00000000B	; MODE BYTES
	DB	11010000B,10011100B,00000000B	; MODE MASKS

DPB31:	DW	64		; SECTORS PER TRACK
	DB	4,15,0		; BSH,BSM,EXM
	DW	300-1,192-1	; DSM-1,DRM-1
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF
	DB	00000010B,01100110B,00000000B	; MODE BYTES
	DB	11010000B,10011100B,00000000B	; MODE MASKS

DPB32:	DW	64		; SECTORS PER TRACK
	DB	4,15,0		; BSH,BSM,EXM
	DW	300-1,192-1	; DSM-1,DRM-1
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF
	DB	00000010B,01100110B,00000000B	; MODE BYTES
	DB	11010000B,10011100B,00000000B	; MODE MASKS

DPB33:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000000B	; MODE MASKS

DPB34:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000000B	; MODE MASKS

DPB35:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000000B	; MODE MASKS

DPB36:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000000B	; MODE MASKS

DEFDPB: DW	26		; EXTRA DPB AND MODE BYTES TO BE USED ONLY
	DB	3,7,0		; BY DRIVER WHEN ACCESSING TRACK 0
	DW	243-1,128-1	; OF A ZENITH 8" DD DISK. TRACK 0 ON THESE
	DB	11000000B,0	; DISKS IS OF THE STANDARD SINGLE DENSITY
	DW	16,2		; FORMAT
	DB	00000000B,00000010B,00000000B
;------------------------------------------------------
;	Sector translation tables for 8" 
;------------------------------------------------------
SKEW1:	DB	1,7,13,19,25,5,11,17,23,3,9,15,21
	DB	2,8,14,20,26,6,12,18,24,4,10,16,22

SKEW2:	DB	1,2,19,20,37,38,3,4,21,22,39,40
	DB	5,6,23,24,41,42,7,8,25,26,43,44
	DB	9,10,27,28,45,46,11,12,29,30,47,48
	DB	13,14,31,32,49,50,15,16,33,34,51,52
	DB	17,18,35,36

SKEW3:	DB	1,2,3,4,5,6,7,8,33,34,35,36,37,38,39,40
	DB	9,10,11,12,13,14,15,16,41,42,43,44,45,46,47,48
	DB	17,18,19,20,21,22,23,24,49,50,51,52,53,54,55,56
	DB	25,26,27,28,29,30,31,32,57,58,59,60,61,62,63,64

SKEW4:	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
;*************************************************************************
;									 *
; INIT$COMBO -- SETS UP INTERRUPT ROUTINE IN PAGE 0 OF MEMORY; CLEARS THE*
;	WD-1797 FROM POWER-ON.						 *
;									 *
;*************************************************************************
 
INIT$COMBO:
	LXI	H,INTRQ$ROUTINE ; load interrupt routine into page-zero
	LXI	D,?RST6 	; as Restart 6.
	LXI	B,LEN$IR
	LDIR			; block transfer
	IN	STAT		; CLEAR WD-1797 from power-on (or whatever)
	RET

;************************************************************************
;									*
; SEL$COMBO -- Select a drive, from any combination of drives.		*
;	Given the physical drive number in 'C' (here, 29 to 36 decimal);*
;	selects the drive (not physical select, but logical);		*
;					       sets location 'mode' to	*
;	the drive's mode byte; looks up the number of tracks the drive  *
;	has and stores it in location 'num$trks'; sets the flag 	*
;	'flag$8dd' if the drive is 8" double density                    *
;			; sets the logical to physical translation	*
;	vector (0000 if no sector skew, else points to the translation	*
;	table) pointer in locations 0 and 1 of the Disk Parameter	*
;	Header to the Sector Skew table for 8" Single Density, or to 0  *
;	for any other format (no skew, or handled in hardware)		*
;	(Note:	see 'CP/M 2.2 Alteration Guide', chapter 10 for further *
;	information on disk parameter blocks and tables); returns with	*
;	HL pointing to the Disk Parameter Header for that drive;	*
;		  REMOVES ONE EXTRA WORD FROM THE STACK INTO DE, and	*
;	returns.  Apparently, the extra pop is to skip the rest of the	*
;	'seldsk' routine and return directly to the BDOS or the user.	*
;									*
;	Inputs:  Physical drive number in 'C'				*
;						    the drive mode byte *
;		table					the Disk	*
;		Parameter Blocks and Headers.				*
;	Outputs:  Physical drive number in 'C', the Disk Parameter	*
;		Header's address in HL, the top of the stack just after *
;		this routine was called in DE, the number of tracks	*
;		for the current drive in 'num$trks'			*
;		the current drive's mode byte in location 'mode',       *
;		a 0FFH for 8" double density else 00H in location       *
;		'flag$8dd', the proper sector skew vector in locations	*
;		0 and 1 of the DPH,					*
;	Destroys 'A', flags, 'D', 'B', top word on stack.		*
;									*
;************************************************************************
;

SEL$COMBO:
	LDA	PNDWRT		; CLEAR ANY PENDING WRITE
	ORA	A
	CNZ	WR$SEC
	LDA	INIT$FLAG	; INITIALIZE DRIVER IF THIS IS FIRST CALL
	ORA	A
	CZ	INIT$COMBO
	LDA	NEWDSK		; get drive select code in 'A'.
	SUI	DRIV0		; relate drive number to 0
	STA	RELDSK		; SAVE IT
SEL0:	LXI	H,DPH-DPHL	; POINT TO DPH TABLE
	LXI	D,DPHL
SEL1:	DAD	D
	DCR	A
	JP	SEL1
	PUSH	H		; SAVE DPH ADDRESS
	XRA	A
	STA	SELERR		; NO SELECT ERROR (YET)
	STA	FLAG$8DD	; CLEAR 8" DD FLAG
	LXI	D,DPHDPB
	DAD	D		; POINT TO ADDRESS OF DPB
	CALL	HLIHL		; POINT TO DPB
	SHLD	CURDPB
	LXI	D,DPBL
	DAD	D		; POINT TO MODE BYTES
	SHLD	MODE		; SAVE MODE BYTE POINTER
	PUSH	H
	CALL	LOGIN		; HAS DISK BEEN LOGGED IN ?
	JRC	LOGGED
	POP	H		; GET MODE BYTE 1
	PUSH	H
	BIT	4,M		; SHOULD WE READ TRACK 0 SECTOR 0 ?
	CNZ	PHYSEL
	POP	H		; GET MODE BYTE 1
	PUSH	H
	INX	H		; MODE BYTE 2
	BIT	2,M		; IS IT A 5.25" DISK ?
	CZ	PHYSEL3 	; THEN CHECK FOR HALF TRACK
LOGGED: POP	H		; GET MODE BYTE 1
	INX	H		; MODE BYTE 2
	MVI	A,40		; 40 TRACKS PER SIDE
	BIT	3,M		; CHECK TRACK DENSITY BIT
	JRZ	STRK
	ADD	A		; 80 TRACKS PER SIDE
STRK:	BIT	2,M		; CHECK FOR 8"
	JRZ	NOT8DD
	MVI	A,77		; 8" DISK HAVE 77 TRACKS PER SIDE
	BIT	6,M		; CHECK FOR DD
	JRZ	NOT8DD
	STA	FLAG$8DD	; FLAG AN 8" DD DISK
NOT8DD: STA	TPS		; SAVE TRACKS PER SIDE
	INX	H		; POINT TO MODE BYTE 3
	MOV	A,M
	ANI	00000111B	; ISOLATE SKEW TABLE BITS
	LXI	D,0
	JRZ	GOTSKW 
	LXI	D,SKEW1
	DCR	A
	JRZ	GOTSKW
	LXI	D,SKEW2
	DCR	A
	JRZ	GOTSKW
	LXI	D,SKEW3
	DCR	A
	JRZ	GOTSKW
	LXI	D,SKEW4
GOTSKW: POP	H		; GET DPH ADDRESS BACK
	MOV	M,E
	INX	H
	MOV	M,D		; SKEW TABLE ADDRESS INSTALLED IN DPH
; CALCULATE DEBLOCKING PARAMETERS
	LHLD	CURDPB		; GET DPB ADDRESS
	INX	H
	INX	H
	INX	H
	MOV	A,M		; GET BLOCK MASK
	STA	BLKMSK		; SAVE IT
	LXI	D,10
	DAD	D
	MOV	A,M		; GET TRACK OFFSET
	STA	OFFSET		; SAVE IT
	LHLD	MODE
	MOV	A,M
	ANI	03H		; ISOLATE SECTOR SIZE BITS
	STA	BLCODE		; STARE AS DEBLOCK CODE
; RETURN TO BIOS
	LDA	RELDSK
	MOV	C,A		; RESTORE PHYSICAL DRIVE #
	LXI	D,DPH		; SELDSK NEEDS START OF DPH TABLE
	RET

LOGIN:	LDA	NEWDSK		; CHECK FOR DISK LOGGED IN
	LXI	B,17
	LXI	H,MIXER
	CCIR
	MVI	A,17
	SUB	C
	MOV	B,A
	LXI	H,PATCH
	LXI	D,0D89H
	ORA	A
	DSBC	D
	CALL	HLIHL
	INX	H
	CALL	HLIHL
	CALL	HLIHL
ROTHL:	RARR	H
	RARR	L
	DJNZ	ROTHL
	RET

PHYSEL: LDA	NEWDSK
	STA	HSTDSK
	XRA	A
	STA	HSTTRK		; TRACK 0
	STA	HSTSEC		; SECTOR 0
	STA	SELOP		; FLAG A SELECT OPERATION
	STA	MODFLG		; RESET CHANGED MODE FLAG
	MVI	A,5		; 5 RETRYS FOR A SELECT OPERATION
	STA	RETRYS
	CALL	READ		; TRY READING LABEL AT DENSITY
				; CURRENTLY INDICATED IN TABLES
	JRZ	PHYSEL1 	; BR IF SUCCESSFUL
	MVI	A,5		; RESET RETRYS TO 5
	STA	RETRYS
	STA	MODFLG		; SET CHANGED MODE FLAG
	LHLD	MODE
	INX	H		; POINT TO MODE BYTE 2
	MOV	A,M		; TRY OTHER DENSITY
	XRI	MODEDD
	MOV	M,A
	CALL	READ		; TRY TO READ LABEL
	JRNZ	PHYSEL5 	; ERROR
PHYSEL1:XRA	A		; ZERO ACCUM.
	MVI	B,LABLEN	; GET LENGTH OF LABEL
	LXI	H,HSTBUF+LABEL
CHKLAB1:ADD	M
	INX	H
	DJNZ	CHKLAB1
	INR	A
	JRZ	PHYSEL2 	; BR IF CORRECT CHECKSUM
	LDA	MODFLG
	ORA	A		; MODE BEEN CHANGED ?
	JRNZ	PHYSEL6 	;  THEN ERROR
	JR	PHYSEL7 	; OTHERWISE DONE, KEEPING OLD MODE BYTES

;
;  EXTRACT MODE INFORMATION FROM LABEL
;
PHYSEL2:
	LHLD	MODE		; HL POINTS TO MODE BYTE
	LXI	D,HSTBUF+LABHTH ; DE POINTS TO HEATH EXTENSION IN LABEL
	LDAX	D		; GET FIRST BYTE OF HEATH EXTENSION
	MVI	B,00011000B	; Z37 DOUBLE DENSITY FORMAT
	MVI	C,00000001B	; 256 BYTES PER SECTOR
	BIT	2,A		; GET EXTENDED DOUBLE DENSITY BIT
	JRZ	GETSID
	MVI	B,00110000B	; Z37 EXTENDED DOUBLE DENSITY FORMAT
	MVI	C,00000011B	; 1024 BYTES PER SECTOR
GETSID: ANI	00000001B	; GET SIDED BIT
	RRC
	RRC
	RRC			; MOVE TO BIT POSITION 5
	ORA	C		; OR IN SECTOR SIZE BITS
	ORI	00010100B	; OR IN OTHER Z37 RELATED BITS
	MOV	M,A		; SAVE NEW MODE BYTE 1
	INX	H		; POINT TO MODE BYTE 2
	MVI	C,0		; BITS FOR SINGLE DENSITY
	LDAX	D
	BIT	1,A		; GET DOUBLE DENSITY BIT
	JRZ	SDEN
	MVI	C,01100000B	; DOUBLE DENSITY
SDEN:	ANI	00001000B	; GET TRACK DENSITY BIT
	ORA	C		; OR IN SECTOR SIZE BITS
	MOV	C,A
	MOV	A,M		; GET MODE BYTE 2
	ANI	00000011B	; KEEP STEP RATE BITS
	ORA	C		; OR IN NEW BITS
	MOV	M,A		; SAVE NEW MODE BYTE 2
	INX	H		; POINT TO MODE BYTE 3
	MOV	M,B		; SAVE NEW MODE BYTE 3
;
;		MOVE LABEL INFO TO DISK PARAMETER BLOCK.
;
	LDED	CURDPB		; GET DPB ADDRESS
	LXI	H,HSTBUF+LABDPB ; GET ADDRESS OF INFO IN LABEL
	LXI	B,DPBL		; COUNT TO MOVE
	LDIR			; MOVE INFO
	JR	PHYSEL7


PHYSEL5:MVI	A,0FFH
	STA	HSTDSK		; FLAG BUFFER AS UNKNOWN
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
	MVI	A,11000000B	; READ ADDRESS
	CALL	PUT$I
	ANI	00011000B SHL 1
	JRNZ	PHYSEL6
	IN	SECTOR
	CPI	2
	JRZ	PHYSEL4
	CPI	1
	JRNZ	PHYSEL6
	LHLD	MODE
	INX	H		; MODE BYTE 2
	BIT	3,M		; IS MODE SET TO DOUBLE TRACK ?
	JRNZ	PHYSEL6 	; ERROR BECAUSE WRONG DPB IS INSTALLED
	SETB	4,M		; SET HALF TRACK BIT
PHYSEL4:			; RESTORE
	CALL	HOME  
	JRC	PHYSEL6
	JR	PHYSEL7

;
WRALL	EQU	0		; WRITE TO ALLOCATED
WRDIR	EQU	1		; WRITE TO DIRECTORY
WRUNA	EQU	2		; WRITE TO UNALLOCATED
READOP	EQU	3		; READ OPERATION

READ$COMBO:
	LDA	PNDWRT		; SECTOR WAITING TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC
	MVI	A,READOP	; FLAG A READ OPERATION
	JR	RWOPER

WRITE$COMBO:
	MOV	A,C

RWOPER: STA	WRTYPE		; SAVE WRITE TYPE
	LDA	SELERR		; WAS THERE AN ERROR ON SELECT ?
	ORA	A
	RNZ
	MVI	A,21		; 21 RETRYS FOR A READ/WRITE OPERATION
	STA	RETRYS
	LDA	NEWTRK
	ORA	A		; ARE WE ON TRACK 0 ?
	JRNZ	NOTZ8DD
	LHLD	MODE
	INX	H		; MODE BYTE 2
	MOV	A,M
	ANI	01100000B	; ISOLATE THE TWO DENSITY BITS
	CPI	01000000B	; IS IT DD WITH TRACK 0 SD ?
	JRNZ	NOTZ8DD
	MVI	A,8		; THEN WE MUST RE-SELECT DISK AS 8" SD
	PUSH	D		; SAVE REG. D
	CALL	SEL0
	POP	D		; RESTORE REG. D
	LXI	H,RESEL 	; RESELECT DISK WHEN DONE WITH I/O OPERATION
	PUSH	H
NOTZ8DD:PUSH	D		; TEMPORARILY SAVE RECORD NUMBER
	LXI	B,3
	LXI	H,NEWDSK
	LXI	D,REQDSK
	LDIR
	POP	D		; RESTORE RECORD NUMBER
;*****************************************************************************
; DBLOCK: THIS SUBROUTINE PERFORMS THE DEBLOCKING FUNCTION.		     ;
;	  INPUTS: NEWSEC (THE REQUESTED LOGICAL SECTOR) 		     ;
;		  BLCODE (THE DEBLOCKING CODE DETERMINED FROM THE MODE BYTE) ;
;	  OUTPUTS:NEWSEC (THE REQUIRED PHYSICAL SECTOR) 		     ;
;		  BLKSEC (THE POSITION OF THE REQUESTED LOGICAL SECTOR	     ;
;			   WITHIN THE PHYSICAL SECTOR)			     ;
;									     ;
DBLOCK: XRA	A		; CLEAR CARRY				     ;
	MOV	C,A		; CALCULATE PHYSICAL SECTOR		     ;
	LDA	BLCODE							     ;
	MOV	B,A							     ;
	LDA	NEWSEC							     ;
DBLOK1: DCR	B							     ;
	JM	DBLOK2							     ;
	RAR								     ;
	RARR	C							     ;
	JR	DBLOK1							     ;
DBLOK2: STA	REQSEC		; SAVE IT				     ;
	LDA	BLCODE		; CALCULATE BLKSEC			     ;
DBLOK3: DCR	A							     ;
	JM	DBLOK4							     ;
	RLCR	C							     ;
	JR	DBLOK3							     ;
DBLOK4: MOV	A,C							     ;
	STA	BLKSEC		; STORE IT				     ;
;*****************************************************************************

	INR	A		; NON-ZERO VALUE TO ACC.
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
	DSBC	D		; SAME AS EXPECTED UNALLOCATED RECORD ?
	JRNZ	ALLOC		; IF NOT, THEN DONE WITH UNALLOCATED BLOCK
	XRA	A		; CLEAR PRE-READ FLAG
	STA	RD$FLAG
	INX	D		; INCREMENT TO NEXT EXPECTED UNALLOCATED RECORD
	SDED	URECORD
	LDA	BLKMSK
	ANA	E		; IS IT THE START OF A NEW BLOCK ?
	JRNZ	CHKRD
ALLOC:	XRA	A		; NO LONGER WRITING AN UNALLOCATED BLOCK
	STA	UNALLOC
CHKRD:				; IS SECTOR ALREADY IN BUFFER ?
;*****************************************************************************
; CHKSEC: THIS SUBROUTINE COMPARES THE REQUESTED DISK TRACK AND SECTOR	     ;
;	  TO THE DISK,TRACK AND SECTOR CURRENTLY IN THE BUFFER. 	     ;
;	  OUTPUT: ZERO FLAG SET IF SAME, RESET IF DIFFERENT		     ;
;									     ;
CHKSEC: LXI	H,NEWTRK
	LDA	OFFSET
	CMP	M		; IS IT THE DIRECTORY TRACK ?
	JRNZ	CHKBUF
	INX	H
	MOV	A,M
	ORA	A		; FIRST SECTOR OF DIRECTORY ?
	JRZ	READIT 
CHKBUF: LXI	H,REQDSK						     ;
	LXI	D,HSTDSK						     ;
	MVI	B,3							     ;
CHKNXT: LDAX	D							     ;
	CMP	M							     ;
	JRNZ	READIT
	INX	H							     ;
	INX	D							     ;
	DJNZ	CHKNXT							     ;
;*****************************************************************************

	JR	NOREAD		; THEN NO NEED TO PRE-READ
READIT: LDA	PNDWRT		; IS THERE A SECTOR THAT NEEDS TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC		; WRITE IT
	LXI	D,HSTDSK	; SET UP NEW BUFFER PARAMETERS
	LXI	H,REQDSK
	LXI	B,3
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
	INR	A		; FLAG A PENDING WRITE (ANY NON-ZERO VALUE)
	STA	PNDWRT
MOVIT3: LDIR			; MOVE IT
	CPI	WRDIR+1 	; CHECK FOR DIRECTORY WRITE (+1 BECAUSE OF INR)
	CZ	WR$SEC		; WRITE THE SECTOR IF IT IS
	XRA	A		; FLAG NO ERROR
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

WR$SEC: XRA	A
	STA	PNDWRT		; FLAG NO PENDING WRITE
	CALL	WRITE		; WRITE A PHYSICAL SECTOR
	RZ			; RETURN IF WRITE WAS SUCCESSFUL
	LDA	WRTYPE
	CPI	READOP		; IGNORE ERROR IF THIS IS A READ OPERATION
	RZ
	JR	RWERR

RD$SEC: CALL	READ		; READ A PHYSICAL SECTOR
	RZ			; RETURN IF SUCCESSFUL
	MVI	A,0FFH		; FLAG BUFFER AS UNKNOWN
	STA	HSTDSK
RWERR:	POP	D		; THROW AWAY TOP OF STACK
	MVI	A,1		; SIGNAL ERROR TO BDOS
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

RESEL:	PUSH	PSW		; SAVE STATUS OF I/O OPERATION
	CALL	SEL$COMBO	; SET UP CORRECT DISK PARAMETERS AGAIN
	POP	PSW		; RECALL STATUS OF I/O OPERATION FOR BDOS
	RET			; RETURN TO BDOS



;************************************************************************
;									*
; READ$COMBO -- Read from a combination of drive types			*
;									*
;************************************************************************
;
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

;************************************************************************
;									*
; WRITE$COMBO -- Write to any of the combined types of drives.		*
;									*
;************************************************************************
;
WRITE:	LHLD	MODE		; CHECK FOR HALF TRACK R/O
	INX	H
	BIT	4,M
	JRNZ	ERROR		; R/O ERROR
	CALL	ACCESS$R	; ACCESS DRIVE FOR WRITE
	JRC	ERROR
	LDA	DSK$STAT	; GET DISK STATUS BYTE
	RAL
	RAL			; WRITE PROTECT BIT TO CARRY
	JRC	ERROR		; WRITE PROTECT ERROR
	CALL	IO$COMBO
	JRZ	NOT8DDW
	LXI	D,WR$8DD	; WRITE ROUTINE FOR 8" DD
NOT8DDW:MVI	B,10101000B	; WRITE COMMAND W/O SIDE SELECT
	MVI	A,0A3H		; OUTI INSTRUCTION (2ND BYTE)

;************************************************************************
;									*
; TYPE$IIR -- Type 2 Disk Read						*
; TYPE$IIW -- Type 2 Disk Write 					*
;	Given the address of the disk transfer routine in 'DE', the	*
;	disk data transfer address in 'HL', set up the parameters	*
;	for the IO$xxxx routines	       , sets the number of	*
;	retries, puts the disk read or write command in 'B' without the *
;	side select bits, and continues execution in the 'RETRY'	*
;	routine.							*
;									*
;	Inputs:  'DE' is the disk transfer routine address, 'HL' is the *
;		disk data transfer address.				*
;	Outputs:  'fix1', 'fix2', 'B' holds command without side select *
;		bits, 'retries' holds retry count.			*
;	Register effects:  Assume all 8080 registers destroyed. 	*
;									*
;************************************************************************
;
;
TYPE$II:
	STA	FIX1+1		;setup physical routines for read/write
;************************************************************************
;									*
; RETRY -- Retry loop for disk transfers.				*
;	Given the disk controller command in 'B', the side select bits	*
;	in location 'side', the disk transfer routine address in 'DE',	*
;	and the disk data transfer address in 'HL', and the interrupt	*
;	control byte at '?int$byte', turns off the 2 millisecond clock, *
;	merges the side select byte with the command byte into 'A', and *
;	calls the disk transfer routine specified in 'DE'.  It then	*
;	stores the disk status byte returned by the routine at location *
;	'dsk$stat', turns back on the 2 millisecond clock, and checks	*
;	for a successful transfer of data.  If so, it ends with 'A' set *
;	to 0 and the Zero flag set.  If not, the retry count is 	*
;	decremented, and if the count is not 0, the routine tries again.*
;	If the retry count is 0, it ends with 'A' = 0FFH and the Zero	*
;	flag reset.							*
;									*
;	Inputs:  disk controller command in 'B' minus the side select	*
;		bits, the side select bits in location 'side', the	*
;		disk transfer routine address in 'DE', the disk data	*
;		transfer address in 'HL', the interrupt byte at 	*
;		'?int$byte', and the inputs of the disk transfer	*
;		routine specified.					*
;	Outputs:  'A' = 0, Zero flag set for success, 'A' = 0FFH, Zero	*
;		flag reset for failure. 				*
;	Register effects:  Assume all 8080 registers destroyed, 'A' and *
;		Flags set according to the results.			*
;									*
;************************************************************************
RETRY:						     
	PUSH	B		; save registers
	PUSH	D
	LDA	?INT$BYTE	; get interrupt byte
	ANI	11111101B	; Turn 2 millisecond clock off
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
	STA	DSK$STAT	; save status of transfer
	LDA	CTRL$IMAGE
	OUT	CTRL		; BURST MODE OFF.
	LDA	?INT$BYTE	; get interrupt byte
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
	LXI	D,HSTBUF
	DSBC	D		; HL NOW CONTAINS # OF BYTES TRANSFERRED
	LDA	DSK$STAT	; check for successful transfer
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

;----------------------------------------------------
;	General INPUT/OUTPUT routine.
;----------------------------------------------------
;
;
IO$COMBO:
	LHLD	MODE
	MOV	A,M		; GET MODE BYTE 1
	ANI	00001100B	; ISOLATE TRACK NUMBERING BITS
	CPI	00001000B	; IS IT XOS/GNAT NUMBERING ?
	LDA	HSTSEC		; GET SECTOR NUMBER
	JRNZ	NOTRAN
	LHLD	CURDPB		;*** This is supposed to translate sector
	CMP	M		;*** for the GNAT or X-O but it won't
	JRC	NOTRAN		;*** work as coded here. The SIDE byte must be
	SUB	M		;*** updated and the sector must be compared to
				;*** SPT/2 not SPT as coded.
NOTRAN: INR	A		; MAKE IT 1,2,3,...,SPT
	OUT	SECTOR		; give to controller
	LXI	D,IO$1024	; I/O ROUTINE FOR ALL BUT 8" DD
	LDA	FLAG$8DD	; CHECK FOR 8" DD
	ORA	A		; ZERO FLAG SET IF NOT
	RET

;************************************************************************
;									*
; ACCESS$R -- Access Drive For Read routine				*
;	Tests drive with physical drive number in 'newdsk' and mode	*
;	byte in 'mode' for readiness, physically selects the drive and	*
;	seeks to the track specified in 'newtrk', returns with 'A' = 0, *
;	Zero flag set for success, 'A' = 0FFH, Zero flag reset for	*
;	failure.  Probably has other parameters and outputs in the	*
;	routines it calls.						*
;									*
;	Inputs:  'newdsk', 'mode', 'newtrk', see SELECT and SEEK	*
;		routines for their inputs.				*
;	Outputs:  'A' = 0, Zero flag set for success, 'A' = 0FFH and	*
;		Zero flag reset for failure.  SELECT and SEEK also	*
;		may have outputs.					*
;	Assume all 8080 registers destroyed, 'A' and Flags set according*
;		to results.						*
;									*
;************************************************************************


;************************************************************************
;									*
; IO$1024 -- Input/Output 1024 Bytes From/To 5" Disk                    *
; RW2 -- Input/Output Number Of Bytes In 'B', 'C' = Data Port.		*
;	Given that the disk controller command has been output to the	*
;	controller, that 'HL' points to the address the data is to be	*
;	transferred to, that INI or OUTI instructions have been 	*
;	inserted at locations FIX1 and FIX2, and that 'B' = the 	*
;	transfer length and 'C' = the controller data port at entry	*
;	point RW2; transfers 512 bytes of data to or from the disk	*
;	controller depending on whether INI or OUTI instructions have	*
;	been inserted at FIX1 and FIX2, or the number of bytes		*
;	specified by 'B' at entry point RW2.  Exits through the 	*
;	INTRQ$ROUTINE routine, triggered by the disk controller's       *
;	INTRQ signal, which inputs from the controller status register, *
;	clears the interrupt's pushed address from the stack, enables   *
;	interrupts, and returns.					*
;									*
;	Inputs:  'HL' = the data transfer address, locations 'fix1'	*
;		and 'fix2', depending on 'fix1' and 'fix2' the 512	*
;		or 128 locations at 'HL' up, at entry point RW2, 'B'	*
;		sets the transfer length and 'C' = the controller	*
;		data port.						*
;	Outputs:  Depending on 'fix1' and 'fix2' the 512 or 128 	*
;		locations at 'HL' up; 'A' = the disk controller's       *
;		status byte.						*
;	Register effects:  'A' set, 'HL', 'B', flags destroyed. 	*
;									*
;************************************************************************
;
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

;************************************************************************
;									*
; TYPE$II$COM -- Type 2 command:  Jump to address in 'DE'.		*
;									*
;************************************************************************
;
TYPE$II$COM:
	LXI	B,(0)*256+(DATA) ; SETUP FOR 256 BYTES
	LXI	H,HSTBUF	 ; DATA BUFFER ADDRESS
	PUSH	D		 ; put 'DE' on stack.
	RET			 ; return to that address.

;************************************************************************
;									*
; SELECT -- Physically select a new drive				*
;	Given the physical drive number in 'newdsk', the mode byte for	*
;	that drive in the 'mode' location,				*
;				  sets up the 'ctrl$image' byte 	*
;	for later outputs to CTRL, sets up the step rate bits for seek- *
;	restore commands, saves the head (track) position of the	*
;	current drive in the 'trks' array addressed by the contents of	*
;	location 'logdsk' (the relative #), stores the new current	*
;	drive number in 'logdsk', sets the current track number for the *
;	requested drive from the 'trks' array, and does a physical seek *
;	to the track that drive is currently on, causing a head-load	*
;	only, returning the controller status in 'A'.			*
;									*
;	Inputs:  'newdsk' is physical drive number, 'mode' array holds	*
;		mode byte, 'trks' array holds track numbers, 'logdsk'	*
;		holds old current drive number. 			*
;	Outputs:  'trks' array holds old current drive track number,	*
;		'ctrl$image' holds CTRL base byte, controller status	*
;		in 'A', 'logdsk' holds new current drive number.	*
;	Register effects:  Assume all 8080 registers destroyed, 'A'	*
;		set according to results.				*
;									*
;************************************************************************
;
SELECT:
	LHLD	MODE		; point to drive mode byte table
	LDA	RELDSK		; get the RELATIVE drive number
	MOV	C,A		; relative drive number in (C) (rel. to driv0)
	INX	H		; POINT TO MODE BYTE 2
	MOV	A,M
	ANI	01000000B	; ISOLATE DENSITY BIT
	XRI	01000000B	; REVERSE IT (CONTROLLER WANTS 1 FOR SDEN.)
	ORA	C		; OR IN DRIVE SELECT CODE
	ORI	00101000B	; BURST MODE OFF, interrupt line enabled
	STA	CTRL$IMAGE	; save image for subsequent outputs
	MOV	A,M
	ANI	00000011B	; setup steprate bits for seek-restore commands
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
;----------------------------------------------------------
;	The control port must be set after the head load
;	signal is activated because if head load drops
;	after the CTRL$IMAGE is output, it clears the
;	control port leaving no drive selected when a
;	command is issued.
;	This will cause the system to hang!
;----------------------------------------------------------
	DI	;MUST NOT BE DISTRACTED
	OUT	STAT		; ISSUE COMMAND, HEAD WILL LOAD IN 15uS
	DAD	D		; 5.371 uS
	LDA	CTRL$IMAGE	; +6.348 =11.719 uS
	OUT	CTRL		; +5.371 = 17.090 uS, HEAD IS LOADED BY NOW
	EI			; COMMAND WILL FINISH IN ABOUT 30 uS
	JR $-1			; "RET" DONE BY INTRQ ROUTINE

;************************************************************************
;									*
; SEEK -- Physical Seek To Track 'newtrk', current drive.		*
;									*
;	Inputs:  Track to seek to in 'newtrk'				*
;	Outputs:  Carry flag set on error, reset on success, side data	*
;		at 'SIDE', drive status in 'DSK$STAT', residual error	*
;		counts at 'SEKERR' and 'SEKERR'+1.			*
;	Register effects:  ALL						*
;									*
;************************************************************************
ACCESS$R:
	CALL	SELECT
	MOV	A,C		; ARE WE SELECTING A DIFFERENT
	ORA	A		; DRIVE FROM BEFORE ?
	JRZ	SEEK
	LXI	D,33000 	; MUST WAIT 400 MS
WAIT:	DCX	D
	MOV	A,D
	ORA	E
	JRNZ	WAIT
;
SEEK:
;************************************************************************
;									*
;	  Convert a requested track number to track and side data.	*
;	Given a requested track number in 'HSTTRK', number of tracks	*
;	per side in location 'NUM$TRKS', sets 'A' to the track number	*
;	on the resulting side and sets 'B' to 0 for the first side,	*
;	to 00000010 for the second side.				*
;									*
;	Inputs:  requested track number in 'HSTTRK', 'NUM$TRKS'.	*
;	Outputs:  'A' holds proper track number, 'B' holds 0 for first	*
;		side, 00000010 for second side. 			*
;	Register effects:  ALL, through "SEEK". 			*
;									*
;************************************************************************
;
CONV:	LDA	HSTTRK		; GET REQUESTED TRACK
	MVI	B,0		; SET SIDE VALUE FOR SIDE 0
	LHLD	MODE
	BIT	2,M	;*** NOTE: this test doesnot take into account the
			;*** condition of "GNAT/XO" or UNDEFINED codes.
	JRNZ	CONZEN		; ALTERNATE CONVERT PROCEDURE FOR ZENITH DISKS
	LXI	H,TPS		; GET TRACKS PER SIDE
	MOV	C,M
	CMP	C		; compare requested track with tracks-per-side
	JRC	SIDE0		; no conversion if on first side.	 
	CMA			; negate logical track number	 
	INR	A	
	ADD	C		; add tot tracks on disk surfaces (2*NUM$TRKS)
	ADD	C	
	DCR	A		; sub 1 because tracks start at 0	 
	JR	SIDE1 
CONZEN: BIT	5,M		; CHECK SIDED BIT
	JRZ	SIDE0		; NO CONVERT IF SINGLE SIDED
	RAR			; DIVIDE BY 2 TO GET REAL TRACK NUMBER
	JRNC	SIDE0
SIDE1:	MVI	B,00000010B	; set side value for 2nd side	 

SIDE0:	MOV	C,A		; store track number
	MOV	A,B		
	STA	SIDE		; save side value for read/write command
	LXI	H,SEKERR	; initialize seek error counters
	MVI	M,4		; 4 ERRORS ON SEEK IS FATAL
	INX	H
	MVI	M,10		; RESTORE once, then 9 errors are fatal
RETRS:	CALL	CHKRDY		; MAKE SURE DRIVE IS READY
	RC			; quit if drive is not ready
	MOV	A,C		; get track number back
	ORA	A		; FORCES "RESTORE" IF "seek to track 0"
	JRZ	HOME		;RESTORE HEAD TO TRACK 0
	LHLD	MODE		;TRACK NUMBER IN (A) MUST BE PRESERVED
	INX	H		; MODE BYTE 2
	MOV	H,M		; BIT 4 IS THE HALF-TRACK OPTION
	IN	TRACK		;CURRENT HEAD POSITION,
	SUB	C		;SEE HOW FAR WE WANT TO GO.
	RZ			;IF ZERO TRACKS TO STEP, WERE FINISHED
	MVI	B,01111000B	;ASSUME STEP-OUT + UPDATE + HEADLOAD
	JRNC	STOUT	;ASSUMPTION WAS CORRECT...
	MVI	B,01011000B	;ELSE MUST BE STEP-IN
	NEG		;AND NUMBER OF TRACKS WOULD BE NEGATIVE
STOUT:	MOV	L,A		;COUNTER FOR STEPING
SEEK5:	BIT	4,H		; CHECK FOR 48 TPI DISK IN 96 TPI DRIVE
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
	LDA	DSK$STAT	;GET TRUE ERROR STATUS OF READ-ADDRESS
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

STEPIN: LHLD	MODE
	INX	H		; MODE BYTE 2
	BIT	4,M		; CHECK HALF TRACK BIT
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

;************************************************************************
;									*
; READ$ADDR -- Read Track Address From Disk				*
;	Attempts to read the current head position into the disk	*
;	controller, returns with controller status byte in 'A' and	*
;	location 'dsk$stat'.						*
;									*
;************************************************************************
;
READ$ADDR:
	LDA	SIDE
	ORI	11000100B	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	JR	PUT$I		; IGNORE DATA (AND DATA-LOST ERROR)

;
;************************************************************************
;									*
; TYPE$I -- Send a Type I (Seek/Restore) Command To The Controller	*
; PUT$I -- Entry That Ignores Steprate Bits				*
;	Given a Seek or Restore command in 'B', ORs in the steprate	*
;	bits from 'stepra', or for entry PUT$I takes command in 'A',	*
;	disables interrupts, sends the command to the controller,	*
;	waits, waits for the controller to not be busy, stores the	*
;	controller status, enables interrupts, and ends.  Used to seek	*
;	or restore the controller, or for entry PUT$I tries to input	*
;	the current track position of the head from the drive.		*
;									*
;	Inputs:  Seek or Restore command in 'B', step rate data in	*
;		'stepra', or for entry PUT$I the command in 'A'.	*
;	Outputs:  Controller status in 'A'.				*
;	Register effects:  'A' set,'DE' used in "CHKRDY".		*
;									*
;************************************************************************
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
	STA	DSK$STAT	;SAVE TYPE$II (III) STATUS FOR ERROR DETECTION.
	MVI	A,11010000B	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	STAT
	EI			; re-enable interrupts.
	IN	DATA		; FALL THROUGH TO CHKRDY
	
;************************************************************************
;									*
; CHKRDY -- Check for drive ready					*
;	Given that a drive has been physically selected, waits up to	*
;	0.8 seconds for the drive to become ready, returns with the	*
;	Carry flag set if the drive did not become ready; returns with	*
;	the Carry flag reset if the drive did become ready.		*
;									*
;	Inputs:  None.							*
;	Outputs:  [CY] on failure, [NC] on success;			*
;	Register effects:  'DE', 'A', Flags destroyed.			*
;									*
;************************************************************************
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
	

HLIHL:	MOV	A,M		; LOAD HL INDIRECT THRU HL
	INX	H
	MOV	H,M
	MOV	L,A
	RET

;---------------------------------------------------
;	FDC interrupt service routine.
;	Stuffed in loc 30h in page zero (rst30).
;---------------------------------------------------
INTRQ$ROUTINE:
	IN	STAT		; Clear interrupt request
	INX	SP		; TERMINATE SUB-ROUTINE by eliminating the
	INX	SP		; return address PUSHed by the interrupt.
	EI			; turn interrupts back on.
	RET			; end
LEN$IR	EQU	$-INTRQ$ROUTINE ; length of routine to transfer.

FLAG$8DD: DB	0
TPS:	DB	0		; TRACKS PER SIDE
STEPRA	DB	0		; STEP RATE CODE 
RETRYS	DB	0
SEKERR	DB	0,0		; SEEK,RESTORE ERROR COUNTS
MODE	DW	0		; POINTER TO MODE BYTE
RELDSK	DB	0		; DRIVE # RELATIVE TO 0
LOGDSK	DB	8		; CURRENT DRIVE SELECTED BY THIS MODULE
CTRL$IMAGE: DB	0		; IMAGE OF CONTROL PORT
SIDE	DB	0		; SIDE SELECT BIT FOR COMMANDS
WRTYPE	DB	0
RD$FLAG DB	0
URECORD DW	0
UNALLOC DB	0
BLKMSK	DB	0
HSTDSK	DB	0FFH
HSTTRK	DB	0
HSTSEC	DB	0
REQDSK: DB	0
REQTRK: DB	0
REQSEC: DB	0
BLKSEC	DB	0
PNDWRT	DB	0
BLCODE	DB	0
INIT$FLAG:
	DB	0
OFFSET: DB	0		; OFFSET TO DIRECTORY TRACK
SELERR: DB	0
SELOP:	DB	0FFH
CURDPB: DW	0
SERIAL: DB	0,0,0,0
MODFLG: DB	0
;----------------------------------------------------
;	Current head positions for each drive
;----------------------------------------------------
TRKS:	DB	255,255,255,255,255,255,255,255,0	
	
	REPT	(($+0FFH) AND 0FF00H)-$
	DB	0	
	ENDM

MODLEN	EQU	$-MBASE 

 DB 00100100B,10000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000010B
 DB 10101000B,00000010B,10101000B,00000010B,10101000B,00000010B,10101000B,00000010B
 DB 10101000B,00000010B,10101000B,00000010B,10101000B,00000010B,10101000B,00000000B
 DB 10000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00010000B,00000000B,01000100B,10001001B,00001001B,00000001B,00001001B
 DB 00000010B,01000000B,10001000B,00000100B,00000100B,00000000B,00000000B,00010010B
 DB 00000000B,00100000B,10000010B,00001000B,00010000B,00100000B,00100100B,00010010B
 DB 00100010B,00001000B,00000100B,00000010B,00100100B,00000001B,00100010B,01001001B
 DB 00001001B,00000010B,01001000B,00001000B,00001000B,00000010B,00000010B,01000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,10010000B,00000001B,00001000B
 DB 01000100B,10000100B,00001001B,00001000B,00000000B,00000100B,00000001B,00000010B
 DB 00100000B,00100100B,00001001B,00000100B,00000000B,00010001B,00000001B,00100000B
 DB 00100010B,00100000B,00100100B,01000000B,01000100B,10000000B,00100010B,01000001B
 DB 00000001B,00001001B,00000010B,01001000B,00000001B,00100000B,00000000B,01000100B
 DB 10010000B,00010001B,00100000B,10001000B,00010010B,00000001B,00000010B,00001001B
 DB 00010000B,00010000B,01000000B,01000010B,00010000B,10000000B,00001000B,00001000B
 DB 01000000B,10000100B,00001000B,00000000B,01000000B,00000000B,00000000B,00000100B
 DB 01001001B,00000000B,00100000B,00000000B,00000010B,00010000B,00100000B,10000000B
 DB 00000010B,00010010B,00100000B,10010001B,00001001B,00001001B,00000001B,00001000B
 DB 00000010B,01000000B,00000001B,00000000B,00000100B,00100001B,00001000B,00100000B
 DB 00000000B,00000000B,00000010B,00010000B,10000100B,00000100B,00100100B,00000000B
 DB 00100000B,10010000B,00000010B,00000100B,00000000B,00000010B,00000010B,00000000B
 DB 00000100B,00100000B,01000000B,00000000B,00000000B,00100100B,00000100B,00000100B
 DB 00000000B,00000000B,00000100B,00000010B,00000000B,00010000B,00001000B,00001000B
 DB 00000000B,00010000B,00000000B,01000000B,10010000B,10000000B,10000000B,00000000B
 DB 00000010B,00000000B,00100000B,00000000B,10000001B,00000000B,00000000B,01000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B

;--------------------------------------------------
;	Common Buffers
;--------------------------------------------------
	ORG	COMBUF	
	DS	20	
	DS	64	
	DS	2	
DIRBUF	DS	128
;
;-----------------------------------------------
;	Local Buffers
;-----------------------------------------------
	ORG	BUFFER
HSTBUF	DS	1024
CSV29	DS	64
ALV29	DS	76
CSV30	DS	64
ALV30	DS	76
CSV31	DS	64
ALV31	DS	76
CSV32	DS	64
ALV32	DS	76
CSV33	DS	64
ALV33	DS	50
CSV34	DS	64
ALV34	DS	50
CSV35	DS	64
ALV35	DS	50
CSV36	DS	64
ALV36	DS	50
;-------------------------------------------------------
BUFLEN	EQU	$-BUFFER
	END
