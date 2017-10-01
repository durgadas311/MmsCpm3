VERS EQU '4 ' ; January 26, 1984  17:00  drm  "MODE.ASM"

; for both CP/M plus and MP/M-II (77500)

	MACLIB	Z80
	$-MACRO

CPM	EQU	0		; JUMP TO BIOS

CR	EQU	0DH		; CARRIAGE RETURN
LF	EQU	0AH		; LINE FEED
ESC	EQU	1BH		; EXCAPE
bell	equ	7		; bell

search	equ	90
lptbl	equ	101		; OFFSET TO lptbl TABLE vector from WBOOT
thread	equ	103		; module thread starting vector
?serdp	equ	105
stroff	equ	12		; string address offset from init rout of mod

;
;	SYSTEM (BDOS) CALLS
;
CONIN	EQU	1		; CONSOLE INPUT
conout	equ	2		; console out
CONIO	EQU	6		; DIRECT CONSOLE I/O
TYPE	EQU	9		; CONSOLE STRING PRINT
RDCON	EQU	10		; READ CONSOLE BUFFER
GETCON	EQU	11		; GET CONSOLE STATUS
getver	equ	12		; get CP/M version number
DSKRES	EQU	13		; DISK RESET
LOGIN	EQU	24		; RETURN LOGIN VECTOR
CURDSK	EQU	25		; GET CURRENT DISK
SETDMA	EQU	26		; SET DMA ADDRESS
RESDRV	EQU	37		; RESET DRIVE FUNCTION

	cseg
base:	JMP	START

BDOS	EQU	base-100h+5	; STANDARD CP/M ENTRY
FCB	EQU	base-100h+5CH	; INPUT FILE CONTROL BLOCK
DMA	EQU	base-100h+80H	; INPUT DMA ADDRESS
TPA	EQU	base		; CP/M PROGRAM AREA

sysadr: dw	0

SIGNON: DB	cr,LF,'MODE v3.10'
	dw	vers
	DB	'  (c) 1983 Magnolia Microsystems',CR,LF,LF,'$'

errver: db	bell,'Requires CP/M 3.1 or MP/M',cr,lf,'$'
nodper: db	bell,'GETDP.REL not linked into system',cr,lf,'$'

vererr: lspd	oldsp
	lxi	d,errver
errout: mvi	c,type
	jmp	bdos

nogetdp:
	lspd	oldsp
	lxi	d,nodper
	jr	errout

START:
	SSPD	OLDSP		; save old stack pointer
	LXI	SP,STACK	; for a fast reboot
	LXI	D,SIGNON	; signon message
	MVI	C,TYPE		; string output function
	CALL	BDOS
	mvi	c,getver
	call	bdos
	mov	a,l
	cpi	30h
	jc	vererr	;can't run 2.F or earlier.
	mov	a,h
	lhld	cpm+1
	cpi	1	;MP/M - 
	jnz	st0
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
st0:	shld	sysadr
	lxi	b,?serdp-3	; Check if GETDP is linked in
	dad	b
	call	hlihl
	lded	sysadr
	xra	a		; clear A and [cy]
	mov	e,a
	dsbc	d
	jz	nogetdp
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
	MOV	A,M
	ANI	80H		; CHECK MODE BYTE DISABLE BIT
	JNZ	FIXED
	CALL	UPMODE		; update the mode byte
	CALL	RESET		; reset the drive
OUTMOD: CALL	GETMOD
	CPI	0FFH		; check for drive not available
	JZ	NODRV
	CPI	0FEH		; check for wrong release
	JZ	WRONG
	MOV	A,M
	ANI	80H		; CHECK NODE BYTE DISABLE BIT
	JNZ	FIXED
	CALL	MPRINT		; and print the new mode values
	JMP	DONE		; and we're done

SPCHK:	LXI	H,DMA		; number of characters input
	MOV	A,M
	ORA	A
	RZ			; no characters available
	INX	H
	SHLD	CMDPTR
	MOV	C,A
	MVI	B,0
	DAD	B
	MVI	M,0	;terminate command tail with a null
	LHLD	CMDPTR
