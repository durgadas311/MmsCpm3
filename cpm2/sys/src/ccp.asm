BASE	EQU	0000H		; ORG for reloc

	TITLE	'MMS Console Command Processor (CCP) ver 2.242'

	MACLIB	Z80
	$-MACRO
;
;	new features
; A. If program not found under curr user/disk then try user 0
;	on curr disk.  If still not found try default drive.
; A1. The 'Try User 0' function is carried on by the BDOS now.
; B. The TYPE command pages its output.
; C. New command PRNT sends output to the LST: device & expands tabs.
; D. The user number is printed as part of the prompt as A0>, A15>.
; E. The ERA command displays the name of each file it erases.
; F. The DIR command has an additional form of "dir @" which lists
;	all files (includes SYStem and R/O files), while "dir" lists
;	only non-system, non-R/O files.
; G. The directory display no longer displays the drive name at
;	the beginning of each line & it now includes a '.' between
;	the file name and type.
; H. The directory display now contains 5 columns
; I. The submit facility now expects the $$$.SUB file to be on the
;	currently logged drive.
; J. The command line prompt is now not printed until all preprocessing 
;	is completed.
; K. The TYPE & PRNT commands mask the msb of each byte so only
;	ASCII is printed.
; L. Fixed bug in definition of delimiter characters (7/7/82)
;
; System constants
;
NLINES	EQU	62		; # lines on LST:
CR	EQU	0DH		;carriage return
LF	EQU	0AH		;line feed
TAB	EQU	9		;tab
FF	EQU	0CH		;form feed
;
; System memory locations
;
UDFLAG	EQU	4		; user # is in high nibble, disk in low
BDOS	EQU	5		;CP/M BDOS
TBUFF	EQU	80H		;Temporary buffer
TFCB	EQU	5CH		;Temporary FCB
TPA	EQU	100H		;User programs
;
;	System Calls
;
CONINF	EQU	1		; Console Input
OUTCON	EQU	2		; CONSOLE OUTPUT
OUTLST	EQU	5		; LIST OUTPUT
CONIO	EQU	6		; DIRECT CONSOLE I/O
RDCON	EQU	10		; READ CONSOLE BUFFER
CONSTF	EQU	11		; Console Status
DSKRES	EQU	13		; DISK RESET
DSKSEL	EQU	14		; SELECT DISK
OPNFIL	EQU	15		; OPEN FILE
CLOFIL	EQU	16		; CLOSE FILE
SFIRST	EQU	17		; SEARCH FOR FIRST
SNEXT	EQU	18		; SEARCH FOR NEXT
DELFIL	EQU	19		; DELETE FILE
RDSEQ	EQU	20		; READ SEQUENTIAL
WRTSEQ	EQU	21		; WRITE SEQUENTIAL
MAKE	EQU	22		; MAKE FILE
RENAME	EQU	23		; RENAME A FILE
CURDSK	EQU	25		; GET CURRENT DISK
SETDMA	EQU	26		; SET DMA ADDRESS
USERN	EQU	32		; GET/SET USER NUMBER

	ORG	BASE
ENTRY:
	JMP	CCP
	JMP	CCP1
;
;	Input cmd line and default cmd
;
BUFLEN	EQU	128		; max buff length
STKLEN	EQU	20		; size of stack

MBUFF:
	DB	BUFLEN		; max buff length
CBUFF:
	DB	0		; # chars in cmd

CIBUFF:
	REPT	BUFLEN		;fill the command buffer with spaces
	  DB	' '
	ENDM

	REPT	STKLEN
	  DB	0		;zero out the stack.
	ENDM
STACK	EQU	$		;top of stack.

CIBPTR: DW	CIBUFF		; pointer to cmd input buff
CIPTR:	DW	CIBUFF		; curr pntr
PPROMPT DB	0FFH		;reset this to disable one (1) outputting of
				;the prompt (use for answers to questions that
				;require no prompt) in REDBUF.
;
;  I/O Utility Routines
;
;************************************************************************
;									*
; SPACER -- Output A Space To The Console				*
;	Outputs a space to the console. 				*
;									*
;	Inputs:  none.							*
;	Outputs:  none. 						*
;	Register effects:  'A', 'DE', Flags destroyed.			*
;									*
;************************************************************************
;
SPACER:
	MVI	A,' '		;set a space
	;continues into CONOUT
;
;	Output char in A & save BC
;
CONOUT:
	PUSH	B
	PUSH	H
	MVI	C,OUTCON
OUTPUT:
	MOV	E,A
	CALL	BDOS
	POP	H
	POP	B
	RET
;
;	Send char in A to list device
;
LSTOUT:
	PUSH	B
	PUSH	H
	MVI	C,OUTLST
	JR	OUTPUT
;
;	Output <CRLF>
;
CRLF:
	MVI	A,CR
	CALL	CONOUT
	MVI	A,LF
	JR	CONOUT
;
;	Print string pointed to by ret addr
;
PRINT:
	XTHL			; get ptr to string
	PUSH	PSW
	CALL	CRLF
	CALL	PRIN1
	POP	PSW
	XTHL			; restore HL and ret adr
	RET
;
;	Print string pointed to by HL
;
PRIN1:
	MOV	A,M		; get next char
	INX	H
	ORA	A		; done if 0
	RZ
	CALL	CONOUT
	JR	PRIN1
;
;	Call BDOS & save BC
;
BDOSB:
	PUSH	B
	CALL	BDOS
	POP	B
	RET
;
;  BDOS function rtns
;
RESET:
	MVI	C,DSKRES
	JR	BDOSB
