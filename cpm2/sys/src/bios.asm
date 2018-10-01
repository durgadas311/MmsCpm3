


********** CP/M BIOS FOR HEATH H89 COMPUTER **********
**********    WITHOUT DISK I/O MODULES	    **********
     * Copyright (C) 1981 Magnolia Microsystems *

	TITLE	'BIOS'

	MACLIB	Z80
	$-MACRO

VERS	EQU	22		; CP/M VERSION 2.2
SUBV1	EQU	4		; MMS VERSION 2.24 (Disk I/O modules)
SUBV2	EQU	2
	IF SUBV2 = 0
VSUB2	  EQU	' '
	  IF SUBV1 = 0
VSUB1	    EQU ' '
	  ELSE
VSUB1	    EQU SUBV1+'0'
	  ENDIF
	ELSE
VSUB1	  EQU	SUBV1+'0'
VSUB2	  EQU	SUBV2+'0'
	ENDIF

BASE	EQU	0000H		; ORG FOR RELOC

***** PHYSICAL DRIVES ARE ASSIGNED IN MODULES *****
***************************************************
** Z89 PORTS AND CONSTANTS
***************************************************
?CONSOLE	EQU	0E8H
?CONSTAT	EQU	0EDH
?MODEM		EQU	0D8H
?MODSTAT	EQU	0DDH
?PRINTER	EQU	0E0H
?PRTSTAT	EQU	0E5H
?DISK$CTL	EQU	7FH
?PORT		EQU	0F2H

?RAM$EN EQU	10000000B	; ENABLE FLOPY-RAM

?RECEIVE EQU	00000001B	; data ready bit in INS8250
?SEND	 EQU	00100000B	; xmit buf empty in '8250

?ESC	EQU	27
***************************************************
** LINKS TO REST OF CPM SYSTEM
***************************************************
@CCP	EQU	BASE
@BDOS	EQU	@CCP+0806H
PATCH	EQU	@BDOS+0E00H-6
COMBUF	EQU	BASE+0C000H	; COMMON BUFFER