MORSP:	CALL	CHAR
	CPI	' '		; and check for spaces
	JZ	MORSP
	DCX	H
	SHLD	CMDPTR
	ORA	A	;[ZR] if a null (end of string)
	RET			; zero if no arguments

CHAR:	MOV	A,M	;returns [CY] if not end of string
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

;	PARSES input command line
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
NXOPT:	push	h	; get address of format strg tbl in de
	call	serdp
	xchg
	pop	h
	MVI	C,0	; c = format bit number counter
CONFIG: mvi	b,8	; length of entry in format string table
	PUSH	H
	mov	a,c
	CPI	15	; if c = 15 then end of table
	JZ	NOTCNF	;NMEMONIC NOT FOUND
	ldax	d
FIG0:	CMP	M
	JNZ	FIG1
	INX	H
	INX	D
	dcr	b
	jz	fig5
	LDAX	D
	CPI	' '
	JNZ	FIG0
fig5:	MOV	A,M
	ORA	A
	JZ	FIG2
	CPI	','
	JZ	FIG2
	CPI	' '
	JNZ	FIG1
FIG2:	POP	D	;DISCARD OLD BUFFER POINTER
	LDA	CNFIG
	ORA	A	;IS THIS THE SECOND ENTRY OF THIS TYPE?
	JNZ	BADCMD	;ERROR IF IT IS.
	MOV	A,C
	ADI	'0'
	STA	CNFIG
	JMP	MORE

FIG1:	INX	D	;go to end of format string table
	djnz	FIG1
FIG3:	POP	H	;restore parameter address
	INR	C	;
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
UPMODE: 
	push	h
	popix
	LDA	CNFIG		; see if configuration was specified
	ORA	A
	JZ	BIT1
	sui	'0'	;make it binary 0,1,2...
	lxi	h,00000000$00000001b
	inr	a
gc1:	dcr	a
	jrz	gc0
	dad	h
	jr	gc1
GC0:
	stx	H,+0
	stx	L,+1
BIT1:
	LDA	SIDE		; see if side was specified
	ORA	A
	JZ	BIT3
	resx	6,+3		; clear the side bit
	CMA
	ANI	1		; mask the lsb
	RRC
	RRC			; to bit 6
	orax	+3		; into the mode byte
	stx	a,+3		; and update the byte
BIT3:	LDA	DENSITY 	; see if density was specified
	ORA	A
	JZ	BIT4
	resx	4,+3		; clear density bit
	CMA
	ANI	1
	RRC
	RRC
	rrc
	rrc			; to bit 4
	orax	+3		; mask the bit
	stx	a,+3		; and save it in memory
BIT4:	LDA	TRACK
	ORA	A
	JZ	BIT5
	cpi	'D'
	jrz	sdt
	cpi	'S'
	jrz	sst 
	resx	5,+3		; reset "Media Track density"
	setx	5,+2		; set "Drive track density"
	jr	bit5
SDT:	setx	5,+3	;
	SETX	5,+2
	jr	bit5
SST:	resx	5,+3
	RESX	5,+2
BIT5:	LDA	STEPRT		; get the requested step rate
	ORA	A		; see if user specified one
	JZ	BIT6
	bitx	7,+2		; size, 5.25 or 8
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
	resx	2,+2
	resx	3,+2		; clear bits
	rlc
	rlc
	orax	+2		; and update mode value
	stx	a,+2
BIT6:	
	call	serdp
	ORA	A
	JNZ	NOCHG		; error if non-zero (NO DPB FOUND)
;
;	mode bytes updated by "?serdp"
;
	LXI	H,MINFO 	; NEW MODE BYTE POINTER
	PUSH	H
	MVI	A,4		; number of bytes to check
	LBCD	MODPTR		; OLD mode byte pointer
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
	MVI	B,4    
	LDED	MODPTR		; actual mode byte pointer
UPONE:	MOV	A,M		; if all's well, let's actually update
	STAX	D		; the mode byte
	INX	H
	INX	D
	DJNZ	UPONE
	RET			; and return


