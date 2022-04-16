VERS EQU '1 ' ; Apr 16, 2022 05:56 drm "CF2014.ASM"
*************************************************************************

	TITLE	'CF - DRIVER FOR MMS MP/M WITH RC2014 CF INTERFACE'
	maclib	z80
	maclib	cfgsys
	$*MACRO

	extrn	@dph,@rdrv,@side,@trk,@sect,@dstat
	extrn	@dirbf,@scrcb,@rcnfg,@cmode,@lptbl
	extrn	?bnksl

nsegmt	equ	004eh	; where to pass segment to CP/M 3

**************************************************************************
; Configure the number of partitions (numparX) on each LUN in your system
;  and if the LUN is removable (true) or not (false).
**************************************************************************

false	equ	0
true	equ	not false

; Logical Unit 0 characteristics

numpar0 equ	8		; number of partitions on LUN

ndev	equ	numpar0
dev0	equ	70

*************************************************************************
**  PORTS AND CONSTANTS
*************************************************************************

GIDE	equ	010h	; GIDE base port
GIDE$DA	equ	GIDE+0	; GIDE data port
GIDE$EF	equ	GIDE+1	; GIDE feature/error register
GIDE$SC	equ	GIDE+2	; GIDE sector count
GIDE$SE	equ	GIDE+3	; GIDE sector number	(lba7:0)
GIDE$CL	equ	GIDE+4	; GIDE cylinder low	(lba15:8)
GIDE$CH	equ	GIDE+5	; GIDE cylinder high	(lba23:16)
GIDE$DH	equ	GIDE+6	; GIDE drive+head	(drive+lba27:24)
GIDE$CS	equ	GIDE+7	; GIDE command/status

ERR	equ	00000001b	; error bit in GIDE$CS
RDY	equ	01000000b	; ready bit in GIDE$CS
DRQ	equ	00001000b	; DRQ bit in GIDE$CS
BSY	equ	10000000b	; busy bit in GIDE$CS

dpbl	equ	17	; length of CP/M 3.0 dpb
alvl	equ	512	; size of allocation vector
csvl	equ	256	; size of check sum vector
modlen	equ	8	; length of each mode byte table entry
datlen	equ	19	; length of each lun data entry
bcode	equ	16	; offset in lun data of the blk code
initflg equ	16	;    "   "   "   "   of lun initialization flag
parstr	equ	17	;    "   "   "   "   of partition start of lun
numpar	equ	18	;    "   "   "   "   of the number of partitions

CSTRNG	EQU	13	; Offsets of data in magic sector
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

***************************************************
	dseg	; MP/M common memory

	dw	thread
driv0	db	dev0,ndev
	jmp	init$gide
	jmp	login
	jmp	read$gide
	jmp	write$gide
	dw	string
	dw	dphtbl,modtbl

string: db	'CF ',0,'RC2014 CF Interface ('
	db	ndev+'0'
	db	' partitions) ',0,'v3.10'
	dw	VERS,'$'

; Mode byte table for GIDE driver

modtbl:
drv	set	0
	rept	numpar0
	db	1000$0000b+drv,000$00000b,00000000b,00000000b
	db	11111111b,11111111b,11111111b,11111111b
drv	set	drv+1
	endm

; Disk parameter tables

dpb:
	rept	ndev
	ds	dpbl
	endm

	$-MACRO
;
;	ACTUAL READ-WRITE OF DATA
;

giderd:
	lda	bbnk
	call	?bnksl
	inir
	inir
	xra	a
	call	?bnksl		; re-select bank 0
	ret

gidewr:
	lda	bbnk
	call	?bnksl
	outir
	outir
	xra	a
	call	?bnksl		; re-select bank 0
	ret

thread	equ	$

	cseg	; MP/M banked memory
	$*MACRO


; Disk parameter headers for the GIDE driver

ncsv	set	0
drv	set	0

