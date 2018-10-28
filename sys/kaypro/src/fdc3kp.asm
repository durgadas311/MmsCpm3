vers equ '0e' ; March 18, 2017  17:04  drm  "FDC3KP.ASM"
;*********************************************************
; Floppy Disk I/O module for CP/M 3.1 on KAYPRO
; Copyright (c) 1986 Douglas Miller
;*********************************************************

	MACLIB Z80

	extrn @dph,@rdrv,@side,@trk,@sect,@dma,@dbnk,@dstat
	extrn @dtacb,@dircb,@scrbf,@rcnfg,@cmode
	extrn ?bnksl,?timot,?getdp
	extrn ?halloc

false	equ	0
true	equ	not false

; Ports and Constants
fdc	equ	010h	;floppy disk controller
sysctl	equ	014h	;floppy disk control bits

*********************************************************
**  FDC (WD1793-02 Floppy Disk Controller)
*********************************************************
FDCSTAT equ	FDC+0
FDCCOMD equ	FDC+0
FDCTRK	equ	FDC+1
FDCSEC	equ	FDC+2
FDCDATA equ	FDC+3

dev0	equ	33		; first drive in system
ndev	equ	3		; # of drives is system
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
DPEH37	EQU	60H		; I.D.

;--------- Start of Code-producing Source --------------

	cseg		;put only whats necessary in common memory...

	dw	thread
	db	dev0,ndev
	jmp	init
	jmp	login
	jmp	read$fdc
	jmp	write$fdc
	dw	string
	dw	dphtbl,modtbl

string: DB	'KAYPRO ',0,'Floppy Disk Controller ',0,'3.10'
	dw	vers
	db	'$'

modtbl:
 DB   00000000b,00000001b,01010000B,01011000B ; drive 33 kaypro,DS,ST,5"
   db 10000000b,00000000b,11110010b,00000000b
 DB   00000000b,00000001b,01010000B,01011000B ; drive 34 kaypro,DS,ST,5"
   db 10000000b,00000000b,11110010b,00000000b
 DB   00000000b,00000001b,01010000B,01011000B ; drive 35 kaypro,DS,ST,5"
   db 10000000b,00000000b,11110010b,00000000b

motor$off: db	0	;must be directly after MODTBL
selmsk:	db	0	;

motoff: lda	motor$off 
	cpi	true
	rz
	lda	selmsk
	mov	b,a
	; all drives are the same, any mode will do?
	lda	modtbl+2
	bit	1,a	; QT drive?
	in	sysctl
	jrnz	motoff0
	ani	10101111b	; motor off
motoff0:
	ora	b	; select off
	out	sysctl
	mvi	a,true
	sta	motor$off
	ret

dpb0:	ds	17	;disks may have labels.
dpb1:	ds	17	;
dpb2:	ds	17	;

savNMI: ds	1

savSTK: ds	2
	ds	8
rwSTK:	ds	0

type$II$ext:
	lda	@dbnk
	call	?bnksl
	lxi	h,0066h
	mov	a,m
	mvi	m,(RET)
	sta	savNMI
	lhld	@dma
	mov	a,e
	mov	e,c
	mvi	c,fdcdata
	di
	out	fdccomd
	ret	;jump to appropriate routine
rd4:	hlt
rd42:	INI ; or OUTI
	jnz	rd4
rd3:	hlt
rd32:	INI ; or OUTI
	jnz	rd3
rd2:	hlt
rd22:	INI ; or OUTI
	jnz	rd2
rd1:	hlt
rd12:	INI ; or OUTI
	jnz	rd1
	ei
	hlt
rd0:	in	fdcstat
	rrc
	jrc	rd0
	rlc
	ana	d
	push	psw
	mvi	a,11010000b	;reset 1797 to TYPE$I status
	out	fdccomd 	;
	in	fdcstat 	;
	lda	savNMI
	sta	0066h
	mvi	a,0
	call	?bnksl
	pop	psw
	lspd	savSTK
	ret

thread	equ	$	;must be last statement in "cseg"

	dseg		;put most everything in banked memory...