;
LOGIN:
	MOV	E,A
	MVI	C,DSKSEL
	JR	BDOSB
;
OPENF:
	XRA	A
	STA	FCBCR
	LXI	D,FCBDN
;
OPEN:
	MVI	C,OPNFIL
;
GRBDOS:
	CALL	BDOS
	INR	A		; set Z flag if error
	RET
;
CLOSE:
	MVI	C,CLOFIL
	JR	GRBDOS
;
SEARF:
	LXI	D,FCBDN 	; specify fcb
SEAR1:
	MVI	C,SFIRST
	JR	GRBDOS
;
SEARN:
	MVI	C,SNEXT
	JR	GRBDOS
;
DELETE:
	MVI	C,DELFIL
	JR	BDOSB
;
READF:
	LXI	D,FCBDN
;
READ:
	MVI	C,RDSEQ
;
GOBDOS:
	CALL	BDOSB		; preserve B
	ORA	A
	RET
;
WRITE:
	MVI	C,WRTSEQ
	JR	GOBDOS
;
CREATE:
	MVI	C,MAKE
	JR	GRBDOS
;
GETUSR:
	MVI	E,0FFH		; get curr user #
SETUSR:
	MVI	C,USERN 	; set/get user
	JR	BDOSB
;
;	Return curr disk # in A
;
GETDRV:
	MVI	C,CURDSK
	JR	BDOSB
;
;	Set DMA to 80H
;
DEFDMA:
	LXI	D,80H
DMASET:
	MVI	C,SETDMA
	JR	BDOSB
;
;  end of BDOS functions
;
;
;  CCP utilities
;
;  set user/disk flag to curr user and default disk
;
SETUD:
	CALL	GETUSR		; get # of curr user
	ADD	A		; to high nybble
	ADD	A
	ADD	A
	ADD	A
	LXI	H,TDRIVE	; DEFDRV to low nybble
	ORA	M		; mask in
	STA	UDFLAG		; set user/disk #
	RET
;
;	Set user/disk to user 0 & DEFDRV
;
SETU0D:
	CALL	SETUD
	MOV	A,M
	JR	LOGIN
;
;	Conv char in A to uppercase
;
UCASE:
	CPI	'a'
	RC
	CPI	'z'+1
	RNC
	ANI	5FH
	RET
;
;	Input next cmd to CCP
;
REDBUF:
	LDA	RNGSUB		; sub file active?
	ORA	A		; 0=no
	JRZ	RB1		; get line from console if not
	LXI	D,SUBFCB	; OPEN $$$.sub
	CALL	OPEN
	JRZ	RB1		; erase sub if EOF & get cmd
	LXI	D,SUBFCB	; point to $$$.SUB fcb.
	LDAX	D		; if drive # is default (00), replace w/TDRIVE
	ORA	A		; now that $$$.SUB has been found.
	JRNZ	NOTDEF
	LDA	TDRIVE		; fix drive number
	INR	A		; change to range 1-16 from 0-15.
	STAX	D
NOTDEF: LDA	SUBFRC		; get value of last rec in file
	DCR	A		; pt to next to last rec
	STA	SUBFCR		; save new last rec val
	LXI	D,SUBFCB	; read last rec
	CALL	READ
	JRNZ	RB1		; abort sub if err during read
	LXI	D,CBUFF 	; copy last rec to CBUFF
	LXI	H,TBUFF 	; from TBUFF
	MVI	B,BUFLEN	; # of bytes
	CALL	MOVEHD
	LXI	H,SUBFs2	; set s2 to 0
	MVI	M,0
	INX	H		; dec rec count of sub file
	DCR	M
	LXI	D,SUBFCB	 ; close $$$.sub
	CALL	CLOSE
	JRZ	RB1		; abort $$$.sub if error
	CALL	PROMPT		;print the prompt if PPROMPT is not reset.
	LXI	H,CIBUFF	 ; PRINT cmd line from $$$.sub
	CALL	PRIN1
	CALL	BREAK		; check for abort
	JRZ	CNVBUF		; if <null> (no abort)
	JR	ERREND		; kill $$$.SUB and restart CCP
;
;	Input cmd from console
;
RB1:
	CALL	SUBKIL		; erase $$$.sub if present
	CALL	SETU0D		; set user & disk
	CALL	PROMPT		;print the prompt, if PPROMPT is not reset.
	MVI	C,RDCON 	; read cmd line from user
	LXI	D,MBUFF
	CALL	BDOS
	CALL	SETU0D		; set curr disk # in lower params
;
;	Capitalize string in CBUFF
;
CNVBUF:
	LXI	H,CBUFF 	; pt to user's cmd
	MOV	B,M		; char count in b
	INR	B		;pre-increment character count for test
CB1:
	INX	H		;bump character pointer
	DCR	B		;test for end of loop
	JRZ	CB2		;jump if so
	MOV	A,M		; capitalize cmd char
	CALL	UCASE
	MOV	M,A
	JR	CB1
CB2:
	MOV	M,B		; store ending <null>
	LXI	H,CIBUFF	; set cmd line ptr to 1st char
	SHLD	CIBPTR
	RET
;
;	Check for char from console. Z set if none
;
BREAK:
	MVI	C,CONSTF	; test console status for key pressed.
	CALL	BDOSB		; BDOS with BC saved
	ORA	A		; end if no key pressed.
	RZ
	;overflow into CONIN.
;
;	Get the character from the console.  Set flags.
;
CONIN:	MVI	C,CONINF
	CALL	BDOSB
	ORA	A
	RET
