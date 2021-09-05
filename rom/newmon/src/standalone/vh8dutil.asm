; Standalone utility to dump core for CP/M 3 (H8x512K) on VDIP1
; linked with vdip1.rel
VERN	equ	010h

	extrn	strcpy,strcmp,sync,runout
	extrn	vdcmd,vdend,vdrd,vdmsg,vdout,vdprmp
	public	vdbuf

CR	equ	13
LF	equ	10
BEL	equ	7
CTLC	equ	3
BS	equ	8

	maclib	z180
	maclib	core
	aseg
	maclib	ram

;...

; Commands:
;	D n	set Drive number
;	V n	set Volume ID
;	I n	Set sector Interleave
;	R file	Restore image from file (Recreate floppy)
;	S file	Save image to file (Save floppy)

zbuf	equ	0a00h	; buffer size 1 track
zstk	equ	100h	; stack size

; disk addresses for H17Floppy ROM and RAM
dabort	equ	2061h	; jmp L1bf6
dsdp	equ	2085h
dsdt	equ	2076h
dsts	equ	2088h
clock	equ	1c19h	; 034.031 CLOCK
rsdp	equ	1e32h	; 036.062 R.SDP
wsp1	equ	1eedh	; 036.355 W.SP1
dwnb	equ	2097h
dxok	equ	205eh
dwrite	equ	206dh
dread	equ	2067h
uivec	equ	201fh
mflag	equ	2008h
dtt	equ	20a0h
ddlyhs	equ	20a4h
ddvctl	equ	20a2h
ddlymo	equ	20a3h
ddrvtb	equ	20a9h
dvolpt	equ	20a7h
dwhda	equ	2053h
ddts	equ	2073h
dudly	equ	208eh
dwsc	equ	2091h
drdb	equ	2082h


	cseg
	di
	lxi	sp,spint
	lda	prodid	; LSB of product ID
	ani	prnofp	; No FP?
	sta	nofp

	; hack R.SDP to work for 3 drives
	lxi	h,m$sdp
	shld	D$CONST+62

	mvi	a,0c3h	; jmp
	sta	uivec
	lxi	h,clock
	shld	uivec+1
	lxi	sp,spint
	lxi	h,mflag	; turn on counter
	mov	a,m
	ori	00000001b
	mov	m,a
	call	ena2ms
	ei
	lxi	d,signon
	call	print
	lxi	d,phelp
	call	print
	; (2mS intr must be ON) track 0
	call	shwprm
	lda	curdrv
	sta	AIO$UNI
main1:
	; Prompt for command and params,
	; perform command,
	; close file...
	call	comnd
	jrnc	main1
exit:
	call	dis2ms
	lhld	retmon
	pchl

abort:	lxi	d,abrted
	call	print
	lxi	h,clf
	call	vdcmd
	jr	main1

; Turn on 2mS clock intrs, interrupts already disabled
ena2ms:	lda	nofp
	ora	a
	jrnz	nfp2ms	; H89 and/or extended H8-Z80 boards
	lxi	h,ctl$F0
	mov	a,m
	sta	sav$F0
	ori	01000000b	; 2mS ON
	mov	m,a
	out	0f0h
	ret
nfp2ms:	lxi	h,ctl$F2
	mov	a,m
	sta	sav$F2
	ori	00000010b	; 2mS ON
	mov	m,a
	out	0f2h
	ani	00000010b	; unlock enable
	out	0f3h		; special Z80 board extension
	ret

dis2ms:	lda	nofp
	ora	a
	jrnz	nfp0ms
	lda	sav$F0
	sta	ctl$F0
	out	0f0h
	ret
nfp0ms:	lda	sav$F2
	sta	ctl$F2
	out	0f2h
	ani	00000010b	; unlock enable
	out	0f3h		; special Z80 board extension
	ret

nofp:	db	0
sav$F0:	db	0
sav$F2:	db	0

; format a single track
; B = track C = vol#
ftrk:
	di
	lxi	h,mflag	; turn on counter
	mov	a,m
	ori	00000001b
	mov	m,a
	mov	a,b
	sta	dtt
	mvi	a,2
	sta	ddlyhs
	xra	a
	out	7fh
	sta	ddvctl
	sta	ddlymo
	lxi	h,ddrvtb+1
	shld	dvolpt
	mov	m,c
	ei
	call	m$sdp	; hacked sdp
	call	dsdt	; dis intrs
	xra	a
	out	7eh
	inr	a
	sta	dwhda
	lda	ddvctl
	inr	a
	out	7fh
trk1:
	call	dsts	; skip this sector
	lda	ddlyhs
	ana	a
	jnz	trk1	; wait delay
	lhld	dvolpt
	mov	b,m	; vol#
	lhld	secpntr	; sec interleave table