dphtbl: dw 0,0,0,0,0,0,dpb0,csv0,alv0,@dircb,@dtacb,0ffffh
	db 0	;(hash buffer bank number)
	dw 0,0,0,0,0,0,dpb1,csv1,alv1,@dircb,@dtacb,0ffffh
	db 0
	dw 0,0,0,0,0,0,dpb2,csv2,alv2,@dircb,@dtacb,0ffffh
	db 0

csv0:	ds	(1024)/4    ;max dir entries: 1024
csv1:	ds	(1024)/4
csv2:	ds	(1024)/4

alv0:	ds	(1351)/4    ;max dsk blocks: 1351
alv1:	ds	(1351)/4
alv2:	ds	(1351)/4

; Max DRM+1 is 1024 (getdp3kp.asm)
init:
	; TODO: detect Kaypro 10 (only one floppy) and do not init all 3.
	lda	0052h	; gift from loader: select mask
	sta	selmsk
	lda	0051h	; gift from loader: drive(s) type
	cpi	1	; ST (or at least not QT)
	jrz	initST
	cpi	2	; QT
	jrz	initQT
	; else error, just leave as-is
init0:
	IN	fdcstat 	; CLEAR WD-1793 from power-on (or whatever)
	push	psw
	jmp	setmot	; set timeout in case no more activity
	; RET

initST:
	lxi	h,modtbl+2
	mvi	b,3
ist0:
	res	5,m
	res	1,m
	res	0,m
	inx	h
	res	5,m
	lxi	d,7
	dad	d
	djnz	ist0
	jr	init0

initQT:
	lxi	h,modtbl+2
	mvi	b,3
iqt0:
	setb	5,m
	setb	1,m
	setb	0,m
	inx	h
	setb	5,m
	lxi	d,7
	dad	d
	djnz	iqt0
	jr	init0

login:
	pushix		;save IX
	lixd	@cmode
	inxix
	inxix
	sixd	cmode	;save cmode+2 for faster access to modes
	xra	a
	sta	selerr		; NO SELECT ERROR (YET)
	bitx	7,+1		; SHOULD WE READ TRACK 0 SECTOR 0 ?
	cnz	physel
	bitx	7,+0		; IS IT A 5.25" DISK ?
	jrnz	login1
	lda	selerr
	ora	a		; was there a select error
	cz	physel3 	; CHECK FOR HALF TRACK: must update DPB.
login1: popix
	; use max hash size ever needed, even if QT drives not installed.
	; Even if we have 5 drives (2 win, 3 flpy) we still won't
	; consume all the hash space (~55K). It is not fatal if we try
	; to allocate more hash than available, just sub-optimal for those
	; drives that fail.
	lxi	b,1024*4	; safe value - the max ever used
	call	?halloc
	;
	lda	selerr	;return error code, error during configuration.
	ora	a
	ret