;
;	Abort sub file if active
;
SUBKIL:
	LXI	H,RNGSUB	; sub file active?
	MOV	A,M
	ORA	A		; 0=no
	RZ
	XRA	A
	MOV	M,A		; sub file not active now
	LDA	TDRIVE
	CALL	LOGIN
	LXI	D,SUBFCB	; delete the $$$.SUB file
	CALL	DELETE
	XRA	A
	STA	SUBFCB		; restore $$$.SUB fcb.
	RET
;
;	Display invalid cmd
;
ERROR:
	CALL	CRLF
	LHLD	CIPTR		; pt to beginning of cmd line
ERR2:
	MOV	A,M		; get char
	CPI	' '		; display '?' if <sp> or <null>
	JRZ	ERR1
	ORA	A
	JRZ	ERR1
	PUSH	H		; save ptr to error cmd char
	CALL	CONOUT
	POP	H		; get ptr
	INX	H		; pt to next
	JR	ERR2		; continue
ERR1:
	MVI	A,'?'
	CALL	CONOUT
ERREND: CALL	SUBKIL
	JMP	RESTRT
;
;	See if DE points to delimiter. Set Z if so
;
SDELM:
	LDAX	D
	ORA	A		; 0=delimiter
	RZ
	CPI	' '		; error if < space
	JC	ERROR
	RZ			; <sp>=delimiter
	CPI	'_'		; underline
	RZ
	CPI	'.'		; period
	RZ
	CPI	':'		; colon, semicolon
	RC			; left pointy thing, equal
	CPI	'>'		; right pointy thing
	RNC
	CMP	A		; set Z flag
	RET
;
;	Skip to next non-blank char in string pointed to
;	by DE.
;
SBLANK:
	LDAX	D
	ORA	A
	RZ
	CPI	' '
	RNZ
	INX	D
	JR	SBLANK
;
;	Add A to HL
;
ADDAH:
	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET
;
;	extract token fm cmd line & put it into FCBDN
;
;	If token resembles filename.typ
;	on input, cubptr => char at which to start scan
;	on output, CIBPTR => char to cont at, and Z is set
;	if '?' is in token
SCANER:
	MVI	A,0		; start at drive spec byte
SCAN1:
	LXI	H,FCBDN 	; point to FCBDN
	CALL	ADDAH		; offset into fCB
	PUSH	H
	PUSH	H
	XRA	A		; set temp drive # to default
	STA	TEMPDR
	LHLD	CIBPTR		; get ptr to next char in cmd line
	XCHG			; ptr in DE
	CALL	SBLANK		; skip to non-blank or EOL
	XCHG
	SHLD	CIPTR		; set ptr to non-blank or EOL
	XCHG			; de => next non-blank or EOL char
	POP	H		; get ptr to next byte in FCBDN
	LDAX	D		; EOL?
	ORA	A		; 0=yes
	JRZ	SCAN2
	SBI	'A'-1		; make possible drive spec to number
	MOV	B,A
	INX	D		; next char
	LDAX	D
	CPI	':'		; delimiter?
	JRZ	SCAN3		; yes - drive spec
	DCX	D		; else back up ptr to 1st non-blank
SCAN2:
	LDA	TDRIVE		; set 1st byte of FCBDN as DEFDRV
	INR	A		; convert to 1-16 range
	MOV	M,A
	JR	SCAN4
SCAN3:
	MOV	A,B		; we have a drive spec
	STA	TEMPDR		; set temp drive
	MOV	M,B		; set 1st byte of FCBDN as specified drive
	INX	D		; next byte after ':'
;
;	Extract filename
;
SCAN4:
	MVI	B,8
SCAN5:
	CALL	EXTRAC		;extract 'B' characters from buffer into FCBDN
;
;	Extract .typ
;
SCAN10:
	MVI	B,3
	CPI	'.'		; .typ delimiter?
	JRNZ	SCAN15		; no - pad with <sp>
	INX	D
SCAN11:
	CALL	EXTRAC		;extract 'B' characters from buffer into FCBDN
	JR	SCAN16		;skip padding with spaces
SCAN15:
	INX	H		; pad rest of .typ with <sp>
	MVI	M,' '
	DJNZ	SCAN15
scan16:
;
;	Fill ex, s1, s2, & RC with zeroes
;
	MVI	B,4
SCAN17:
	INX	H
	MVI	M,0
	DJNZ	SCAN17
;
;	Scan done - DE => delimiter after token
;
	XCHG			; store ptr to next char in cmd
	SHLD	CIBPTR
;
;	Set Z flag to indicate '?' in filename
;
	POP	H		; get ptr to FCBDN in HL
	LXI	B,11*256	; scan for '?' in filename.typ
SCAN18:
	INX	H
	MOV	A,M
	CPI	'?'
	JRNZ	SCAN19
	INR	c		; c<>0 inidcates '?' found
SCAN19:
	DJNZ	SCAN18		; count down
	MOV	A,C		; a=c=# of '?' found
	ORA	A		; set Z flag
	RET
;
; EXTRAC -- Given the number of characters to extract from a buffer in 'B',
; the destination FCB section in 'HL', the source buffer pointer in 'DE',
; extract characters until done with expansion of wild cards, pad rest of
; buffer with spaces.
;
EXTRAC:
	CALL	SDELM		; done if delimiter
	JRZ	SCAN9		; so pad with spaces.
	INX	H		; next byte in FCBDN
	CPI	'*'		; wild card?
	JRNZ	SCAN6		; cont if not
	MVI	M,'?'
	JR	SCAN7
