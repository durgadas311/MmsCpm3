VERS EQU '1 ' ; Apr 27, 2022 20:54 drm "H8CF.ASM"
*************************************************************************

	TITLE	'CF - DRIVER FOR MMS MP/M WITH CF INTERFACE'
	maclib	z80
	maclib	cfgsys
	$*MACRO

	extrn	@dph,@rdrv,@side,@trk,@sect,@dstat
	extrn	@scrcb,@dirbf,@rcnfg,@cmode,@lptbl
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

GPIO	EQU	0F2H		; SWITCH 501

CF	equ	080h	; CF base port
CF$BA	equ	CF+0	; CF-select port
CF$DA	equ	CF+8	; CF data port
CF$EF	equ	CF+9	; CF feature/error register
CF$SC	equ	CF+10	; CF sector count
CF$SE	equ	CF+11	; CF sector number	(lba7:0)
CF$CL	equ	CF+12	; CF cylinder low	(lba15:8)
CF$CH	equ	CF+13	; CF cylinder high	(lba23:16)
CF$DH	equ	CF+14	; CF drive+head	(drive+lba27:24)
CF$CS	equ	CF+15	; CF command/status

ERR	equ	00000001b	; error bit in CF$CS
RDY	equ	01000000b	; ready bit in CF$CS
DRQ	equ	00001000b	; DRQ bit in CF$CS
BSY	equ	10000000b	; busy bit in CF$CS

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
	dseg	; common memory

	dw	thread
driv0	db	dev0,ndev
	jmp	init$cf
	jmp	login
	jmp	read$cf
	jmp	write$cf
	dw	string
	dw	dphtbl,modtbl

string: db	'H8CF ',0,'CF Interface ('
	db	ndev+'0'
	db	' partitions) ',0,'v3.00'
	dw	VERS,'$'

; Mode byte table for CF driver

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
bbnk:	db	0
bdma:	dw	0

cfrd:
	lda	bbnk
	call	?bnksl
	inir
	inir
	xra	a
	call	?bnksl		; re-select bank 0
	ret

cfwr:
	lda	bbnk
	call	?bnksl
	outir
	outir
	xra	a
	call	?bnksl		; re-select bank 0
	ret

thread	equ	$

	cseg	; banked memory
	$*MACRO


; Disk parameter headers for the CF driver

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

init$cf:
	; anything to do? Leave reading of magic sector until
	; first drive access?
	lda	nsegmt-1	; LUN
	inr	a		; 0->01b, 1->10b
	sta	cfsel
	lhld	nsegmt		;grab this before it's gone...
	shld	segoff
	xra	a
	out	CF$EF		; ensure this reg is sane
	ret

login:	lda	init
	inr	a
	jrnz	login0
	sta	init
	call	init$hard
login0:
	lda	nparts
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
	shld	bdma	; is this safe now?
	lda	@scrcb+14	; hstbnk
	sta	bbnk	; is this safe now?
	lhld	segoff
	shld	curlba+0
	lxi	h,0
	shld	curlba+2		; phy sec 0 = partition table
	call	stlba2		; selects CF card
	call	read$raw	; deselects CF card
	rnz	; error
	mvi	a,NPART
	call	bufoff
	mov	a,m
	cpi	numpar0
	jrc	ih3
	mvi	a,numpar0
ih3:	sta	nparts		; use all partitions (and no more)
	; copy over all DPBs, add PSH,PSK
	mvi	a,DDPB	; CP/M 2.2 DPBs in magic sector
	call	bufoff
	lxi	d,dpb		; Our CP/M 3 DPBs
	lda	nparts
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
	lda	nparts		; num entries
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
read$cf:
	ldy	a,+14	; hstbnk
	sta	bbnk
	ldy	l,+12	; hstbuf
	ldy	h,+13
	shld	bdma
	call	set$lba		; selects CF card - all paths must deselect
read$raw:
	mvi	a,20h
	out	CF$CS
cfr0: in	CF$CS		; FIRST CHECK FOR DRIVE READY
	bit	7,a		; BSY
	jrnz	cfr0
	bit	0,a		; ERR
	jrnz	rwerr0
	bit	6,a		; RDY
	jrz	rwerr
	bit	3,a		; DRQ
	jrz	cfr0
	lhld	bdma		; data buffer address
	mvi	c,CF$DA
	mvi	b,0
	call	cfrd
	xra	a
	out	CF$BA	; deselect drive
	ret

rwerr0:
	in	CF$EF
	sta	dskerr
rwerr:
	xra	a
	out	CF$BA	; deselect drive
	inr	a
	ret

;
;	WRITE A PHYSICAL SECTOR CODE
; IY=buffer header
write$cf:
	ldy	a,+14	; hstbnk
	sta	bbnk
	ldy	l,+12	; hstbuf
	ldy	h,+13
	shld	bdma
	call	set$lba		; selects CF card - all paths must deselect
	mvi	a,30h
	out	CF$CS
cfw0: in	CF$CS		; FIRST CHECK FOR DRIVE READY
	bit	7,a		; BSY
	jrnz	cfw0
	bit	6,a		; RDY
	jrz	rwerr
	bit	0,a		; ERR
	jrnz	rwerr0
	bit	3,a		; DRQ
	jrz	cfw0
	lhld	bdma		; data buffer address
	mvi	c,CF$DA
	mvi	b,0
	call	cfwr
cfw2:
	in	CF$CS		; wait for not busy
	bit	7,a		; BSY
	jrnz	cfw2
	bit	0,a		; ERR
	jrnz	rwerr0
	; TODO: confirm DRQ also off?
	xra	a
	out	CF$BA	; deselect drive
	ret

;	CALCULATE THE REQUESTED SECTOR
; IY=buffer header
set$lba:
	; note: LBA is stored big-endian, LHLD/SHLD are little-endian
	; so H,D are LSB and L,E are MSB.
	ldy	h,+8		; get requested track, byte-swapped
	ldy	l,+9
	lxi	d,0
	mvi	b,4		; shift 4 bits left (16 psec/trk)
stlba0:
	slar	h
	ralr	l
	ralr	d	; can't carry out
	djnz	stlba0
	; sector can't carry - 0-15 into vacated bits
	ldy	a,+10		; get requested sector
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
	lda	cfsel
	out	CF$BA	; card is selected now... errors must deselect
	lxi	h,curlba
	mov	a,m
	ori	11100000b	; LBA mode, etc
	out	CF$DH
	inx	h
	mov	a,m
	out	CF$CH
	inx	h
	mov	a,m
	out	CF$CL
	inx	h
	mov	a,m
	out	CF$SE
	mvi	a,1
	out	CF$SC	; always 1 sector at a time
	xra	a
	out	CF$EF	; feature always zero?
	ret

;
;	DATA BUFFERS AND STORAGE
;

nparts:	db	0	; number of partitions we used
cfsel:	db	0	; bits to select current CF card
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
