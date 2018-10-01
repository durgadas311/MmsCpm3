VERS EQU '4 ' ; February 15, 1983  13:51  klf  "MODE.ASM"

	MACLIB	Z80

; The MODE utility installs new DPB's and mode bytes in drivers specified
; on the command line. The mode bytes are described below:
;
;  7  6  5  4  3  2  1	0     7  6  5  4  3  2	1  0	 7  6  5  4  3	2  1  0
;  -  - DS CNF DSA   SSZ      E DD DT0 TPI   8" STPR        ORIGIN       SKEW
;		    
;
; DS	Double Sided (1=DS)
; CNF	Configure from sector 0
; DSA	Double sided Algorithm 00=MMS, 01=Zenith, 10=XO/GNAT, 11=??
; SSZ	Sector Size 00=128, 01=256, 10=512, 11=1024
;
; TPI	Tracks Per Inch 00=48, 01=96, 10=48in96, 11=??
; 8"    8" flag (0=5.25")
; STPR	Step Rate (as per WD179x)
; DT0	Density of Track 0 (1=MFM)
; DD	Density of tracks 1-n (1=MFM)
; E	Enable modes (0=enable)
;
; SKEW	Skew table selector  000 = sequential
;			     001 = use table 1
;			     010 = use table 2
;			     011 = use table 3
;			     100 = use user defined table
; ORIGIN  format origin    00000 = MMS double density format
;			   00001 = Z17 format
;			   00010 = M47 format
;			   00011 = Z37 format
;			   00100 = Z47 format
;			   00101 = Z67 format
;			   00110 = Z37 extended format
;			   00111 = Z47 extended format
;			   01000 = Columbia
;			   01001 = Robin
;			   01010 = TeleVideo
;
;     byte 4,5,6 are mode masks for bytes 1,2,3
;
;     The 'origin' field of the mode byte is used to specify a set of
;     parameters specific to a particular format. These parameters include
;     the method of numbering tracks, the skew factors, if track zero is
;     single or double density, and if sector zero contains information on
;     the setup of the disk.
;

BASE	EQU	100H		; PROGRAM STARTING ADDRESS
CPM	EQU	0		; JUMP TO BIOS
BDOS	EQU	5		; STANDARD CP/M ENTRY
FCB	EQU	5CH		; INPUT FILE CONTROL BLOCK
DMA	EQU	80H		; INPUT DMA ADDRESS
TAB	EQU	9
CR	EQU	0DH		; CARRIAGE RETURN
LF	EQU	0AH		; LINE FEED
ESC	EQU	1BH		; ESCAPE
MIXER	EQU	03CH		; OFFSET IN BIOS TO MIXER TABLE
DBASE	EQU	MIXER+16	; DRIVE BASE TABLE
NUBYT	EQU	3		; 3 MODE BYTES PER DRIVE
;
;	SYSTEM (BDOS) CALLS
;
CONIN	EQU	1		; CONSOLE INPUT
CONIO	EQU	6		; DIRECT CONSOLE I/O
TYPE	EQU	9		; CONSOLE STRING PRINT
RDCON	EQU	10		; READ CONSOLE BUFFER
GETCON	EQU	11		; GET CONSOLE STATUS
DSKRES	EQU	13		; DISK RESET
LOGIN	EQU	24		; RETURN LOGIN VECTOR
CURDSK	EQU	25		; GET CURRENT DISK
SETDMA	EQU	26		; SET DMA ADDRESS
RESDRV	EQU	37		; RESET DRIVE FUNCTION


	ORG	BASE		; base of TPA

	JMP	START

	DB	'082082DRM'
SIGNON: DB	LF,'MODE v2.24'
	DW	VERS
	DB	' (c) 1982,1983 Magnolia Microsystems',CR,LF,LF,'$'
START:
	SSPD	OLDSP		; save old stack pointer
	LXI	SP,STACK	; for a fast reboot
	LXI	D,SIGNON	; signon message
	MVI	C,TYPE		; string output function
	CALL	BDOS
	CALL	SPCHK		; scan command line for first
	JNZ	HADARG		; non space character.
	LXI	D,HELP		; help text
	MVI	C,TYPE
	CALL	BDOS
	JMP	DONE		; this is all, let's leave
HADARG: CALL	INCMD		; evaluate the command line
	JNZ	ENDERR		; bad command line if non-zero
	LDA	NEWARG		; get the data flag
	ORA	A		; zero if data was entered
	JNZ	OUTMOD		; if none, output the mode data
	CALL	GETMOD		; get the mode byte
	CPI	0FFH		; check for error
	JZ	NODRV
	CPI	0FEH		; check for wrong release
	JZ	WRONG
	INX	H		; point to second mode byte
	MOV	A,M		; which contains the usage flag
	DCX	H		; restore pointer for UPMODE
	ANI	80H		; check usage
	JNZ	FIXED		; cannot change if non-zero
	CALL	UPMODE		; update the mode byte
	CALL	RESET		; reset the drive
OUTMOD: CALL	GETMOD
	CPI	0FFH		; check for drive not available
	JZ	NODRV
	CPI	0FEH		; check for wrong release
	JZ	WRONG
	STA	DSKNM
	INX	H		; point to second mode byte
	MOV	A,M		; which contains the usage flag
	DCX	H		; restore pointer for MPRINT
	ANI	80H		; check usage
	JNZ	FIXED		; cannot change if non-zero
	CALL	MPRINT		; and print the new mode values
	JMP	DONE		; and we're done
SPCHK:	LXI	H,DMA		; number of characters input
	MOV	A,M
	ORA	A
	RZ			; no characters available
MORSP:	INX	H
	MOV	A,M		; get a character
	CPI	' '		; and check for spaces
	JZ	MORSP
	SHLD	CMDPTR
	ORA	A
	RET			; zero if no arguments


;	output the mode data to the CRT
;	A pointer to the mode data is passed in the HL
;
MPRINT: 
	LDA	DSKNM		; get physical drive number
	LXI	B,0		; tens counter in C and ones in B
MORTEN: INR	C
	SUI	10
	JZ	GOTNUM
	JP	MORTEN
	DCR	C
	ADI	10
	MOV	B,A
GOTNUM: LXI	H,3030H 	; numeric offset to ASCII
	DAD	B
	MOV	A,L		; tens digit
	CPI	'0'		; check for zero
	JNZ	NOZE
	MVI	A,' '		; if so, replace with a space
NOZE:	MOV	L,A
	SHLD	DSKNM
	LXI	D,TTLE1
	LDA	NEWARG		; was configuration changed
	ORA	A		; zero if not changed
	JZ	TYPNC
	LXI	D,TTLE0
TYPNC:	MVI	C,TYPE
	CALL	BDOS
	LXI	D,DRSTR 	; drive letter and number message
	MVI	C,TYPE
	CALL	BDOS
	LIXD	MODPTR		; pointer to system mode byte
	BITX	7,+1		; check validity
	JNZ	DONE		; non-zero if hard disk
	BITX	2,+1		; size, 0=5" and 1=8"
	LXI	D,INCH5
	JZ	PRINCH
	LXI	D,INCH8
PRINCH: MVI	C,TYPE
	CALL	BDOS
	LXI	D,CTLMSG
	MVI	C,TYPE
	CALL	BDOS
	CALL	GETTXT		; get text string pointer in DE
	MVI	C,TYPE
	CALL	BDOS
	LXI	D,RDMSG
	MVI	C,TYPE
	CALL	BDOS
	BITX	6,+1
	JZ	SD		; single density if zero
	LXI	D,DDMSG 	; double density drive message
	JMP	DD
SD:	LXI	D,SDMSG 	; single density drive message
DD:	MVI	C,TYPE
	CALL	BDOS
	LXI	D,SIDMSG
	MVI	C,TYPE
	CALL	BDOS
	BITX	5,+0		; check the side bit
	JZ	SS		; single sided if zero
	LXI	D,DSMSG 	; double sided drive message
	JMP	DDS
SS:	LXI	D,SSMSG 	; single sided drive message
DDS:	MVI	C,TYPE
	CALL	BDOS
	LXI	D,TPIMSG
	MVI	C,TYPE
	CALL	BDOS
	LDX	A,+1		; get the first byte
	ANI	00011000B	; mask out track density
	JZ	T48		; 48 tpi if zero
	CPI	00001000B	; bit 1 set if 96 tpi
	JZ	T96
	LXI	D,HALFTK	; half track message
	JMP	HTRK
T48:	LXI	D,T48MSG	; 48 tpi message
	JMP	HTRK
T96:	LXI	D,T96MSG	; 96 tpi message
HTRK:	MVI	C,TYPE
	CALL	BDOS
	LDX	A,+1		; and get it
	ANI	00000111B	; three lsb's for step rate
	LXI	H,STRTBL	; step rate table
	ADD	A		; two bytes per entry
	MOV	E,A
	MVI	D,0		; 16 bit value for offset
	DAD	D
	MOV	E,M		; first byte of step rate
	INX	H
	MOV	D,M		; and the second
	XCHG
	SHLD	STRATE		; save text in message
	LXI	D,STRMSG	; step rate message
	MVI	C,TYPE
	CALL	BDOS
	LXI	D,STRATE
	LDA	STRATE
	CPI	' '		; skip a character if a space
	JNZ	NSPC
	INX	D
NSPC:	MVI	C,TYPE
	CALL	BDOS
	LXI	D,FMTTYP
	MVI	C,TYPE
	CALL	BDOS
	LDX	A,+2		; get the first byte
	ANI	11111000B	; mask out drive origin
	RRC
	RRC			; in 5 lsb's (times 2)
	CPI	NUMFMT*2
	LXI	D,DRMS0 	; Is it an unknown format ?
	JNC	GOTFMT
	LXI	H,MSTBL 	; beginning of table
	MOV	C,A
	MVI	B,0
	DAD	B		; get table entry address
	MOV	E,M
	INX	H
	MOV	D,M		; text pointer in DE
GOTFMT: MVI	C,TYPE
	CALL	BDOS
	RET


;	this function puts the mode byte at MINFO and
;	returns a pointer to it in the HL. It also places
;	pointers to the actual mode byte and mask in
;	MODPTR and MSKPTR and the drive number in DRVNUM
;
GETMOD: XRA	A
	STA	FLGZ37		; clear Z37 driver flag
	LDA	NDRIVE		; get logical drive number
	LHLD	CPM+1		; address of BIOS
	LXI	D,MIXER-3	; offset to mixer table
	DAD	D
	MOV	E,A		; use logical drive number as offset
	MVI	D,0		; into logical/physical table
	DAD	D
	MOV	A,M		; get physical drive number
	STA	DRVNUM		; and save it away
	CPI	0FFH
	RZ			; return if no drive installed
	LXI	B,DBASE-3	; address of drive base table
	LHLD	CPM+1
	DAD	B
	MVI	B,8		; eight entrys only
NXENT:	MOV	C,M
	INX	H		; point to upper limit
	CMP	C		; see if in range
	JC	NOTHIS
	MOV	C,M
	CMP	C
	JNC	NOTHIS
	DCX	H		; point to first drive
	MOV	C,M		; and get it again
	SUB	C		; get drive number offset
	MOV	B,A		; number of times to add 16
	INX	H
	INX	H		; point to address
	MOV	E,M		; of driver
	INX	H
	MOV	D,M		; and get it in DE
;
;	CHECK IF DRIVER IS RECENT RELEASE (HAS MODE BYTES)
;	DO THIS BY CHECKING FOR MULTIPLE STRINGS
;
	PUSH	D
	PUSH	B
	MVI	A,1		; more than one string in this release
	CALL	GETSTR
	POP	B
	POP	D		; clean up the stack
	ORA	A		; and see if there are 2 strings
	JZ	REL223		; correct release level
NOT223: MVI	A,0FEH		; this error code says the
	RET			; release level is incorrect
REL223: MVI	A,30		; a ridiculous string number
	CALL	GETSTR		; DE points to null (we hope)
	XCHG			; make it HL
	DCX	H		; point to terminator
	MOV	A,M		; and verify it is a '$'
	INX	H		; point to first DPH if ok
	CPI	'$'
	JNZ	NOT223		; additional check
	MOV	A,B
	ORA	A		; set zero flag
	JZ	GOTADR		; first drive ???
	LXI	D,16		; DPH is 16 bytes long
NXAD:	DAD	D
	DJNZ	NXAD
	JMP	GOTADR		; got address of DPH

NOTHIS: INX	H		; point to next entry
	INX	H
	INX	H
	DJNZ	NXENT
	JMP	SYSERR

GOTADR: LXI	D,10		; offset to DPB pointer
	DAD	D
	MOV	E,M		; get address of DPB
	INX	H
	MOV	D,M
	LXI	H,15		; offset in DPB to mode byte
	DAD	D
	SHLD	MODPTR		; save the mode byte pointer
	XCHG
	LXI	H,3		; +3 to mask
	DAD	D
	SHLD	MSKPTR		; save the mode byte mask pointer
	LXI	H,MINFO 	; internal storage buffer
	XCHG			; from HL to DE for LDIR
	LXI	B,NUBYT 	; 3 bytes
	LDIR			; to store the mode byte internally
	LXI	H,MINFO 	; restore pointer
	LDA	DRVNUM
	RET

GETLOG: PUSH	H
	PUSH	D
	PUSH	B
	LHLD	CPM+1		; address of BIOS
	LXI	D,MIXER-3	; offset to mixer table
	DAD	D
	LXI	B,16
	CCIR			; check for physical drive
	JZ	GLOG		; search was successful
	MVI	B,16		; force 0 drive number
GLOG:	MVI	A,16
	SUB	C		; convert to 1-16
	POP	B
	POP	D
	POP	H
	RET
;
;	This subroutine searches for the driver text string specified
;	by the accumulator. Strings are numbered 0-N.
;	on entry:
;		DE = pointer to driver
;		A  = desired string
;	On exit:
;		DE = pointer to desired string or first character
;			past the last string (null in later releases)
;		A  = error code 0 = found, 0FFH = not found
;
GETSTR: PUSH	H		; save registers
	PUSH	B
	PUSH	PSW		; save requested field
	LXI	H,9		; point past initial jumps
	DAD	D		; to start of strings
GETAGN: MOV	A,M		; look for a character greater than 
	CPI	' '		; or equal to a space
	INX	H
	JC	GETAGN		; got one if carry is not set
	DCX	H		; point to ASCII character
	SHLD	STRADR		; initial text pointer
CANTHR: INX	H		; now let's search for the terminator
	MOV	A,M		; get a character
	CPI	'$'		; a $ is what we want
	JZ	GOTDOL
	ORA	A		; and a NULL is acceptable
	JZ	CANTHR
	CPI	' '		; now check for invalid characters
	JC	SETERR		; non-ASCII character
	JMP	CANTHR
GOTDOL: XRA	A
	STA	GETERR		; clear error flag
	STA	FLDNUM		; set field number 0
	LHLD	STRADR
NXTFLD: LDA	GETERR		; check error flag
	ORA	A
	JNZ	GETXIT		; error if non zero
	SHLD	STRADR		; start of search string
	MVI	B,100		; search 100 characters
GETCHR: MOV	A,M
	INX	H		; point past separator
	CPI	'$'		; field terminator
	JZ	CHKEND
	ORA	A
	JZ	CHKEND		; $ or a NULL
	CPI	' '
	JC	SETERR
	DJNZ	GETCHR
SETERR: MVI	A,0FFH
	STA	GETERR		; set error flag
	JMP	NXTFLD
CHKEND: LDA	FLDNUM
	MOV	B,A
	POP	PSW		; get requested field
	PUSH	PSW
	CMP	B		; is this one correct
	JZ	GETXIT		; found if zero
	INR	B		; increment field number
	MOV	A,B
	STA	FLDNUM
	DCX	H		; now see if $
	MOV	A,M
	INX	H
	ORA	A
	JZ	NXTFLD
	MVI	A,0FFH		; found terminator of $
	STA	GETERR		; without finding field
	SHLD	STRADR		; also update pointer past terminator
GETXIT: LDED	STRADR		; string address
	POP	PSW		; clean up stack
	LDA	GETERR		; error flag
	POP	B		; restore registers
	POP	H
	RET


;	THIS SUBROUTINE SEARCHES FOR A DPB ASSOCIATED WITH A
;	SPECIFIED MODE BYTE. ENTRY IS:
;	HL = POINTER TO MODE BYTE


;	THIS SUBROUTINE RESETS THE DRIVE WITH THE NEW MODE BYTE
;
RESET:	LDA	NDRIVE		; get drive number
	INR	A		; start with 1-16
	LXI	D,1		; 1 for drive A:
LRST:	DCR	A		; decrement drive number
	JZ	REST		; if zero, then DE is setup
	SLAR	E		; shift left with zero fill
	RALR	D		; shift left with carry
	JMP	LRST		; keep shifting
REST:	MVI	C,RESDRV	; BDOS reset drive function
	CALL	BDOS
	RET
;
;	THIS FUNCTION RETURNS A TEXT STRING TO BE OUTPUT
;
GETTXT: 	;search a table for the string discribing the controller
	LXI	H,TXTTBL	;by the physical drive number.
	MVI	B,NUMTXT
	LDA	DRVNUM
GT0:	CMP	M
	INX	H
	JC	GT1
	CMP	M
	JNC	GT1
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	RET
GT1:	INX	H
	INX	H
	INX	H
	DCR	B
	JNZ	GT0
	LXI	D,DRMS0
	RET

;	specified drive does not exist
;
NODRV:	LXI	D,NODRMS	; drive not sysgened message
	JMP	ERXIT
;
;	FDC driver is the wrong release level
;
WRONG:	LXI	D,WRGMSG
	JMP	ERXIT
;
;	drive is in logical/physical table but has not been
;	linked in. system error.
;
SYSERR: LXI	D,SERMSG	; drive not LINKed message
	JMP	ERXIT
;
;	driver is not FDC or Z37
;
FIXED:	LXI	D,DIFFER	; do not use flag is set
	JMP	ERXIT
;
;	this is the error for changing an invalid item
;
NOCHG:	LXI	D,CHGMSG	; cannot change a parameter message
	MVI	C,TYPE
	CALL	BDOS
	LXI	D,HALFHL
	JMP	ERXIT
;
;	Bad command line error
;
ENDERR: LXI	D,BADMSG	; bad command line message

ERXIT:	MVI	C,TYPE		; error exit
	CALL	BDOS

DONE:	LSPD	OLDSP		; normal exit
	RET			; restore original stack pointer


;	data storage
;
HELP:	DB	'The MODE utility is called in one of the following ways:'
	DB	CR,LF,LF,TAB,'MODE',CR,LF
	DB	'Outputs HELP information',CR,LF,LF
	DB	TAB,'MODE d:',CR,LF
	DB	'Displays the present drive status to the user',CR,LF,LF
HALFHL: DB	TAB,'MODE d:arg1,arg2,arg3',CR,LF
	DB	'Updates the present status and displays it. Valid'
	DB	' arguments are:',CR,LF,LF
	DB	TAB,'DS or SS = double or single sided',CR,LF
	DB	TAB,'DT, ST or HT = double (96 tpi), single (48 tpi),'
	DB	' or half track',CR,LF
	DB	TAB,'  half track is 48 tpi media in a 96 tpi drive.',CR,LF
	DB	TAB,'DD or SD = double or single density',CR,LF
	DB	TAB,'S6, S30, etc. = step rate in milliseconds',CR,LF
	DB	TAB,'MMS, Z37, Z37X etc. (media formats); the X implies'
	DB	' extended format.',CR,LF,LF,'$'

DIFFER: DB	'Drive '
DIFD:	DB	'A: has a fixed configuration which cannot '
	DB	'be determined by MODE.',CR,LF,'$'

CTLMSG: DB	'       Controller - $'
DRMS0:	DB	'unknown',CR,LF,'$'

INCH5:	DB	'5.25 inch floppy',CR,LF,'$'
INCH8:	DB	'8 inch floppy',CR,LF,'$'

SIDMSG: DB	'            Sides - $'
SSMSG:	DB	'1',CR,LF,'$'
DSMSG:	DB	'2',CR,LF,'$'

RDMSG:	DB	'Recording Density - $'
SDMSG:	DB	'Single',CR,LF,'$'
DDMSG:	DB	'Double',CR,LF,'$'

TPIMSG: DB	'  Tracks per Inch - $'
T48MSG: DB	'48',CR,LF,'$'
T96MSG: DB	'96',CR,LF,'$'
HALFTK: DB	'48 tpi media in 96 tpi drive (R/O)',CR,LF,'$'

FMTTYP: DB	'      Format Type - $'

IMGMSG: DB	'      IMAGINARY drive ('
DRLET:	DB	'A:)',CR,LF,'$'
STRMSG: DB	'        Step Rate - $'
STRATE: DB	'00 milliseconds',CR,LF,'$'
DRSTR:	DB	'            Drive - '
DSKLT:	DB	'A: ('
DSKNM:	DB	'  ) $'
TTLE0:	DB	'PRESENT Configuration is:',CR,LF,'$'
TTLE1:	DB	'NEW Configuration is:',CR,LF,'$'

BADMSG: DB	'Invalid command line or command line arguments.',CR,LF,'$'
CHGMSG: DB	'The requested format is invalid for the specified drive.'
	DB	CR,LF,'The complete configuration must be supplied',LF
CRLF:	DB	CR,LF,'$'
NODRMS: DB	'A: does not exist.',CR,LF,'$'
UNSPMS: DB	'Unspecified imaginary drive -ERROR IN SYSTEM-',CR,LF,'$'
WRGMSG: DB	'The driver module for '
WRGD:	DB	'A: is incompatible with MODE.',CR,LF,'$'
CHKSTR: DB	'FDC223$'
SERMSG: DB	'Drive is specified but not linked - ERROR IN SYSTEM-'
	DB	CR,LF,'$'

STRTBL: DB	' 6122030 3 61015'	; possible step rates, 2 bytes each
STEPTB: DB	7,13,21,31,4,7,11,16

MINFO:	DB	0,0,0
MODPTR: DW	0
MSKPTR: DW	0
CMDPTR: DW	0
DRVNUM: DB	0
FLGZ37: DB	0
STRADR: DW	0
GETERR: DB	0
FLDNUM: DB	0

NEWARG: DB	0
NDRIVE: DB	0	; 0 to 15
CNFIG:	DB	0	; MMS=0, MMSD=1,Z17=2 (ALL + '0')
TRACK:	DB	0	; D or S or H
SIDE:	DB	0	; D or S
DENSITY: DB	0	; D or S
STEPRT: DB	0	; binary number

OLDSP:	DW	0
	DS	32
STACK:	DS	0
;
;

CHAR:	MOV	A,M
	ORA	A
	RZ	;END OF BUFFER
	INX	H
	CPI	'a'
	RC
	CPI	'z'+1
	CMC
	RC
	SUI	'a'-'A'
	STC
	RET

;	PARES input command line
;
INCMD:	MVI	A,1
	STA	NEWARG		; initialize argument flag to none
	LHLD	CMDPTR		; pointer to first non-blank character
	CALL	CHAR		; get it
	JNC	BADCMD
	CPI	'A'		; check range of A-P
	JC	BADCMD
	CPI	'P'+1
	JNC	BADCMD
	STA	NODRMS		; setup error messages etc.
	STA	DSKLT
	STA	DIFD
	STA	WRGD
	SUI	'A'		; make a drive number (0-15)
	MOV	B,A		; and save in B
	CALL	CHAR		; get a character
	JNC	BADCMD
	CPI	':'		; which must be a ':'
	JNZ	BADCMD
	MOV	A,B		; get drive
	STA	NDRIVE		; save for later
NXARG:	CALL	CHAR
	RNC
	CPI	' '
	JZ	NXARG
	DCX	H
NXOPT:	LXI	D,CONTXT	;search table for nmemonic
	MVI	C,0
CONFIG: PUSH	H
	LDAX	D
	CPI	'$'
	JZ	NOTCNF	;NMEMONIC NOT FOUND
FIG0:	CMP	M
	JNZ	FIG1
	INX	H
	INX	D
	LDAX	D
	CPI	'$'
	JNZ	FIG0
	INX	D
	MOV	A,M
	ORA	A
	JZ	FIG2
	CPI	','
	JZ	FIG2
	CPI	' '
	JNZ	FIG3
FIG2:	DCX	D
	DCX	D
	LDAX	D	;WILL BE "X" FOR EXTENDED DENSITY FORMATS
	CPI	'X'
	JNZ	FIG4
	MVI	A,'D'
	STA	DENSITY ;FORCE DOUBLE DENSITY IF EXTENDED DENSITY
FIG4:	POP	D	;DISCARD OLD BUFFER POINTER
	LDA	CNFIG
	ORA	A	;IS THIS THE SECOND ENTRY OF THIS TYPE?
	JNZ	BADCMD	;ERROR IF IT IS.
	MOV	A,C
	ADI	'0'
	STA	CNFIG
	JMP	MORE

FIG1:	LDAX	D
	INX	D
	CPI	'$'
	JNZ	FIG1
FIG3:	POP	H
	INR	C
	JMP	CONFIG

NOTCNF: POP	H	;WE KNOW THERE MUST BE AT LEAST ONE CHARACTER
	CALL	CHAR		; get a character for the loop
	CPI	'D'		; check for 'D' command
	JZ	DPROC
	CPI	'S'
	JZ	STEP		;STEPRATE OR "SINGLE XXX"
	CPI	'H'		; half track option maybe
	JNZ	BADCMD
HPROC:	MOV	B,A
	CALL	CHAR
	JNC	BADCMD
	CPI	'T'
	JNZ	BADCMD
TRK:	MOV	A,B
	STA	TRACK
	JMP	MORE

SPROC:	MVI	A,'S'
DPROC:	MOV	B,A		; save SINGLE or DOUBLE
	CALL	CHAR		; get the character
	JNC	BADCMD
	CPI	'T'
	JZ	TRK
	CPI	'D'
	JZ	DENS
	CPI	'S'
	JNZ	BADCMD
	MOV	A,B		; get the SIDE argument
	STA	SIDE
	JMP	MORE

DENS:	MOV	A,B		; get the DENSITY argument
	STA	DENSITY
	JMP	MORE

STEP:	MOV	A,M		; get next argument
	CPI	'0'		; must be numeric
	JC	BADCMD
	CPI	'9'+1
	JNC	SPROC
	CALL	CHAR
	SUI	'0'		; make it numeric
	MOV	B,A		; and save it
	MOV	A,M		; it must be a number, a comma, or null
	ORA	A
	JZ	SOK
	CPI	','
	JZ	SOK
	CPI	' '
	JZ	SOK
	CPI	'0'
	JC	BADCMD
	CPI	'9'+1
	JNC	BADCMD
	CALL	CHAR
	SUI	'0'		; numeric, make it binary
	MOV	C,A		; and save it
	MOV	A,B		; get first number
	ADD	A
	ADD	A
	ADD	B
	ADD	A		; TIMES 10
	ADD	C		; plus second number
	MOV	B,A		; expected in B
SOK:	MOV	A,B		; get step rate
	STA	STEPRT		; and save it
MORE:	CALL	CHAR		; get next character
	JNC	FINISH
	CPI	','		; continue if a comma
	JZ	NXOPT0
	CPI	' '		; or a space
	JZ	MORE
	DCX	H
	JMP	NXOPT
NXOPT0: CALL	CHAR
	JNC	FINISH
	CPI	' '
	JZ	NXOPT0
	DCX	H
	JMP	NXOPT

FINISH: XRA	A
	STA	NEWARG
	RET

BADCMD: MVI	A,1
	ORA	A		; set the zero flag
	RET

;	update the present mode value
;
UPMODE: LDA	CNFIG		; see if configuration was specified
	ORA	A
	JZ	BIT1
	INX	H
	INX	H		; in byte 3
	PUSH	PSW		; save the argument
	MOV	A,M		; get byte 1
	ANI	00000111B	; clear bits 3-7
	MOV	M,A		; and restore it
	POP	PSW		; restore the argument
	SUI	'0'		; make 0,1,2 etc.
	RLC
	RLC
	RLC			; shift to desired bit position
	ORA	M		; set the bits
	MOV	M,A		; and update the byte
	DCX	H
	DCX	H		; restore pointer
BIT1:	LDA	SIDE		; see if side was specified
	ORA	A
	JZ	BIT3
	RES	5,M		; clear the side bit
	CMA
	ANI	1		; mask the lsb
	RRC
	RRC
	RRC			; to bit 5
	ORA	M		; into the mode byte
	MOV	M,A		; and update the byte
BIT3:	LDA	DENSITY 	; see if density was specified
	ORA	A
	JZ	BIT4
	INX	H		; density is in byte 2
	RES	6,M		; clear density bit
	CMA
	ANI	1
	RRC
	RRC			; to bit 6
	ORA	M		; mask the bit
	MOV	M,A		; and save it in memory
	DCX	H		; point to byte 1 again
BIT4:	LDA	TRACK
	ORA	A
	JZ	BIT5
	INX	H		; byte 2
	RES	3,M
	RES	4,M
	ANI	0CH		; two good bits
	RAL			; into the correct spot
	ORA	M		; mask the bit
	MOV	M,A		; and save it in memory
	DCX	H		; restore pointer
BIT5:	LDA	STEPRT		; get the requested step rate
	ORA	A		; see if user specified one
	JZ	BIT6
	INX	H
	PUSH	H
	BIT	2,M		; size, 5.25 or 8
	LXI	H,STEPTB
	LXI	D,4		; table is 4 bytes long
	JZ	FIVE
	DAD	D		; add offset
FIVE:	MVI	B,0		; initial step rate
NXRT:	CMP	M		; compare request with table
	JC	GSRT		; memory is greater, this is it
	INX	H
	INR	B
	DCR	E
	JNZ	NXRT
	MVI	B,3		; in case of overflow
GSRT:	MOV	A,B		; step rate mask
	POP	H		; point to mode byte
	RES	0,M
	RES	1,M		; clear bits
	ORA	M		; and update mode value
	MOV	M,A
	DCX	H		; restore pointer
BIT6:	CALL	GETDPB		; and see if a DPB exists
	ORA	A
	JNZ	NOCHG		; error if non-zero
	PUSH	D
	PUSH	H
;
;	update mode bytes from DPB table
;
	LXIX	XSMASK		;POINT TO EXCESS MODES MASKS
	MVI	C,3		;3 BYTES TO UPDATE
XSM0:	LDX	A,+0		; excess bit mask
	CMA
	ANA	M		; clear bits
	MOV	B,A
	LDAX	D
	ANAX	+0
	ORA	B		; and set new ones
	MOV	M,A
	INX	H
	INX	D		; now next byte
	INXIX
	DCR	C
	JNZ	XSM0
	DCX	H
	DCX	H
	DCX	H		; point to mode byte
	MVI	A,NUBYT 	; number of bytes to check
	LBCD	MODPTR		; actual mode byte pointer
	LDED	MSKPTR		; mode byte mask pointer
ANOTHR: PUSH	PSW		; save the counter
	LDAX	B		; get old mode byte
	XRA	M		; set bit for values changed
	XCHG
	ANA	M		; check for changed bytes
	XCHG
	JNZ	NOCHG		; error if non zero
	INX	D
	INX	B
	INX	H		; point to the next byte
	POP	PSW		; get counter
	DCR	A		; and decrement it
	JNZ	ANOTHR
	POP	H		; restore pointer
	MVI	B,NUBYT
	LDED	MODPTR		; actual mode byte pointer
UPONE:	MOV	A,M		; if all's well, let's actually update
	STAX	D		; the mode byte
	INX	H
	INX	D
	DJNZ	UPONE
	LHLD	MODPTR		; pointer to mode byte
	LXI	D,-15		; offset to DPB
	DAD	D
	XCHG			; in DE
	POP	H		; pointer to new DPB
	LXI	B,3		; skip excess bit leader
	DAD	B
	LXI	B,15		; 15 bytes long
	LDIR			; install new DPB
	RET			; and return

;-------------------------------------------------------------
;		EXIT IS:
;	HL = POINTER TO MODE BYTE
;	DE = POINTER TO DPB
;	A  = ERROR CODE (0 = OK, 1 = NOT FOUND)
;
GETDPB: LXIX	SRMASK	;POINT TO SEARCH BITS MASKS
	PUSH	H		; save mode byte pointer
	MOV	A,M		; get first mode byte
	ANAX	+0		; mask FIRST BYTE
	MOV	E,A    
	INX	H		; and point to the second
	MOV	A,M
	ANAX	+1		; mask SECOND BYTE
	MOV	D,A
	INX	H
	MOV	A,M
	ANAX	+2		; configuration bits
	MOV	C,A		; C,D,E = MASKED MODES TO LOOK FOR
	LXI	H,PTRTBL	; table lookup
NXDPB:	MOV	A,M		; get first byte
	INX	H
	ANAX	+0		;mask it also
	CMP	E		;compare to target mode
	JNZ	NXD0
	MOV	A,M		; and the second
	INX	H
	ANAX	+1		;mask it
	CMP	D		;compare it
	JNZ	NXD1
	MOV	A,M		;the third byte
	ANAX	+2		;mask it
	CMP	C		;compare it
	JNZ	NXD1		; zero if we have a match
	DCX	H  
	DCX	H
	XCHG			; and get the DPB address in DE
	POP	H		; restore the mode byte pointer
	XRA	A		; and clear the accumulator
	RET			; as this is the successful return

NXD0:	INX	H
NXD1:	INX	H
	PUSH	B
	LXI	B,15		; point to the next entry
	DAD	B
	POP	B
	MOV	A,M
	CPI	11111111B
	JNZ	NXDPB		;loop if more entries in table
	POP	H		; restore mode byte pointer
	MVI	A,1		; and set the accumulator to non-zero
	RET			; as this is the error return

;******* The following should be the only area changed when new ********
;******* formats/controllers are added. 			********

;Table for selecting messages by physical drive number.
;This table is similar in operation to the DBASE table in the BIOS.
TXTTBL: DB	0,0+3	;Z17 controller, drives 0-2
	DW	DRMS3
	DB	5,5+4	;REMEX interfaces, drives 5-8
	DW	DRMS4
	DB	29,29+8 ;77316 controller, drives 29-36
	DW	DRMS1
	DB	46,46+4 ;Z37 controller, drives 46-49
	DW	DRMS2
	DB	50,50+9 ;Z67 controller, drives 50-58
	DW	DRMS5
NUMTXT	EQU	($-TXTTBL)/4

;These messages are selected according to the physical drive number.
DRMS1:	DB	'MMS 77316 Double Density',CR,LF,'$'
DRMS2:	DB	'Zenith Z89-37',CR,LF,'$'
DRMS3:	DB	'Zenith Z17',CR,LF,'$'
DRMS4:	DB	'MMS 77314/Zenith Z89-47',CR,LF,'$'
DRMS5:	DB	'MMS 77320/Zenith Z89-67',CR,LF,'$'

;Table for decoding user's string (format origin entry)
CONTXT: DB	'MMS$'		; 0  ; configuration input text table
	DB	'Z17$'		; 1
	DB	'M47$'		; 2
	DB	'Z37$'		; 3
	DB	'Z47$'		; 4
	DB	'Z67$'		; 5
	DB	'Z37X$' 	; 6
	DB	'Z47X$' 	; 7
	DB	'$'	;END OF TABLE

;Table for selecting messages by format origin.
MSTBL:	DW	MMSDMS	; 0	; configuration output text table
	DW	T0MSG	; 1
	DW	T1MSG	; 2
	DW	T2MSG	; 3
	DW	T3MSG	; 4
	DW	T4MSG	; 5
	DW	T2XMSG	; 6
	DW	T3XMSG	; 7
	DW	T5MSG	; 8
	DW	T6MSG	; 9
	DW	T7MSG	; 10

NUMFMT	EQU	($-MSTBL)/2

;These messages are selected according to the format origin field.
MMSDMS: EQU	DRMS1
T0MSG:	DB	'Z17',CR,LF,'$'
T1MSG:	DB	'M47',CR,LF,'$'
T2MSG:	DB	'Z37',CR,LF,'$'
T3MSG:	DB	'Z47',CR,LF,'$'
T4MSG:	DB	'Z67',CR,LF,'$'
T2XMSG: DB	'extended Z37',CR,LF,'$'
T3XMSG: DB	'extended Z47',CR,LF,'$'
T5MSG:	DB	'Columbia',CR,LF,'$'
T6MSG:	DB	'Robin',CR,LF,'$'
T7MSG:	DB	'TeleVideo',CR,LF,'$'

;----------------------------------------------------------------------
;
;	THIS IS A TABLE OF DPB'S EACH ONE CONTAINS THREE MODE BYTES
;	FOLLOWED BY THE STANDARD 15 BIT DPB AS DEFINED BY DIGITAL
;	RESEARCH.
;
;----------------------------------------------------------------------
;		RRSRRRRR  -SR-SS--  SSSSSRRR	;S=searched, R=replaced
; "SRMASK" determines which mode bits are used to search the DPB table.
;SEARCHED:	--1-----  -1--11--  11111---
SRMASK: DB	00100000B,01001100B,11111000B	;SEARCH MODES MASKS

; "XSMASK" determines which mode bits are forced from the table.
;REPLACED:	11-11111  --1-----  -----111
XSMASK: DB	11011111B,00100000B,00000111B	;EXCESS MODES MASKS

PTRTBL:
	DB	00000000B,00000100B,00010001B	    ; M47,SD,SS
	DW	26		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	243-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,2		; CKS,OFF

	DB	00000011B,01100100B,00010011B	    ; M47,DD,SS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	300-1,192-1	; DSM,DRM
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF

	DB	00100011B,01100100B,00010011B	    ; M47,DD,DS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	608-1,192-1	; DSM,DRM
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF

	DB	00000010B,01100000B,00000000B	    ; MMS,5",DD,SS,ST
	DW	36		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	83-1,96-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF

	DB	00100010B,01100000B,00000000B	    ; MMS,5",DD,DS,ST
	DW	36		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	173-1,96-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF

	DB	00000010B,01101000B,00000000B	    ; MMS,5",DD,SS,DT
	DW	36		; SPT
	DB	5,31,3		; BSH,BLM,EXM
	DW	86-1,128-1	; DSM,DRM
	DB	10000000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF

	DB	00100010B,01101000B,00000000B	    ; MMS,5",DD,DS,DT
	DW	36		; SPT
	DB	5,31,3		; BSH,BLM,EXM
	DW	176-1,128-1	; DSM,DRM
	DB	10000000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF

	DB	00000000B,00000100B,00000001B	    ; MMS,8",SD,SS
	DW	26		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	243-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,2		; CKS,OFF

	DB	00000010B,01100100B,00000000B	    ; MMS,8",DD,SS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	300-1,192-1	; DSM,DRM
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF

	DB	00100010B,01100100B,00000000B	    ; MMS,8",DD,DS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	608-1,192-1	; DSM,DRM
	DB	11100000B,0	; AL0,AL1
	DW	48,2		; CKS,OFF

	DB	00010001B,00000000B,00011000B	    ; Z37,SD,SS,ST
	DW	20		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	92-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,3		; CKS,OFF

	DB	00010001B,01100000B,00011000B	   ; Z37,DD,SS,ST
	DW	32		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	152-1,128-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00010011B,01100000B,00110000B	   ; Z37,XD,SS,ST
	DW	40		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	186-1,128-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00110101B,00000000B,00011000B	    ; Z37,SD,DS,ST
	DW	20		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	188-1,128-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF

	DB	00110101B,01100000B,00011000B	   ; Z37,DD,DS,ST
	DW	32		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	156-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00110111B,01100000B,00110000B	   ; Z37,XD,DS,ST
	DW	40		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	195-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00010001B,00001000B,00011000B	    ; Z37,SD,SS,DT
	DW	20		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	192-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,3		; CKS,OFF

	DB	00010001B,01101000B,00011000B	   ; Z37,DD,SS,DT
	DW	32		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	156-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00010011B,01101000B,00110000B	   ; Z37,XD,SS,DT
	DW	40		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	195-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00110101B,00001000B,00011000B	    ; Z37,SD,DS,DT
	DW	20		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	196-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF

	DB	00110101B,01101000B,00011000B	   ; Z37,DD,DS,DT
	DW	32		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	316-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00110111B,01101000B,00110000B	   ; Z37,XD,DS,DT
	DW	40		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	395-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00000000B,00000100B,00100001B	    ; Z47,SD,SS
	DW	26		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	243-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,2		; CKS,OFF

	DB	00100100B,00000100B,00100001B	     ; Z47,SD,DS
	DW	26		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	247-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00000001B,01000100B,00100010B	    ; Z47,DD,SS
	DW	52		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	243-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00100101B,01000100B,00100010B	     ; Z47,DD,DS
	DW	52		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	494-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00000011B,01000100B,00111000B	     ; Z47,XD,SS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	300-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00100111B,01000100B,00111000B	     ; Z47,XD,DS
	DW	64		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	608-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00000000B,00000100B,00101001B	    ; Z67,SD,SS
	DW	26		; SPT
	DB	3,7,0		; BSH,BLM,EXM
	DW	243-1,64-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	16,2		; CKS,OFF

	DB	00100100B,00000100B,00101001B	     ; Z67,SD,DS
	DW	26		; SPT
	DB	4,15,1		; BSH,BLM,EXM
	DW	247-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00000001B,01000100B,00101010B	    ; Z67,DD,SD
	DW	52		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	243-1,128-1	; DSM,DRM
	DB	11000000B,0	; AL0,AL1
	DW	32,2		; CKS,OFF

	DB	00100101B,01000100B,00101010B	     ; Z67,DD,DS
	DW	52		; SPT
	DB	4,15,0		; BSH,BLM,EXM
	DW	494-1,256-1	; DSM,DRM
	DB	11110000B,0	; AL0,AL1
	DW	64,2		; CKS,OFF

	DB	00000001B,00000011B,00001001B	  ; Z17,SD,SS,ST
	DW	20		; SPT
	DB	3,7,0		; BSH,BSM,EXM
	DW	92-1,64-1	; DSM,DRM
	DB	11000000B,0	; ALV0
	DW	16,3		; CKS,OFF

	DB	00100001B,00000011B,00001001B	  ; Z17,SD,DS,ST
	DW	20		; SPT
	DB	3,7,0		; BSH,BSM,EXM
	DW	182-1,64-1	; DSM,DRM
	DB	11000000B,0	; ALV0
	DW	16,3		; CKS,OFF

	DB	00000001B,00001011B,00001001B	  ; Z17,SD,SS,DT
	DW	20		; SPT
	DB	4,15,1		; BSH,BSM,EXM
	DW	96-1,64-1	; DSM,DRM
	DB	10000000B,0	; ALV0
	DW	16,3		; CKS,OFF

	DB	00100001B,00001011B,00001001B	  ; Z17,SD,DS,DT
	DW	20		; SPT
	DB	4,15,1		; BSH,BSM,EXM
	DW	186-1,64-1	; DSM,DRM
	DB	10000000B,0	; ALV0
	DW	16,3		; CKS,OFF

	DB	11111111B	;FLAG FOR END OF TABLE

	END
