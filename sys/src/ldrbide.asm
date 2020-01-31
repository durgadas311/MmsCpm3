VERS	EQU   '1 '  ; June 27, 2019 05:26 drm "ldrbide.asm"

	MACLIB	z80
	$-MACRO

	extrn cboot,btend,loader

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****	   50 - 58 Sasi drives		      *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************

?PORT	EQU	0F2H

ctl$F2	EQU	2036H		; last image of ?PORT
SYSADR	EQU	2377H		; ADDRESS OF WHERE THE PARTN LBA
				; SHOULD BE FOR BOOT LOADER TO PUT PARTITION
				; ADDRESS IN.
SEGOFF	EQU	2156H		; address where ROM put segment offset

GIDE	equ	080h	; GIDE base port
GIDE$DA	equ	GIDE+8	; GIDE data port
GIDE$EF	equ	GIDE+9	; GIDE feature/error register
GIDE$SC	equ	GIDE+10	; GIDE sector count
GIDE$SE	equ	GIDE+11	; GIDE sector number	(lba7:0)
GIDE$CL	equ	GIDE+12	; GIDE cylinder low	(lba15:8)
GIDE$CH	equ	GIDE+13	; GIDE cylinder high	(lba23:16)
GIDE$DH	equ	GIDE+14	; GIDE drive+head	(drive+lba27:24)
GIDE$CS	equ	GIDE+15	; GIDE command/status

DRQ	EQU	00001000B
RDY	EQU	01000000B
ERR	EQU	00000001B
BUSY	EQU	10000000B


***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	org	2280H
boot:	jmp	around

sysend: dw	btend
systrt: dw	loader
drive:	db	0	;boot drive - calculated at run time
btmode: db	0	;not used by this hard disk loader
	db	70	;first drive
	db	9	;number of drives

around: pop	h	;ADDRESS OF ERROR ROUTINE
	lxi	sp,?stack
	push	h

*****************************************
* Start of unique routine for booting 
*****************************************

	lxi	h,btend
	lxi	d,loader
	ora	a
	dsbc	d		;length of system in bytes
	shld	syssiz
	lxi	d,100h		;add boot module size
	dad	d
	mvi	b,9	; 2^9 = 512
	srlr	h	; >>9 == >>8 (byte) and >>1
	inr	h		; PHYSICAL SECTORS TO BE BOOTED (rounded up)
	mov	e,h	; sector count to E
	; SYSADR already has SEGOFF...
	lda	SYSADR+0
	ori	11100000b
	out	GIDE$DH	; LBA 27:24, drive and mode
	lda	SYSADR+1
	out	GIDE$CH	; LBA 23:16
	lda	SYSADR+2
	out	GIDE$CL	; LBA 15:8
	lda	SYSADR+3
	out	GIDE$SE	; LBA 7:0
	mov	a,e
	out	GIDE$SC
	mvi	a,20h
	out	GIDE$CS
	lxi	h,3000h
	mvi	c,GIDE$DA
	mvi	b,0	; should always be 0 after inir
load:
	in	GIDE$CS
	bit	7,a	; BUSY
	jrnz	load
	bit	0,a	; ERR
	rnz
	bit	6,a	; RDY
	rz
	bit	3,a	; DRQ
	jrz	load
	inir	; 256 bytes
	inir	; 512 bytes
	dcr	e
	jrnz	load

DONE:	DI
	mvi	a,10011111b	; H8 2mS off, display blank
	out	0f0h	; H89 NMI here should be OK
	lda	ctl$F2
	ani	11111101b	; CLK off
	out	?PORT
	ani	00100000b	; ORG0 already?
	jrnz	done2
	LXI	H,?CODE ;SEQUENCE TO MOVE MEMORY-MAP
	MVI	B,?CODE$LEN	;NUMBER OF BYTES IN SEQUENCE
	MVI	C,?PORT ;I/O PORT TO SEND SEQUENCE
	OUTIR
done2:	lxi	h,3000h+256
	lxi	d,loader
	lbcd	syssiz
	ldir
	jmp	cboot

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$00B	;changes memory if "-FA" also
?CODE$LEN	EQU	$-?CODE

	; TODO: detect overrun at assembler  time
	ORG	SYSADR
LBA:	DB	0,0,0,0	; synonymous with SYSADR
STAT:	DB	0
syssiz	dw	0

	REPT	256-($-BOOT)-1
	DB	0
	ENDM

?stack: equ	$+128

	END