SCAN6:
	MOV	M,A		; store filename char in FCBDN
	INX	D		; next char in cmd
SCAN7:
	DJNZ	EXTRAC		; do all 8
SCAN8:
	CALL	SDELM
	RZ			; Z set if delimiter found, end.
	INX	D		; next char
	JR	SCAN8
SCAN9:
	INX	H		;if not 'B' characters,
	MVI	M,' '		; pad with <sp>
	DJNZ	SCAN9
	RET			;end
;
;  CCP built-in cmd table and cmd processor
;
NCHARS	EQU	4		; # of chars/cmd
;
;	CCP Commands
;
CMDTBL:
	DB	'DIR '
	DB	'ERA '
	DB	'PRNT'
	DB	'TYPE'
	DB	'SAVE'
	DB	'REN '
	DB	'RES '
	DB	'CLS '
	DB	'USER'
NCMNDS	EQU	($-CMDTBL)/NCHARS
;
;	Command address table
;
REQTBL:
	DW	DIR		; DIRectory list command
	DW	ERA		; ERAse command
	DW	LIST		; PRiNT command
	DW	TYPE		; TYPE command
	DW	SAVE		; SAVE command
	DW	REN		; REName command
	DW	REST		; soft disk RESet
	DW	CLS		; clear screen
	DW	USER		; USER defined function

	DW	COM		; Default if .COM
;
;	Command table scanner
;
;	On exit: A=table entry #
;
CMDSER:
	LXI	H,CMDTBL	; pt to cmd table
	MVI	C,0		; set cmd counter
CMS1:
	MOV	A,C		; check for done
	CPI	NCMNDS
	RNC
	LXI	D,FCBFN 	; pt to stored cmd name
	MVI	B,NCHARS
CMS2:
	LDAX	D
	CMP	M
	JRNZ	CMS3		; no match
	INX	D		; pt to next char
	INX	H
	DJNZ	CMS2		; count down
	LDAX	D		; next char in input cmd must be <sp>
	CPI	' '
	JRNZ	CMS4
	MOV	A,C		; table entry # in a
	RET
CMS3:
	INX	H		; skip to next entry
	DJNZ	CMS3
CMS4:
	INR	C		; inc table entry #
	JR	CMS1
;
;  CCP starting points
;
;  start CCP & don't process stored default cmd
;
CCP1:
	XRA	A		; set no default cmd
	STA	CBUFF
;
;	Start CCP & process stored cmd
;
CCP:
	LXI	SP,STACK
	PUSH	B
	MOV	A,C		; get user/disk  #
	RAR			; extract user #
	RAR
	RAR
	RAR
	ANI	0FH
	MOV	E,A		; set user #
	CALL	SETUSR
	CALL	RESET		; reset disk system
	POP	B
	MOV	A,C		; get user/disk #
	ANI	0FH		; extract drive
	STA	TDRIVE		; set it
	CALL	LOGIN		; log in default disk
	LXI	D,SUBFCB	; check for sub file
	CALL	SEAR1		; 0ffh returned if no sub
	inr	a		; convert to 0h if no sub file.
	STA	RNGSUB		; set flag (0=no $$$.sub)
	LDA	CBUFF		; exec default cmd?
	ORA	A		; 0=no
	JRNZ	RS1
;
;	Display prompt
;
RESTRT:
	LXI	SP,STACK
;
;	Read input from user or sub
;
	CALL	DEFDMA		;set DMA before reading $$$.SUB
	CALL	REDBUF
;
;	Process input line
;
RS1:
;	LXI	D,TBUFF 	; pt to input cmd line (in TBUFF)
;	CALL	DMASET		; set TBUFF to DMA address
	CALL	DEFDMA		; same, with less bytes
	CALL	GETDRV		; set DEFDRV
	STA	TDRIVE
	CALL	SCANER		; parse cmd name
	CNZ	ERROR		; error if it contains a '?'
	LDA	TEMPDR		; is cmd of form 'd:cmd'?
	ORA	A		; nz=yes
	JNZ	COM		; process as COM file
	CALL	CMDSER		; scan for resident cmd
	LXI	H,REQTBL	; exec cmd
	MOV	E,A		; compute offset into addr table
	MVI	D,0
	DAD	D
	DAD	D
	MOV	A,M		; get address in HL
	INX	H
	MOV	H,M		; msb
	MOV	L,A		; lsb
	PCHL
;
; Print the prompt if PPROMPT is not reset, then set PPROMPT.
;
PROMPT: PUSH	PSW
	LDA	PPROMPT 	; test 'print prompt' flag.
	ORA	A
	JRZ	PREND		; end if reset.
	CALL	CRLF
	CALL	GETDRV		; curr drive is part of prompt
	ADI	'A'		; make ascii
	CALL	CONOUT
	CALL	GETUSR		; get user #
	CPI	10		; user < 10?
	JRC	prompt1
	SUI	10		; sub 10 from it
	PUSH	PSW		; save it
	MVI	A,'1'		; output 10's digit
	CALL	CONOUT
	POP	PSW
PROMPT1:
	ADI	'0'		; output 1's digit
	CALL	CONOUT
	MVI	A,'>'		; display end of prompt
	CALL	CONOUT
PREND:	MVI	A,0FFH		;set 'print prompt' flag.
	STA	PPROMPT
	POP	PSW		;restore registers
	RET			;end
;
;  Error messages
;
PRNNF:
	CALL	PRINT
	DB	'No file',0
	RET
