VERS	EQU   '1 '  ; April 26, 2022 21:41 drm "ldrbcf.asm"

	MACLIB	z80
	$-MACRO

	extrn cboot,btend,loader

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****	   70 - 78 CF partitions	      *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************

?H8PT	EQU	0F0H
?PORT	EQU	0F2H
?PORT2	EQU	0F3H

ctl$F2	EQU	2036H		; last image of ?PORT
SYSADR	EQU	2377H		; ADDRESS OF WHERE THE PARTN LBA
				; SHOULD BE FOR BOOT LOADER TO PUT PARTITION
				; ADDRESS IN.
AIO$UNI	EQU	2131H		; LUN from boot command
SEGOFF	EQU	2156H		; address where ROM put segment offset

CF	equ	080h	; CF base port
CF$BA	equ	CF+0	; CF card selection port
CF$DA	equ	CF+8	; CF data port
CF$EF	equ	CF+9	; CF feature/error register
CF$SC	equ	CF+10	; CF sector count
CF$SE	equ	CF+11	; CF sector number	(lba7:0)
CF$CL	equ	CF+12	; CF cylinder low	(lba15:8)
CF$CH	equ	CF+13	; CF cylinder high	(lba23:16)
CF$DH	equ	CF+14	; CF drive+head	(drive+lba27:24)
CF$CS	equ	CF+15	; CF command/status

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
	lda	AIO$UNI
	inr	a	; 0->01b, 1->10b
	out	CF$BA	; select card
	; SYSADR already has SEGOFF...
	lda	SYSADR+0
	ori	11100000b
	out	CF$DH	; LBA 27:24, drive and mode
	lda	SYSADR+1
	out	CF$CH	; LBA 23:16
	lda	SYSADR+2
	out	CF$CL	; LBA 15:8
	lda	SYSADR+3
	out	CF$SE	; LBA 7:0
	mov	a,e
	out	CF$SC
	mvi	a,20h
	out	CF$CS
	lxi	h,3000h
	mvi	c,CF$DA
	mvi	b,0	; should always be 0 after inir
load:
	in	CF$CS
	bit	7,a	; BUSY
	jrnz	load
	bit	0,a	; ERR
	jrnz	cferr
	bit	6,a	; RDY
	jrz	cferr
	bit	3,a	; DRQ
	jrz	load
	inir	; 256 bytes
	inir	; 512 bytes
	dcr	e
	jrnz	load
	xra	a
	out	CF$BA	; deselect CF
	DI
	mvi	a,10011111b	; H8 2mS off, display blank
	out	?H8PT		; H89 NMI here should be OK
	mvi	a,00000010b	; aux 2mS enable
	out	?PORT2		; in case of H8 CPU
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

cferr:	xra	a
	out	CF$BA	; deselect CF
	ret

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