physel: 
	lxi	h,0		;
	shld	@trk		; TRACK 0
	shld	@sect		; SECTOR 0
	lhld	@scrbf		;use BIOS scratch buffer to read Z37 label.
	shld	@dma	;we must also make sure that bank 0 is selected.
	xra	a
	sta	@dbnk	;set disk bank=0 (the bank we're in now)
	sta	@side	;side=0
	STA	MODFLG		; RESET CHANGED MODE FLAG
	mvi	a,true		; flag a select operation
	sta	selop
	MVI	A,5		; 5 RETRYS FOR A SELECT OPERATION
	STA	RETRYS
	CALL	READ		; TRY READING LABEL AT DENSITY
				; CURRENTLY INDICATED IN TABLES
	JZ	PHYSEL1 	; BR IF SUCCESSFUL
	bitx	7,+0
	jnz	physel6 	; if 8" error out
	MVI	A,5		; RESET RETRYS TO 5
	STA	RETRYS
	STA	MODFLG		; SET CHANGED MODE FLAG
			; IX=mode bytes
	ldx	a,+1		; TRY OTHER DENSITY
	XRI	00010000b
	stx	a,+1
	CALL	READ		; TRY TO READ LABEL
	jrz	physel1 	
	ldx	a,+1
	xri	00010000b	; return mode bytes to former state
	stx	a,+1
	jmp	physel6 	; jmp to error
PHYSEL1:XRA	A		; ZERO ACCUM.
	MVI	B,LABLEN	; GET LENGTH OF LABEL
	lhld	@scrbf
	LXI	d,LABEL
	dad	d
CHKLAB1:ADD	M
	INX	H
	DJNZ	CHKLAB1
	INR	A
	JRZ	PHYSEL2 	; BR IF CORRECT CHECKSUM
	LDA	MODFLG
	ORA	A		; MODE BEEN CHANGED ?
	jz	physel7 	; NO KEEPING OLD MODE BYTES
	ldx	a,+1
	xri	00010000b	; return mode bytes to former state
	stx	a,+1
	jmp	physel6 	; jmp to error

;
;  EXTRACT MODE INFORMATION FROM LABEL
;
physel2:
	lhld	@scrbf
	lxi	d,LABHTH
	dad	d		; HL POINTS TO HEATH EXTENSION IN LABEL
	ldx	b,-1		; keep old format 
	ldx	c,-2
	mvix	0,-1
	mvix	0,-2
	mov	a,m
	ani	111$00000b
	cpi	001$00000b	; z100 formats
	jrnz	nf1
	setx	5,-1;		; set mode byte
	jr	setmode
nf1:	cpi	011$00000b	; z37
	jrnz	nf2
	bit	2,m		; check for extended density
	jrz	gf1
	setx	4,-1		; z37x
	jr	setmode
gf1:	liyd	@scrbf		; get cpm sectors per physical sector
	ldy	a,+labhth+2
	cpi	4		; see if 512 byte sectors - if so set to z100
	jrnz	gf0		; this is in here because the Z100 puts the
	setx	5,-1		; device type code in the label on 5"
	jr	setmode
gf0:	setx	3,-1		; z37
	jr	setmode
;; currently no 8" support in this module
nf2: ;	cpi	100$00000b	; z47
;	jrnz	nf3
;	bit	2,m		; check for extended density
;	jrz	gf2
;	setx	6,-1		; z47x
;	jr	setmode
;gf2:	 setx	 5,-1
;	jr	setmode
nf3: ;	cpi	110$00000b	; z67
;	jrz	f1		; keep old mode if device type not valid
	stx	b,-1
	stx	c,-2
	jmp	physel7
;f1:	 setx	 7,-1		 ; z67
setmode:
	mov	a,m		; get flag byte
	bit	3,a		; track density bit
	jrz	gs0
	setx	5,+0		; set drive and media to dt
	setx	5,+1
	jr	gs2 
gs0:	resx	5,+0
	resx	5,+1
gs2:	bit	1,a		; density bit
	jrz	gs1
	setx	4,+1
	jr	gs3
gs1:	resx	4,+1
gs3:	bit	0,a		; sides bit
	jrz	gs4
	setx	6,+1
	jr	gs6
gs4:	resx	6,+1
gs6:
	lhld	@cmode
	call	?getdp		; setup mode bytes
	jnz	physel6 	; error if format doesnt exists
	liyd	@dph		; set dpb addr in dph
	sty	c,+0		; store XLAT address in DPH
	sty	b,+1
	ldy	l,+12		; get DPB address in DPH
	ldy	h,+13
	xchg
	lhld	@scrbf
	lxi	b,labdpb
	dad	b
	lxi	b,15
	ldir			; move dpb 

	xchg			; hl points to psh byte (15)
	liyd	@scrbf
	ldy	a,+labhth+2
	mov	b,a		; save CP/M sectors per physical sector
	mvi	c,0
pshlp	srlr	a		; rolate LSB into [cy]
	jc	psh1
	inr	c
	jr	pshlp
psh1	mov	m,c		; set PSH byte
	inx	h		; mode pointer to PSM
	dcr	b
	mov	m,b		; put in dpb
	JR	PHYSEL7

PHYSEL6:MVI	A,1
	STA	SELERR		; FLAG A SELECT ERROR
PHYSEL7:
	call	done		; setup motor turn-off
	lxi	h,selop
	mvi	m,false 	; SELECT OPERATION IS OVER
	ret

physel3:
	CALL	SELECT
	JRC	PHYSEL6 	; ERROR IF NOT READY
	CALL	HOME		;RESTORE HEAD TO TRACK 0
	JRC	PHYSEL6
	MVI	B,01001000B	;STEP IN, NO UPDATE
	CALL	TYPE$I
	CALL	TYPE$I
	CALL	TYPE$I
	CALL	TYPE$I		;STEP IN FOUR TIMES
	call	read$addr	; READ ADDRESS
	lda	@dstat
	ANI	00011000B SHL 1 ;check for FDC error.
	JRNZ	PHYSEL6
	lhld	cmode
	mov	b,m
	inx	h
	mov	c,m
	in	fdcsec	;track number, from read-addr
	CPI	4
	JRZ	phy4s2	; drive matches media...
	CPI	2
	JRZ	phy4s3	; media has half the tracks of drive
	CPI	1
	JRNZ	PHYSEL6
	; media has 1/4 tracks as drive...
	; must be ST media in QT drive...
	setb	1,b	;make drive "QT"
	setb	5,b	;make drive "DT" also
	res	0,b	;make media non-QT
	res	5,c	;make disk "ST" and reconfigure
phy4s0:	; update mode bytes, check for changes...
	mov	a,c
	xra	m
	mov	m,c
	dcx	h
	mov	c,a
	mov	a,b
	xra	m
	mov	m,b
	ora	c	; NZ if either byte changed...
	jz	PHYSEL4
	mvi	a,0ffh
	sta	@rcnfg	;set "re-configure" flag so BIOS will get new DPB/XLAT
PHYSEL4:
	CALL	HOME  
	JRC	PHYSEL6
	JR	PHYSEL7

phy4s2:	; drive tpi matches media, but force media modes
	bit	5,b
	jrz	phy4s20
	setb	5,c
	jr	phy4s21
phy4s20:
	res	5,c
phy4s21:
	bit	1,b
	jrz	phy4s22
	setb	0,b
	jr	phy4s0
phy4s22:
	res	0,b
	jr	phy4s0

phy4s3:	; use drive settings if possible...
	; NOTE: this case would not normally exist on a Kaypro.
	; must be at least a DT drive, non-QT media, so force that
	setb	5,b	;make drive "DT"
	res	0,b	;make media non-QT
	bit	1,b	;test drive "QT"
	jrnz	phy4s4
	res	5,c	;make media "ST" in DT drive
	jr	phy4s0

phy4s4:	; QT drive, so media must be DT...
	setb	5,c	;make media "DT" in QT drive
	jr	phy4s0

setup$rw:
	MVI	A,21		; 21 RETRYS FOR A READ/WRITE OPERATION
	STA	RETRYS
	lhld	@cmode
	inx	h
	inx	h
	shld	cmode
	ret

read$fdc:
	call	setup$rw
READ:	CALL	ACCESS$R	; START DRIVE AND STEP TO PROPER TRACK
	JRC	ERROR
	lxi	d,10011111$10001000B	 ; status mask + read command
	JR	TYPE$II

error:	xra	a		; [NZ] to indicate error
	inr	a
done:	push	psw
	lda	selop
	ora	a
	jrnz	retrn
	mvi	a,false 	;motor off false
	sta	motor$off
setmot:
	lxi	d,motoff
	mvi	c,15	;15 seconds
	mvi	b,dev0	;I.D.
	call	?timot
retrn:	pop	psw
	ret

write$fdc:
	call	setup$rw
WRITE:	LHLD	CMODE		; CHECK FOR HALF TRACK R/O
	bit	5,m	;see if drive is DT.
	jrz	ht0
	inx	h
	bit	5,m	;see if media is not DT.
	jrz	ERROR		; R/O ERROR
ht0:	CALL	ACCESS$R	; ACCESS DRIVE FOR WRITE
	JRC	ERROR
	in	fdcstat
	sta	@dstat		; save DISK STATUS BYTE
	ani	01000000b	; WRITE PROTECT BIT
	jrnz	ERROR		; WRITE PROTECT ERROR
	lxi	d,11111111$10101000B	 ; status mask + write command

TYPE$II:
	lhld	cmode
	inx	h
	mov	a,m
	ani	1	;sector offset
	lxi	h,@sect 	; GET SECTOR NUMBER
	add	m	;others use sectors 1-n
	OUT	fdcsec		; give to controller
RETRY:						     
	PUSH	d		; save registers

	CALL	TYPE$II$COM	; execute disk transfer routine.
	STA	@dstat		; save status of transfer
	XRA	A		; CLEAR CARRY FOR DSBC
	lded	@dma 
	DSBC	D		; HL NOW CONTAINS # OF BYTES TRANSFERRED
	LDA	@dstat		; check for successful transfer
	ANI	11111111B	; WP is 0 for any read command.
	JRNZ	IOERR		; RETRY IF ERROR
	LDA	SELOP		; IS THIS A SELECT OPERATION ?
	ORA	A
	jrnz	POPRET		; THEN DON'T CHECK SECTOR SIZE
	LDA	BLCODE		; CHECK IF CORRECT NUMBER OF BYTES TRANSFERRED
	CPI	3
	JRNZ	NOTED		; BLCODE=3 => 1024 BYTE SECTOR EXPECTED
	INR	A		; INCREMENT BECAUSE (H) FOR 1024 IS 4
NOTED:	CMP	H		; COMPARE TO EXPECTED SIZE
POPRET:
	POP	d
	mvi	a,0	;signal "no error" to BDOS.
	jrz	done		; RETURN IF CORRECT
	JR	TRYAGN		; RETRY IF INCORRECT
IOERR:
	POP	B
	JM	ERROR		; ERROR IF NO READY SIGNAL
TRYAGN:
	LXI	H,RETRYS	; decrement retry count
	DCR	M
	JZ	ERROR		; NO MORE RETRIES
	MOV	A,M
	CPI	10
	JNC	RETRY		; LESS THAN TEN RETRYS LEFT => STEP HEAD
	LDA	SELOP
	ORA	A
	jnz	RETRY		; DO NOT STEP HEAD IF SELECT OPERATION
	PUSH	d		; SAVE REGISTERS
	CALL	STEPIN		; STEP IN COMMAND
	CALL	SEEK		; SEEK WILL REPOSITION HEAD
	POP	d
	JMP	RETRY		; TRY AGAIN

rtbl:	db	128	;128 bytes
	dw	rd1
	db	0	;256 bytes
	dw	rd1
	db	0	;512 bytes
	dw	rd2
	db	0	;1024 bytes
	dw	rd4

type$II$com:	;command in E
	mov	a,e
	ani	00100000b	; 1 if write
	rlc! rlc! rlc		; 0000000w
	ori	0a2h		;A2/A3 for INI/OUTI
	sta	rd12+1
	sta	rd22+1
	sta	rd32+1
	sta	rd42+1
	call	setside
	sspd	savSTK		;
	lxi	sp,rwSTK	;
	lda	blcode
	mov	c,a
	add	a	; *2
	add	c	; *3
	lxi	h,rtbl
	mov	c,a
	mvi	b,0
	dad	b
	mov	b,m
	inx	h
	mov	c,m
	inx	h
	mov	h,m
	mov	l,c
	push	h
	jmp	type$II$ext

SELECT:
	mvi	c,0
	mvi	b,dev0
	call	?timot	;clear any pending "motor off"
	lda	selmsk
	mov	d,a
	cma
	mov	b,a
	LDA	@rdrv		; get the RELATIVE drive number
	MOV	C,A		; relative drive number in (C) (rel. to driv0)
	lhld	cmode
	INX	H		; POINT TO MODE BYTE 2
	inr	a		; 1,2,3,4
	cma			; 111111xx
	ana	d	; 2,1,0,3 but avoid win reset bit
	bit	4,m	;single density ?
	jrnz	se1
	ori	00100000b	;select single density data rate.
se1:
	dcx	h	; point to mode byte 1
	bit	1,m	; QT drive?
	jrz	se2
	bit	0,m	; QT media?
	jrnz	se3	; motor "off" - low speed - for QT
se2:
	ori	00010000b	;motor on, also (QT drive = high speed)
se3:
	mov	e,a
	di
	in	sysctl		;
	; TODO: if motor bit changes for QT drive, must de-select briefly
	ani	10001111b	; DDEN, clear MOTOR
	ana	b	; strip select bit(s)
	ora	e		;
	out	sysctl		;
	ei
	MOV	A,M
	ANI	00001100B	; setup steprate bits for seek-restore commands
	rrc
	rrc
	STA	STEPRA		; RATE FOR SUBSEQUENT SEEK/RESTORE
	LXI	H,LOGDSK	; save position (track) of current drive
	MOV	E,M		; in 'trks' array addressed by contents of
	MOV	M,C		; location 'logdsk'.
	MVI	B,0
	MOV	D,B
	LXI	H,TRKS
	DAD	D
	IN	fdctrk
	MOV	M,A		; SAVE CURRENT TRACK #
	LXI	H,TRKS		; identify position (track) of requested drive
	DAD	B		; from 'trks' array addressed by new 'logdsk'.
	MOV	A,M
	OUT	fdctrk		; set track number
	mov	a,c
	sub	e	;same drive as last time?
	sui 1 ! sbb a	;.true. if same drive
	cma
	di
	lxi	h,motor$off ;if diff. drive, must check ready.
	ora	m	;if same but motor off, must check ready.
	mvi	m,true	;this prevents the motor from being turned off
	sta	mtflg
; test drive for ready.
	cma ! ora a	;[NC]
	jrnz	fb3	;[NZ] if motor still on.
;
	mvi	a,11010000b
	out	fdccomd
	in	fdcstat
	mvi	b,10	;must be ready within 10 rev.
fb1:
	call	find$NE
	lxi	d,IP$count
fb2:	in	fdcstat
	ani	00000010b
	jrnz	got$IP
	dcx	d
	mov	a,e
	ora	d
	jrnz	fb2
	djnz	fb1
	stc
fb3:	ei
	ret

IP$count equ 17250	; 200mS +10%, timed to "fb2" loop

got$IP:
	xra	a
	ei
	ret

find$NE:
	in	fdcstat
	ani	00000010b
	mov	c,a
	mvi	h,4	;wait even longer... (3.67 sec)
fb00:	lxi	d,0	;wait a long time for any edge
fb01:	in	fdcstat
	ani	00000010b
	cmp	c
	jrnz	got$edge
	dcx	d
	mov	a,e
	ora	d
	jrnz	fb01
	dcr	h
	jrnz	fb00
	pop	d	;discard address from "fb1" loop
	stc
	ei
	ret

got$edge
	ora	a
	rz
	mov	c,a	;if not NE, go find another
	jr	fb00

ACCESS$R:
	lhld	@dph
	lxi	d,12
	dad	d
	mvi	a,15	;PSH
	add	m
	mov	e,a
	inx	h
	mvi	a,0
	adc	m
	mov	d,a
	ldax	d
	sta	blcode		;get physical sector size
	lhld	cmode
	mov	c,m		; mode byte 2
	inx	h
	mov	a,m		; mode byte 3
	cma			; get "NOT MDT...
	ana	c		; ... AND DDT"
	ani	00100000b	; flag is in bit 5
	bit	1,c	; drive QT?
	jrz	accr0	; no...
	bit	0,c	; must be 0?
	jrnz	accr0	;
	ori	01100000b	; set both just in case
accr0:
	sta	htflag		; half track flag
	CALL	SELECT
	rc
SEEK:
	LXI	H,SEKERR	; initialize seek error counters
	MVI	M,4		; 4 ERRORS ON SEEK IS FATAL
	INX	H
	MVI	M,10		; RESTORE once, then 9 errors are fatal
	call	setside
	lda	@trk
	mov	c,a
RETRS:
	MOV	A,C		; get track number back
	ORA	A		; FORCES "RESTORE" IF "seek to track 0"
	jz	HOME		;RESTORE HEAD TO TRACK 0
	lda	htflag
	mov	h,a		; get half-track flag in h
	IN	fdctrk		;CURRENT HEAD POSITION,
	SUB	C		;SEE HOW FAR WE WANT TO GO.
	RZ			;IF ZERO TRACKS TO STEP, WERE FINISHED
	MVI	B,01111000B	;ASSUME STEP-OUT + UPDATE + HEADLOAD
	JRNC	STOUT	;ASSUMPTION WAS CORRECT...
	MVI	B,01011000B	;ELSE MUST BE STEP-IN
	NEG		;AND NUMBER OF TRACKS WOULD BE NEGATIVE
STOUT:	MOV	L,A		;COUNTER FOR STEPING
SEEK5:	BIT	5,H		; CHECK FOR 48 TPI DISK IN 96 TPI DRIVE
	JRZ	NOTHT
	RES	4,B	;SELECT NO-UPDATE
	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	bit	6,h	; added bit for QT
	JRZ	NOTQT
	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
NOTQT:
	SETB	4,B	;SELECT UPDATE TO TRACK-REG
notht:	CALL	TYPE$I	;STEP HEAD
	ANI	00000100B SHL 1 ;DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	DCR	L
	JRNZ	SEEK5
	IN	fdcsec		;SAVE CURRENT SECTOR NUMBER
	MOV	L,A
	CALL	READ$ADDR	; GET ACTUAL TRACK UNDER HEAD (IN SECTOR REG)
	in	fdcsec		;GET TRACK NUMBER FROM MEDIA
	MOV	H,A
	MOV	A,L
	OUT	fdcsec		;RESTORE SECTOR NUMBER
	LDA	@dstat		;GET TRUE ERROR STATUS OF READ-ADDRESS
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
	OUT	fdctrk		; re-define head position accordingly
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
	jmp	RETRS		; RETRY SEEK

STEPIN: lda	htflag
	mov	c,a
	ora	a		; CHECK HALF TRACK modes
	MVI	B,01001000B	; STEP IN WITHOUT UPDATE
	CNZ	TYPE$I		; STEP A SECOND TIME (W/O UPDATE) FOR HALF-TRK
	bit	6,c	; QT
	CNZ	TYPE$I		; STEP A THIRD TIME (W/O UPDATE) FOR QUARTER-TRK
	bit	6,c	; QT
	CNZ	TYPE$I		; STEP A FOURTH TIME (W/O UPDATE) FOR QUARTER-TRK
	MVI	B,01011000B	; STEP IN AND UPDATE TRACK REGISTER
	JR	TYPE$I

HOME:		;POSITION HEAD AT TRACK ZERO...
	mvi	a,11010000b	;force TYPE$I status
	out	fdccomd 
	in	fdcstat
	ANI	00000100B	;TEST TRACK ZERO SENSOR,
	JRNZ	@TRK0		;SKIP ROUTINE IF WE'RE ALREADY AT TRACK 0.
	IN	fdctrk		;DOES THE SYSTEM THINK WE'RE AT TRACK 0 ??
	ORA	A
	JRNZ	HOME1	;IF IT DOESN'T, ITS PROBEBLY ALRIGHT TO GIVE "RESTORE"
	MVI	L,6 ;(6 TRKS)	;ELSE WE COULD BE IN "NEGATIVE TRACKS" SO...
	MVI	B,01001000B	;WE MUST STEP-IN A FEW TRACKS, LOOKING FOR THE
HOME0:	CALL	TYPE$I		;TRACK ZERO SIGNAL.
	ANI	00000100B SHL 1 ;"SHL 1" BECAUSE TYPE$I DOES AN "RLC"
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
	OUT	fdctrk		;MAKE SURE EVERYONE KNOWS WERE AT TRACK 0
	RET

;
READ$ADDR:
	mvi	a,11000100B	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	jr	PUT$I

TYPE$I:
	LDA	STEPRA		; STEP-RATE BITS
	ORA	B		; MERGE COMMAND
PUT$I:
	OUT	fdccomd 	; SEND command TO CONTROLLER
WB:	IN	fdcstat 	; WAIT FOR BUSY SIGNAL
	RAR			; TO COME UP
	JRNC	WB
WNB:	IN	fdcstat 	; poll controller for function-complete
	RAR			; Busy?
	JRC	WNB		; wait until not busy.
	RAL
	STA	@dstat		;SAVE TYPE II (III) STATUS FOR ERROR DETECTION.
	MVI	A,11010000B	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	fdccomd
	IN	fdcdata 	;
	in	fdcstat 	;
	rlc
	ret

setside:
	lda	@side
	xri	00000001b	; active low output
	rlc ! rlc
	mov	c,a
	di
	in	sysctl
	ani	10111011b	; clear old side bit
	ora	c		; add new side bit
	out	sysctl
	ei
	ret

STEPRA	DB	0		; STEP RATE CODE 
RETRYS	DB	0
SEKERR	DB	0,0		; SEEK,RESTORE ERROR COUNTS
CMODE	DW	0		; POINTER TO MODE BYTE
LOGDSK	DB	 2		; CURRENT DRIVE SELECTED BY THIS MODULE
BLCODE	DB	0
SELERR: DB	0
SELOP:	DB	false
MODFLG: DB	0
TRKS:	DB	255,255,0	
htflag: db	0
mtflg:	db	0

	END
