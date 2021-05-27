VERS	EQU   '1 '  ; Apr 03, 2020 18:46 drm "ldrsdc.asm"
***************************************************
;	Loader disk I/O module for MMS CP/M 2.24
;	for the SDCard H8xSPI interface 
;	Copyright (c) 1983 Magnolia Microsystems
***************************************************

	MACLIB	z80
	$-MACRO

	public	btend		;end of system (boot stops loading there)
	extrn	BDOS,CBOOT,DSKSTA,TIMEOT,MIXER,DIRBUF,DLOG
	extrn	NEWDSK,NEWTRK,NEWSEC,DMAA,phytrk

DRIV0	EQU	80		; FIRST PHYSICAL DRIVE NUMBER
NDRIV	EQU	9

***************************************************
**  PORTS AND CONSTANTS
***************************************************
GPIO	EQU	0F2H		; SWITCH 501

spi	equ	40h	; same board as WizNet

spi?dat	equ	spi+0
spi?ctl	equ	spi+1
spi?sts	equ	spi+1

SD0SCS	equ	0100b	; SCS for SDCard 0
SD1SCS	equ	1000b	; SCS for SDCard 1

CMDST	equ	01000000b	; command start bits

DPHDPB	EQU	10
DPHL	EQU	16
DPBL	EQU	21
DDEFL	EQU	4
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

BTDRV	EQU	2034H	; BOOT DRIVE SAVE BY PROM
STRNG	EQU	25F0H	; ASCII SEGMENT NUMBER SAVE BY BOOT LOADER
UNITNUM EQU	2131H	; PARTITION NUMBER SAVE BY EPROM
SEGOFF	EQU	2156H	; segment offset setup by ROM
nsegmt	equ	004eh	; where to pass segment to CP/M 3

***************************************************
** START OF RELOCATABLE DISK I/O MODULE
*************************************************** 

; Assume SPT is always 64 (16x512):
; Init:
;	seg_off = (STRNG - 'A') << 19		[256M segments]
;	partn(UNITNUM) += seg_off
; each I/O:
;	LBA = partn(UNITNUM) + (NEWTRK << 4) + (NEWSEC - 1)

	cseg   
 
	jmp	INIT$SDC
	jmp	SEL$SDC
	jmp	READ$SDC

	dw	0
	dw	0     

;	TEXT
	DB	'SDC ',0,'SDCard system loader ',0,'v3.00'
	DW	VERS,'$'


DPH0:	DW	0,0,0,0,DIRBUF,DPB0,CSV0,ALV0
DPH1:	DW	0,0,0,0,DIRBUF,DPB1,CSV0,ALV0
DPH2:	DW	0,0,0,0,DIRBUF,DPB2,CSV0,ALV0
DPH3:	DW	0,0,0,0,DIRBUF,DPB3,CSV0,ALV0
DPH4:	DW	0,0,0,0,DIRBUF,DPB4,CSV0,ALV0
DPH5:	DW	0,0,0,0,DIRBUF,DPB5,CSV0,ALV0
DPH6:	DW	0,0,0,0,DIRBUF,DPB6,CSV0,ALV0
DPH7:	DW	0,0,0,0,DIRBUF,DPB7,CSV0,ALV0
DPH8:	DW	0,0,0,0,DIRBUF,DPB8,CSV0,ALV0


;	SECTOR DEFINITION/TRANSLATION TABLE
;	already converted to 512b sectors
;	i.e. base LBA 27:0
;		-----ADDRESS----
DDEFTBL:DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0
	DB	0,   0,   0,   0

;
;
; DISK PARAMETER BLOCKS -- CONTAIN DUMMY DATA. REAL DATA IS OBTAINED FROM 
;			   MAGIC SECTOR ON INITIALIZATION OF PARTITION
;
DPB0:	DW	64		; SPT
	DB	5,31,1		; BSH,BLM,EXM
	DW	4-1,512-1	; DSM,DRM
	DB	0F0H,0		; AL0,AL1
	DW	0,2		; CKS,OFF
	DB	00000010B,10000000B,0  ; MODE BYTES
	DB	0FFH,0FFH,0FFH	; MODE MASKS

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

;	SELECT DISK CODE
;	this should always select the same drive
SEL$SDC:
	xra	a
	sta	SELERR		; NO SELECT ERRORS (YET)
	lda	PARTLUN
	mov	b,a
	lda	NEWDSK
	sui	DRIV0
	cmp	b
	jnc	ERREXT
	mov	b,a
	lxi	d,DDEFTBL
	mov	l,a		; NOW POINT TO THE CORRECT
	mvi	h,0		; ENTRY IN THE SECTOR
	dad	h		; OFFSET TABLE
	dad	h		; *4
	dad	d
	shld	SECPTR
	lxi	h,DPH0-DPHL	; POINT TO DPH TABLE
	lxi	d,DPHL		; LENGTH OF DPH's
	inr	b
