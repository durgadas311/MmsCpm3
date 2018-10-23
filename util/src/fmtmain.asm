vers equ '6 ' ; Reconstructed Oct 22, 2018  21:30  drm  "FMTMAIN.ASM" 

;
; Format main routines
;
; Link commmand: LINK FORMAT=FMTMAIN,FMTZ89 or FMT500,FMTDISP,FMTTBL[NC,NR]
;  Note: FMTMAIN must be linked first and FMTTBL last.
;

	public	phydrv,vsectb,sid,trk,modes,mfm,stepr,wdflag,curmdl

	extrn	setjmp,inithd,intoff,inton,table,buffer,str
	extrn	ctrlio,comnd,writt,rdcom,dskxit,getst
	extrn	restor,stepin,writrk,rdadr
	extrn	std8,z47d,vskstd
	extrn	getchr,putchr,putlne,getlne
	extrn	clrscr,clrend,clrlne,curact,curoff,cursor,prtmsg

	MACLIB Z80
	$-MACRO

false	equ	000h
true	equ	0FFh
ff	equ	0ffh

base	equ	0
cpm	equ	base
bdos	equ	base+5
dma	equ	base+80H

@intby	equ	100		; BIOS entry points
lptbl	equ	101
thread	equ	103
?serdp	equ	105
stroff	equ	12		; string address offset from init rout of mod
modtbl	equ	16		; mode byte table offset from init rout of mod

resdsk	equ	1		; BIOS function numbers
bconst	equ	2
bconin	equ	3
conout	equ	4
home	equ	8
seldsk	equ	9
settrk	equ	10
setsec	equ	11
setdma	equ	12
reads	equ	13
writes	equ	14
sectrn	equ	16
search	equ	90	      

conin	equ	1		; BDOS function numbers
conot	equ	2
msgout	equ	9
linein	equ	10
getver	equ	12
getdsk	equ	25
restt	equ	37
seterr	equ	45
cbios	equ	50
sdirlab equ	100
setcmod equ	109

; error codes

initerrcd	equ	0	; can not initialize directory
setlabcd	equ	1	; can not set directory label
wrtprocd	equ	2	; write protected disk
notrdycd	equ	3	; drive not ready
hrdsectcd	equ	4	; hard sector media in soft sector controller
z17sftcd	equ	5	; soft sector media in hard sector controller
notsupcd	equ	6	; format not supported error
badportcd	equ	7	; bad port address for z67/z47
dterrcd 	equ	8	; 96/48 tpi mismatch
trk0ercd	equ	9	; can not find track zero
dserrcd 	equ	10	; double sided error
drverrcd	equ	11	; invalid drive
wterrcd 	equ	12	; error during step/format
wmerrcd 	equ	13	; can not write Zenith's marker 

brl	equ	2		; base message line
drvl	equ	3		; get drive message line
crl	equ	4		; CONTROLLER ID MESSAGE LINE
drl	equ	3		; LINE OF DRIVE MESSAGE
rdl	equ	5		; LINE OF RECORDING DENSITY
sil	equ	6		; LINE FOR SIDE
tpl	equ	7		; TRACKS-PER-INCH MESSAGE LINE
srl	equ	8		; LINE FOR STEP RATE
fsl	equ	9		; FORMAT SOURCE LINE
prl	equ	11		; PROMPT LINE
bgl	equ	13		; FIRST LINE USED BY BAR GRAPH
erl	equ	19		; ERROR MESSAGE LINE
mfc	equ	20		; COLUMN OF MODE FORMAT DISPLAY

srm0:	equ	10000011b
srm1:	equ	00011100b ; search mode masks

esc	equ	27
cr	equ	13
lf	equ	10
bell	equ	7
bs	equ	8
ctrlC	equ	3
ctrlD	equ	4

	cseg

	jmp	start

signon1:
	db	'FORMAT $'
; string here, from hardware module.
signon2:
	db	' v3.10'
	dw	vers
	db	' (c) 1983 Magnolia Microsystems$'

vererr: lspd	save$stack
	lxi	d,errver
errt:	jmp	putlne

nogetdp:
	lspd	save$stack
	lxi	d,nodper
	jr	errt

start:
	sspd	save$stack	; store stack pointer
	lxi	sp,stack
;
	call	prt$signon
;
	mvi	c,getver
	call	bdos
	mov	a,h
	cpi	1	;can't run MP/M
	jz	vererr
	mov	a,l
	cpi	31h
	jc	vererr		; must be CP/M 3.1 or later.
	lhld	cpm+1
	lxi	b,?serdp-3	; Check if GETDP is linked in
	dad	b
	call	hlihl
	lded	cpm+1
	xra	a		; clear A and [cy]
	mov	e,a
	dsbc	d
	jz	nogetdp
	mvi	e,0ffh		; set error mode to return on error
	mvi	c,seterr
	call	bdos
	mvi	c,getdsk	; GET DURRENTLY LOGGED IN DISK
	call	bdos
	sta	logdsk
	lxi	h,dma		; check command tail buffer for drive name
	mov	a,m
	ora	a
	jz	nodsk		; print help msg
entry0: shld	cmdptr
	call	get$drive	; check for drive name and select it
	jnz	new$drive
	jc	error		; error if drive does not exist
entry1: call	setjmp		; Set hardware dependent jump vector
	jc	error
	lxi	h,orgmode
	lxi	d,modes
	lxi	b,4
	ldir
	lda	modes+2 	; Make media tpi same as drive tpi
	ani	0010$0000b
	mov	l,a
	lda	modes+3
	ani	1101$1111b
	ora	l
	sta	modes+3
entry2: call	parse
	jnc	parm
	lxi	d,invp
	jmp	err$parm
parm:	call	show
	lxi	h,prl
	call	cursor
	call	clrend
	lxi	h,prl
	lxi	d,askok 	; IS THIS CORRECT? (Y/N)
	call	prtmsg
	mvi	c,1		; GET RESPONSE
	call	bdos
	ani	0DFh		; MAKE CAPITAL
	cpi	'Y'
	jz	got$parm	; IF 'Y', RETURN
	cpi	cr		; DEFAULT IS 'Y'
	jz	got$parm
	cpi	ctrlC		; ^C
	jz	exit
	jmp	new$parm	; user wants to change params
got$parm:

; From this point on, any possible exit from this program must restore
; the DPB and MODES to the system.
	call	start$dsk
err$over:
	call	setup
	jc	error 
next$dsk:
	lxi	h,prl
	lxi	d,prmt
	call	prtmsg		; prompt to insert a disk...
	call	getchr
	cpi	ctrlD
	jz	new$fix 	; restore system DPs and prompt for new drive
	cpi	cr
	jnz	exit$fix	; anything except CR exits to CP/M
	lxi	h,prl+1
	call	cursor
	call	clrend
	call	inithd		; initialize hardware dependent varibles,etc.
	call	image$t0s0	;
	call	restor		; restore drive
	call	getst		; check for drive ready, track zero, etc.
	rlc			; (A) = status from 1797
	jc	not$rdy 	; check for drive ready
	rlc
	jc	wrt$pro 	; check for write-protected disk
	ani	00010000b
	jz	trk0err 	; verify that we made it to track 0
	call	testdt		; do double track test
	jc	error