;
;  More CCP utilities
;
;  Extract # from cmd line
;
NUMBER:
	CALL	SCANER		; parse # and place in FCBFN
	LDA	TEMPDR		; token start with drive spec (d:)?
	ORA	A		; error if so
	JNZ	ERROR
	LXI	H,FCBFN 	; pt to token for conversion
	LXI	B,11		; B=accumulated value, C=char count
NUM1:
	MOV	A,M		; get char
	CPI	' '		; done if <SP>
	JRZ	NUM2
	INX	H		; pt to next char
	SUI	'0'		; make binary
	CPI	10		; error if >= 10
	JNC	ERROR
	MOV	D,A		; digit in D
	MOV	A,B		; get accumulated value
	ANI	0E0h		; check for range error (>255)
	JNZ	ERROR
	MOV	A,B		; new val = old val * 10
	RLC
	RLC
	RLC
	ADD	B		; check for range error
	JC	ERROR
	ADD	B		; check for range error
	JC	ERROR
	ADD	D		; new val = old val * 10 + digit
	JC	ERROR		; check for range error
	MOV	B,A		; set new value
	DCR	C		; count down
	JRNZ	NUM1
	RET
;
;	Rest of token buffer must be <SP>
;
NUM2:
	MOV	A,M
	CPI	' '
	JNZ	ERROR
	INX	H		; pt to next
	DCR	C		; count down
	JRNZ	NUM2
	MOV	A,B		; get accumulated value
	RET
;
;	Move 3 bytes from HL to DE
;
MOVHD3:
	MVI	B,3		; move 3 chars
MOVEHD:
	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DJNZ	MOVEHD
	RET
;
;	Pt to DIR entry in TBUFF, offset is specified by A & C
;
DIRPTR:
	LXI	H,TBUFF 	; pt to temp buff
	ADD	C		; pt to 1st byte of DIR entry
	CALL	ADDAH		; pt to desired byte in dir entry
	MOV	A,M
	RET
;
;	Check for specified drive & log it if not default
;
SLOGIN:
	XRA	A		; set FCBDN for DEFDRV
	STA	FCBDN
	CALL	COMLOG		; check drive
	RZ
	JMP	LOGIN		; do LOGIN otherwise
;
;	Check for specified drive & log it if <> default
;
DLOGIN:
	CALL	COMLOG		; check drive
	RZ			; abort if same
	LDA	TDRIVE
	JMP	LOGIN
;
;	rtn common to both LOGIN rtns
;	On exit: Z set means abort
;
COMLOG:
	LDA	TEMPDR		; drive specified?
	ORA	A		; 0=no
	RZ
	DCR	A		; COMp to default
	LXI	H,TDRIVE
	CMP	M
	RET			; abort if same
;
;	DIR routine
;
DIR:
	MVI	A,80H		; set to include sys files
	PUSH	PSW
	CALL	SCANER		; SCAN for possible d:file.typ token
	CALL	SLOGIN		; log drive is necessary
	LXI	H,FCBFN 	; make fCB all '?' if no file.typ
	MOV	A,M		; get 1st char
	CPI	' '		; if <SP>, all wild
	JRZ	DIR0
	CPI	'@'		; system files?
	JRNZ	DIR2
	INX	H		; just '@'?  <SP> must follow
	MOV	A,M
	DCX	H		; back up
	CPI	' '		; just '@' if <SP> follows
	JRNZ	DIR2
	POP	PSW		; get flag
	XRA	A		; set no sys files
	PUSH	PSW
DIR0:
	MVI	B,11
DIR1:
	MVI	M,'?'		; store '?'
	INX	H
	DJNZ	DIR1
DIR2:
	POP	PSW		; get flag
	CALL	DIRPR		; print dir
	JMP	RSTCCP		; restart CCP
;
;	DIR print rtn

DIRPR:
	MOV	D,A		; store system flag in D
	MVI	E,5		; column counter
	PUSH	D
	CALL	SEARF
	CZ	PRNNF		; print no file msg
DIR3:
	JRZ	DIR11		; done if Z flag set
	DCR	A		; adjust to returned value
	RRC			; convert # to offset into TBUFF
	RRC
	RRC
	ANI	60H
	MOV	C,A		; offset into TBUFF
	MVI	A,10		; offset to SYS file attrib bit
	CALL	DIRPTR
	POP	D		; get bit mask from D
	PUSH	D
	ANA	D
	JRNZ	DIR10
	POP	D		; get entry count
	MOV	A,E		; add 1 to it
	INR	E
	PUSH	D		; save it
	CPI	4		; if 5 entries printed send CRLF
	JRC	DIR4
	CALL	CRLF		; crlf
	POP	D		; get counter off stack
	MVI	E,0		; RESET COUNTER
	PUSH	D		; put counter back on stack.
DIR4:
	MVI	A,9		; get a pointer to the first character
	CALL	DIRPTR		; of the filetype on the stack
	PUSH	H		; save the pointer.
	MVI	A,1		; get a pointer to the first character
	CALL	DIRPTR		; of the filename on the stack
	PUSH	H		; save the pointer
	MVI	B,8		; 8 characters in a filename, max.
	MOV	A,B		; pt to last char of filename
	CALL	DIRPTR		; in HL, and get that character.
DIR6:	;search for the last non-space in filename, leaving it in 'B'.
	MOV	A,M		; get character from filename
	ANI	7FH		; mask off bit 7.
	CPI	' '		; test for space
	JRNZ	DIR7		; end loop if not, with Zero reset.
	DCX	H		; decrement pointer
	DJNZ	DIR6		; decrement count in 'B'.
				; if zero, no filename, end loop with Zero set,
				; else continue the loop.