serdp	LXI	D,MINFO 	; MODE BYTE POINTER TO DE
	LHLD	sysadr		; call serdp
	LXI	B,?SERDP-3
	DAD	B		; POINTER TO SERDP CALL ADDRESS
	CALL	HLIHL		; GET CALL ADDRESS
	push	h
	CALL	ICALL		; CALL "GETDP" TO FIND A DPB FOR THIS MODE
	pop	d		; add start of serdp to hl to get start of
	dad	d		; format string table
	ret		

;	output the mode data to the CRT
;	A pointer to the mode data is passed in the HL
;
MPRINT: 
	LDA	DRVNUM		; get physical drive number
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
	LHLD	MODPTR		; pointer to system mode byte
	PUSH	H		; save the mode pointer
	BIT	7,M		; check validity
	JNZ	DONE		; non-zero if hard disk
	inx	h
	inx	h
	BIT	7,M		; size, 0=5" and 1=8"
	LXI	D,INCH5
	JZ	PRINCH
	LXI	D,INCH8
PRINCH: MVI	C,TYPE
	CALL	BDOS
	LXI	D,CTRMSG
	MVI	C,TYPE
	CALL	BDOS
	CALL	GETTXT		; get text string pointer in DE
	MVI	C,TYPE
	CALL	BDOS
	call	crlf
	POP	H
	PUSH	H		; get mode address again
	inx	h
	inx	h
	INX	H		; point to byte 2
	BIT	4,M
	JZ	SD		; single density if zero
	LXI	D,DDMSG 	; double density drive message
	JMP	DD
SD:	LXI	D,SDMSG 	; single density drive message
DD:	MVI	C,TYPE
	CALL	BDOS
	POP	H
	PUSH	H
	inx	h
	inx	h
	inx	h
	BIT	6,M		; check the side bit
	JZ	SS		; single sided if zero
	LXI	D,DSMSG 	; double sided drive message
	JMP	DDS
SS:	LXI	D,SSMSG 	; single sided drive message
DDS:	MVI	C,TYPE
	CALL	BDOS
	POP	H
	PUSH	H		; get mode address again
	inx	h
	inx	h
	INX	H
	bit	5,m		; bit set if 96 tpi
	JNZ	T96
	dcx	h
	bit	5,m	;check for drive "DT"
	inx	h
	jz	t48
	LXI	D,HALFTK	; half track message
	JMP	HTRK
T48:	LXI	D,T48MSG	; 48 tpi message
	JMP	HTRK
T96:	LXI	D,T96MSG	; 96 tpi message
HTRK:	MVI	C,TYPE
	CALL	BDOS
	POP	H		; get pointer again
	PUSH	H
	INX	H		; point to second byte
	inx	h
	MOV	A,M		; and get it
	ANI	00001100b	; bits for step rate
	bit	7,m
	jrz	sr00
	setb	4,a
sr00:	LXI	H,STRTBL	; step rate table
	rrc			; 
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
	lxi	d,fmtstr
	mvi	c,type
	call	bdos
	POP	H		; get pointer to format origin bytes
	mov	d,m		; load bytes in de
	inx	h
	mov	e,m
	push	d
	call	serdp		; get start of format string table in hl
	pop	d
	lxi	b,8
	xra	a
fmt1:	srlr	d
	rarr	e	;shift and wait for a carry...
	jrc	fmt2
	dad	b
	jr	fmt1
fmt2:	mvi	b,8
fmt3:	mov	e,m	; got format string - now print 8 characters
	push	h	
	push	b	; hl = string start
	mvi	c,conout
	call	bdos
	pop	b
	pop	h
	inx	h
	djnz	fmt3
	call	crlf
	ret

;	this function puts the mode byte at MINFO and
;	returns a pointer to it in the HL. It also places
;	pointers to the actual mode byte and mask in
;	MODPTR and MSKPTR and the drive number in DRVNUM
;
GETMOD: LDA	NDRIVE		; get logical drive number
	LHLD	sysadr		; address of BIOS
	LXI	D,lptbl-3	; offset to POINTER TO mixer table
	DAD	D
	CALL	HLIHL		; MIXER TABLE
	MOV	E,A		; use logical drive number as offset
	MVI	D,0		; into logical/physical table
	DAD	D
	MOV	A,M		; get physical drive number
	STA	DRVNUM		; and save it away
	CPI	0FFH
	RZ			; return if no drive installed