continue:			; entry from dt error if Ignore option
	call	format
	jc	error
	call	verify
	jc	error
	call	curact		; turn cursor back on
	call	display$count	; display disk count
	lxi	h,22
	lxi	d,mormed
	call	prtmsg		; ask if more media to format
	call	getchr
	ani	0DFH		; make response capital
	cpi	'Y'
	jz	next$dsk
	cpi	cr
	jnz	exit$fix	; if not Y or CR, quit
	jmp	next$dsk	; prompt for another disk(but don't do DT test)

;
;	Gets new parmeters and/or drive from console
;	D reg = error msg to be printed
;

err$parm:
	lxi	h,prl
	call	cursor
	call	clrend
	lxi	h,prl
	call	prtmsg
	jr	new$parm2

new$parm:
	lxi	h,prl
	call	cursor
	call	clrend
new$parm2:
	lxi	h,prl+1
	lxi	d,parprm
	call	prtmsg
	lxi	h,prl+3
	lxi	d,valid
	call	prtmsg		; show valid parmeters
	lxi	h,256*33+PRL+1	; restore cursor
	call	cursor
	lxi	d,line
	call	getlne		; linein, W/OUT ^C reboot
	lxi	h,line+2
	mov	a,m
	cpi	ctrlC
	jz	exit		; exit on ctrl-C
	dcx	h
	shld	cmdptr
	call	get$drive	; sets SYSDPB/ORGMODES
	jnz	entry2		; if no drive in parms, use old mode bytes
	lxi	d,dr$err
	jc	err$parm	; if error display message and repeat new$parm
	jmp	entry1		; if a drive letter in line, copy orig modes

;
;	Output help message and exit
;

nodsk:	lxi	d,help
	call	putlne
	lxi	d,thisut	; other info
	call	putlne
	call	getchr
	cpi	ctrlC		; ^C
	jz	exit		; reboot on ^C
	call	prt$signon
	jmp	new$drive

;
;	Error routines -  
;	 A reg contains the error code
;

error:
	slar	a		;double A
	lxi	h,errtbl
	mov	e,a
	mvi	d,0
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

errtbl: dw	initer		;0
	dw	setlaber	;1
	dw	wrt$pro 	;2
	dw	not$rdy 	;3
	dw	hrd$sect	;4
	dw	z17$sft 	;5
	dw	not$sup 	;6
	dw	bad$port	;7
	dw	dterr		;8
	dw	trk0err 	;9 
	dw	dserr		;10
	dw	drv$err 	;11
	dw	wterr0		;12
	dw	wmer		;13

initer:
	lxi	d,initerr
	jmp	errms

setlaber:
	lxi	d,slaberr
	jmp	errms

wmer:
	lxi	d,wmerr
	jmp	errms

wrt$pro:
	lxi	d,wr$pt 	; disk is write-protected
	jmp	errms

not$rdy:
	lxi	d,nt$rd 	; drive is not ready (disk not in drive)
	jmp	errms

hrd$sect:
	lxi	d,h$sec
	jmp	errms

z17sft: lxi	d,s$z17
	jmp	errms

wterr0: lxi	d,wterr
	jmp	errms

trk0err:
	lxi	d,hm$err	; error: track zero not found

errms:	call	curact		; turn on cursor
	lxi	h,erl
	call	prtmsg
	call	dskxit
	jmp	err$over

notsup: lxi	d,nosup
	jmp	err$fix 	; ask for correct format

badport:
	lxi	d,badprt
	jmp	err$drive

drv$err:
	lxi	d,dr$err
	jmp	err$drive

dterr:
	lhld	modes+2
	bit	5,h		; test track bit
	lxi	h,'48'		; assume requested 48tpi
	lxi	d,'96'		; but drive was 96 tpi
	jrz	q1
	xchg			; if not, request was 96, etc.
q1:	mov	b,h
	mov	c,l
	lxi	h,gap1		;point to "requested" field
	mov	m,c		;put tpi in message
	inx	h
	mov	m,b
	lxi	h,gap2		;point to "drive was" field
	mov	m,e
	inx	h
	mov	m,d		; move alternate track density
	lxi	h,prl
	lxi	d,dter
	call	prtmsg
	call	clrlne		; clear rest of line
	call	dskxit
	call	getchr		; get user response
	cpi	ctrlC
	jz	exit$fix 
	ani	0DFh		; make capital
	cpi	'I'
	jz	continue	
	call	done$dsk	; fix module
	lxi	h,prl+2
	jmp	new$drive2

dserr:
	lxi	d,dser

err$fix:			; fix module, print error and get new drive
	push	d		 
	call	dskxit		; hardware disk exit
	call	done$dsk
	pop	d
err$drive:			; print error and get new drive and parms
	lxi	h,brl
	call	cursor
	call	clrend
	lxi	h,drvl-1
	call	prtmsg
	lxi	h,drvl
	jr	newdrive2

new$fix:			; fixes module and mode bytes
	call	dskxit
	call	done$dsk
new$drive:			; get a new drive letter
	lxi	h,brl
	call	cursor
	call	clrend
	lxi	h,drvl
new$drive2:
	lxi	d,ndsk		; prompt for user to enter drive name
	call	prtmsg
	call	curact		; turn cursor on
	lxi	d,line
	call	getlne
	lxi	h,line+2
	mov	a,m
	cpi	ctrlC
	jz	exit
	dcx	h
	jmp	entry0

;
;	Exits to the program
;

exit$fix:
	call	done$dsk	; fix what start$dsk did
exit:	
	lxi	h,22		; position cursor to 23rd line
	call	cursor
	call	curact		; turn cursor on
	lda	logdsk		; re-select LOGIN drive
	mov	c,a
	mvi	e,0
	mvi	a,seldsk
	call	biosc
;
	jmp	cpm		; return to system


*******************************************************************************
; Subroutines 
*******************************************************************************

prt$signon:
	call	clrscr
	lxi	d,signon1
	call	putlne
	lxi	d,str
	call	putlne
	lxi	d,signon2
	call	putlne
	ret
       
;
; GET$DRIVE:  parses command line for optional drive name. returns:
;    [NZ] if no drive name was specified
;    [CY] if the specified drive was invalid (not in system)
;

get$drive:
	lhld	cmdptr
	mov	b,m
	inx	h
skp:	call	xchar		; SKIP OVER SPACES
	jm	nzcy
	cpi	' '
	jz	skp
	cpi	'A'		; ERROR IF NOT A-P
	jc	nzcy
	cpi	'P'+1
	jnc	nzcy
	mov	c,a
	call	xchar
	jm	nzcy
	cpi	':'		; ERROR IF NO ":"
	jnz	nzcy
	mov	a,c
	dcx	h
	mov	m,b
	shld	cmdptr
	sta	tdrv
	sui	'A'
	mov	c,a
	lhld	cpm+1		; LOOK UP PHYSICAL DRIVE NUMBER
	lxi	d,lptbl-3	;  IN LOGICAL/PHYSICAL TABLE
	dad	d
	call	hlihl
	mov	e,c
	mvi	d,0
	dad	d
	mov	a,m
	sta	tphy	       ; GOT PHYSICAL DRIVE NUMBER
	cpi	0ffh
	jz	zrcy
	mov	c,a
	lhld	cpm+1		; call search routine
	lxi	d,search-3
	dad	d
	call	icall		; returns module address
	jc	zrcy		; and relative drive number
	mov	c,a		; save reldrv in C
	push	h		; save curmdl
	lxi	d,modtbl	 
	dad	d
	call	hlihl		; get address of mode byte table
	add	a
	add	a
	add	a
	mov	e,a
	mvi	d,0
	dad	d		; index relative drive
	bit	7,m		; check for hard disk flag
	pop	d		; restore curmdl to D
	jnz	zrcy
	shld	modptr
	mov	a,c		; store reldrv
	sta	reldrv		 
	sded	curmdl
	lda	tphy
	sta	phydrv
	lda	tdrv
	sta	drive
	lxi	d,orgmode
	lxi	b,4
	ldir
	xra	a 
	ret

nzcy:	xra	a		; No drive specfied exit
	inr	a
	stc
	ret

zrcy:	xra	a		; Invalid drive exit
	mvi	a,drverrcd
	stc
	ret

hlihl:	push	psw
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	pop	psw
	ret

icall:	pchl

;
; Parse command line for mode info, if present.  Enter with current mode
; value in MODES, pointer to command string in CMDPTR
;

PARSE:
	MVI	A,FALSE
	STA	TRCK
	STA	SDE
	STA	DENSITY
	STA	CNFIG
	STA	STEPRT
	LDA	VFLAG0
	STA	VFLAG
	LXI	H,MODES
	LXI	D,TMODE
	LXI	B,4
	LDIR
	LHLD	CMDPTR		; number of characters input
	MOV	C,M
	INX	H
	MVI	B,0
	DAD	B
	MVI	M,0
	MOV	A,C
	ORA	A
	JZ	NOCOMD
	LHLD	CMDPTR
SKPBL:	INX	H
NXOPT:	CALL	CHAR		; get a character for the loop
	CPI	' '
	JZ	SKPBL
	CPI	','
	JZ	SKPBL
	CPI	'D'		; check for 'D' command
	JZ	DPROC
	CPI	'S'		; check for step rate
	JZ	STEP
	CPI	'N'		; check of nv, ns, or ni options
	JZ	N$opts
	push	h	
	call	serdp	
	push	h
	popix		; ix = address of format string table
	pop	h	; hl = buffer pointer
	MVI	C,0	; c = format bit number counter
CONFIG: mvi	b,8	; b = length of entry in format string table
	PUSH	h
	mov	a,c
	CPI	15	; if c = 15 then end of table
	jz	nochg	;NMEMONIC NOT FOUND
fig0:	ldx	d,+0
	call	char	; get char from buffer and make upper case
	CMP	d	; compare with serdp table
	JNZ	FIG1
	INX	H
	inxix
	dcr	b
	jz	fig5
	ldx	a,+0	; see if end of format table
	CPI	' '
	JNZ	FIG0
fig5:	call	char
	ORA	A
	JZ	FIG2
	CPI	','
	JZ	FIG2
	CPI	' '
	JNZ	FIG1
FIG2:	POP	d	;DISCARD OLD BUFFER POINTER
	LDA	CNFIG
	ORA	A	;IS THIS THE SECOND ENTRY OF THIS TYPE?
	JNZ	BADCMD	;ERROR IF IT IS.
	MOV	A,C
	ADI	'0'
	STA	CNFIG
	JMP	MORE

FIG1:	inxix		;go to end of format string table
	djnz	FIG1
FIN3:	pop	h
	inr	c		; and increment the entry counter
	jmp	config

SPROC:	
DPROC:	CALL	CHAR
	MOV	C,A
	INX	H		; save SINGLE or DOUBLE
	CALL	CHAR		; get the character
	INX	H
	ORA	A
	JZ	BADCMD
	CPI	'T'
	JZ	TRK000
	CPI	'D'
	JZ	DNS
	CPI	'S'
	JNZ	BADCMD
	MOV	A,C		; get the argument
	STA	SDE
	JMP	MORE
DNS:	MOV	A,C		; get the argument
	STA	DENSITY
	JMP	MORE
TRK000: MOV	A,C
	STA	TRCK
	JMP	MORE

STEP:	INX	H
	CALL	CHAR		; test next argument
	DCX	H
	CPI	'0'		; must be numeric
	JC	BADCMD		; ERROR IF < '0'
	CPI	'9'+1
	JNC	SPROC		;TRY 'SINGLE'
	INX	H
	INX	H
	SUI	'0'		; make it numeric
	MOV	C,A		; and save it
	CALL	CHAR	;test next, it must be a number, a comma, or null
	ORA	A		; we accept spaces also
	JZ	SOK
	CPI	','
	JZ	SOK
	CPI	' '
	JZ	SOK
	CPI	'0'
	JC	BADCMD
	CPI	'9'+1
	JNC	BADCMD
	INX	H
	SUI	'0'		; numeric, make it binary
	MOV	E,A		; and save it
	MOV	A,C		; get first number
	ADD	A
	ADD	A
	ADD	C
	ADD	A		; TIMES 10
	ADD	E		; plus second number
	MOV	C,A		; expected in C
SOK:	MOV	A,C		; get step rate
	STA	STEPRT		; and save it
	JMP	MORE

N$opts: INX	H		; FIRST CHARACTER IS 'N'
	CALL	CHAR		; GET NEXT CHARACTER
	INX	H
	cpi	'I'		; turn off directory initialization
	jrnz	not$I		; and set label
inoff:	mvi	a,0ffh
	sta	initflg
	jr	more
not$I:	cpi	'S'		; turn off directory initialization
	jrz	inoff
not$S:	CPI	'V'		; NEXT CHARACTER MUST BE A 'V'
	JNZ	BADCMD
	MVI	A,FALSE 	; SET VERIFICATION FLAG TO FALSE
	STA	VFLAG

MORE:	CALL	CHAR		; point to next character and get it
	INX	H
	CPI	','		; continue if a comma
	JZ	NXOPT
	CPI	' '		; or a space
	JZ	NXOPT
	ORA	A		; if a null, it's OK too
	JNZ	BADCMD		; if not, it's an error
;
;	update the present mode value
;
	lxix	tmode
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
	LDA	sde		; see if side was specified
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
BIT4:	LDA	trck 
	ORA	A
	JZ	BIT5
	cpi	'S'
	jrz	sst 
	setx	5,+3	;
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
nocomd: call	serdp
	ORA	A
	JNZ	badcmd		; error if non-zero (NO DPB FOUND)
	sbcd	sectbl		; save x-late table pointer
	sded	sysdpb		; save dpb pointer
	LHLD	MODPTR		; check if mode-mask prevent user's selection
	INX	H
	INX	H
	INX	H
	inx	h
	XCHG			;DE = mode byte mask pointer
	LXI	H,TMODE
	LXI	B,MODES
	MVI	A,4	;NUMBER OF MODE BYTES
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
	LXI	H,TMODE
	LXI	D,MODES
	LXI	B,4
	LDIR
	XRA	A
	RET			; and return

NOCHG:	POP	PSW
BADCMD: XRA	A
	INR	A		; set [NZ] flag
	STC
	RET	;[NZ] [CY] IF ERROR
 

serdp	LXI	D,tmode 	; MODE BYTE POINTER TO DE
	LHLD	CPM+1		; call serdp
	LXI	B,?SERDP-3
	DAD	B		; POINTER TO SERDP CALL ADDRESS
	CALL	HLIHL		; GET CALL ADDRESS
	push	h
	CALL	ICALL		; CALL "GETDP" TO FIND A DPB FOR THIS MODE
	xchg			; hl <> de  table offset to de - dpb ptr to hl
	xthl			; hl <> tos dpb ptr to tos - serdp addr to hl
	dad	d		; format string table - add serdp addr & offset
	pop	d		; restore de to dpb pointer
	ret		

;
;	Gets a character from the buffer and points to next character
;

xchar:	call	char
	inx	h
	dcr	b
	ret

;
;	Gets a character from the buffer and makes upper case
;

char:	mov	a,m		; remove a character from buffer
	cpi	'a'
	rc
	cpi	'z'+1
	rnc
	sui	'a'-'A'
	ret

;
;	output the mode data to the CRT
;

SHOW:	
	lxi	h,brl		; clear rest of screen
	call	cursor
	call	clrend
	lxi	h,brl
	lxi	d,basmsg	; POSITION THE MODE INFO
	call	prtmsg
	LDA	PHYDRV		;  get physical drive number
	LXI	B,0		;  tens counter in C and ones in B
MORTEN: INR	C
	SUI	10
	JZ	GOTNUM
	JP	MORTEN
	DCR	C
	ADI	10
	MOV	B,A
GOTNUM: LXI	H,'00'		;  numeric offset to ASCII
	DAD	B
	MOV	A,L		;  tens digit
	CPI	'0'		;  check for zero
	JNZ	NOZE
	MVI	A,' '		;  if so, replace with a space
NOZE:	MOV	L,A
	SHLD	DSKNM
	LDA	DRIVE		;  get drive letter
	lxi	d,dsklt
	stax	d		;  put in string
	lxi	h,mfc*256+drl
	call	prtmsg
	LXIX	MODES
	BITX	7,+2		;  size, 0=5" and 1=8"
	LXI	D,INCH5
	JZ	PRINCH
	LXI	D,INCH8
PRINCH: call	putlne
	call	getstr
	lxi	h,mfc*256+crl
	call	prtmsg
	BITX	6,+3		;  check the side bit
	JZ	SS		;  single sided if zero
	LXI	D,DSMSG 	;  double sided drive message
	JMP	DDS
SS:	LXI	D,SSMSG 	;  single sided drive message
DDS:	lxi	h,mfc*256+sil
	call	prtmsg
	BITX	4,+3
	JZ	SD		;  single density if zero
	LXI	D,DDMSG 	;  double density drive message
	JMP	DD
SD:	LXI	D,SDMSG 	;  single density drive message
DD:	lxi	h,mfc*256+rdl
	call	prtmsg
	BITX	5,+3		;  mask out track density
	JZ	T48		;  48 tpi if zero
	LXI	D,T96MSG	; 96 tpi message
	JMP	HTRK
T48:	LXI	D,T48MSG	; 48 tpi message
HTRK:	lxi	h,mfc*256+tpl
	call	prtmsg
	call	setcn		;  handle configuration
	ldx	a,+2		;  GET STEPRATE BYTE
	ani	00001100B
	rrc
	rrc			; move steprate bits down
	bitx	7,+2
	jz	sr5
	ori	00000100b	; or in 8" bit
sr5:	LXI	H,STRTBL	; step rate table
	ADD	A		;  two bytes per entry
	MOV	E,A
	MVI	D,0		;  16 bit value for offset
	DAD	D
	MOV	E,M		;  first byte of step rate
	INX	H
	MOV	D,M		;  and the second
	XCHG
	SHLD	STRATE		;  save text in message
	LXI	D,STRATE	; step rate message
	LDAX	D
	CPI	' '		;  skip a character if a space
	JNZ	NSPC
	INX	D
NSPC:	lxi	h,mfc*256+srl
	call	prtmsg
	ret

SETCN:	lxi	h,mfc*256+fsl
	call	cursor
	lxi	h,modes 	; get pointer to format origin bytes
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
fmt3:	mov	a,m	; got format string - now print 8 characters
	call	putchr	
	inx	h
	djnz	fmt3
	ret

getstr: 
	lhld	curmdl
	lxi	d,stroff	; address text string offset
	dad	d
	mov	e,m		; move to de
	inx	h
	mov	d,m
	ret

;
;	This routine modifies the driver module so that the login function
;	is not called. It also copys the new mode bytes into the system.
;	Done$dsk undos what this routine did.
;

start$dsk:
	lxi	h,modes
	lded	modptr
	lxi	b,4
	ldir
	lhld	curmdl		; go into driver
	lxi	b,3
	dad	b		; POINT TO JUMP TO LOGIN ROUTINE
	mvi	a,0afh		; code for "XRA A"
	mov	m,a		; overlay "JMP" instruction
	inx	h		;  so that LOGIN never gets called
	mov	a,m		; byte to be saved
	sta	savbyte
	mvi	a,0c9h		; code for "RET"
	mov	m,a
	lda	drive
	sui	'A'		; logical drive number
	mov	c,a
	mvi	e,0		; flag drive not logged in
	mvi	a,seldsk	; select the disk (this will put dpb address
	call	biosc		;  into dph)
	ret

setup:
	xra	a
	sta	dsflag
	lhld	sysdpb		; get DPB address
	mov	a,m		; get the number of sectors per track
	sta	spt0		; must be changed if mode is changed
	lxi	d,dpb
	lxi	b,15
	ldir			; copy DPB into local area
	lhld	modes+2 	; get corrected mode value
	mvi	c,0
	bit	4,h	;DD BIT
	jz	nodd
	setb	1,c	;SET DOUBLE DENSITY
nodd:	bit	6,h	;DS BIT
	jz	nods
	setb	0,c	;SET DOUBLE SIDED
nods:	bit	5,h
	jz	nodt
	setb	3,c
nodt:	lxix	modes
	bitx	0,+0		; see if z100
	jrz	no$z100
	mvi	a,00100100b	; mark as z100 (z207 controller)
	jr	markfmt
no$z100 bitx	5,+1
	jrz	no$z47
	mvi	a,10000000b	; mark as z47
	jr	markfmt
no$z47: bitx	6,+1
	jrz	no$z47x
	mvi	a,10000100b	; mark as z47x
	jr	markfmt
no$z47x bitx	7,+1
	jrz	no$z67
	mvi	a,11000000b	; mark as z67
	jr	markfmt
no$z67: bitx	3,+1
	jrz	no$z37		; no valid format
	MVI	A,01100000B	; mark as Z37 type disk
	jr	markfmt
no$z37: bitx	4,+1		; test for z37 extended
	jrz	markfmt
	mvi	a,01100100b	; mark as z37 extended
markfmt ORA	C
	STA	Z37MODE
	MOV	A,h
	ANI	01000000B	; determine how many sides to format
	RLC
	RLC
	STA	SIDES
	MOV	A,l
	ANI	00001100B	; get the steprate for this drive
	rrc
	rrc
	STA	STEPR
	LDA	SPT0		; convert SPT to physical, if neccessary
	MOV	B,A
	MOV	A,L
	ANI	00000011B	; sector size code (0,1,2,3)
	STA	SZ
	INR	A
ST0:	DCR	A
	JZ	SD80
	SRLR	B		; shift SPT down to physical equivilent.
	JMP	ST0
SD80:	MOV	A,B
	STA	SPT
	LXI	D,(77)+(77)*256 ; determine the number of tracks on the drive.
	BIT	7,l		; (E = tracks on 1st side, D = tracks on 2nd)
	JNZ	GOTT		; 8" DT is not supported.
	LXI	D,(40)+(40)*256
	LDA	MODES+1 	; check ORG for "Z17"
	CPI	00000010B
	JNZ	NZ17
	MVI	D,(36)		; only 36 tracks on second side of Z17 disk
NZ17:	BIT	5,L		; check DT bit
	JZ	GOTT
	SLAR	E		; twice as many tracks if double track density.
	SLAR	D
GOTT:	SDED	TRKS
	LDA	MODES+1
	CPI	00000001B	; IF IT'S AN MMS FORMAT
	JNZ	NMMS
	bit	7,l
	jz	nmms
	bit	4,h
	jz	nmms
	lda	phydrv		;  THEN Z47/M47 CONTROLLER CANNOT FORMAT IT.
	sui	5
	cpi	4
	mvi	a,notsupcd
	jc	exit$setup
nmms:	lda	wd$flag
	ora	a
	jz	not$wd		;SKIP search IF NOT 1797-TYPE FORMATTER
	call	search$table	; searches table for 1797 track format entry
	jc	exit$setup	; jmp to exit if format not supported
not$wd:
	lda	modes+2
	ani	10000000B	; 8" bit
	mvi	a,true
	sta	dsflag		; allow test for DS error.
	lda	dtflag0
	jrz	fivnch		; disallow test for DT if 8" drive
	mvi	a,false
fivnch: 
	sta	dtflag
	ora	a		; clear [CY]
exit$setup:			; returns [CY] if error
	ret


;
;	Searches format table 
;

search$table:			;searches table for format and dd type
	lxi	h,modes  
	mov	c,m		;no need to mask format origin code.
	inx	h
	mov	b,m
	inx	h
	mov	a,m		; get first mode byte
	ani	srm0		; mask FIRST BYTE
	mov	e,a    
	inx	h		; and point to the second
	mov	a,m
	ani	srm1		; mask SECOND BYTE
	mov	d,a
	lxi	h,table 	; table lookup...
nxtxt:
	mov	a,m		; format origin code.
	inx	h
	ana	c	;compare it: if the format requested matches
	jrnz	got1	    ;(if the bit is set in both DPB and requested
	mov	a,m	    ; mode ([NZ] condition) then we have a match.)
	ana	b		;check for possible extend format origin
	jrz	nxd1	;...
got1:	inx	h
	mov	a,m		; get first byte
	inx	h
	ani	srm0		;mask it also
	cmp	e		;compare to target mode
	jrnz	nxd3
	mov	a,m		; and the second
	ani	srm1		;mask it
	cmp	d		;compare it
	jrnz	nxd3
	lda	modes+3 	; we don't format double sided/single density
	ani	01010000b		     
	cpi	01000000b
	jz	errout
	bit	7,m		; check confg bit in table
	jrz	no$cfg
	mvi	a,true
	jr	c1
no$cfg: mvi	a,false
c1:	sta	cflg
	inx	h
	mov	a,m	;pick up format table
	inx	h
	mov	h,m
	mov	l,a
	shld	xtable		
	lxi	d,6	;pick verify sector table
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	shld	vsectb
	ora	a	;clear [CY]
	jr	search$exit
nxd1:	inx	h
nxd2:	inx	h
nxd3:	inx	h
	inx	h
	inx	h
	mov	a,m
	cpi	11111111b
	jrnz	nxtxt		; loop if more entries in table
errout: mvi	a,notsupcd
	stc
search$exit:
	ret

;
;	Tests drives for incorrect drive/media requests tpi mismatch
;	       Assumes drive has been restored already
;

testdt: 			
	lda	dtflag		; if zero don't do the test
	ora	a
	jz	testdt2
	xra	a
	sta	dtflag		; prevent further tests until something changes
	mvi	e,47		; step in 47 tracks (will only go about 45 if
stin0:	mvi	a,01001011B	; drive is 48 tpi).
	call	comnd		; step-in
	dcr	e
	jnz	stin0
	mvi	e,46		; step out 46 tracks (on 96 tpi drive head will
stot0:	mvi	a,01101011B	; not get back to track 00).
	call	comnd		; step-out
	dcr	e
	jnz	stot0		; (A) = status, check TR00 bit.
	xri	00000100B	; make [ZR] for 48 tpi (std DT bit)
	rlc			; put bit in same position as system DT bit
	rlc
	rlc
	lhld	modes+2
	xra	l		; test if DT mode is diff from actual drive...
	ani	00100000B	; ignore other bits - returns [CY] if tpi error
	jz	testdt1
	mvi	a,dterrcd	 
	stc
	jr	testdt2
testdt1:
	call	restor		; restore drive for format
	ora	a		; clear [CY]
testdt2:
	ret

;
;  This section the actual formatting of each track
;

format:
	call	image$t0s0	; set up trk0 side 0 image & set up controller 
	lda	trks		; move base values to temp variable space
	sta	trks1
	xra	a
	sta	trk		; track = 0
	sta	sid		; side = 0
	call	bargraph	; setup display of tracks formatted
	call	fmtprog
	call	sec$header	; format trk0 side 0 
	call	trk$write
	jc	fmterr
	lda	sides
	ora	a
	jrz	fmt$ss
	call	nxt$side
	call	image$t0s1	; format trk0 side 1
	call	fmtprog
	call	sec$header
	call	trk$write
	jc	fmterr
	lda	dsflag		; ds test
	ora	a
	jz	no$dstest
	call	testds
	jc	fmterr
no$dstest:
	call	nxt$side
fmt$ss: call	nxt$trk
	jc	fmterr
	call	image$trk	; set up buffer for rest of disk
trk$loop:
	call	fmtprog
	call	sec$header
	call	trk$write
	jc	fmterr
	lda	sides		; if double sided switch sides and format
	ora	a
	cnz	nxt$side
	jrnz	trk$loop	; if side 1 ([Z]=0) do loop again
	call	nxt$trk
	jc	fmterr
	jz	trk$loop 
	ora	a		; clear [CY]
	ret
fmterr:
	stc			; set [CY] for error
	ret

;
;	This routine puts the sector headers in the buffer
;

sec$header:		 
	lda	wd$flag
	ora	a
	rz
	lda	spt		; setup registers to update track-side fields
	lbcd	trk
	lded	bias 
	lhld	first$trk
fill$num:
	mov	m,c		; put track and side number in sector header
	inx	h
	mov	m,b
	dad	d		; step to next sector field
	dcr	a		; count sectors
	jnz	fill$num	; continue if more sectors to fill
	ret

;
;	This routines writes the buffer out
;

trk$write:
	call	intoff		;TURN SPECIFIC INTERUPTS OFF
	lxi	h,buffer	; point to track buffer for data source
	call	writrk		; write a track to disk
	sta	dskst
	push	psw		; save CARRY bit
	push	h		; save address of last byte written
	call	inton		;TURN INTERUPTS ON AGAIN
	pop	h
	pop	psw		;restore carry bit
	jc	err1		;error: soft-sector media in hard-sector ctrlr.
	lxi	d,buffer
	ora	a
	dsbc	d		; calculate number of bytes written
	lxi	d,2000		; compare to 2000
	ora	a
	dsbc	d		; if less than 2000,
	jc	err2		; must be 10-sector disk on soft-sector ctrlr.
	mvi	a,146		; 1000 microsecond delay:
dly:	dcr	a		; The tunnel erase is active for up
				; to 500 microseconds
	jnz	dly		; after write-gate is turned off.
	lda	dskst		; check status of write-track command
	ora	a		; clear [CY]
	rz
	mov	c,a
	lda	dsflag		; HAS DOUBLE SIDED TEST BEEN DONE YET ?
	ora	a
	mov	a,c
	jz	ndserr
	lda	sid		; IF IT HASN'T AND WE ARE ON SIDE 1,
	ora	a		;  THEN TREAT AS IF NO ERROR
	mov	a,c		;  SO THAT DOUBLE SIDED TEST WILL BE DONE
	rnz	
ndserr: rlc
	jnc	noerr1		; NOT READY ERROR
	mvi	a,notrdycd
	jr	wrterr
noerr1: rlc
	jnc	err0		; WRITE PROTECT ERROR
	mvi	a,wrtprocd
	jr	wrterr
err0:	mvi	a,wterrcd
	jr	wrterr		; error if anything ELSE went wrong
err1:	mvi	a,z17sftcd
	jr	wrterr
err2:	mvi	a,hrdsectcd
wrterr: stc
	ret

;
;	Increments to next side
;

nxt$side:
	lxi	h,sid		; update side
	mov	a,m 
	xri	00000001B
	mov	m,a
	ret			; [Z] is set if side 0

;
;	increments to next trk
;

nxt$trk:
	lxi	h,trk		; update track numbers
	inr	m
	lxi	h,trks1
	dcr	m		; count each track
	jz	nxt$trk1
	call	step$in 	; step head towards hub
	ani	11001001B	; (A) = status from 1797, clears carry
	rz
	mvi	a,wterrcd
	stc			; [CY] = error
	ret
nxt$trk1:
	mvi	a,1		; [NZ] = last track
	ora	a
	ret

;
;	These routines build the image needed to write to the disk
;

image$trk:
	lda	trk
	cpi	1		; if track not 1, return
	rnz
	lda	sid		; if not side 0, return
	bit	0,a
	rnz
	lda	modes+3
	ani	0000$1100b
	jrnz	image$norm	; if trk0 side 0 or side1 was different reimage
	ret

image$t0s0:
	lda	modes+3
	bit	3,a		; if dd with trk 0 side 0 dd, jump
	jrz	image$norm
	lxi	h,std8		; select SD 8" for this track
	mvi	c,0		; sector size = 128 bytes
	mvi	a,26		; 26 physical sectors per track
	jr	put$image

image$t0s1:
	lda	modes+3
	bit	2,a		; jmp if trk 0 side 1 is the z47d format (256)
	jrnz	imag1
	bit	3,a		; see if trk 0 side 0 was different
	rz			; return if it wasn't different
	jr	image$norm
imag1:	lxi	h,z47d		; select dd trk0 side 1 on z47x
	mvi	c,1		; sector size = 256
	mvi	a,26		; 26 physical sectors per track
	jr	put$image

image$norm:			  
	LHLD	XTABLE
	LDA	SZ
	MOV	C,A
	LDA	SPT
put$image:
	STA	SPTC
	MOV	A,C		; sector size code
	STA	SZ0		; save for later stuffing into image
	LXI	B,128/2 	; B = 0, C = 128/2
	INR	A
SI0:	SLAR	C		; mult BC by 2
	RALR	B
	DCR	A		; do it A times
	JNZ	SI0
	SBCD	SECSIZ		; used by data-fill routine and VERIFY
	LDA	WD$FLAG
	ORA	A
	jz	ctrlio
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	SDED	FMTBL		; table that discribes format
	MOV	A,M
	STA	MFM		; DD enable flag
	INX	H
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	SDED	FMTTBL		; skew table for format
	MVI	A,2
	STA	FLAG
	LXI	H,BUFFER
	XRA	A
	STA	SE		; set starting sector number = 0
	CALL	FILL$BUFF	; build buffer image
	LHLD	BIAS
	LDED	FIRST$TRK
	ORA	A
	DSBC	D		; compute length of (each) sector image
	DCX	H
	SHLD	BIAS		; used to update track and side in track image
	jmp	ctrlio		; setup controll port image

FILL$BUFF:
	MOV	D,H		; DE = HL+1
	MOV	E,L
	INX	D
	PUSH	H		; TOS = buffer start address
	LHLD	FMTBL		; HL = table address
	MVI	B,0
POST$INDEX:
	MOV	A,M
	INX	H
	ORA	A
	JZ	FILL$SECT
	MOV	C,A
	MOV	A,M
	INX	H
	XTHL
	MOV	M,A
	LDIR
	XTHL
	JMP	POST$INDEX
FILL$SECT:
	MOV	C,L
	MOV	B,H		; BC = HL (table)
	XTHL			; TOS = table, HL = buffer
	PUSH	B		; -TOS = TOS = table
	MVI	B,0
FILL$S: XTHL			; HL = table, TOS = buffer
	MOV	A,M
	INX	H
	ORA	A
	JZ	END$SECT
	MOV	C,A
	MOV	A,M
	INX	H
	XTHL
	MOV	M,A
	LDIR
	CPI	0FEH		; ID address mark
	JZ	SECT$ID
	CPI	0FBH		; Data address mark
	JNZ	FILL$S
	LBCD	SECSIZ		; fill data field of sector
	MVI	M,0E5H		; fill constant
	LDIR
	MVI	M,0F7H		; crc flag
	INX	H
	INX	D		; keep DE = HL + 1
	JMP	FILL$S
SECT$ID:			; save HL 1st time as FIRST$TRK, next as BIAS
	LDA	FLAG
	DCR	A
	JM	NOSAVE		; 0 = don't save buffer address
	STA	FLAG
	JZ	SAVEBIAS	; 1 = calc diff and save
	SHLD	FIRST$TRK	; 2 = save first sectors ID address
	JMP	NOSAVE
SAVEBIAS:
	SHLD	BIAS		; note: BIAS must have FIRST$TRK subtracted
NOSAVE: MVI	M,0		; current track number, filled in later
	INX	H
	MVI	M,0		; side value, filled in later
	INX	H
	LDED	FMTTBL		; get logical-physical sector table
	MOV	A,E
	ORA	D
	LDA	SE		; do log/phy sector translation
	JZ	NOSK		; skip if no skew
	ADD	E		; index table
	MOV	E,A
	MVI	A,0
	ADC	D
	MOV	D,A
	LDAX	D		; physical sector
	DCR	A
NOSK:	INR	A
	MOV	M,A
	INX	H
	LDA	SZ0		; sector size code
NNNN:
	MOV	M,A
	INX	H
	MVI	M,0F7H		; crc flag
	INX	H
	MOV	E,L
	MOV	D,H
	INX	D		; DE = HL + 1
	JMP	FILL$S
END$SECT:
	LXI	B,SE		; sector + 1
	LDAX	B
	INR	A
	STAX	B
	LXI	B,SPTC		; sector-per-track counter
	LDAX	B
	DCR	A
	STAX	B
	JZ	FILL$LAST
	POP	H		; HL = buffer
	POP	B		; BC = table
	PUSH	B		; TOS = table
	PUSH	B		; -TOS = table, TOS = table
	MVI	B,0
	JMP	FILL$S		; do next sector
FILL$LAST:
	MOV	C,M
	INX	H
	MOV	B,M		; BC = fill size
	POP	H		; HL = buffer (DE = HL+1)
	POP	PSW		; discard table
	LDIR			; fill last used byte to end of track
	RET


;
;	Prints bar graph on screen
;

bargraph:
	call	curoff
	lxi	h,prl
	call	cursor
	call	clrend		; clear bottom half of screen
	lxi	h,bgl
	lxi	d,side0 	; print 'SIDE 0'
	call	prtmsg
	lxi	h,bgl+2 	  
	call	cursor		; position display
	call	writbar 	; MAKE THE BAR
	lda	sides
	ora	a		; SS OR DS?
	rz
	lxi	h,bgl+4
	lxi	d,side1 	; WRITE 'SIDE 1'
	call	prtmsg
	lhld	trks		;see if any tracks on side 1 are skipped.
	mov	a,l
	cmp	h
	rz		
	dcr	l
	push	h
	lxi	d,tkmsg
	call	putlne
	pop	h
	mov	a,h
	call	decout
	mvi	a,'-'
	call	putchr
	mov	a,l
	call	decout
	lxi	d,anu
	call	putlne
	ret

writbar:
	lxi	d,bar		; START OF BAR
	lda	trks		; HOW MANY TRACKS?
	mov	b,a
wb0:	ldax	d
	inx	d
	call	putchr
	djnz	wb0
	ret

;
;	Prints the progress of the format on the bargraph
;

fmtprog:			; SEND NEXT 'F' TO BARGRAPH
	lda	sid		; CURRENT SIDE NUMBER
	add	a
	adi	bgl+1		; OFFSET TO DISPLAY POSITION
	mov	l,a
	lda	trk
	mov	h,a
	call	cursor
	mvi	a,'f'
	jmp	putchr

;
;	Tests for single sided drive or media 
;

testds:
	xra	a
	sta	dsflag
	mvi	a,1		; side 1
	call	rdadr		; try to read valid side-1 address
	jnz	tstdserr	; [NZ] = side 1 not formatted
	inr	a
	jc	tstdserr	; crc error on side-1 indicates DS error
	mvi	a,0		; side 0
	call	rdadr		; try to read valid side-0 address
	jnz	tstdserr	; [NZ] = side 0 not formatted
	ora	a		; Clear [CY]
	ret
tstdserr:
	mvi	a,dserrcd
	stc
	ret

;
;	Reads each sector on the disk, writes initdir data and Zenith label
;

verify: 			; formatting done, verify each sector
	call	inton
	lhld	secsiz
	dad	h
	mov	a,h
	sta	lps
	call	restor		; put head in known position
	call	dskxit
	lxi	b,buffer	; set DMAA to a controlled location...
	mvi	a,setdma	;
	call	biosc		; (we must reserve at least 1024 bytes)
	lda	drive
	sui	'A'
	mov	c,a
	inr	a		; setup drive for set dir label
	sta	sfcb
	mvi	e,1		; to tell bios disk is already logged in
	mvi	a,seldsk
	call	biosc		; select drive
	mvi	a,home
	call	biosc		; request track zero
	lxi	b,0
	mvi	a,setsec
	call	biosc
	mvi	a,reads
	call	biosc
	mvi	a,0FFh		; FLAG DISK NOT VERIFIED
	sta	tec
	lda	vflag		; CHECK FOR NO VERIFICATION OPTION
	ora	a
	jz	verify$end2
	lded	trks
	mov	a,e	; number of tracks on first side
	lhld	modes+2
	bit	6,h	; check double-sided bit
	jz	ntsd1	; 
	bit	1,h	; check for XO/GNAT track numbering. (cont)
	jnz	ntsd1	;
	add	d	; add in number of tracks on second side
ntsd1:	mov	l,a
	mvi	h,0
	shld	vtrk		; save counter values
	mov	l,h		; both have zero in them
	shld	vsec
	xra	a
	sta	tec		; init track error counter
verify0:
	call	outv		; temporarely put a "." on track display
	lbcd	vtrk
	mvi	a,3
	cmp	c		; see if <= track 3 and z17
	jrc	v1
	lda	modes+1
	bit	1,a
	jrz	v0
	lda	spt
	lxi	h,0		; no skew on track 0 and 1 of z17 format
	jr	v2
v0:	dcr	c
	jrnz	v1		; jmp if not trk0
	lda	modes+3 	; see if trk0 sd
	bit	3,a
	jrz	v1
	mvi	a,26
	lxi	h,vskstd
	jr	v2
v1:	lhld	vsectb
	lda	spt
v2:	sta	sptv
	shld	vskew 
verify1:
	lbcd	vtrk		; set trk #
	dcx	b
	mvi	a,settrk	
	call	biosc
	lhld	vskew
	lbcd	vsec
	mov	a,h
	ora	l
	jz	no$skw
	dad	b
	mov	c,m
	mvi	b,0
	dcx	b
no$skw: mvi	a,setsec
	call	biosc
	mvi	a,reads
	call	biosc
	ora	a		; check if system found an error
	jnz	verify$err	; RECORD error if there was one
	lxi	h,vsec		; count to next sector
	lda	sptv
	inr	m
	dcr	a
	cmp	m		; check for last sector on track
	jnc	verify1

	mvi	a,'v'
	jr	verify2
verify$err:
	lxi	h,tec
	inr	m		; INR TEC
	mvi	a,'E'		; send E
verify2:
	call	putchr		; send whatever to display
	call	vend		; check for Q or ^C
	jc	verify$end
	lxi	h,0
	shld	vsec
	lxi	h,vtrk
	dcr	m		; step to next track number
	jnz	verify0

verify$end:
	lda	tec		; check if any errors occured
	ora	a
	jz	verify$end2
	call	disperr 	; display message if errors
	jmp	exit$verify
verify$end2:
	call	setmark
	jc	exit$verify
	call	initdir
	jc	exit$verify
	lda	initflg
	ora	a		; see if to create a disk label and enable
	jrnz	exit$verify	;   time and date stamping
	lxi	d,sfcb
	mvi	c,sdirlab
	call	bdos
	ora	a
	jrz	exit$verify	; jump if no error
	mvi	a,setlabcd
	stc
exit$verify:
	ret

disperr:
	call	curact
	lxi	h,erl
	lxi	d,frm$err	; inform user that at least one error
	call	prtmsg		; was encountered during verify
	call	clrlne
	ret    

;
;	Check for error on verify.  If error, notify user that he may end
;	 verification by typeing 'Q' or ctrl-C
;
   
vend:
	lda	tec		;ERROR COUNTER
	ora	a
	jrz	ve0		;IF NO ERRORS, CHECK FOR ^C AND RETURN
	dcr	a		;1ST ERROR?
	jnz	ve0
	lxi	h,erl
	lxi	d,vqmess
	call	prtmsg		;IF 1ST ERROR, PRINT MESSAGE
	call	clrlne
ve0:	call	conc		;CHECK FOR ^C, RETURN CHAR
	jz	vend$exit	;NO CHAR READY
	cpi	ctrlC
	jz	ve1
	ani	0DFh		;CAPITAL
	cpi	'Q'
	jnz	vend$exit	;IGNORE IF NOT 'Q'
ve1:	lda	tec
	ora	a
	jnz	ve2		;IF ERROR, THINGS WILL BE FINE
	lda	medcnt
	sui	1		;IF NO ERROR, DISPLAY$COUNT WILL INCREMENT
	daa			;  MEDCNT, SO WE'LL DECREMENT IT NOW.
	sta	medcnt
ve2:	stc
vend$exit:
	ret

conc:				;CHECK FOR ^C
	mvi	a,bconst
	call	biosc
	ora	a
	rz
	mvi	a,bconin
	call	biosc
	ora	a	; NOT NULL?
	ret		; return with character

;
;	Prints the progress of the verify on the bargraph
;

outv:
	push	h
	lhld	modes+2
	mov	a,h
	ani	00000011B	;TRACK NUMBERING CODE
	cpi	00000001B	; ZENITH NUMBER SCHEME
	jnz	notzen
	lda	vtrk		; BIOS TRACK NUMBER
	dcr	a
	mov	l,a
	mvi	a,0
	bit	6,h		; CONVERT ZENITH TRACK ONLY IF DS
	jz	zen0
	srlr	l		; DIVIDE BY 2 AND GET REMAINDER IN CARRY
	ral			; GET SIDE FROM REMAINDER
mz0:	add	a		; MULT BY 2 (2 LINES BETWEEN SIDE DISPLAYS)
zen0:	adi	bgl+1		; OFFSET BY BAR-GRAPH LINE (SIDE 0)
	mov	h,l
	mov	l,a
	push	h
	call	cursor		; POSITION CURSOR
	mvi	a,'.'		; mark track as "being verified"
	call	putchr
	pop	h
	call	cursor		; put cursor back to previos position
	pop	h
	ret
notzen: 			; DO MMS TRACK-SIDE CONVERSION
	lda	trks
	mov	l,a		; H = TOTAL NUMBER OF TRACKS ON A SIDE
	mvi	h,0		; ASSUME SIDE 0
	lda	vtrk		; BIOS TRACK NUMBER
	dcr	a
	cmp	l
	jc	mds0
	lhld	trks
	sub	l	;make logical track on second side
	neg
	add	h	;reverse ( N's compliment)
	dcr	a	; -1 because tracks start at 0
	mvi	h,1		; SIDE 1
mds0:	mov	l,a
	mov	a,h
	jmp	mz0

;
;	Write the directory initialization entries for time and date stamping
;

initdir:
	lda	initflg
	ora	a
	jnz	initdir8
	lxi	d,buffer+1		; set up buffer for directory init
	lxi	h,buffer
	lxi	b,1024
initdir1:
	mov	a,c
	ani	0111$1111b
	cpi	20h
	jrnz	initdir2
	mvi	m,21h
	jr	initdir3
initdir2:
	mvi	m,0e5h
initdir3:
	ldi
	jpe	initdir1
	lxi	b,buffer		; set dma address to point to buffer
	mvi	a,setdma
	call	biosc
	lixd	sysdpb
	ldx	h,+8			; get DRM 
	ldx	l,+7
	inx	h			; add one
	ldx	b,+15			; get PSH
	inr	b			; PSH and divide by 4
	inr	b 
initdir4:
	srlr	h			; make DRM number of physical directory
	rarr	l			;  sectors
	djnz	initdir4
	mov	b,l
	lxi	h,0
	shld	isec			; initialize varaibles
	shld	itrk
	ldx	a,+13
	sta	itrk
initdir5:
	push	b
	lbcd	itrk
	mvi	a,settrk		; set track number
	call	biosc
	lbcd	isec
	lded	sectbl			; do sector translation
	mvi	a,sectrn
	call	biosc
	mov	b,h
	mov	c,l
	mvi	a,setsec		; set sector number
	call	biosc
	mvi	a,writes		; write sector
	call	biosc
	pop	b
	ora	a
	jz	initdir6
	mvi	a,initerrcd
	stc
	jr	initdir8
initdir6:
	lxi	h,isec
	inr	m
	lda	spt
	cmp	m
	jnz	initdir7
	lxi	h,itrk
	inr	m
	lxi	h,0
	shld	isec
initdir7:
	djnz	initdir5
	ora	a
initdir8:
	ret

;
;	Writes the z37, z47, z100 sector zero label
;

setmark:
	lda	cflg
	ora	a		; check if need to write configuration data
	jz	exit$setm
	lxi	h,buffer
	lxi	d,buffer+1
	lxi	b,1024		; 1024 is largest sector size
	mvi	m,0E5H
	ldir
	lxi	h,buffer+4
	mvi	m,0		; 1 byte "00" marker
	inx	h
	lda	z37mode
	mov	m,a		; 1 byte mode control
	inx	h
	inx	h		; 1 byte "E5"
	lda	lps
	mov	m,a		; 1 byte "records per physical sector"
	inx	h
	lda	dpb+3
	inr	a
	mov	m,a		; 1 byte "records per allocation block"
	inx	h
	inx	h
	inx	h		; 2 bytes "E5"
	mvi	m,0		; 1 byte "00"
	inx	h
	inx	h		; 1 byte "E5"
	xchg
	lxi	h,dpb
	lxi	b,15
	ldir			; 15 bytes of DPB
	lxi	h,buffer+4
	xra	a
	mvi	c,24		; (24 bytes to sum)
chksum: add	m
	inx	h
	dcr	c
	jnz	chksum
	cma
	stax	d		; 1 byte Check-Sum
	lxi	b,buffer	; write the label out
	mvi	a,setdma
	call	biosc
	lxi	b,0
	mvi	a,settrk
	call	biosc
	lxi	b,0
	mvi	a,setsec
	call	biosc
	mvi	a,writes
	call	biosc		; write marker to disk
	ora	a
	jrz	exit$setm	; jump if no error
	mvi	a,wmerrcd
	stc
exit$setm:			; returns [CY] if error
	ret


;
;	Update and display count of disks correctly formatted
;

display$count:
	lda	fmtcnt
	adi	1
	daa
	sta	fmtcnt		; COUNT OF FORMATTED DISKS
	lda	tec		; GET ERROR COUNT FOR CURRENT DISK
	ora	a
	jrnz	x23		; IF <>0, NO UPDATE
	lda	medcnt		; GET COUNT
	adi	1
	daa			; IT'S BCD
	sta	medcnt
x23:
	lxi	h,20
	lxi	d,afmtd
	call	prtmsg
	lda	fmtcnt
	call	bcdout		;PUT IN NUMBER ATTEMPTED
	lxi	d,gapmsg
	call	putlne
	lda	medcnt
	call	bcdout		;PUT IN NUMBER VERIFIED
	lxi	d,vrfd
	call	putlne
	ret

bcdout:
	call	outbcd
	push	psw
	lxi	d,disk
	call	putlne
	pop	psw
	dcr	a
	rz
	mvi	a,'s'		;FOR MORE THAN ONE
	call	putchr
	ret

outbcd: cpi	10h
	jc	lobcd
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	nible
	pop	psw
lobcd:	push	psw
	call	nible		;NOW DO LOW DIGIT
	pop	psw
	ret

nible:	ani	0fH
	adi	90H
	daa
	aci	40H
	daa
	jmp	putchr

decout: cpi	100	;CONVERT BINARY 0-99 TO BCD
	jrc	lt100
	mvi	a,99
lt100:	mov	c,a
	inr	c
	xra	a
do0:	dcr	c
	jz	outbcd
	adi	1
	daa
	jr	do0

;
;	Restores the system to original state before start$dsk
;

done$dsk:
	lxi	h,orgmode	; PUT BACK ORIGINAL MODE BYTES
	lded	modptr
	lxi	b,4
	ldir
	lhld	curmdl		; point to "JMP LOGIN" in driver
	lxi	b,3		; restore bytes that were overlayed
	dad	b
	mvi	a,0c3h		; code for "JMP"
	mov	m,a
	inx	h
	lda	savbyte 	; restore saved byte
	mov	m,a
	lda	drive		; SETUP TO RESET DRIVE JUST FORMATTED
	sui	'A'-1
	lxi	d,1
	ana	a		; (CLEAR CARRY)
agn:	dcr	a
	jz	resdr
	ralr	e
	ralr	d
	jr	agn
resdr:	mvi	c,restt
	call	bdos		; RESET DRIVE
	ret

;
;	Call BIOS through BDOS
;

biosc:				; setup BIOS parameter block
	sta	biospb		; BIOS function number
	sbcd	biospb+2	; BC register
	sded	biospb+4	; DE register
	shld	biospb+6	; HL register
	mvi	c,cbios
	lxi	d,biospb	; call BIOS through BDOS
	jmp	bdos

biospb: db	0,0
	dw	0,0,0

basmsg: 
	db	'Selected Configuration:',CR,LF
	db	'            Drive -',CR,LF
	db	'       Controller -',CR,LF
	db	'Recording Density -',CR,LF
	db	'            Sides -',CR,LF
	db	'  Tracks per Inch -',CR,LF
	db	'        Step Rate -',CR,LF
	db	'      Format Type -',CR,LF
	db	'$'

NDSK:	DB	'Enter DRIVE-NAME: (and parameters) --$'
PARPRM: DB	'Enter (drive-name:) Parameters --$'
INVP:	DB	BELL,'Invalid parameters or syntax!$'
FRM$ERR DB	BELL,'Disk did NOT format! Try again or Discard this diskette$'
HM$ERR: DB	BELL,'Cannot find track zero!$'
DR$ERR: DB	BELL,'Improper drive name!$'
WR$PT:	DB	BELL,'Diskette is WRITE-PROTECTED!$'
NT$RD:	DB	BELL,'Drive is NOT READY!$'
HRDSEL: DB	BELL,'Cannot format that drive!$'
WTERR:	DB	BELL,'Error during Track Write/Step$'
FALT:	DB	BELL,'Disk Module is in Error!$'
NOSUP:	DB	BELL,'Format not supported$'
BADPRT: DB	BELL,'No port selected for Z67 controller$'
H$SEC:	DB	BELL,'Can''t format hard-sectored diskettes on this controller$'
S$Z17:	DB	BELL,'Can''t format soft-sectored diskettes on this controller$'
DTER:	DB	BELL,'Cannot format '
GAP1:	DB	'$$ tpi in a '
GAP2:	DB	'$$ tpi drive.  '
	DB	'Press <RETURN> to acknowledge: $'
DSER:	DB	BELL,'Drive or media is not double sided.$'
wmerr:	db	BELL,'Can not write Zenith''s format ID$'
slaberr db	BELL,'Can not write directory date and time stamping label$'
initerr db	BELL,'Can not initialize directory for date and time stamping$'
mormed: DB	'Do you have more media to FORMAT? Y',8,'$'
vqmess: DB	'An error has been found. '
	DB	'To Quit verifying this diskette, type ''Q''.$'

prmt:	DB	'Insert BLANK disk in drive '
drive:	DB	'@:.  Push RETURN to begin formatting, ^C to quit >$'

errver: db	bell,cr,lf,lf,'Requires CP/M 3.1 or later',cr,lf,'$'
nodper: db	bell,cr,lf,lf,'GETDP.REL not linked into system',cr,lf,'$'

MEDCNT: DB	0
FMTCNT: DB	0
AFMTD:	DB	'Attempted to format $'
DISK:	DB	' Disk$'
VRFD:	DB	' Verified OK$'
GAPMSG: DB	',  $'

askok:	DB	'Is this the format you want? (Y/N) Y',8,'$'

INCH5:	DB	'5.25 inch floppy$'
INCH8:	DB	'8 inch floppy$'
SSMSG:	DB	'1$'
DSMSG:	DB	'2$'
SDMSG:	DB	'Single$'
DDMSG:	DB	'Double$'
T48MSG: DB	'48$'
T96MSG: DB	'96$'
STRATE: DB	'00 milliseconds$'
DSKLT:	DB	'A: ('
DSKNM:	DB	'  ) $' 	;drive size appended here

CRLF:	DB	CR,LF,'$'

HELP:
	DB	CR,LF
	DB	'The FORMAT utility is called in one of the following ways:'
	DB	CR,LF,LF,'        FORMAT',CR,LF
	DB	'Which outputs HELP information',CR,LF,LF
	DB	'        FORMAT d:',CR,LF
	DB	'Which formats the specified disk according to the'
	DB	' present drive status',CR,LF,LF
	DB	'        FORMAT d:arg1,arg2,arg3',CR,LF
	DB	'Which temporarily updates the drive status and '
	DB	'formats the disk',CR,LF,'accordingly. '

VALID:	DB	'Valid values for arguments are as follows:',CR,LF,LF
	DB	'        DS or SS = double or single sided',CR,LF
	DB	'        DT or ST = double (96 tpi) or single (48 tpi)'
	DB	' track',CR,LF
	DB	'        DD or SD = double or single density',CR,LF
	DB	'        S6, S30, etc. = step rate in milliseconds',CR,LF
	DB	'        MMS, Z37, Z37X etc. (media formats)'
	DB	'; the X implies extended format.',CR,LF,LF
	DB	'Incorrect arguments may be changed'
	DB	' before formatting begins.$'

THISUT: DB	CR,LF,LF,'Press RETURN to continue or ^C to exit.$'


STRTBL: DB	' 6122030 3 61015'	;  possible step rates, 2 bytes each
STEPTB: DB	7,13,21,31,4,7,11,16


;SETUP THE BAR GRAPH DISPLAY

BAR:	DB	'0---------1---------2---------3---------'
BAR2:	DB	'4---------5---------6---------7---------'
side0:	db	'SIDE 0$'
side1:	db	'SIDE 1$'
TKMSG:	DB	'    Tracks $'
ANU:	DB	' on side 1 are not used by the Operating System$'

DPB:	DW	0
	DB	0,0,0
	DW	0,0
	DB	0,0
	DW	0,0

sfcb	db	0		; drive
	db	'        '	; default label
	db	'   '
	db	0011$0000b	; enable create and update time and date
	db	0,0,0
	db	0,0,0,0,0,0,0,0 ; no password
	db	0,0,0,0
	db	0,0,0,0

LINE:	DB	20,0,'....................  '  

DTFLAG0:DB	TRUE
VFLAG0: DB	TRUE 
VFLAG:	DB	0	; verify flag
curmdl	dw	0	; address of current module in system
reldrv	db	0	; drive number relative to drive zero
LOGDSK	DB	0	; currently logged on disk
CNFIG:	DB	0	; MMS=0,Z17=1... (ASCII DIGIT)
TRCK:	DB	0	; "D" or "S"
SDE:	DB	0	; "D" or "S"
DENSITY: DB	0	; "D" or "S"
STEPRT: DB	0	; binary number, 0-99

Z37MODE: DB	0	; mode for zenith sector zero label
XTABLE: DW	0	; sector translation table address
FMTTBL: DW	0	; format defination table address
CMDPTR: DW	0	; command line buffer pointer
SPT0	DB	0	; sector-per-track value for selected drive
TRKS	DB	0	; number of tracks on side 0 (physically on drive)
	DB	0	; number of tracks used on side 1 (all are formatted)
TRK	DB	0	; current track number
SID	DB	0	; number of sides (0 or 1)
SPT	DB	0	; sectors-per-track (physical value)
SPTC	DB	0	; sector-per-track counter
SE	DB	0	; current sector number
SECSIZ	DW	0	; size of sector (bytes)
SZ	DB	0	; sector size code
SZ0:	DB	0	; temp size code, used to build track image
SIDES:	DB	0	; number of sides to format disk
WD$FLAG: DB	0	; WD179X controller type controller if true
MFM:	DB	0	; single or double density flag
DSFLAG: DB	0	; allows DS test
DTFLAG: DB	0	; allows DT test only once per drive.
FLAG:	DB	0	; flag for extraction of buffer image pointers
TRKS1:	DB	0	; track counter
FIRST$TRK: DW	0	; address to track byte in first sector header
BIAS:	DW	0	; number of bytes in each sector image
initflg db	0	; initialize directory flag - if non zero then don't
cflg	db	0	; config label flag  if 0FFh don't 
isec	dw	0	; initdir sector counter
itrk	dw	0	; initdir track counter
fmtbl:	DW	0	; table discribing format
phydrv: db	0	; physical drive number (from BIOS)
tphy:	db	0	; temporary for "phydrv" in get$drive
tdrv:	db	0	; temporary for "drive"  in get$drive
savbyte db	0	; byte saved from modification for module by start$dsk
DSKST:	DB	0	; disk controller status 
STEPR:	DB	0	; STEPRATE from mode byte
MODPTR: DW	0	; address of modes in BIOS
LPS:	DB	0	; logical/physical sector ratio
SECTBL: DW	0	; sector table address from BIOS
SYSDPB: DW	0	; system dpb address
vsectb: dw	0	; verify sector table address
vsec:	dw	0	; sector counter for verify
vtrk:	dw	0	; track counter
sptv:	db	0	; temporary sector per track for verify
vskew:	dw	0	; temporary address of verify skew table
TEC:	DB	0	; track error counter

MODES:	DB	0,0,0,0 ; mode for curently selected drive
TMODE:	DB	0,0,0,0 ; temporary modes
ORGMODE: DB	0,0,0,0 ; SPACE FOR ORIGINAL MODE VALUE

	DS	64
STACK:	DS	0

SAVE$STACK	DS	2

	END
