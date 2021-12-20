; MMS "magic sector" boot image for RomWBW and RC2014

	maclib	z80
	$-MACRO

boot	equ	2280h		; ADDRESS TO LOAD BOOT MODULE INTO
sysadr	EQU	2377h		; LOCATION IN BOOT MODULE TO PLACE SECTOR
				;  ADDRESS OF OPERATING SYSTEM
	org	8000h
begin:	jmp	start
	;
	; rest of space used for partition table, etc.
	;
dctype:	ds	1	; not used
control:ds	1	; not used
drvdata:ds	8	; not used
istring:ds	6	; not used
npart:	ds	1	; num partitions
sectbl:	ds	9*3	; partition table
dpb:	ds	8*21	; DPBs

	ds	512-($-begin)

	; org 8200h
start:	; we have no partition (or other) params
	lxi	sp,?stack	; SET UP LOCAL STACK

	; TODO: any hardware to shut down?

	; For now, hard-coded to partition 0
	lxi	h,sectbl	; big-endian sector addrs
	; get start sector into DE:BC
	mvi	d,0
	mov	e,m
	inx	h
	mov	b,m
	inx	h
	mov	c,m

	; DE:BC is LBA in 128B records, convert to 512B (shift 2)
	; since D is always 0, don't shift it.
	srlr	e		; ROTATE THE THREE BYTES
	rarr	b
	rarr	c
	srlr	e
	rarr	b
	rarr	c
	sbcd	lba0	; store little-endian
	sded	lba0+2	;
;
;  READ IN BOOT MODULE AND JUMP TO IT WHEN DONE
;
load:
	lhld	lba0
	lded	lba0+2
	mvi	c,41h	; set LBA
	call	0fffdh
	jrnz	error
	lxi	d,boot
	lxi	h,1
	mvi	c,42h	; read sector(s)
	call	0fffdh
	jrnz	error
	; copy LBA0 into boot module
	lhld	lba0
	shld	sysadr
	lhld	lba0+2
	shld	sysadr+2
	jmp	boot

error:	lxi	d,errmsg
	lxi	h,0
	lxi	b,15h	; print NUL-term string
	call	0fffdh
	; TODO: is there a return to RomWBW?
	di
	hlt

errmsg:	db	13,10,7,'Phase-I load error',0
;
;  MISCELLANEOUS STORAGE
;
lba0:	DB	0,0,0,0	; little-endian LBA

?stack	equ	$+256

	END