DIR7:	;now, print the filename for the length given in 'B', unless B=0.
	;At this point, Zero flag set if no filename, reset otherwise.
	POP	H		; restore a pointer to the filename.
	CNZ	PRLENB		; print filename with length 'B', if length >0.
	MVI	A,'.'		; add the period.
	CALL	CONOUT		; output it.
	POP	H		; restore a pointer to the filetype.
	MVI	A,11		; eleven spaces
	SUB	B		; minus filename length
	PUSH	PSW		; save spaces to output after filetype.
	MVI	B,3		; filetype is 3 long.
	CALL	PRLENB		; print filetype with length 3.
	POP	B		; number of spaceout to output in 'B', 'B'>0.
DIR8:	;'B' will always be >0.
	CALL	SPACER		; output a space.
	DJNZ	DIR8		; decrement 'B', 0 if done, loop if not done.
DIR10:
	CALL	BREAK		; check for abort
	JRNZ	DIR11
	CALL	SEARN		; search for next file
	JR	DIR3		; continue
DIR11:
	POP	D		; restore stack
	RET
;
; PRLENB:  Subroutine for DIR:	Prints the string at 'HL' for length 'B'.
; Masks off bit 7.  Destroys 'A', Flags, 'HL'.	'B' MUST BE > 0.
;
PRLENB: PUSH	B		;save BC
PRLEN1: MOV	A,M		;fetch character from 'HL'.
	ANI	7FH		;mask bit 7
	CALL	CONOUT		;output the character
	INX	H		;point to next char.
	DJNZ	PRLEN1		;decrement count in 'B', loop if not 0.
	POP	B		;restore length, offset.
	RET			;end
;
;	ERA routine
;
ERA:
	CALL	SCANER		; parse file spec
	CPI	11		; all wild?
	JRNZ	ERA1		; if not, do erases
	CALL	PRINT
	DB	'ALL (Y/N)?',0
	XRA	A		;clear 'print prompt' flag.
	STA	PPROMPT
	CALL	REDBUF
	LXI	H,CBUFF
	DCR	M
	JNZ	RESTRT		; restart CCP if just <CR>
	INX	H
	MOV	A,M
	CPI	'Y'
	JNZ	RESTRT		; no - restart CCP
	INX	H
	SHLD	CIBPTR
ERA1:
	CALL	SLOGIN		; log in selected disk if any
	MVI	A,80H		; skip SYS and R/O files
	CALL	DIRPR		; print DIR of erased files
	LXI	D,FCBDN 	; delete file specified
	CALL	DELETE
	JMP	RSTCCP		; reenter CCP
;
;	LIST routine
;
LIST:
	MVI	A,0FFH		; turn on printer flag
	JR	TYPE0
;
;	TYPE routine
;
TYPE:
	XRA	A		; turn off printer flag
TYPE0:
	STA	PRFLG		; set flag
	CALL	SCANER		; extract file.typ token
	JNZ	ERROR		; error if any '?'
	CALL	SLOGIN		; log in selected disk if any
	CALL	OPENF		; open selected file
	JZ	TYPE4		; abort if error
	CALL	CRLF
	MVI	A,NLINES
	STA	PAGCNT		; set line counter
	LXI	H,CHRCNT	; set char pos/count
	MVI	M,0FFH		; empty line
	MVI	B,0		; set TAB char counter
TYPE1:
	LXI	H,CHRCNT
	MOV	A,M		; end of buffer?
	CPI	80H
	JRC	TYPE2
	PUSH	H		; read next block
	CALL	READF
	POP	H
	JRNZ	TYPE3		; error?
	XRA	A		; reset count
	MOV	M,A
TYPE2:
	INR	M		; inc char count
	LXI	H,TBUFF 	; pt to buffer
	CALL	ADDAH
	MOV	A,M		; get next char
	ANI	7FH		; mask out msb
	CPI	1AH		; EOF?
	JZ	RSTCCP		; yes - restart CCP
	PUSH	PSW		; save char
	LDA	PRFLG		; type or list?
	ORA	A		; 0=type
	JRZ	TYPE2T
;
;	Output char to lst: w/tabulation
;
	POP	PSW		; get char
	CPI	CR		; reset TAB count?
	JRZ	TABRST
	CPI	LF		; reset TAB count?
	JRZ	PAGER
	CPI	FF		; new form ?
	JRZ	PAGSET
	CPI	TAB		; TAB?
	JRZ	LTAB
	CALL	LSTOUT		; list char
	INR	B		; inc char count
	JR	TYPE2L
TABRST:
	CALL	LSTOUT		; output <CR>
	MVI	B,0		; reset TAB counter
	JR	TYPE2L
LTAB:
	MVI	A,' '
	CALL	LSTOUT
	INR	B		; inc pos count
	MOV	A,B
	ANI	7
	JRNZ	LTAB
	JR	TYPE2L
;
;	Send char to con: w/tabulation
;
TYPE2T:
	POP	PSW		 ; get char
	PUSH	PSW
	CALL	CONOUT
	POP	PSW
TYPE2L:
	CALL	BREAK		; check for abort
	JRZ	TYPE1		; cont if no char
	JMP	RSTCCP		; abort if not
TYPE3:
	DCR	A		; no error?
	JZ	RSTCCP
	CALL	PRINT		; print read error msg
	DB	'Read error',0
TYPE4:
	CALL	DLOGIN		; log in default drive
	JMP	ERROR