DROK:	LXI	B,search-3	; address of search routine
	LHLD	sysadr
	DAD	B
	MOV	C,A		; SEARCH REQUIRES DRIVE NUMBER IN REG. C
	call	icall	;call module-search with A=physical drive number
	jc	syserr
	shld	module
	STA	RELDSK
;
;	CHECK IF DRIVER IS RECENT RELEASE (HAS MODE BYTES)
;	DO THIS BY CHECKING FOR MULTIPLE STRINGS
;
	MVI	A,1		; more than one string in this release
	PUSH	H		; SAVE MODULE ADDRESS
	CALL	GETSTR
	POP	H		; RESTORE MODULE ADDRESS
	ORA	A		; and see if there are 2 strings
	mvi	a,0feh
	rnz
	MVI	A,30		; a ridiculous string number
	CALL	GETSTR		; DE points to null (we hope)
	XCHG			; make it HL
	DCX	H		; POINT TO TERMINATOR
	MOV	A,M
	CPI	'$'		; IS IT A DOLLAR SIGN ?
	mvi	a,0feh
	rnz			; additional check
; A=relative drive number
; HL=modtbl
	LHLD	MODULE		; START OF MODULE
	LXI	D,16
	DAD	D		; POINTER TO MODE TABLE
	CALL	HLIHL		; MODE TABLE
	LDA	RELDSK
	add	a
	add	a
	add	a		; *8
	mov	e,a
	mvi	d,0
	dad	d
GOTADR: 
	SHLD	MODPTR		; save the mode byte pointer
	XCHG
	LXI	H,4		; +4 to mask
	DAD	D
	SHLD	MSKPTR		; save the mode byte mask pointer
	LXI	H,MINFO 	; internal storage buffer
	XCHG			; from HL to DE for LDIR
	LXI	B,4		; 4 bytes
	LDIR			; to store the mode byte internally
	LXI	H,MINFO 	; restore pointer
	LDA	DRVNUM
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
GETSTR: PUSH	PSW		; save requested field
	LXI	d,12		; point to string vector
	DAD	D		; to start of strings
	CALL	HLIHL
	SHLD	STRADR		; initial text pointer
	XRA	A
	STA	GETERR		; clear error flag
	STA	FLDNUM		; set field number 0
NXTFLD: LDA	GETERR		; check error flag
	ORA	A
	JNZ	GETXIT		; error if non zero
	SHLD	STRADR		; start of search string
	MVI	B,100		; search 100 characters
GETCHR: MOV	A,M
	INX	H		; point past separator
	CPI	'$'		; field terminator
	JZ	CHKEND		;  DOLLAR SIGN OR NULL
	ORA	A
	JZ	CHKEND
	CPI	' '
	JC	SETERR
	DJNZ	GETCHR
SETERR: MVI	A,0FFH
	STA	GETERR		; set error flag
	JMP	GETXIT
CHKEND: LDA	FLDNUM
	MOV	B,A
	POP	PSW		; get requested field
	PUSH	PSW
	CMP	B		; is this one correct
	JZ	GETXIT		; found if zero
	INR	B		; increment field number
	MOV	A,B
	STA	FLDNUM
	DCX	H
	MOV	A,M		; GET FIELD TERMINATOR
	INX	H
	SHLD	STRADR		; SET NEW STRING ADDRESS
	ORA	A		; IS TERMINATOR A NULL ?
	JNZ	SETERR		; IF NOT IT'S A '$' AND WE'VE HIT END OF STRING
	JMP	NXTFLD		;  BEFORE FINDING FIELD
GETXIT: LDED	STRADR		; string address
	POP	PSW		; clean up stack
	LDA	GETERR		; error flag
	RET

;	THIS SUBROUTINE RESETS THE DRIVE that got THE NEW MODE BYTE
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

ICALL:	PCHL

