VERS EQU '1 ' ; Dec 20, 2021 08:26 drm "SDC.ASM"
*************************************************************************

	TITLE	'SDC - DRIVER FOR MMS MP/M WITH SDCard INTERFACE'
	maclib	z80
	maclib	cfgsys
	$*MACRO

	extrn	@dph,@rdrv,@side,@trk,@sect,@dstat
	extrn	@scrcb,@dirbf,@rcnfg,@cmode,@lptbl
	extrn	?bnksl

nsegmt	equ	004eh	; where to pass segment to CP/M 3, LUN is -1

**************************************************************************
; Configure the number of partitions (numparX) on each LUN in your system
;  and if the LUN is removable (true) or not (false).
**************************************************************************

false	equ	0
true	equ	not false

; Logical Unit 0 characteristics

numpar0 equ	8		; number of partitions on LUN

ndev	equ	numpar0
dev0	equ	80

*************************************************************************
**  PORTS AND CONSTANTS
*************************************************************************

CMDST	equ	01000000b	; command start bits

dpbl	equ	17	; length of CP/M 3.0 dpb
alvl	equ	512	; size of allocation vector - 4096 blocks
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
	jmp	init$sdc
	jmp	login
	jmp	read$sdc
	jmp	write$sdc
	dw	string
	dw	dphtbl,modtbl

string: db	'SDC ',0,'SDCard Interface ('
	db	ndev+'0'
	db	' partitions) ',0,'v3.00'
	dw	VERS,'$'

; Mode byte table for SDC driver

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

sdcrd:
	lda	bbnk
	call	?bnksl
	inir
	inir
	xra	a
	call	?bnksl		; re-select bank 0
	ret

sdcwr:
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


; Disk parameter headers for the SDC driver

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

nparts:	db	0

;
;	DRIVER INITIALIZATION CODE
;

init$sdc:
	; anything to do? Leave reading of magic sector until
	; first drive access?
if 1
	; This only works if SDC was boot device
	lda	nsegmt-1	; LUN, 0 or 1
	ora	a
	mvi	a,SD0SCS
	jrz	is0
	mvi	a,SD1SCS	; might be non-functional
is0:	sta	scs	; SD0SCS, SD1SCS
	call	sdcini
	lhld	nsegmt		;grab this before it's gone...
	shld	segoff
endif
	xra	a
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
ih3:	sta	nparts		; use all partitions (and no more)
	; copy over all DPBs, add PSH,PSK
	mvi	a,DDPB		; CP/M 2.2 DPBs in magic sector
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
	lded	segoff+0; E = LBA31:24
	;		; D = LBA23:19 is segment offset, carry-in
	stx	e,+0	; LBA31:24 is fixed
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
read$sdc:
	ldy	a,+14	; buffer bank
	sta	bbnk
	ldy	l,+12	; buffer address
	ldy	h,+13
	shld	bdma
	call	set$lba
read$raw:
	mvi	a,CMDST+17
	sta	cmd
	lxi	h,cmd
	mvi	d,1
	mvi	e,0	; leave SCS on (unless error)
	call	sdcmd
	jrc	rwerr
	call	sdrblk	; turns off SCS
	jrc	rwerr
	xra	a
	ret

rwerr:
	xra	a
	inr	a
	ret

;
;	WRITE A PHYSICAL SECTOR CODE
;
write$sdc:
	call	set$lba
	mvi	a,CMDST+24
	sta	cmd
	lxi	h,cmd
	mvi	d,1
	mvi	e,0	; leave SCS on (unless error)
	call	sdcmd
	jrc	rwerr
	call	sdwblk	; turns off SCS
	jrc	rwerr
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
	lhld	curlba+0
	shld	cmd+1
	lhld	curlba+2
	shld	cmd+3
	ret

; send (6 byte) command to SDCard, get response.
; HL=command+response buffer, D=response length
; return A=response code (00=success), HL=idle length, DE=gap length
sdcmd:
	lda	scs
	; drop out here if no device...
	ora	a
	stc
	rz
	out	spi?ctl	; SCS on
	mvi	c,spi?rd
	; wait for idle
	; TODO: timeout this loop
	push	h	; save command+response buffer
	lxi	h,0	; idle timeout
sdcmd0:	inp	a
	cpi	0ffh
	jrz	sdcmd1
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd0
	; timeout - error
sdcmd5:
	pop	h
	xra	a
	out	spi?ctl	; SCS off
	stc
	ret
sdcmd1:	pop	h	; command buffer back
 if spi?rd <> spi?wr
	mvi	c,spi?wr
 endif
	mvi	b,6
	outir
 if spi?rd <> spi?wr
	mvi	c,spi?rd
 endif
	inp	a	; prime the pump
	push	h	; points to response area...
	lxi	h,0	; gap timeout
sdcmd2:	inp	a
	cpi	0ffh
	jrnz	sdcmd3
	dcx	h
	mov	a,h
	ora	l
	jrnz	sdcmd2
	jr	sdcmd5
sdcmd3:	pop	h	; response buffer back
	mov	b,d
	mov	m,a
	inx	h
	dcr	b
	jrz	sdcmd4
	inir	; rest of response
sdcmd4:	mov	a,e	; SCS flag
	ora	a
	rz	; NC
	xra	a
	out	spi?ctl	; SCS off
	ret	; NC

; read a 512-byte data block, with packet header and CRC (ignored).
; READ command was already sent and responded to.
; SCS must already be ON.
; return CY on error (A=error), SCS always off
sdrblk:
	mvi	c,spi?rd
	; wait for packet header (or error)
	lxi	d,0	; gap timeout
sdrbk0:	inp	a
	cpi	0ffh
	jrnz	sdrbk1
	dcx	d
	mov	a,d
	ora	e
	jrnz	sdrbk0
	stc
	jr	sdrbk2
sdrbk1:	
	cpi	11111110b	; data start
	stc	; else must be error
	jrnz	sdrbk2
	mvi	b,0	; 256 bytes at a time
	lhld	bdma
	call	sdcrd
	inp	a	; CRC 1
	inp	a	; CRC 2
	xra	a	; NC
sdrbk2:	mvi	a,0	; don't disturb CY
	out	spi?ctl	; SCS off
	ret

; write a 512-byte data block, with packet header and CRC (ignored).
; WRITE command was already sent and responded to.
; SCS must already be ON.
; return CY on error (A=error), SCS always off
sdwblk:
	mvi	c,spi?wr
	; TODO: wait for idle?
	mvi	a,11111110b	; data start token
	outp	a
	mvi	b,0	; 256 bytes at a time
	lhld	bdma
	call	sdcwr	; send 512B block
	outp	a	; CRC-1
	outp	a	; CRC-2
 if spi?rd <> spi?wr
	mvi	c,spi?rd
 endif
	inp	a	; prime the pump
	; wait for response...
	lxi	d,0	; gap timeout
sdwbk0:	inp	a
	cpi	0ffh
	jrnz	sdwbk1
	dcx	d
	mov	a,d
	ora	e
	jrnz	sdwbk0
	stc
	jr	sdwbk2
sdwbk1:	
	ani	00011111b	; mask off unknown bits
	cpi	00000101b	; data accepted
	stc	; else must be error
	jrnz	sdwbk2
	xra	a	; NC
sdwbk2:	mvi	a,0	; don't disturb CY
	out	spi?ctl	; SCS off
	ret

sdcini:
	; TODO: initialize card
	ret

;
;	DATA BUFFERS AND STORAGE
;

cmd:	db	0,0,0,0,0,1 ; command buffer w/end bit
	db	0	; response
scs:	db	0
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