;
;	Paging routines
;
PAGER:
	LXI	H,PAGCNT	; count down
	DCR	M
	JNZ	TABRST		; reset tab counter
	CALL	LSTOUT		; page boundry
PAGSET:
	MVI	A,NLINES	; get line count
	STA	PAGCNT
	MVI	A,FF		; form feed character
	JR	TABRST
;
;	SAVE routine
;
SAVE:
	CALL	NUMBER		; extract # from cmd line
	PUSH	PSW
	CALL	SCANER		; extract filename.type
	JNZ	ERROR		; must be no '?' in it
	CALL	SLOGIN		; log in selected disk
	LXI	D,FCBDN 	; delete file if it already exists
	PUSH	D
	CALL	DELETE
	POP	D
	CALL	CREATE		; make new file
	JRZ	SAVE3		; error?
	XRA	A		; set rec count field of new file's fCB
	STA	FCBCR
	POP	PSW		; get page count
	MOV	L,A		; HL=page count
	MVI	H,0
	DAD	H		; double it (256 byte pages)
	LXI	D,TPA		; save area
SAVE1:
	MOV	A,H		; done with save?
	ORA	L		; HL=0 if so
	JRZ	SAVE2
	DCX	H		; count down on secs
	PUSH	H		; save ptr to block to save
	LXI	H,128		; 128 bytes per sec
	DAD	D		; pt to next sector
	PUSH	H		; save on stack
	CALL	DMASET
	LXI	D,FCBDN 	; write sector
	CALL	WRITE
	POP	D
	POP	H
	JRNZ	SAVE3		; write error?
	JR	SAVE1		; continue
SAVE2:
	LXI	D,FCBDN 	; close saved file
	CALL	CLOSE
	INR	A		; error?
	JRNZ	SAVE4
SAVE3:
	CALL	PRINT
	DB	'No space',0
SAVE4:
	CALL	DEFDMA		; set DMA to 80h
	JMP	RSTCCP		; restart CCP
;
;	REN routine
;
REN:
	CALL	SCANER		; extract file name
	JNZ	ERROR		; error if any '?'
	LDA	TEMPDR		; save DEFDRV
	PUSH	PSW
	CALL	SLOGIN		; log in selected disk
	CALL	SEARF		; look for specified file
	JRZ	REN0		; cont if not found
	CALL	PRINT
	DB	'File exists',0
	JMP	RENRET
REN0:
	LXI	H,FCBDN 	; save new file name
	LXI	D,FCBDM
	MVI	B,16		; 16 bytes
	CALL	MOVEHD
	LHLD	CIBPTR		; get ptr to next cmd char
	XCHG			; ... in de
	CALL	SBLANK		; skip to non-blank
	CPI	'='
	JRZ	REN1
	CPI	'_'
	JRNZ	REN4
REN1:
	XCHG
	INX	H
	SHLD	CIBPTR		; SAVE ptr to old file name
	CALL	SCANER		; extract filename.typ token
	JRNZ	REN4		; ERROR if any '?'
	POP	PSW		; get old default drive
	MOV	B,A		; save it
	LXI	H,TEMPDR	; comp to curr DEFDRV
	MOV	A,M		; match?
	ORA	A
	JRZ	REN2
	CMP	B		; check for drive error
	MOV	M,B
	JRNZ	REN4
REN2:
	MOV	M,B
	XRA	A
	STA	FCBDN		; set DEFDRV
	LXI	D,FCBDN 	; rename file
	MVI	C,RENAME	; BDOS rename fct
	CALL	BDOS
	INR	A		; error? - file not found if so
	JRNZ	RENRET
REN3:
	CALL	PRNNF		; print no file msg
RENRET:
	JMP	RSTCCP		; restart CCP
REN4:
	CALL	DLOGIN		; log in default drive
	JMP	ERROR
;
;	USER routine
;
MAXUSR	EQU	15		; max user #
USER:
	CALL	NUMBER		; extract user # from cmd line
	CPI	MAXUSR+1	; error if > MAXUSR
	JNC	ERROR
	MOV	E,A		; user # to E
	LDA	FCBFN		; check for parse error
	CPI	' '		; <SP>=error
	JZ	ERROR
	CALL	SETUSR		; set specified user
	JMP	RCCPNL		; restart CCP (no default LOGIN)
;
;	Execute COM routine
;
COM:
	CALL	GETUSR		; get curr user #
	STA	TMPUSR		; save it for later
	STA	TSELUSR 	; temp user to select
	LDA	FCBFN		; any cmd?
	CPI	' '		; <SP> means D: type cmd
	JRNZ	COM1		; not <SP>, must be transient
	LDA	TEMPDR		; look for drive spec
	ORA	A		; if zero, just blank
	JZ	RCCPNL
	DCR	A		; adjust for log in
	PUSH	PSW		; this is so we can recover from
	CALL	LOGIN		; a BDOS error when changing default
	POP	PSW		; drives
	STA	TDRIVE		; set DEFDRV
	CALL	SETU0D		; set drive with user 0
	JMP	RCCPNL		; restart CCP
COM1:
	LDA	FCBFT		; check for error in FCB
	CPI	' '		; error if so
	JNZ	ERROR
;
;	COMA - reenter here for non-STAndard cp/m modification
;	this is the rtn that searchs for .COM files
;
COMA:
	CALL	SLOGIN		; log in specified drive if any
	LXI	H,COMMSG	; place 'COM' in FCB
	LXI	D,FCBFT 	; pt to file type
	CALL	MOVHD3
	CALL	OPENF		; open CMD.COM file
	JRNZ	COMA1		; error?