dphtbl:
	rept	numpar0
	dw	0,0,0,0,@dirbf,dpb+(drv*dpbl)
	dw	0	; no CSV - DPB.CKS must be 8000h
	dw	alv+(drv*alvl)
drv	set	drv+1
	endm

; Allocation vectors

alv:
	rept	ndev
	ds	alvl
	endm

; Check sum vectors for removable media (none)

csv:
	rept	ncsv
	ds	csvl
	endm

	$-MACRO

;
;	DRIVER INITIALIZATION CODE
;

init$gide:
	; anything to do? Leave reading of magic sector until
	; first drive access?
	lhld	nsegmt		;grab this before it's gone...
	shld	segoff
	xra	a
	out	GIDE$EF		; ensure this reg is sane
	ret

login:	lda	init
	inr	a
	jrnz	login0
	sta	init
	call	init$hard
login0:
	lda	npart
	mov	e,a
	lda	@rdrv
	cmp	e	; See if loging in a drive that doesn't exist
	jnc	rwerr
	xra	a
	ret

; A=offset into bdma (@scrcb+12)
; Returns HL=bdma+A
bufoff:
	lhld	bdma
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	ret

init$hard:
	; since we only have one disk, init partn table now.
	; read "magic sector" - LBA 0 of chosen disk segment.
	lhld	@scrcb+12	; hstbuf - use bios scratch buffer for magic sector
	shld	bdma
	lda	@scrcb+14	; hstbnk
	sta	bbnk
	lhld	segoff
	shld	curlba+0
	lxi	h,0
	shld	curlba+2		; phy sec 0 = partition table
	call	stlba2
	call	read$raw
	rnz	; error
	mvi	a,NPART
	call	bufoff
	mov	a,m
	cpi	numpar0
	jrc	ih3
	mvi	a,numpar0
ih3:	sta	npart		; use all partitions (and no more)
	; copy over all DPBs, add PSH,PSK
	mvi	a,DDPB		; CP/M 2.2 DPBs in magic sector
	call	bufoff
	lxi	d,dpb		; Our CP/M 3 DPBs
	lda	npart
ih0:
	push	psw		; num partitions
	lxi	b,15	; CP/M 2.2 DPB length
	ldir
	mvi	a,2	; 512 byte shift, from 128 byte
	stax	d
	inx	d
	mvi	a,3	; 512 byte mask, from 128 byte
	stax	d
	inx	d
	lxi	b,6	; skip mode bytes
	dad	b
	pop	psw
	dcr	a
	jrnz	ih0
	; copy over sector (partition) offsets,
	; converting from LBA and 4-byte entries.
	mvi	a,SECTBL
	call	bufoff
	lxix	partbl
	lda	npart		; num entries
	mov	b,a
ih1:	push	b
	lded	segoff+0; E = LBA27:24,DRV (future seg off)
	;		; D = LBA23:19 is segment offset, carry-in
	stx	e,+0	; LBA27:24,DRV is fixed
	inxix
	mvi	b,3
	mov	a,m
	ani	00011111b	; must clear LUN bits
	mov	m,a
ih2:
	mvi	e,0
	mov	a,m
	inx	h
	srlr	a	; convert 128B-secnum to 512B-secnum
	rarr	e	;
	srlr	a	;
	rarr	e	; E=carry-out
	ora	d	; carry-in from previous
	stx	a,+0
	inxix
	mov	d,e	; carry-out becomes next carry-in
	djnz	ih2
	pop	b
	djnz	ih1
	; anything else to do?
	xra	a
	ret

;	READ - WRITE ROUTINES
;
;	READ A PHYSICAL SECTOR CODE
; IY=buffer header
read$gide:
	ldy	a,+14	; buffer bank
	sta	bbnk
	ldy	l,+12	; buffer address
	ldy	h,+13
	shld	bdma
	call	set$lba
read$raw:
	mvi	a,20h
	out	GIDE$CS