SEL1:	dad	d
	djnz	SEL1		; CALCULATE POINTER TO REQUESTED DPH
	shld	curdph		
	lxi	d,DPHDPB
	dad	d		; POINT TO ADDRESS OF DPB
	call	HLIHL		; DPB ADDRESS IN HL
	shld	CURDPB		; SAVE IT
	lhld	curdph
	ret

ERREXT: mvi	a,1
	sta	SELERR
	lxi	h,0
	ret

INIT$SDC:
	; gather info from bootloader
	lda	UNITNUM
	sta	nsegmt-1	;hope it is safe here
	inr	a	; 0->01b, 1->10b
	rlc
	rlc
	sta	scs
	lda	BTDRV		;FROM BOOT LOADER
	sta	MIXER
	lhld	SEGOFF		;from ROM
	shld	nsegmt		;hope it is safe here
	; since we only have one disk, init partn table now.
	; read "magic sector"
	shld	CURLBA+0
	lxi	h,0
	shld	CURLBA+2		; phy sec 0 = partition table
	call	READ
	rnz	; error
	lda	HSTBUF+NPART	; num partns
	sta	PARTLUN		; use all partitons
	; copy over all DPBs
	lda	PARTLUN		; compute length of DPB block
	mov	b,a
	lxi	h,0		; CALCULATE TOTAL LENGTH OF DPB'S TO BE MOVED 
	lxi	d,DPBL
NXTLEN:	dad	d
	djnz	NXTLEN
	mov	b,h		; PUT LENGTH IN BC
	mov	c,l
	lxi	d,DPB0
	lxi	h,HSTBUF+DDPB	; PUT FROM ADDRESS IN HL
	ldir
	; copy over sector (partition) offsets,
	; converting from LBA and 4-byte entries.
	lxix	DDEFTBL		; destination start
	lxi	h,HSTBUF+SECTBL	; source start
	lda	PARTLUN		; num entries
	mov	b,a
nxtdef:	push	b
	lda	SEGOFF+0; LBA27:24,DRV is fixed
	stx	a,+0
	inxix
	mvi	b,3
	lda	SEGOFF+1; LBA23:19 is segment offset
	mov	d,a	; carry-in, s0000000
	mov	a,m
	ani	00011111b	; must clear LUN bits
	mov	m,a
nxdef0:
	mvi	e,0
	mov	a,m
	inx	h
	srlr	a	; convert 128B-secnum to 512B-secnum
	rarr	e	;
	srlr	a	;
	rarr	e	;
	ora	d	; carry-in from previous
	stx	a,+0
	inxix
	mov	d,e	; carry-out becomes next carry-in
	djnz	nxdef0
	pop	b
	djnz	nxtdef
	; anything else to do?
	xra	a
	ret

; HL, DE are LBA buffers to be compared
cmplba:	mvi	b,4
cmplba0:
	ldax	d
	cmp	m
	rnz
	inx	h
	inx	d
	djnz	cmplba0
	xra	a
	ret

scs:	db	SD0SCS
cmd17:	db	CMDST+17,0,0,0,0,1
	db	0

READ$SDC:
	lda	SELERR
	ora	a
	rnz
	lhld	phytrk
	shld	REQTRK
	mvi	c,0		; CALCULATE PHYSICAL SECTOR
	lda	NEWSEC
	srlr	a		; DIVIDE ACCUMULATOR BY 2
	rarr	c		; SAVE OVERFLOW BIT
	srlr	a		; DIVIDE ACCUMULATOR BY 4
	rarr	c		; SAVE OVERFLOW BIT
	sta	REQSEC		; SAVE IT
	mov	a,c
	rlc
	rlc			; sub-sector index
	sta	BLKSEC		; STORE IT
	call	SET$LBA		; setup CURLBA from REQTRK/SEC
	; only one disk, each partn LBAs are unique
	lxi	h,HSTLBA
	lxi	d,CURLBA
	call	cmplba
	jz	NOREAD		; no pre-read required
	; no flushing required - we never write
	call	READ		; READ THE SECTOR
	rnz
NOREAD: lxi	h,HSTBUF	; POINT TO START OF SECTOR BUFFER
	lxi	b,128
	lda	BLKSEC		; POINT TO LOCATION OF CORRECT LOGICAL SECTOR
MOVIT1: dcr	a
	jm	MOVIT2
	dad	b
	jr	MOVIT1
MOVIT2: lded	DMAA		; POINT TO DMA
	ldir			; MOVE IT
	xra	a		; FLAG NO ERROR
	ret			; RETURN TO BDOS

;
;	READ A PHYSICAL SECTOR CODE
;
READ:
	call	SET$SEC 	; set ctrl regs from CURLBA
	call	SDCRD		; DO READ OR WRITE
	rnz
	lxi	h,CURLBA
	lxi	d,HSTLBA	; SET UP NEW BUFFER PARAMETERS
	lxi	b,4
	ldir
	xra	a
	ret