;
;	THIS FUNCTION RETURNS A TEXT STRING TO BE OUTPUT
;
GETTXT: 
	lhld	module		; get module address
	lxi	d,stroff	; address text string offset
	dad	d
	mov	e,m		; move to de
	inx	h
	mov	d,m
	ret

;
;	LOAD HL INDIRECT THROUGH HL
;
HLIHL:	MOV	C,M
	INX	H
	MOV	H,M
	MOV	L,C
	RET

;
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
FIXED:	LXI	D,DIFFER	; not FDC or Z37 driver
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

crlf	lxi	d,crlfmsg
	mvi	c,type
	call	bdos
	ret

;	data storage
;
HELP:	DB	'The MODE utility is called in one of the following ways:'
	DB	CR,LF,LF,'        MODE',CR,LF
	DB	'Outputs HELP information',CR,LF,LF
	DB	'        MODE d:',CR,LF
	DB	'Displays the present drive status to the user',CR,LF,LF
HALFHL: DB	'        MODE d:arg1,arg2,arg3',CR,LF
	DB	'Updates the present status and displays it. Valid'
	DB	' arguments are:',CR,LF,LF
	DB	'        DS or SS = double or single sided',CR,LF
	DB	'        DT, ST or HT = double (96 tpi), single (48 tpi),'
	DB	' or half track',CR,LF
	DB	'          half track is 48 tpi media in a 96 tpi drive.',CR,LF
	DB	'        DD or SD = double or single density',CR,LF
	DB	'        S6, S30, etc. = step rate in milliseconds',CR,LF
	DB	'        MMS, Z37, Z37X etc. (media formats); the X implies'
	DB	' extended format.',CR,LF,LF,'$'
DIFFER: DB	'Drive '
DIFD:	DB	'A: has a fixed configuration which cannot '
	DB	'be determined by MODE.',CR,LF,'$'

INCH5:	DB	'5.25 inch floppy',CR,LF,'$'
INCH8:	DB	'8 inch floppy',CR,LF,'$'
CTRMSG: DB	'       Controller - $'
SSMSG:	DB	'            Sides - 1',CR,LF,'$'
DSMSG:	DB	'            Sides - 2',CR,LF,'$'
SDMSG:	DB	'Recording Density - Single',CR,LF,'$'
DDMSG:	DB	'Recording Density - Double',CR,LF,'$'
T48MSG: DB	'  Tracks per Inch - 48',CR,LF,'$'
T96MSG: DB	'  Tracks per Inch - 96',CR,LF,'$'
HALFTK: DB	'  Tracks per Inch - 48 tpi media in 96 tpi drive (R/O)'
crlfmsg DB	CR,LF,'$'
fmtstr: DB	'      Format Type - $'
STRMSG: DB	'        Step Rate - $'
STRATE: DB	'00 milliseconds',CR,LF,'$'
DRSTR:	DB	'            Drive - '
DSKLT:	DB	'A: ('
DSKNM:	DB	'  ) $'
TTLE0:	DB	'PRESENT Configuration is:',CR,LF,'$'
TTLE1:	DB	'NEW Configuration is:',CR,LF,'$'

BADMSG: DB	'Invalid command line or command line arguments.',CR,LF,'$'
CHGMSG: DB	'The requested format is invalid for the specified drive.'
	DB	CR,LF,'The complete configuration must be supplied',CR,LF,'$'
NODRMS: DB	'A: does not exist.',CR,LF,'$'
WRGMSG: DB	'The driver module for '
WRGD:	DB	'A: is incompatible with MODE.',CR,LF,'$'
	DB	' inoperative.',CR,LF,'$'
SERMSG: DB	'Drive is specified but not linked - ERROR IN SYSTEM-'
	DB	CR,LF,'$'

STRTBL: DB	' 6122030 3 61015'	; possible step rates, 2 bytes each
STEPTB: DB	7,13,21,31,4,7,11,16

MODULE: DW	0
RELDSK: DB	0
MINFO:	DB	0,0,0,0
MODPTR: DW	0
MSKPTR: DW	0
CMDPTR: DW	0
DRVNUM: DB	0
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


	END
