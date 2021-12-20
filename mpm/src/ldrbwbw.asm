; LDR Boot for RomWBW on RC2014 systems.
; Uses H89 Boot ORG, for simplicity of tools.

	maclib	z80
	$-MACRO

	extrn cboot,btend,loader

sysadr	equ	2377h	; well-known location in module

***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	org	2280H
boot:	jmp	around

sysend: dw	btend
systrt: dw	loader
syssiz	dw	0
nlbas:	dw	0

around: ; TODO: how to get additional boot params...
	; and error return address.
	lxi	sp,?stack

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
	; RomWBW / SDCard uses 512B blocks, round up
	lxi	d,511
	dad	d
	; shift left 8 (discard low byte), then shift 1
	; to divide by 512.
	srlr	h
	mov	l,h
	mvi	h,0
	shld	nlbas

	lhld	lba0
	lded	lba0+2
	mvi	c,41h	; set LBA
	call	0fffdh
	jrnz	error
	lxi	d,0100h	; where loader resides
	lhld	nlbas
	mvi	c,42h	; read sectors
	call	0fffdh
	jrnz	error
	jmp	cboot	; jump directly into BIOS

error:	lxi	d,errmsg
	lxi	h,0	; L=term char
	lxi	b,15h	; print NUL-term string
	call	0fffdh
	; TODO: is there a return to RomWBW?
	di
	hlt

errmsg:	db	13,10,7,'Phase-II load error',0

	org	sysadr
lba0:	DB	0,0,0,0	; little-endian

	rept	256-($-boot)-1
	db	0
	endm

?stack: equ	$+128

	end
