vers equ '2 ' ; December 27, 1983   8:36  mjm "COPYSYS.ASM"

**********************************************
* Copyright (c) Magnolia Microsystems,	1983 *
**********************************************
	MACLIB Z80
	$-MACRO
bdos	equ	5
fcb	equ	5Ch	;DEFAULT FCB LOCATION
fcb1	equ	fcb+16	;second parameter location
fcbrr	equ	fcb+33	;Random Record in FCB
tpa	equ	100h	;TRANSIENT PROGRAM AREA
comtail equ	80h	;Command line tail addr

boots	equ	100h	;SIZE OF BOOT ROUTINE
ldra	equ	200h	;address of loader
btdroff equ	7h	;boot drive offset 
btmoff	equ	8h	;boot mode offset in boot routine
drv0off equ	9h	;drive zero phy drv number
ndevoff equ	0Ah	;number of devices

BOOT	EQU	0	;JMP TO 'BOOT' TO REBOOT SYSTEM
CONI	EQU	1	;CONSOLE INPUT FUNCTION
CONO	EQU	2	;CONSOLE OUTPUT FUNCTION
retver	equ	12	;get BDOS version number
SELF	EQU	14	;SELECT DISK
OPENF	EQU	15	;DISK OPEN FUNCTION
DREADF	EQU	20	;DISK READ FUNCTION
SDMA	equ	26	;set DMA address
QUSER	EQU	32	;QUERY/SET USER NUMBER
SETDM	EQU	26
WRITEF	EQU	21
CLOSEF	EQU	16
DELT	EQU	19
CREAT	EQU	22
rread	equ	33	;random file read
getsiz	equ	35	;get file size
REST	EQU	37	;RESET INDIVIDUAL DRIVES
getdpb	equ	31	;
RENAME	EQU	23
SET$RAND	EQU	36
goBIOS	equ	50	;CP/M 3.0