;	ABSOLUTE SECTOR NUMBER
;
;	CALCULATE THE REQUESTED SECTOR
;
SET$LBA:
	; note: LBA is stored big-endian, LHLD/SHLD are little-endian
	; so H,D are LSB and L,E are MSB.
	lhld	REQTRK		; GET REQUESTED TRACK
	mov	e,l	;
	mov	l,h	;
	mov	h,e	; bswap HL
	lxi	d,0
	mvi	b,4		; shift 4 bits left (16 psec/trk)
stlba0:
	slar	h
	rarr	l
	rarr	d	; can't carry out
	djnz	stlba0
	; sector can't carry - 0-15 into vacated bits
	lda	REQSEC		; GET REQUESTED SECTOR
	ora	h
	mov	h,a
	shld	CURLBA+2
	xchg
	shld	CURLBA+0
	; add 32-bit values LBA += *(SECPTR)
	lxi	h,CURLBA+3
	lded	SECPTR	; adjusted by SEGOFF already
	inx	d
	inx	d
	inx	d	; SECPTR+3
	; CY is cleared above
	mvi	b,4
stlba1:
	ldax	d
	adc	m
	mov	m,a
	dcx	h
	dcx	d
	djnz	stlba1
	ret

SET$SEC:
	lhld	CURLBA	; adjusted by SEGOFF already
	shld	cmd17+1
	lhld	CURLBA+2
	shld	cmd17+3
	ret

HLIHL:	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	ret

;
;	ACTUAL READ OF DATA
;

; read LBA stored in cmd17...
; HL=buffer
; returns CY on error
SDCRD: 			; THIS ROUTINE IS FOR READING
	lxi	h,HSTBUF
	push	h
	lxi	h,cmd17
	mvi	d,1
	mvi	e,0	; leave SCS on
	call	sdcmd
	pop	h
	jrc	badblk	; turn off SCS
	lda	cmd17+6
	ora	a
	jrc	badblk	; turn off SCS
	call	sdblk	; turns off SCS
	ret	; NZ=error
badblk:
	xra	a
	out	spi?ctl	; SCS off
	inr	a
	ret	; NZ = error

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success), HL=idle length, DE=gap length
sdcmd:
	lda	scs
	out	spi?ctl	; SCS on
	mvi	c,spi?dat
	; wait for idle
	; TODO: timeout this loop
	push	h	; save command+response buffer
	lxi	h,256	; idle timeout
sdcmd0:	inp	a
	cpi	0ffh
	jrz	sdcmd1
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd0
	; timeout - error
	pop	h
	stc
	ret
sdcmd1:	pop	h	; command buffer back
	mvi	b,6
	outir
	inp	a	; prime the pump
	push	h	; points to response area...
	lxi	h,256	; gap timeout
sdcmd2:	inp	a
	cpi	0ffh
	jrnz	sdcmd3
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd2
	pop	h
	stc
	ret
sdcmd3:	pop	h	; response buffer back
	mov	b,d
	mov	m,a
	inx	h
	dcr	b
	jrz	sdcmd4
	inir	; rest of response
sdcmd4:	mov	a,e	; SCS flag
	ora	a
	rz
	xra	a
	out	spi?ctl	; SCS off
	ret	; ZR

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; HL=buffer
; return CY on error (A=error), SCS always off, HL=next buf
sdblk:
	lda	scs
	out	spi?ctl	; SCS on
	mvi	c,spi?dat
	; wait for packet header (or error)
	; TODO: timeout this loop
	lxi	d,256	; gap timeout
sdblk0:	inp	a
	cpi	0ffh
	jrnz	sdblk1
	dcx	d
	mov	a,d
	ora	e
	jrnz	sdblk0
	inr	a	; NZ
	stc
	jr	sdblk2
sdblk1:	
	cpi	11111110b	; data start
	stc	; else must be error
	jrnz	sdblk2
	mvi	b,0	; 256 bytes at a time
	inir
	inir
	inp	a	; CRC 1
	inp	a	; CRC 2
	xra	a	; ZR,NC
sdblk2:	push	psw
	xra	a
	out	spi?ctl	; SCS off
	pop	psw
	ret

****************************************************************

;
;	DATA BUFFERS AND STORAGE
;
SECPTR	DW	0		; POINTER TO CURRENT SECTOR TABLE ENTRY
CURDPH	DW	0		; current disk parameter header
SELERR	DB	0		; SELECT ERROR FLAG
PARTLUN DB	0		; NUMBER OF PARTITIONS IN CURRENT LUN
DSKERR:	db	0
;
; DEBLOCKING VARIABLES
;
REQTRK	DW	0
REQSEC	DB	0
BLKSEC: DB	0		; LOCATION OF LOGICAL SECTOR WITHIN PHYSICAL
CURDPB	DW	0		; ADDRESS OF CURRENT DISK PARAMETER BLOCK

CURLBA:	db	0,0,0,0
HSTLBA:	db	0ffh,0,0,0

btend	equ	$

********************************************************
** BUFFERS
********************************************************

HSTBUF: DS	512
CSV0:	DS	128
ALV0:	DS	256

	END