gider0: in	GIDE$CS		; FIRST CHECK FOR DRIVE READY
	bit	7,a		; BSY
	jrnz	gider0
	bit	0,a		; ERR
	jrnz	rwerr0
	bit	6,a		; RDY
	jrz	rwerr
	bit	3,a		; DRQ
	jrz	gider0
	lhld	bdma		; data buffer address
	mvi	c,GIDE$DA
	mvi	b,0
	call	giderd
	xra	a
	ret

rwerr0:
	in	GIDE$EF
	sta	dskerr
rwerr:
	xra	a
	inr	a
	ret

;
;	WRITE A PHYSICAL SECTOR CODE
; IY=buffer header
write$gide:
	ldy	a,+14	; buffer bank
	sta	bbnk
	ldy	l,+12	; buffer address
	ldy	h,+13
	shld	bdma
	call	set$lba
	call	set$lba
	mvi	a,30h
	out	GIDE$CS
gidew0: in	GIDE$CS		; FIRST CHECK FOR DRIVE READY
	bit	7,a		; BSY
	jrnz	gidew0
	bit	6,a		; RDY
	jrz	rwerr
	bit	0,a		; ERR
	jrnz	rwerr0
	bit	3,a		; DRQ
	jrz	gidew0
	lhld	bdma		; data buffer address
	mvi	c,GIDE$DA
	mvi	b,0
	call	gidewr
gidew2:
	in	GIDE$CS		; wait for not busy
	bit	7,a		; BSY
	jrnz	gidew2
	bit	0,a		; ERR
	jrnz	rwerr0
	; TODO: confirm DRQ also off?
	xra	a
	ret

;	CALCULATE THE REQUESTED SECTOR
; IY=buffer cb
set$lba:
	; note: LBA is stored big-endian, LHLD/SHLD are little-endian
	; so H,D are LSB and L,E are MSB.
	ldy	h,+8		; get requested track, byte-swapped
	ldy	l,+9		;
	lxi	d,0
	mvi	b,4		; shift 4 bits left (16 psec/trk)
stlba0:
	slar	h
	ralr	l
	ralr	d	; can't carry out
	djnz	stlba0
	; sector can't carry - 0-15 into vacated bits
	ldy	a,+10		; get requested sector (phy)
	ora	h
	mov	h,a
	shld	curlba+2
	xchg
	shld	curlba+0	; CURLBA = (@trk << 4) | @sec
	; compute &partbl[@rdrv]+3.
	; We'd like to only do this only if seldsk changes,
	; but we have no callback for that.
	lda	@rdrv
	add	a
	add	a	; *4
	adi	3	; can't carry
	mov	e,a
	mvi	d,0
	lxi	h,partbl
	dad	d
	xchg		; DE = &partbl[@rdrv]+3
	; add 32-bit values CURLBA += PARTBL[@rdrv]
	lxi	h,curlba+3
	xra	a	; clear CY
	mvi	b,4
stlba1:
	ldax	d
	adc	m
	mov	m,a
	dcx	h
	dcx	d
	djnz	stlba1
stlba2:	; setup controller regs from CURLBA
	lxi	h,curlba
	mov	a,m
	ori	11100000b	; LBA mode, etc
	out	GIDE$DH
	inx	h
	mov	a,m
	out	GIDE$CH
	inx	h
	mov	a,m
	out	GIDE$CL
	inx	h
	mov	a,m
	out	GIDE$SE
	mvi	a,1
	out	GIDE$SC	; always 1 sector at a time
	xra	a
	out	GIDE$EF	; feature always zero?
	ret

;
;	DATA BUFFERS AND STORAGE
;

segoff:	dw	0	; orig from ROM, passed in nsegmt by CPM3LDR
curlba:	db	0,0,0,0

; Partition start LBAs for each partition.
; Loaded from the magic sector, converted to LBA.

partbl:
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0
	db	0,0,0,0

init:	db	0ffh	; one-time initialization
dskerr:	db	0

	END