trk2:
	mvi	c,10
	call	wsp1	; writes 0's
	mov	a,b	; vol#
	call	dwnb
	lda	dtt	; track
	call	dwnb
	mov	a,m	; sec#
	call	dwnb
	inx	h	; incr sec pntr
	mov	a,d	; ?chksum?
	call	dwnb
	mvi	c,16
	call	wsp1
trk3:
	call	dwnb
	dcr	c	; 256 0's
	jnz	trk3
trk4:
	xra	a
	call	dwnb	; end pad
	in	7fh
	rar
	jnc	trk4	; until sec end
	mov	a,m
	ora	a	; 0 marks end of sectable
	jnz	trk2	; until end of track
	lda	ddvctl
	out	7fh
	ei
	call	dxok
	mvi	a,20
	sta	dwhda
	lxi	h,mflag	; turn off counter ?
	mov	a,m
	ani	11111110b
	mov	m,a
	ret

; Read file from VDIP1 into 'buffer'.
; Reads 1 H17 track - 10x256 sectors.
; File was already opened.
; Read 128 bytes at a time, as per vdrd routine.
vrtrk:	lxi	h,buffer
	mvi	b,20	; 20 records == 10 sectors
vrt0:	push	b
	call	vdrd
	pop	b
	rc	; error
	djnz	vrt0
	ret

; Write to file on VDIP1 from 'buffer'.
; Writes 1 H17 track - 10x256 sectors.
; File was already opened (for write).
; Write 512 bytes at a time.
vwtrk:	lxi	d,buffer
	mvi	b,5	; 5x512 == 10x256
vwt0:	push	b
	call	vdwr
	pop	b
	rc
	djnz	vwt0
	ret

; This probably should be in vdip1.asm...
; DE=data buffer (dma adr)
; Returns DE=next
vdwr:	lxi	h,wrf
	call	vdmsg
	lxi	b,512
vdwr0:	ldax	d
	call	vdout
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jrnz	vdwr0
	push	d
	call	vdend
	pop	d
	ret	; CY=error

wrf:	db	'wrf ',0,0,2,0,CR,0	; 512 byte writes

; Copy tracks from image file onto H17
wrimg:
	call	m$sdp	; select unit number from AIO$UNI
	xra	a
	sta	secnum
	sta	secnum+1
	sta	curtrk
wrimg1:
	lxi	h,ddrvtb+1
	mov	m,a
	shld	dvolpt
;
	call	vrtrk	; read track from image
	rc
;
	lda	curtrk
	mov	b,a
	ora	a
	jz	wrimg3	; c is zero from above
	lda	curvol	;  on first track