WBOOT	EQU	1	;ADDRESS OF WARM BOOT (OTHER PATCH ENTRY
SELDSK	EQU	9	;WBOOT+24 FOR DISK SELECT
SETTRK	EQU	10	;WBOOT+27 FOR SET TRACK FUNCTION
SETSEC	EQU	11	;WBOOT+30 FOR SET SECTOR FUNCTION
SETDMA	EQU	12	;WBOOT+33 FOR SET DMA ADDRESS
READF	EQU	13	;WBOOT+36 FOR READ FUNCTION
WRITF	EQU	14	;WBOOT+39 FOR WRITE FUNCTION

WRUAL	EQU	2	;WRITE-UNALLOCATED CODE
WRDIR	EQU	1	;WRITE-DIRECTORY CODE
WRALL	EQU	0	;WRITE-ALLOCATED CODE

CR	EQU	0DH	;CARRIAGE RETURN
LF	EQU	0AH	;LINE FEED

	org	tpa	;TRANSIENT PROGRAM AREA
	jmp	start

SIGNON: DB	CR,LF,'COPYSYS v3.10'
	DW	VERS
	DB	'  (c) 1983 Magnolia Microsystems$'

ASKGET: DB	cr,lf,lf,'Get System from what Drive (RETURN to quit) ? $'

GETF:	DB	CR,LF,LF,'Getting System from file "'
SNAME:	DB	'd:filename.typ"...$'

PUTMSG:
GETMSG: DB	CR,LF,'Insert disk in Drive '
PDISK:
GDISK:	DB	'@: and push RETURN (^C aborts) $'

ASKPUT: DB	CR,LF,LF,'Put System to what Drive (RETURN to quit) ? $'

PERD:	DB	CR,LF,LF,'PERMANENT ERROR reading drive '
PED:	DB	'@:$'
PEWR:	DB	CR,LF,LF,'PERMANENT ERROR writing drive '
PEDW:	DB	'@:, Disk will not be bootable.$'

readm:	db	'read from$'
writm:	db	'written to$'
RDONE:	DB	CR,LF,'System Successfully $ drive '
RDD:	DB	'@:$'

WONT:	DB	CR,LF,LF,'Can''t COPYSYS to destination drives''s media format$'

QDISK:	DB	CR,LF,LF,'INVALID DRIVE for current system$'

BADFILE:
	DB	CR,LF,LF,'Source File INCOMPLETE$'

SZERR	DB	CR,LF,LF,'System is too Large for Drive '
SZD:	DB	'@:$'
inv:	db	cr,lf,lf,'Must run under CP/M 2 or 3$'

pterr1	db	CR,LF,LF,'''S'' option and command line mode changes not allowed together$'
pterr2	db	CR,LF,LF,'Bad command line option$'
dermsg	db	CR,LF,LF,'Wrong boot loader for destination drive$'
badbtdr db	CR,LF,LF,'Wrong boot loader for physical drive number specified$'		     
incomp	db	CR,LF,LF,'Wrong version boot loader-'
	db	'COPYSYS can not reconfigure for destination drive',CR,LF,'$'
NOSP	DB	CR,LF,LF,'No Directory Space$'
WERR	DB	CR,LF,LF,'Disk Full$'
RERR	DB	CR,LF,LF,'Verify-Read Error$'
VERR	DB	CR,LF,LF,'Verify Error$'
RENR	DB	CR,LF,LF,'File renaming error$'
confgmsg:
	db	CR,LF,'Boot loader has been reconfigured to $'
sdmsg:	db	'sd$'
ddmsg:	db	'dd$'
ssmsg:	db	'ss$'
dsmsg:	db	'ds$'
stmsg:	db	'st$'
dtmsg:	db	'dt$'
 
no$file db	CR,LF,'"'
nofnam	db	'd:filename.typ" not Found$'

endmsg	db	CR,LF,'"'
endnam	db	'd:filename.typ" Copied Sucessfully to drive '
endrv	db	'd:$'

SORCE:	DW	GDISK,RDD,PED,0
DEST:	DW	PDISK,RDD,SZD,PEDW,0

sopar:	db	0	;0=none, A-P=drive name, 254=file
depar:	db	0	;0=none, A-P=drive name

bootmode: db	0      
bootdrv:  db	0FFh

; bootmode bit defination
;	       0	       1
;     bit7    5.25" disk       8" disk
;     bit6    SS	       DS
;     bit5    ST	       DT
;     bit4    SD	       DD
;     bit3   check if source   don't check
;	     and dest drivers
;	     match
;     bit2   don't use command  using command options
;	     line option modes			     Can't have both 1 & 2 set
;     bit1   don't use dest     use dest drive mode
;	     drive mode bytes
;     bit0   copy CPM3.SYS &	don't copy
;	     CCP.COM

chkpar: lda	fcb1
	ora	a
	jz	cp4
	adi	'A'-1
cp4:	sta	depar
	jz	cp1
	lda	fcb1+1
	cpi	' '
	jz	cp1
	xra	a
	sta	depar
cp1:	lda	FCB
	ora	a
	jz	cp3
	adi	'A'-1
cp3:	sta	sopar
	lda	FCB+1
	cpi	' '
	jz	cp0
	mvi	a,254		;filename specified
	sta	sopar
	stc
	ret		;[CY]
cp0:	xra	a
	ret		;[NC]

; Command line options
; S  =	Setup loader boot module to destination mode bytes (default)
; NS =	Don't setup loader boot module to destination mode bytes
; NC =	Don't copy CPM3.SYS and CCP.COM
; NE =	Don't check if loader boot module and destination drive match
; nn =	set boot drive to this decimal number
; DD or SD
; DS or SS Set destination mode to this kind of drive
; DT or ST	Can't be used with the S option

parsopt lxi	h,comtail	; parse command line tail
	lda	comtail 	; get length of command tail
	ora	a
	rz			; if no command tail return
	mov	c,a
	mvi	b,0
	mvi	a,'['
	ccir			; search for '['
	rnz			; return if no match with '['
	lxix	bootmode
	setx	1,+0		; default setup (S) option
ptloop	call	getnxt
	rc
	jz	per2
	cpi	'S'		; see if S option
	jrnz	ptD
	call	getnxt
	jrnz	ptSD
	push	psw
	setx	1,+0
	bitx	2,+0		; if a mode option is on line too, error out
	jnz	per1 
	pop	psw
	rc			; return if last command line option
	dcx	h		; go back to comma
	jmp	nxtopt
ptSD	cpi	'D'
	jrnz	ptST
	resx	4,+0
	jmp	chksopt
ptST	cpi	'T'
	jrnz	ptSS
	resx	5,+0
	jmp	chksopt
ptSS	cpi	'S'
	jnz	per2		; bad option
	resx	6,+0
	jmp	chksopt
ptD	cpi	'D'
	jrnz	ptN
	call	getnxt
	rc
	jz	nxtopt
	cpi	'D'		; if DD
	jrnz	ptDT
	setx	4,+0
	jmp	chksopt
ptDT	cpi	'T'
	jrnz	ptDS
	setx	5,+0
	jmp	chksopt
ptDS	cpi	'S'
	setx	6,+0
chksopt bitx	1,+0		; setup loader flag
	jnz	per1
	setx	2,+0		; set usage bit
	jmp	nxtopt
ptN	cpi	'N'
	jnz	ptnum		; check for the 'Nx' options
	call	getnxt
	jz	per2		; error if only a N
	cpi	'C'
	jrnz	ptNE
	setx	0,+0 
	jmp	nxtopt
ptNE	cpi	'E'		; check if drive type check is to be disabled
	jrnz	ptNS 
	setx	3,+0
	jmp	nxtopt
ptNS	cpi	'S'		; check to disable setup option
	jrnz	per2
	resx	1,+0
nxtopt	call	getnxt
	rc
	jz	ptloop		; if comma get next option
per2	lxi	h,pterr2
erout	call	outmsg
	jmp	reboot
per1	lxi	h,pterr1
	jr	erout

ptnum	cpi	'0'		; get boot drive number if on command line
	jc	per2
	cpi	'9'+1
	jnc	per2
	sui	'0'
	mov	b,a
	call	getnxt
	push	psw
	jz	gnum
	cpi	'0'
	jc	per2
	cpi	'9'+1
	jnc	per2
	sui	'0'
	mov	c,a
	mov	a,b
	add	a		; multiply by 10 and add first digit
	add	a
	add	b
	add	a
	add	c
	mov	b,a
gnum	mov	a,b
	sta	bootdrv
	pop	psw
	rc			; if last option exit
	jmp	nxtopt

getnxt	mov	a,m
	inx	h
	cpi	','
	rz		;[Z] = 1 if comma
	cpi	']'
	jrz	setcy
	cpi	0
	rnz
setcy	stc		;[Z] & [CY] = 1 if end of line or ]
	ret


invver: lxi	h,inv
	call	outmsg
	jmp	boot

START:
	LXI	SP,STACK	;SET LOCAL STACK POINTER
	LXI	H,SIGNON
	CALL	OUTMSG
	mvi	c,retver
	call	bdos
	mov	a,l
	cpi	20h
	jc	invver
	lxi	h,cpm2
	cpi	30h
	jc	putvec
	lxi	h,cpm3
	cpi	40h
	jnc	invver
putvec: lxi	d,doBIOS
	lxi	b,patlen
	ldir
	call	chkpar	;get valid parameters from FCB (FCB1)
	call	parsopt ;get options from command line tail
	lda	sopar	;check source for "get from file"
	cpi	254
	jnz	getsys	;no filename given
	mvi	a,'C'	;force com file
	sta	fcb+9
	mvi	a,'O'
	sta	fcb+10
	mvi	a,'M'
	sta	fcb+11
	lxi	h,fcb
	lxi	d,sname
	call	setnam
	lxi	h,getf
	call	outmsg
	LXI	D,FCB	;TRY TO OPEN IT
	mvi	c,openf
	call	bdos	;
	INR	A	;255 BECOMES 00
	JNZ	RDOK	;OK TO READ IF NOT 255
	lxi	d,nofnam
	lxi	h,fcb 
	call	setnam
	LXI	H,no$file	;ERROR: file not on disk
	CALL	OUTMSG
	JMP	REBOOT

RDOK:	lxi	h,0
	shld	fcb+32	;CURRENT RECORD = 0
	lxi	d,fcb
	mvi	c,getsiz ;boot loader is last record of file
	call	bdos
	lhld	fcbrr	;getsiz points to last record + 1
	lxi	b,boots/128
	ora	a	;clear [CY]
	dsbc	b	;subtract boot loader length in sectors
	lxi	d,loadp ;now load system image
	call	dload	;load boot routine
	jnz	badrd
	lhld	loadp+3 ; (DE=next dma address) HL=loader end
	lbcd	loadp+5 ; BC=loader start
	ora	a
	dsbc	b	;number of bytes in loader
	lxi	b,007fh ;
	dad	b
	dad	h
	mov	c,h	;number of records
	mvi	b,0	;(in BC)
	lxi	h,(ldra-tpa)/128
	call	dload
	jnz	badrd
	mvi	a,'A'
	sta	SOUR$DRIVE
	jmp	putsys

BADRD:		;EOF ENCOUNTERED IN INPUT FILE
	LXI	H,BADFILE
	CALL	OUTMSG
	JMP	REBOOT

dload:	shld	fcbrr	;
dl0:	push	b
	lxi	h,128
	dad	d	;next DMA address
	push	h
	mvi	c,sdma
	call	bdos
	lxi	d,fcb
	mvi	c,rread
	call	bdos
	lhld	fcbrr
	inx	h
	shld	fcbrr
	pop	d
	pop	b
	ora	a
	rnz
	dcx	b
	mov	a,b
	ora	c
	jnz	dl0
	ret

GETSYS: lda	sopar	;should we prompt for source ?
	ora	a
	jnz	nops
gse:	LXI	H,ASKGET	;GET SYSTEM?
	CALL	OUTMSG
	CALL	GETCHAR
	CPI	CR
	JZ	REBOOT	;QUIT IF CR ONLY
	cpi	3	;ctrl-C
	jz	REBOOT
	cpi	'A'
	jc	BADG
	cpi	'P'+1
	jnc	BADG
nops:	sta	SOUR$DRIVE
	mov	c,a		;TO SET MESSAGE
	lxi	h,SORCE
	call	setmsg
	ANI	00011111B
	DCR	A
	CALL	SEL		;TO SELECT THE DRIVE
	JNZ	GETC		;SKIP TO GETC IF SO

;    INVALID DRIVE NUMBER
BADG:	CALL	BADDISK
	JMP	gse		;TO TRY AGAIN

GETC:	
	lda	sopar	;should we wait for response ?
	ora	a
	jnz	nows
	LXI	H,GETMSG
	CALL	OUTMSG
	CALL	GETCHAR
	CPI	CR
	JNZ	REBOOT
nows:	XRA	A
	STA	NEEDED
	STA	RW
	CALL	GETPUT
	jc	GETERR
	LXI	H,readm
	CALL	donmsg

PUTSYS:
	lhld	LOADP+3 ;end of loader
	lded	LOADP+5 ;start of loader
	ora	a
	dsbc	d	;number of bytes for boot to load
	lxi	d,007fh
	dad	d	;round up
	dad	h
	mov	a,h	;NUMBER OF 128 byte SECTORS FOR BOOT TO LOAD
	ADI	2	;ADD IN BOOT'S SECTORS
	STA	NEEDED	;TOTAL SECTORS IN SYSTEM
	lda	depar	;should we prompt for destination ?
	ora	a
	jnz	nopd
pse:	LXI	H,ASKPUT
	CALL	OUTMSG
	CALL	GETCHAR
	CPI	CR
	JZ	REBOOT
	cpi	3
	jz	reboot
	cpi	'A'
	jc	BADP
	cpi	'P'+1
	jnc	BADP
nopd:	sta	DEST$DRIVE
	mov	c,a	;MESSAGE SET
	lxi	h,DEST
	call	setmsg
	ANI	00011111B
	CALL	RST$DRV ;RESET DRIVE FOR FILE WRITE
	DCR	A
	CALL	SEL	;SELECT DEST DRIVE
	JNZ	PUTC
BADP:	CALL	BADDISK ;invalid drive for current system
	JMP	pse	;TO TRY AGAIN

PUTC:	LHLD	DPB
	MOV	E,M	;SECTORS PER TRACK
	mvi	d,0
	LXI	B,13
	DAD	B
	MOV	B,M	;TRACKS IN SYSTEM
	mov	a,b
	ora	a
	lxi	h,0
	jz	xmlt2	;if no system tracks reserved
	MOV	L,E
	MOV	H,D
MLT2	DCR	B
	JZ	XMLT2
	DAD	D
	JMP	MLT2
XMLT2		;SECTORS AVAILABLE FOR SYSTEM
	LDA	NEEDED	;SECTORS NEEDED FOR SYSTEM
	MOV	C,A
	MOV	A,H
	ORA	A
	JNZ	SZOK
	MOV	A,L
	CMP	C
	JNC	SZOK
	LXI	H,SZERR ;there is not enough room on the destination disk
	CALL	OUTMSG	 ;for the system thats in memory.
	JMP	pse   

cant:	lxi	h,WONT
	call	outmsg
	JMP	reboot

SZOK:	call	btckvers	; check if old version of boot loader 
	call	dnumchk 	; check physical drive number
	call	chk$mode	; check format and setup bootmode 
	call	putbtcd 	; put boot mode in loader from bootmode
	call	putbtdr 	; put boot drive number in loader if not FFh
	call	outconfg	; print configured message
	lda	depar		; should we wait for answer ?
	ora	a
	jnz	nowd
	LXI	H,PUTMSG
	CALL	OUTMSG
	CALL	GETCHAR
	CPI	CR
	JNZ	REBOOT
nowd:	LXI	H,RW
	MVI	M,1
	CALL	GETPUT	;TO PUT SYSTEM BACK ON DISKETTE
	jc	PUTERR
	LXI	H,writm
	CALL	donmsg
	call	copyfil ; copy ccp.com and cpm3.sys
	lda	depar	;if in SUBMIT mode, don't ask for more.
	ora	a
	jnz	reboot
	JMP	PUTSYS	;FOR ANOTHER PUT OPERATION

GETERR: lxi	h,PERD
	call	outmsg
	jmp	gse

PUTERR: lxi	h,PEWR
	call	outmsg
	jmp	pse

setmsg: mov	e,m	;HL=messages addresses list, c=drive (ascii)
	inx	h
	mov	d,m
	inx	h
	mov	a,d
	ora	e
	mov	a,c	;return Drive in (A) or get ready for STAX D
	rz	;stop if no more messagess to fill.
	stax	d	;put drive name in message
	jmp	setmsg	;do next item in list.

SETNAM: 
	mov	a,m	;drive designator
	inx	h
	dcr	a
	jp	SN0
	xra	a
	stax	d	;put "null" in drive name
	inx	d
	stax	d	;put "null" in ":" place
	jmp	SN1
SN0:	adi	'A'
	stax	d
	inx	d	;point to ":"
SN1:	inx	d	;point to first letter of name
	mvi	c,8	;8 characters in name
NL0:	mov	a,m
	inx	h
	cpi	' '
	jnz	SN2
	xra	a
SN2:	stax	d
	inx	d
	dcr	c
	jnz	NL0
	inx	d	;skip over "."
	mvi	c,3
NL1:	mov	a,m
	inx	h
	cpi	' '
	jnz	SN3
	xra	a
SN3:	stax	d
	inx	d
	dcr	c
	jnz	NL1
	ret

outconfg:
	lda	bootmode
	bit	1,a
	jrnz	cg1
	bit	2,a
	rz
cg1	lxi	h,confgmsg
	call	outmsg
	lda	bootmode
	bit	4,a
	jrz	cg$sd
	lxi	h,ddmsg
	jr	cg2
cg$sd:	lxi	h,sdmsg
cg2:	call	outmsg
	mvi	a,','
	call	putchar
	lda	bootmode
	bit	6,a
	jrz	cg$ss
	lxi	h,dsmsg
	jr	cg3
cg$ss:	lxi	h,ssmsg
cg3:	call	outmsg
	lda	bootmode
	bit	7,a
	rnz
	mvi	a,','
	call	putchar
	lda	bootmode
	bit	5,a
	jrz	cg$st
	lxi	h,dtmsg
	jr	cg4
cg$st:	lxi	h,stmsg
cg4:	call	outmsg
	ret

RST$DRV:
	PUSH	PSW
	LXI	H,0000000000000001B
DRLP	DCR	A
	JZ	GDRV
	DAD	H	;SHIFT (HL) LEFT 1 BIT
	JMP	DRLP
GDRV	MOV	E,L
	MOV	D,H
	MVI	C,REST 
	CALL	BDOS
	POP	PSW
	RET

REBOOT:
	MVI	A,0
	CALL	SEL
	CALL	CRLF
	JMP	BOOT

doBIOS:   jmp	$-$
chk$mode: jmp	$-$
setup:	  jmp	$-$
SEL:	  jmp	$-$
patlen	equ	$-doBIOS

cpm3:	jmp	cpm3bios
	jmp	cpm3mode
	jmp	cpm3setup
	jmp	cpm3sel

cpm2:	jmp	cpm2bios
	jmp	cpm2mode
	jmp	cpm2setup
	jmp	cpm2sel

cpm2bios:
	mov	e,a
	add	a
	add	e
	mov	e,a
	mvi	d,0
	LHLD	BOOT+1
	mvi	l,0
	DAD	D
	PCHL

cpm3bios:
	cpi	setsec
	jnz	c3b
	dcx	b	;sectors numbered 0-(n-1)
c3b:	sbcd	rBC
	sded	rDE
	shld	rHL
	sta	func
	lxi	d,func
	mvi	c,goBIOS
	jmp	bdos

func:	db	0	;BIOS vector number
	db	0	;(A)
rBC:	dw	0	;(BC)
rDE:	dw	0	;(DE)
rHL:	dw	0	;(HL)

cpm2mode:
	LHLD	DPB	;GET DPH ADDRESS
	LXI	D,+15	;POINT TO MODES (FORMAT ORIGIN BYTE)
	DAD	D
	lda	cdrvnum
	sui	15
	cpi	10
	jc	hdsk	; jmp if corvus (in cpm3mode)
	lda	cdrvnum
	sui	50
	cpi	78
	jc	hdsk	; jmp if sasi	(in cpm3mode)
	bit	4,m	;trk 0 config
	jnz	cant
	inx	h
	bit	6,m	;data den
	jz	cpm2a
	bit	5,m	;trk 0 end
	jz	cant	;if single den error

cpm2a	lda	bootmode
	bit	1,a		;if dest usage bit = 0 return
	rz
	bit	2,a		;if command line bit = 1 return
	rnz

	bit	6,m		; media density bit 2.2
	jz	cpm2SD
	setb	4,a
	jr	a1
cpm2SD	res	4,a
a1	bit	3,m		; track density
	jz	cpm2ST
	setb	5,a
	jr	a2
cpm2ST	res	5,a
a2	bit	2,m
	jrz	cpm2s		; get disk size
	setb	7,a
	jr	a4
cpm2s:	res	7,a
a4:	dcx	h
	bit	5,m		; # of sides
	jz	cpm2SS 
	setb	6,a
	jr	a3
cpm2SS	res	6,a
a3	sta	bootmode
	ret

cpm3mode:
	lhld	boot+1
	mvi	l,70h	;current mode
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	bit	7,m		; if hard disk
	jrz	cpm3flp
hdsk:	lda	bootmode
	ani	0000$1001b
	sta	bootmode
	ret
cpm3flp:
	inx	h
	inx	h
	inx	h		; last mode byte
	bit	7,m
	jnz	cant		; config trk 0
	bit	3,m		; trk 0 den side 0
	jnz	cant
	bit	2,m		; trk 0 den side 1
	jnz	cant

	lda	bootmode
	bit	1,a		;if dest usage bit = 0 return
	rz
	bit	2,a		;if command line bit = 1 return
	rnz
	mov	a,m		; get mode byte #3
	ani	0111$0000b
	mov	b,a
	dcx	h
	bit	7,m		; get disk size
	jrz	s0
	setb	7,b
s0:	lda	bootmode
	ani	0000$1111b
	ora	b
	sta	bootmode
	ret

cpm2setup:
	push	h
	lxi	h,128
	shld	secsiz
	pop	h
	ret

cpm3setup:
	push	h	;count
	push	d	;SPT
	lhld	DPB
	lxi	d,+15
	dad	d	;physical sector info.
	mov	a,m	;physical-sector-shift factor
	inx	h
	mov	c,m	;physical sector mask, rounding factor
	mov	b,a
	lxi	h,128
	inr	b
s31:	dcr	b
	jz	s30
	dad	h
	jmp	s31
s30:	shld	secsiz
	pop	d
	pop	h
	ora	a
	rz
	mvi	b,0
	dad	b	;round-up to next integer/divide by 2^x
	xchg		;
	dad	b	;
	xchg
s32:	srlr	h
	rarr	l
	srlr	d
	rarr	e
	dcr	a
	jnz	s32
	ret

cpm2sel:	; SELECT DISK GIVEN BY REGISTER A
	MOV	C,A
	mvi	a,seldsk
	call	cpm2bios
	mov	a,c
	sta	cdrvnum
	mov	a,h
	ora	l
	rz
	lxi	d,+10
	dad	d
	mov	e,m
	inx	h
	mov	h,m
	mov	l,e
	shld	DPB
	ret

cpm3sel:
	mov	e,a
	mvi	c,self
	call	bdos
	mvi	c,getdpb
	call	bdos
	shld	DPB
	push	h
	lhld	boot+1
	mvi	l,6Ch		;get current phy drv number
	mov	a,m
	pop	h
	sta	cdrvnum
	xra	a
	inr	a
	ret

btckvers:
	lda	loadp+1 	; low order byte of boot address
	ani	01111111b
	cpi	0BH		; if not new type of boot loader
	rz
ncomperr:
	lxi	h,incomp
	call	outmsg
	lda	bootmode	
	ani	1111$1001b	; clear mode byte bit and setup option bit
	ori	0000$1000b	; don't check driver type (driv0 and ndrv may
	sta	bootmode	;	      not be there)
	mvi	a,0FFh
	sta	bootdrv 	; don't change boot drive
	ret

dnumchk lda	bootmode	; checks dest phy drv number with drive zero
	bit	3,a		; in boot loader
	rnz
	lda	cdrvnum
	lxix	loadp+drv0off
	subx	+0
	jc	derr1
	cmpx	+1
	rc
derr1	lxi	h,dermsg
	call	outmsg
	jmp	REBOOT

putbtcd lda	bootmode
	bit	1,a
	jnz	pbt1
	bit	2,a
	rz
pbt1	lda	loadp+drv0off	; check special case of a boot loader
	cpi	29		;  have drives 29 to 36 (both 8" and 5.25")
	jnz	pbt2
	lda	loadp+ndevoff
	cpi	4+1
	jc	pbt2
	lda	bootmode
	bit	7,a
	jnz	pbt2
	lxi	h,btm33
	jmp	foundbt2
pbt2	lxi	h,loadp+drv0off ; drive zero from loader boot module
	lxix	drvntbl 	; table of drive numbers
btloop	ldx	a,+0
	cpi	0FFh
	jz	ncomperr	; loader boot module not compatiable
	cmp	m
	jz	foundbt
	inxix
	inxix
	inxix
	jmp	btloop
foundbt ldx	l,+1
	ldx	h,+2
foundbt2:
	lda	bootmode
	ani	01110000b
	rrc    
	rrc    
	rrc    
	rrc    
	mov	e,a
	mvi	d,0
	dad	d
	mov	a,m
	sta	loadp+btmoff
	ret

putbtdr lda	bootdrv
	cpi	0FFh
	rz
	lxix	loadp+drv0off
	subx	+0
	jc	bterr 
	cmpx	+1
	jc	setbtdr
bterr	lxi	h,badbtdr
	call	outmsg
	jmp	REBOOT
setbtdr lda	bootdrv
	sta	loadp+btdroff
	ret

BADDISK:
	LXI	H,QDISK ;invalid drive name
	JMP	OUTMSG

GETCHAR:	; READ CONSOLE CHARACTER TO REGISTER A
	MVI C,CONI! CALL BDOS!
	CPI 'a' ! RC	 ;RETURN IF BELOW LOWER CASE A
	CPI 'z'+1
	RNC	;RETURN IF ABOVE LOWER CASE Z
	ANI 01011111b ! RET

PUTCHAR:	; WRITE CHARACTER FROM A TO CONSOLE
	MOV E,A! MVI C,CONO! CALL BDOS! RET

CRLF:	;SEND CARRIAGE RETURN, LINE FEED
	MVI	A,CR
	CALL	PUTCHAR
	MVI	A,LF
	CALL	PUTCHAR
	RET

donmsg: xchg
	lxi	h,RDONE
dm0:	push	d
	call	outmsg
	xthl
	call	outmsg
	pop	h
	inx	h
	jmp	outmsg

CRMSG:	;PRINT MESSAGE ADDRESSED BY HL TIL ZERO WITH LEADING CRLF
	PUSH H! CALL CRLF! POP H ;DROP THRU TO OUTMSG0
OUTMSG:
	MOV A,M! CPI '$' ! RZ
	PUSH H! CALL PUTCHAR! POP H! INX H
	JMP	OUTMSG

TRK:	;SET UP TRACK
	mvi	a,SETTRK
	jmp	doBIOS

SEC:	;SET UP SECTOR NUMBER
	mvi	a,SETSEC
	jmp	doBIOS

DMA:	;SET DMA ADDRESS TO VALUE OF B,C
	mvi	a,SETDMA
	jmp	doBIOS

READ:	;PERFORM READ OPERATION
	mvi	a,READF
	jmp	doBIOS

WRITE:	;PERFORM WRITE OPERATON
	mvi	a,WRITF
	MVI	C,WRUAL ;WRITING TO UNALLOCATED SECTORS
	jmp	doBIOS

GETPUT:
;	GET OR PUT CP/M (RW=0 FOR READ, 1 FOR WRITE)
;	DISK IS ALREADY SELECTED
	LXI	H,LOADP ;LOAD POINT IN RAM FOR CP/M DURING SYSGEN
	SHLD	DMADDR
	LHLD	DPB
	MOV	E,M	;SECTORS PER TRACK
	mvi	d,0
	LXI	B,13
	DAD	B
	MOV	B,M	;TRACKS IN SYSTEM
	mov	a,b
	ora	a
	lxi	h,0
	jz	XMLT	;if no system tracks reserved
	MOV	L,E
	MOV	H,D
MLT1	DCR	B
	JZ	XMLT
	DAD	D
	JMP	MLT1
XMLT:
	LDA	NEEDED	;SECTORS NEEDED FOR SYSTEM
	ORA	A
	JZ	NOTGET
	MOV	L,A
	MVI	H,0
NOTGET:
	call	setup	;DE=logical SPT, HL=128-byte sectors to read/write
	inr	e	;compensate for sectors numbered 1-n
	push	d	;physical sectors-per-track
	PUSH	H	;physical sector count
	XRA	A
	STA	TRACK
	INR	A
	STA	SECTOR
DOTRK	LDA	TRACK
	MOV	C,A
	MVI	B,0
	CALL	TRK
HRD$LOOP:
	LDA	SECTOR
	MOV	C,A
	mvi	b,0
	CALL	SEC
	LHLD	DMADDR
	MOV	C,L
	MOV	B,H
	CALL	DMA
	LDA	RW
	ORA	A
	JZ	RHRD
	CALL	WRITE
	JMP	CHKHRD
RHRD:	CALL	READ
CHKHRD: ORA	A
	JNZ	ERR$HRD
NXT$SEC:
	LHLD	DMADDR
	lded	secsiz
	DAD	D
	SHLD	DMADDR
	POP	D
	POP	B
	DCX	D
	MOV	A,D
	ORA	E
	jz	endwrt
	PUSH	B
	PUSH	D
	LXI	H,SECTOR
	INR	M
	MOV	A,M
	CMP	C
	JC	HRD$LOOP
	MVI	M,1
	LXI	H,TRACK
	INR	M
	JMP	DOTRK

endwrt: lda	rw
	ora	a
	rz
	call	read	;to flush buffer
	xra	a
	ret

ERR$HRD:
	pop	psw
	pop	psw	;normalize stack...
	xra	a
	stc		;set carry for ERROR
	ret

COPYFIL:		;Copy CCP.COM and CPM3.SYS
	lda	bootmode
	bit	0,a
	rnz		; dont copy if bit #0 = 1
	lxi	h,loadp
	lded	loadp+3 ; get end of loader in memory
	dad	d
	shld	BUFFER$START

	LHLD	BDOS+1	;find top of memory from BDOS address
	MVI	L,0
	LDED	BUFFER$START
	ORA	A
	DSBC	D	;number of bytes of buffer space available
	MOV	A,L	;multiply bt 2
	RAL
	MOV	A,H
	RAL
	MOV	L,A	;and divide by 256
	MVI	A,0
	RAL
	MOV	H,A	;effectively dividing by 128
	SHLD	MAX$BUFFER	;set max number of records in a copy pass

	lxi	h,ccpcom
	call	docopy
	lda	sopar
	cpi	254
	rz
	lxi	h,cpm3sys
	call	docopy
	ret

docopy: LXI	D,SOURCE$FCB+1	;set name in FCB
	LXI	B,11
	LDIR
	XCHG
	CALL	ZERO$REST	;zero rest of FCB
	lda	sour$drive
	sui	'A'-1
	sta	source$fcb
	LXI	H,SOURCE$FCB+1
	LXI	D,DEST$FCB+1	;setup destination FCB
	LXI	B,8
	LDIR
	XCHG
	MVI	M,'$'	;use "temporary" file type
	INX	H
	MVI	M,'$'
	INX	H
	MVI	M,'$'
	INX	H
	CALL	ZERO$REST	;clear rest of FCB
	LDA	DEST$DRIVE	;set destination drive
	sui	'A'-1
	STA	DEST$FCB
	XRA	A
	STA	EOF$FLAG	;clear end of file flag
	LXI	D,SOURCE$FCB	;try to open source file
	MVI	C,OPENF
	CALL	BDOS
	CPI	255
	JZ	SNF
	LXI	D,DEST$FCB	;delete any previous copy of temp name
	MVI	C,DELT
	CALL	BDOS
	LXI	D,DEST$FCB	;and create new entry
	MVI	C,CREAT
	CALL	BDOS
	CPI	255
	JZ	DFULL
BLOCK$LOOP:
	LHLD	BUFFER$START	;set buffer to start of buffer
	SHLD	BUFFER$POINTER
	LHLD	MAX$BUFFER	;count max records we can read without smashing
READ$LOOP:			; BDOS.
	PUSH	H
	LDED	BUFFER$POINTER
	LXI	H,128	;set next value of buffer address
	DAD	D
	SHLD	BUFFER$POINTER
	MVI	C,SETDM        ;set current buffer address
	CALL	BDOS
	LXI	D,SOURCE$FCB	;read source file record
	MVI	C,DREADF
	CALL	BDOS
	POP	H
	ORA	A
	JNZ	END$S	;detect end of file (last pass)
	DCX	H	;count a record
	MOV	A,H
	ORA	L
	JRNZ	READ$LOOP	;keep reading untill memory is full

	LHLD	MAX$BUFFER	;begin write sequence
WRITE$BLOCK:
	mov	a,h		;trap zero-length files
	ora	l		;
	jz	end$verify	;
	PUSH	H	;save number of records (for verify)
	PUSH	H	;save for write loop also
	LHLD	BUFFER$START	;start buffer pointer at beginning
	SHLD	BUFFER$POINTER
	LXI	D,DEST$FCB	;compute current random record number
	MVI	C,SET$RAND	;(starting record of block)
	CALL	BDOS
	POP	H
WRITE$LOOP:
	PUSH	H
	LDED	BUFFER$POINTER	;get next buffer address
	LXI	H,128
	DAD	D
	SHLD	BUFFER$POINTER	;set current buffer address
	MVI	C,SETDM
	CALL	BDOS
	LXI	D,DEST$FCB	;write a record
	MVI	C,WRITEF
	CALL	BDOS
	POP	H
	ORA	A
	JNZ	DWE
	DCX	H	;count a record
	MOV	A,H
	ORA	L
	JRNZ	WRITE$LOOP	;loop untill entire block is written
	LXI	D,BUFFER	;set buffer for verify
	MVI	C,SETDM
	CALL	BDOS
	LHLD	BUFFER$START	;start comparing at beginning of block
	SHLD	BUFFER$POINTER
	LXI	D,DEST$FCB	;reset file to record for start of block
	MVI	C,RREAD
	CALL	BDOS
	POP	H
VERIFY$LOOP:
	PUSH	H
	LXI	D,DEST$FCB	;read record previously written
	MVI	C,DREADF
	CALL	BDOS
	ORA	A
	JNZ	VRE
	LHLD	BUFFER$POINTER	;compare to buffer
	LXI	D,BUFFER
	MVI	C,128
VLOOP	LDAX	D
	CMP	M
	JNZ	NOVRF
	INX	D
	INX	H
	DCR	C
	JRNZ	VLOOP
	SHLD	BUFFER$POINTER	;set new buffer pointer
	POP	H
	DCX	H	;count a record
	MOV	A,H
	ORA	L
	JRNZ	VERIFY$LOOP	;loop untill al records verified
END$VERIFY:
	LDA	EOF$FLAG	;check if this was the last pass
	ORA	A
	JZ	BLOCK$LOOP	;loop if still more in file
	LXI	D,DEST$FCB	;else close destination file
	MVI	C,CLOSEF
	CALL	BDOS
	LXI	H,SOURCE$FCB+1	;copy source name to destination FCB
	LXI	D,DEST$FCB+1	;(for RENAME operation)
	LXI	B,11
	LDIR
	LXI	D,DEST$FCB	;delete any previous accurance of dest file
	MVI	C,DELT
	CALL	BDOS
	LXI	H,DEST$FCB+1	;copy name to lower half of FCB for RENAME
	LXI	D,DEST$FCB+17
	LXI	B,11
	LDIR
	DCX	H
	MVI	M,'$'	;set source type of rename to "$$$"
	DCX	H
	MVI	M,'$'
	DCX	H
	MVI	M,'$'
	XRA	A
	STA	DEST$FCB+16
	LXI	D,DEST$FCB	;rename temp file to destination name
	MVI	C,RENAME
	CALL	BDOS
	CPI	255
	JZ	RENERR

	lxi	d,endnam
	lxi	h,source$fcb
	call	setnam
	lda	dest$drive
	sta	endrv
	lxi	h,endmsg	; output copyed sucessfully
	call	outmsg
	ret

SNF	lxi	d,nofnam
	lxi	h,source$fcb
	call	setnam
	LXI	h,no$file	; file Not Found
	call	outmsg
	ret			; continue if not found

DFULL	LXI	h,NOSP		; destination directory full
OUTER	CALL	outmsg
	JMP	REBOOT

DWE	CPI	255	;Destination Write Error (disk or directory?)
	JRZ	DFULL	;directory full message if directory was full
	LXI	h,WERR	;else use "write error" message
	JR	OUTER

VRE	POP	H	;Verify operation Read Error
	LXI	h,RERR
	JR	OUTER

NOVRF	POP	H	;Negative Verification on data
	LXI	h,VERR
	JR	OUTER

RENERR	LXI	h,RENR	;Error while Renaming dest file
	JR	OUTER

ZERO$REST:	;fill remainder of FCB with zeros
	MVI	M,0
	MOV	D,H
	MOV	E,L
	INX	D
	LXI	B,23
	LDIR
	RET

END$S:	;end of source file detected
	XRA	A
	CMA
	STA	EOF$FLAG	;set End Of File flag
	LDED	MAX$BUFFER	;compute number of records read
	XCHG
	DSBC	D
	JMP	WRITE$BLOCK	;begin write sequence


; boot loader module mode code tables

drvntbl db	29
	dw	btm29
	db	33
	dw	btm33
	db	0
	dw	btm0
	db	46
	dw	btm46
	db	0FFh

btm29	db	0		; SS ST SD
	db	2		; SS ST DD
	db	0		; SS DT SD
	db	2		; SS DT DD
	db	0		; DS ST SD
	db	2		; DS ST DD
	db	0		; DS DT SD
	db	2		; DS DT DD

btm33	db	4
	db	4
	db	6
	db	6
	db	4
	db	4
	db	6
	db	6

btm0:
btm46:	db	1
	db	1
	db	3
	db	3
	db	1
	db	1
	db	3
	db	3

;
;	Fcb's for copy routine
;

ccpcom	db	'CCP     COM'

cpm3sys db	'CPM3    SYS'

SOURCE$FCB:
	DB	0,'???????????',0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0

DEST$FCB:
	DB	0,'           ',0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0

;
;	VARIABLES
;

SDISK:	DB	0	;SELECTED DISK FOR CURRENT OPERATION
TRACK:	DB	0	;CURRENT TRACK
SECTOR: DB	0	;CURRENT SECTOR
RW:	DB	0	;READ IF 0, WRITE IF 1
DMADDR: DW	0	;CURRENT DMA ADDRESS
DPB:	DW	0
NEEDED: DB	0
secsiz: dw	0
cdrvnum db	0	;current physical drive number

BUFFER$POINTER	DW	0	;pointer to current buffer record
BUFFER$START	DW	0	;end of loader, start of copy buffer
MAX$BUFFER	DW	0
EOF$FLAG	DB	0
DEST$DRIVE	DB	0	;destination drive number
SOUR$DRIVE	DB	0	;source drive number

	DS	32
STACK:	DS	0

BUFFER	DS	128	; buffer for verify of copy

LOADP:
	END