;
;	Rtn to select default drive if necessary
;
COMA0:
	LXI	H,TEMPDR	; get drive from curr cmd
	XRA	A		; if drive specified on command line, 
	CMP	M		; do not search default drive.
	JRNZ	COM8
	LDA	SYSDRV		; get user specified system drive
	CMP	M		; 1-16, see if it has already
	MOV	M,A		; in FCB
	JRNZ	COMA
;
;	Transient load error
;
COM8:
	CALL	RESETUSR	; reset curr user #
	CALL	DLOGIN		; log in default disk
	JMP	ERROR
;
;	File found - proceed with load
;
COMA1:
	LXI	H,TPA
;
COM2:
	PUSH	H		; save addr of next sec
	XCHG			; ... in de
	CALL	DMASET		; set DMA for load
	LXI	D,FCBDN 	; read next sec
	CALL	READ
	POP	H		; address of this sector now
	JRNZ	COM3		; if error
	LXI	D,128
	DAD	D
	LXI	D,ENTRY 	; start of CCP
	MOV	A,L
	SUB	E
	MOV	A,H
	SBB	D
	JRC	COM2		; otherwise cont
;
;	Load error
;
PRNLE:
	CALL	PRINT
	DB	'Bad Load',0
	JR	RSTCCP
COM3:
	DCR	A
	JRNZ	PRNLE
	CALL	RESETUSR	; reset curr user #
	CALL	DLOGIN		; log in default drive
	CALL	SCANER		; scan for next token
	LXI	H,TEMPDR	; save ptr to drive spec
	PUSH	H
	MOV	A,M		; set drive spec
	STA	FCBDN
	MVI	A,10H		; offset for 2nd file spec
	CALL	SCAN1		; put it into FCBDN+16
	POP	H		; set up drive specs
	MOV	A,M
	STA	FCBDM
	XRA	A
	STA	FCBCR
	LXI	D,TFCB		; copy to default FCB
	LXI	H,FCBDN 	; from FCBDN
	MVI	B,33		; set up default FCB
	CALL	MOVEHD
	LXI	H,CIBUFF
COM4:
	MOV	A,M		; skip to end of 2nd file name
	ORA	A		; end of line?
	JRZ	COM5
	CPI	' '		; end of token?
	JRZ	COM5
	INX	H
	JR	COM4
;
;	Load cmd line into TBUFF
;
COM5:
	MVI	B,0		; set char count
	LXI	D,TBUFF+1	; pt to char pos
COM6:
	MOV	A,M		; copy cmd line to TBUFF
	STAX	D
	ORA	A		; done if zero
	JRZ	COM7
	INR	B		; incr char count
	INX	H		; pt to next
	INX	D
	JR	COM6
;
;	Run transient
;
COM7:
	MOV	A,B		; save char count
	STA	TBUFF
	CALL	CRLF
	CALL	DEFDMA
	CALL	SETUD		; set user/disk
	CALL	TPA		; run it
	CALL	SETU0D		; set user 0/disk
	JMP	RESTRT		; restart CCP
;
;	Reset selected user # if changed
;
RESETUSR:
	LDA	TMPUSR		; get old user #
	MOV	E,A
	JMP	SETUSR		; reset
;
;	File type for cmd
;
COMMSG:
	DB	'COM'
;
;	soft reset command
;
REST:	CALL	RESET
	JR	RCCPNL
;
;	clear screen command
;
CLS:	CALL	PRINT
	DB	27,'E',0
	JR	RCCPNL
;
;	Enter here to restart CCP with LOGIN of DEFDRV
;
RSTCCP:
	CALL	DLOGIN		; log in default drive
;
;	Enter here to restart CCP with no LOGIN
;
RCCPNL:
	CALL	SCANER		; get next token
	LDA	FCBFN		; get 1st char of token
	SUI	' '		; any char?
	LXI	H,TEMPDR
	ORA	M
	JNZ	ERROR
	JMP	RESTRT

RNGSUB:
	DB	0		; 0=SUB not active
SUBFCB:
	DB	0		; disk name
	DB	'$$$     SUB'
	DB	0		; extent #
	DB	0		; S1
SUBFS2:
	DB	0		; S2
SUBFRC:
	DB	0		; rec count
	DB	0,0,0,0,0,0,0,0 ; disk group map
	DB	0,0,0,0,0,0,0,0
SUBFCR:
	DB	0		; curr rec #
;
;  File control block
;
FCBDN:
	DB	0		; disk name
FCBFN:
	DB	0,0,0,0,0,0,0,0 ; file name
FCBFT:
	DB	0,0,0		; file type
	DB	0		; extent #
	DB	0,0		; s1 and s2
	DB	0		; rec count
FCBDM:
	DB	0,0,0,0,0,0,0,0 ; disk group map
	DB	0,0,0,0,0,0,0,0
FCBCR:
	DB	0		; curr rec #
;
;	Other buffers
;
PRFLG:
	DB	0		; 0=no printer
PAGCNT:
	DB	NLINES-2	; lines left on page
IORESL:
	DB	0		; i/o results
TDRIVE:
	DB	1		; temp drive #
TEMPDR:
	DB	0
CHRCNT:
	DB	0		; char count for type
TMPUSR:
	DB	0		; temp user # for COM
TSELUSR:
	DB	0		; temp selected user #

	REPT	(($+0FFH) AND (0FF00H))-$-1
	  DB	0FFH
	ENDM

SYSDRV: DB	0

	END