wrimg3:
	mov	c,a	;  use vol# on the rest
	call	ftrk	; format this track (B=track, C=volume
	lda	curtrk
	inr	a
	sta	curtrk	; only used to detect track 0
;
	lxi	b,zbuf
	lxi	d,buffer
	lhld	secnum
	call	wrbuf
;
	mvi	a,'R'
	call	chrout
	call	ckctlc
	jc	abort

	lhld	secnum
	lxi	d,10	; sec/trk
	dad	d
	shld	secnum
	lxi	d,-400	; 400 sectors max
	dad	d
	mov	a,h
	ora	l
	lda	curvol
	jnz	wrimg1	; last track?
	jmp	crlf

; Write sector(s) to H17
; BC = buffer size
; DE = buffer addr
; HL = first sec#
wrbuf:
	mvi	a,2
	sta	ddlyhs
	call	dwrite
	ret

; Copy all tracks from H17 to image file
rdimg:
	call	m$sdp	; select unit number from AIO$UNI
	xra	a
	sta	secnum
	sta	secnum+1
rdimg1:
	lxi	h,ddrvtb+1
	mov	m,a
	shld	dvolpt
;
	lxi	b,zbuf
	lxi	d,buffer
	lhld	secnum
	call	rdbuf	; read track off diskette
;
	call	vwtrk
	rc
	mvi	a,'S'
	call	chrout
	call	ckctlc
	jc	abort

	; next sector...
	lhld	secnum
	lxi	d,10	; sec/trk
	dad	d
	shld	secnum
	lxi	d,-400	; 400 sectors max
	dad	d
	mov	a,h
	ora	l
	lda	curvol
	jnz	rdimg1
	jmp	crlf

; Read sector(s) from H17
; BC = buffer size
; DE = buffer addr
; HL = first sec#
rdbuf:
	mvi	a,2
	sta	ddlyhs
	call	dread	; if carry, read error
	cmc		; if carry, no error
	sbb	a	; -1 if good read, else 0
	sta	goodrd
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routines for interactive, VDIP1

; Read a command line, parse it, execute it.
; Return CY if Ctrl-C
comnd:
	lxi	d,prompt
	call	print
	call	linein	; if NC, C=length
	rc
	lxi	h,buffer
	call	skipb
	jrc	comnd
	inx	h
	ani	01011111b	; toupper
	cpi	'H'
	jrz	chelp
	cpi	'D'
	jrz	cdrive
	cpi	'V'
	jrz	cvolnm
	cpi	'I'
	jrz	cintlv
	cpi	'R'
	jrz	crestr
	cpi	'S'
	jz	csave
invcmd:	lxi	d,invld
	call	print
	jr	chelp
badcmd:
	push	h
	mvi	a,'"'
	call	chrout
	pop	d
	call	print
	mvi	a,'"'
	call	chrout
	call	crlf
	lxi	d,syntax
	call	print
chelp:
	lxi	d,signon
	call	print
	lxi	d,help
	call	print
	jr	comnd

failvd:	; TODO: dump vdbuf?
	lxi	d,failed
	call	print
	jr	comnd

cdrive:	call	skipb
	call	parsnm
	jrc	badcmd
	mov	a,d
	cpi	3	; 3 drives supported by hacking ROM routine
	jrnc	badcmd
	sta	curdrv
	sta	AIO$UNI
showup:	call	shwprm
	jr	comnd

cvolnm:	call	skipb
	call	parsnm
	jrc	badcmd
	mov	a,d
	sta	curvol
	jr	showup

cintlv:	call	skipb
	call	parsnm
	jrc	badcmd
	mov	a,d
	cpi	10
	jrnc	badcmd
	call	mkmap
	jr	showup

; Restore image file onto a diskette
crestr:	call	skipb
	lxi	d,opr+4
	call	strcpy
	mvi	a,CR	; TODO: need to trim?
	stax	d
	lxi	h,opr
	call	vdcmd
	jc	failvd	; no need for close...
	call	shwprm
	call	dinit
	call	wrimg
	; CY if error
	push	psw
	lxi	h,clf
	call	vdcmd
	pop	psw
	jc	failvd
	jmp	comnd

; Save diskette image in file
csave:	call	skipb
	lxi	d,opw+4
	call	strcpy
	mvi	a,CR	; TODO: need to trim?
	stax	d
	lxi	h,opw
	call	vdcmd
	jc	failvd	; no need for close...
	; TODO: need to truncate?
	call	shwprm
	call	dinit
	call	rdimg
	; CY if error
	push	psw
	lxi	h,clf
	call	vdcmd
	pop	psw
	jc	failvd
	jmp	comnd

dinit:	lxi	h,isinit
	mov	a,m
	sui	1
	rnc
	mov	m,a
	jmp	dabort	; (2mS intr must be ON) track 0, select AIO$UNI

clf:	db	'clf',CR,0
opw:	db	'opw ','filename.typ',CR,0
	ds	16	; safety margin
opr:	db	'opr ','filename.typ',CR,0
	ds	16	; safety margin

; Skip blanks.
; HL=buffer curptr
; Return: CY if EOL, A=non-blank-char
skipb:	mov	a,m
	cpi	' '
	jrz	skb0
	ora	a
	rnz
	stc
	ret
skb0:	inx	h
	jr	skipb

shwprm:
	lxi	d,msgusg
	call	print
	lda	curdrv
	adi	'0'
	call	chrout
	lxi	d,usg1
	call	print
	lda	curvol
	call	decout
	lxi	d,usg2
	call	print
	lxi	d,sectbl
	mvi	b,10
	call	aryout
	jmp	crlf

; Create the 10-sector interleave table for formatting
; A = interleave factor (0 => 1)
mkmap:	ora	a
	jrnz	mkm4
	inr	a
mkm4:	push	psw
	lxi	h,buffer
	mvi	b,10
	xra	a
mkm1:	mov	m,a
	inx	h
	dcr	b
	jnz	mkm1
	lxi	h,buffer
	lxi	d,sectbl
	lxi	b,0
mkm0:	mvi	m,1	; flag as used
	xchg
	mov	m,c
	inx	h
	xchg
	pop	psw
	push	psw
	add	c
	cpi	10
	jc	mkm3
	sui	10
mkm3:	mov	c,a
	lxi	h,buffer
	dad	b
mkm2:	mov	a,m
	ora	a
	jz	mkm0
	inr	c
	inx	h
	mov	a,c
	cpi	10
	jc	mkm2
	pop	psw
	ret

; Print Array of values 0-9.
; DE = array, B = num elements
aryout:
	mvi	a,' '
	call	chrout
	ldax	d
	inx	d
	adi	'0'
	call	chrout
	djnz	aryout
	ret

; input a line from console, allow backspace
; returns C=num chars
linein:
	lxi	h,buffer
	mvi	c,0	; count chars
lini0	call	chrin
	cpi	CR
	jrz	linix
	cpi	CTLC	; cancel
	stc
	rz
	cpi	BS
	jrz	backup
	cpi	' '
	jrc	chrnak
	cpi	'~'+1
	jrnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	c
	jm	chrovf	; 128 chars max
	call	chrout
	; TODO: detect overflow...
	jr	lini0

linix:	mvi	m,0	; terminate buffer
	jmp	crlf

chrovf:	dcx	h
	dcr	c
chrnak:	mvi	a,BEL
	call	chrout
	jr	lini0
backup:
	mov	a,c
	ora	a
	jrz	lini0
	dcr	c
	dcx	h
	mvi	a,BS
	call	chrout
	mvi	a,' '
	call	chrout
	mvi	a,BS
	call	chrout
	jr	lini0

crlf:	mvi	a,CR
	call	chrout
	mvi	a,LF
	jmp	chrout

; A=number to print
; leading zeroes blanked - must preserve B
decout:
	push	b
	mvi	c,0
	mvi	d,100
	call	divide
	mvi	d,10
	call	divide
	adi	'0'
	call	chrout
	pop	b
	ret

hexout:
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:	ani	0fh
	adi	90h
	daa
	aci	40h
	daa
	jmp	chrout

divide:	mvi	e,0
div0:	sub	d
	inr	e
	jrnc	div0
	add	d
	dcr	e
	jrnz	div1
	bit	0,c
	jrnz	div1
	ret
div1:	setb	0,c
	push	psw	; remainder
	mvi	a,'0'
	add	e
	call	chrout
	pop	psw	; remainder
	ret

; Parse a 8-bit (max) decimal number
; HL=string, NUL terminated
; Returns D=number, CY=error
parsnm:
	lxi	d,0
pd0:	mov	a,m
	ora	a
	rz
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rc
	ani	0fh
	mov	e,a
	mov	a,d
	add	a	; *2
	rc	
	add	a	; *4
	rc	
	add	d	; *5
	rc	
	add	a	; *10
	rc	
	add	e	;
	rc
	mov	d,a
	inx	h
	jr	pd0

chrout:	push	psw
cono0:	in	0edh
	ani	00100000b
	jrz	cono0
	pop	psw
	out	0e8h
	ret

chrin:	in	0edh
	ani	00000001b
	jrz	chrin
	in	0e8h
	ani	01111111b
	ret

ckctlc:	in	0edh
	ani	00000001b
	rz
	in	0e8h
	ani	01111111b
	cpi	CTLC	; cancel
	rnz
	stc	; CY=cancel
	ret

print:	ldax	d
	ora	a
	rz
	call	chrout
	inx	d
	jr	print

; hack to support 3 drives on H17
m$sdp:
	mvi	a,10
	sta	DECNT
	lda	AIO$UNI
	push	psw	; 0,1,2
	adi	-2	;
	aci	3	; 1,2,4
	jmp	rsdp+10	; hacked R.SDP for 3-drives

msgusg:	db	'Using drive ',0
usg1:	db	', volume ',0
usg2:	db	', secmap',0
prompt:	db	'H8DUTIL> ',0
signon:	db	'H8DUTIL v',(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0',0
phelp:	db		' - Type H(cr) for help',CR,LF,0
help:	db		' Commands:',CR,LF
	db	'  D n     set Drive number',CR,LF
	db	'  V n     set Volume ID',CR,LF
	db	'  I n     set sector Interleave',CR,LF
	db	'  R file  Restore image from file (Recreate floppy)',CR,LF
	db	'  S file  Save image to file (Save floppy)',CR,LF
	db	'  H       Print this help message',CR,LF
	db	0
invld:	db	'Invalid command',CR,LF,0
syntax:	db	'Syntax error',CR,LF,0
failed:	db	'Command failed',CR,LF,0
abrted:	db	' *aborted*',CR,LF,0

isinit:	db	0
curdrv:	db	0
curvol:	db	0
sectbl:	db	0,1,2,3,4,5,6,7,8,9
secend:	db	0	; still used?

goodrd:	db	0
secpntr: dw	sectbl
curtrk:	db	0
secnum:	dw	0	; 100K disk = 400 sectors max
dummy:	db	0ffh,0,0ffh,0	; insure async alignment

dbend:
buffer:
	ds	zbuf

vdbuf:	ds	512

	ds	zstk
spint:

	end