?MSGOUT EQU	9		; BDOS CODE FOR PRINT BUFFER $
?RESET	EQU	13		; reset disk system
?OPENF	EQU	15		; open file
?READF	EQU	20		; read file
?SETDMA EQU	26		; set dma address
?USER	EQU	32		; set/get user number
***************************************************
** DEFAULT IOBYTE VALUE
***************************************************
** CON: device options
@TTY	EQU	0		; TTY: device code
@CRT	EQU	1		; CRT: device code
@BAT	EQU	2		; BAT: device (RDR:=input, LST:=output)
@UC1	EQU	3		; UC1: device (User Console #1)

** RDR: device options
*TTY	EQU	0		; TTY: device code
@RDR	EQU	1		; RDR: device (High Speed Reader)
@UR1	EQU	2		; UR1: device (User Reader #1)
@UR2	EQU	3		; UR2: device (User Reader #2)

** PUN: device options
*TTY	EQU	0		; TTY: device code
@PUN	EQU	1		; PUN: device (High Speed Punch)
@UP1	EQU	2		; UP1: device (User Punch #1)
@UP2	EQU	3		; UP2: device (User Punch #2)

** LST: device options
*TTY	EQU	0		; TTY: device code
*CRT	EQU	1		; CRT: device code
@LPT	EQU	2		; LPT: device (Line Printer)
@UL1	EQU	3		; UL1: device (User List #1)

** Default (initial) IOByte value
**			    LST:	 PUN:	      RDR:	 CON:
?DEF$DEV	EQU	(@LPT SHL 6)+(@PUN SHL 4)+(@RDR SHL 2)+(@CRT)
***************************************************
** DEFAULT LOGIN DRIVE (+ USER NUMBER)
***************************************************
@DSK	EQU	'A'-65		; Login Drive (A-P)
@USR	EQU	0		; User Number (0-15)

?DEF$DSK	EQU	(@USR SHL 4)+(@DSK)
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
		DS	1
?RST2		DS	8
?RST3		DS	8
?RST4		DS	8
?RST5		DS	8
?RST6		DS	8
?RST7		DS	8
		DS	28
?FCB		DS	36
?DMA		DS	128
?TPA		DS	0
***************************************************
** BASE BIOS CODE
***************************************************
	ORG	PATCH

VCOLD:	JMP	CBOOT
VWARM:	JMP	WBOOT
VCONS:	JMP	XCONS		; System I/O area defines these devices
VCNIN:	JMP	XCNIN
VCOUT:	JMP	XCOUT
VLIST:	JMP	XLIST
VPUN:	JMP	XPUN
VRDR:	JMP	XRDR
VHOME:	JMP	HOME
VDSK:	JMP	SELDSK
VTRK:	JMP	SETTRK
VSEC:	JMP	SETSEC
VDMA:	JMP	SETDMA
VREAD:	JMP	READS
VWRIT:	JMP	WRITES
VPRTS:	JMP	XPRTS
VSECT:	JMP	SECTRN

DSK$STAT DB	0		; disk status byte (last read/write call)
STEPR	 DB	0		; *2mS PER TRACK for Z17 only
SIDED	 DB	0,0,0		; SIDE CONTROL FOR EACH Z17 DRIVE (0-SINGLE,1=DOUBLE)
DENS	 DB	0,0,0,0 	; DENSITY/SIDE CONTROL FOR REMEX/Z47 drives

** Logical-Physical drive table
MIXER	DB	255,255,255,255,255,255,255,255
	DB	255,255,255,255,255,255,255,255

** Drive Base table (modules' drives,starting address
DRIVE$BASE:
	REPT	8
	 DB	0,0
	 DW	NOBASE
	ENDM

TIME$OUT:
	DB	(RET)		; PATCHED BY Z17 MODULE
	DW	BASE		; put address to generate bit in map

NEWBAS	DW	0
NEWDSK	DB	0
NEWTRK	DB	0
NEWSEC	DB	0
HRDTRK	DW	0
DMAA	DW	0
*** THE ABOVE CODE IS PATCHED BY EACH MODULE TO
*** INTEGRATE IT INTO THE SYSTEM.

NOBASE	DW	SLCERR
	DW	SECERR
	DW	SECERR

IO$FILE:
	DB	1,'CCP     SYS',0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
NXT$REC DB	0,0,0,0  

SGNON	DB	13,10,7
	DB	'00K Z89/Z90 CP/M v'
	DB	VERS/10+'0','.',VERS MOD 10 +'0',VSUB1,VSUB2
	DB	' (c) Magnolia Microsystems 1982$'

CBOOT:				; COLD BOOT ROUTINE
	LXI	H,?DEV$STAT
	MVI	M,?DEF$DEV	; default IOByte value
	INX	H
	MVI	M,?DEF$DSK	; default Login Drive + User Number

	MVI	A,?RAM$EN	; initialize Z17 ctrl port
	STA	?CTL$BYTE
	OUT	?DISK$CTL

	LXI	D,SGNON 	; display cold boot Signon Message
	MVI	C,?MSGOUT
	CALL	@BDOS
	LXI	H,@CCP		; setup CCP cold start address
	PUSH	H
BOOT$CCP:
	CALL	CBOOT1		; initialize page zero
	NOP
	NOP
	LXI	H,0
	MVI	E,31		; go to user number 31
	MVI	C,?USER
	CALL	@BDOS
	LXI	D,IO$FILE	; try to open "CCP.SYS"
	MVI	C,?OPENF
	CALL	@BDOS
	CPI	255
	JZ	NO$FILE 	; fatal error if file not found
	XRA	A
	STA	NXT$REC 	; set "next record" to 0 (first record)
	LXI	H,@CCP		; put starting DMA address in (HL)
IO$LOOP:
	SHLD	LOADA		; save current DMA address
	XCHG			; put into (DE)
	MVI	C,?SETDMA	; set DMA address through BDOS
	CALL	@BDOS
	LXI	D,IO$FILE	; read record from file
	MVI	C,?READF
	CALL	@BDOS
	LHLD	LOADA		; update DMA address
	LXI	D,128
	DAD	D
	ORA	A		; test for "read past end of file"
	JZ	IO$LOOP 	; loop if more records to read
** Fall into CBOOT1 (return is to CCP address previously pushed on stack)
CBOOT1: 			; initialize page zero
	DI			; no interuptions
	MVI	A,(JMP) 	; set JMP's at vector locations
	STA	?CPM		; warm boot
	STA	?BDOS		; BDOS entry
	STA	?RST1		; system clock interupt handler
	LXI	H,VWARM 	; setup warm boot entry address
	SHLD	?CPM+1
	LXI	H,@BDOS 	; BDOS entry address
	SHLD	?BDOS+1
	LXI	H,TIMER 	; system clock handler address
	SHLD	?RST1+1
	LXI	H,0		; reset clock to 0
	SHLD	?CLOCK
	MVI	A,00100010B	; set GPIO port image (enable RAM at 0 in "-FA")
	STA	?INT$BYTE
	OUT	?PORT
	EI			; allow clock to interupt
	LDA	?LOGIN$DSK	; set default drive/user number
	MOV	C,A		; in case the RET sends us to the CCP
	RET			; go where-ever

WBOOT:				; WARM BOOT ROUTINE
	LXI	SP,MMEND
	LXI	H,@CCP+3	; CCP warm start entry
	PUSH	H		; is return address for CBOOT1
	LHLD	PATCHE		; re-disable ESC sequence detection
	MVI	M,(RET) 	; fore-shortens CRT input routine
	LXI	H,@BDOS-6	; address to load BDOS into
	SHLD	DMAA		; set DMA address
	MVI	C,0		; select drive A: as warm boot drive
	CALL	SELDSK
	MOV	A,H
	ORA	L
	JZ	WBOOT		; loop infinite if drive A: is not installed
	LXI	D,+10
	DAD	D		; point to ADDRESS OF DPB
	MOV	E,M		; get DPB address
	INX	H
	MOV	H,M
	MOV	L,E		; (HL) = DPB
	MOV	E,M		; get number of sectors per track (less than 256)
	MVI	A,3		; start on sector 3 (1-n)
	STA	BSEC
	XRA	A
	STA	BTRK		; start on track 0
BOOT:
	PUSH	D		; save Sectors Per Track
	LDA	BTRK
	MOV	C,A
	MVI	B,0
	CALL	SETTRK		; set current track number
	LDA	BSEC
	MOV	C,A
	CALL	SETSEC		; set sector number
	CALL	READS		; read sector
	JNZ	WBOOT		; start over if error
	POP	D		; restore (E) = SPT
	LHLD	DMAA		; get next DMA address
	LXI	B,128
	DAD	B
	SHLD	DMAA
	MOV	A,H
	CPI	PATCH/256	; check if next read would overwrite BIOS
	JZ	BOOT$CCP	; stop loading if BDOS read in.
	LXI	H,BSEC		; increment sector number
	INR	M
	MOV	A,E
	CMP	M		; check for last sector on track
	JNC	BOOT		; loop if not at end of track
	MVI	M,1		; else reset sector to 1
	DCX	H
	INR	M		; step to next track
	JMP	BOOT		; read more sectors

BTRK	DB	0		; boot current track number
BSEC	DB	0		; boot current sector number

HOME:				; set track number to 0
	XRA	A
	STA	NEWTRK		; set single byte track value to 0
	STA	HRDTRK		; set (both bytes) 16 bit track number
	STA	HRDTRK+1	; to 0
	RET

SLCERR	POP	H		; select error (at module level)
	LXI	H,0
	RET

SECERR	XRA	A		; read/write error (at module level)
	INR	A
	RET

SELDSK:
	MOV	A,C
	CPI	16		; allow only 16 drives (0-15)
	JRNC	SELERR		; SIGNAL ERROR IF > P:
	LXI	H,MIXER 	; do logical-physical drive translation
	MVI	B,0
	DAD	B		; index table
	MOV	C,M
	MOV	A,C
	CPI	255		; check for invalid drive
	JRZ	SELERR
	MVI	D,8		; 8 entries in Drive Base table
	LXI	H,DRIVE$BASE	; search Drive Base table for module
SELPP	CMP	M		; that controls selected drive
	INX	H
	JRC	NXTDSK		; skip if drive not within limits
	CMP	M
	JRC	GOTDSK		; (drive is within limits)
NXTDSK	INX	H		; skip to next entry in table
	INX	H
	INX	H
	DCR	D		; count for last entry
	JRNZ	SELPP		; if not last, loop and search
SELERR: 			; table was searched and correct entry was not found
	LXI	H,0
	RET

GOTDSK: 			; get module address from table
	INX	H
	MOV	E,M
	INX	H
	MOV	H,M
	MOV	L,E
	SHLD	NEWBAS		; save module address
	LXI	D,RETRN 	; setup for return from module select routine
	PUSH	D
	MOV	A,C
	STA	NEWDSK		; save physical drive number
	PCHL			; jump to module select routine
RETRN:	MOV	L,C		; index DPH table to get indivivual DPH for drive
	MVI	H,0
	DAD	H
	DAD	H
	DAD	H
	DAD	H		; *16
	DAD	D		; ADD IN DPH table address
	LDA	NEWDSK
	MOV	C,A		; put physical drive in (C)
	RET			; return to BDOS (or user)

SETTRK: 			; set track from (BC)
	MOV	A,C
	STA	NEWTRK		; byte track value
	SBCD	HRDTRK		; word track value
	RET

SECTRN: 			; do logical physical sector translation
	MOV	L,C		; put sector (BC) into (HL) in case no
	MOV	H,B		; translation is required.
	INX	H		; CHANGE 0,1,2... INTO 1,2,3...
	MOV	A,D		; check for no translation (table address = 0)
	ORA	E
	RZ			; return with logical sector +1 if no translation
	XCHG			; else	put table address into (HL) for indexing
	DAD	B		; index table by logical sector number (BC)
	MOV	L,M		; get physical sector number into (HL)
	MVI	H,0
	RET			; return with physical sector number

SETSEC: 			; set sector from (BC)
	MOV	A,C
	DCR	A		; WE WANT 0,1,2,... NOT 1,2,3,...
	STA	NEWSEC
	RET

SETDMA: 			; set DMA address from (BC)
	SBCD	DMAA
	RET

READS:				; READ SECTOR ROUTINE
	LHLD	NEWBAS
	MVI	L,3		; use second jump vector at beginning of module
	PCHL

WRITES: 			; write sector, preserve (BC),(DE) for deblock info to module
	LHLD	NEWBAS
	MVI	L,6		; use third jump vector
	PCHL

TIMER:				; 2 millisecond clock handler
	SSPD	SSTK		; save stack
	LXI	SP,INT$STACK	; use internal interupt stack
	PUSH	PSW
	PUSH	H
	LDA	?INT$BYTE	; reset clock for next tic
	OUT	?PORT
	LHLD	?CLOCK
	INX	H		; increment tic counter
	SHLD	?CLOCK
	MOV	A,L		; check for 512 millisecond interval
	ORA	A
	CZ	TIME$OUT	; call timeout routine at 512 milliseconds
	POP	H
	POP	PSW
	LSPD	SSTK		; restore stack
	EI			; return to normal operation
	RET

LOADA	DW	0		; DMA address for loading CCP.SYS file

NO$FILE:			; error routine if CCP file not found
	LXI	D,MSG
	MVI	C,?MSGOUT
	CALL	@BDOS		; print error message
	DI			; lock processor until RESET
	HLT
MSG	DB	13,10,7,'NO CCP$'

	REPT	100H-($ AND 0FFH)
	DB	0
	ENDM

************************************************************
** Define USER AREA entry points:
************************************************************
XCONS	DS	3		; CONST
XCNIN	DS	3		; CONIN
XCOUT	DS	3		; CONOUT
XLIST	DS	3		; LIST
XPUN	DS	3		; PUNCH
XRDR	DS	3		; READER
XPRTS	DS	3		; PRTST

	DS	200H-($ AND 0FFH)-2	; size of USER AREA is 512 bytes
PATCHE	DS	2		; ESC sequence patch address
***************************************************

*********************************************************
** STACKS AND DIRECTORY BUFFER
**********************************************************
	ORG	COMBUF
; BOOT STACK:
	DS	20		; stack for warm-cold boot
MMEND	DS	0
; INTERUPT STACK:
	DS	64		; stack for interupt(s)
INT$STACK:	DS	0
SSTK	DS	2		; storage for user stack during interupt
DIRBUF	DS	128		; directory (1 sector) buffer for BDOS
**********************************************************
	END

