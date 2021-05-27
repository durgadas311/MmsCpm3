VERS	EQU   '1 '  ; Mar 28, 2020 09:26 drm "ldrbsdc.asm"

	MACLIB	z80
	$-MACRO

	extrn cboot,btend,loader

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****	   80 - 88 SDCard partitions	      *****
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
SEGOFF	EQU	2156H		; address where ROM put segment offset
AIO$UNI	EQU	2131h		; LUN from ROM

spi	equ	40h	; same board as WizNet

spi?dat	equ	spi+0
spi?ctl	equ	spi+1
spi?sts	equ	spi+1

SD0SCS	equ	0100b	; SCS for SDCard 0
SD1SCS	equ	1000b	; SCS for SDCard 1

CMDST	equ	01000000b	; command start bits

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
	db	80	;first drive
	db	9	;number of drives

around: pop	h	;ADDRESS OF ERROR ROUTINE
	lxi	sp,?stack
	push	h

*****************************************
* Start of unique routine for booting 
*****************************************

	lda	AIO$UNI
	inr	a	; 0->01b, 1->10b
	rlc
	rlc
	sta	scs	; SD0SCS, SD1SCS
	lxi	h,btend
	lxi	d,loader
	ora	a
	dsbc	d		;length of system in bytes
	shld	syssiz
	mvi	b,9	; 2^9 = 512
	srlr	h	; >>9 == >>8 (byte) and >>1
	inr	h		; PHYSICAL SECTORS TO BE BOOTED (rounded up)
	mov	a,h	; 512B sector count
	sta	cnt
	; SYSADR already has SEGOFF and partition offset,
	; but must add 1 to skip bootloader (this).
	; Do that by placing 'incr' before read.
	lhld	SYSADR+0
	shld	cmd17+1
	lhld	SYSADR+2
	shld	cmd17+3
	; TODO: employ multi-block read?
	lxi	h,3000h-512	; biased for first incr
	shld	dma
load:
	call	incr
	lhld	dma
	call	read
	rc
	lxi	h,cnt
	dcr	m
	jrnz	load

DONE:	DI
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
done2:	lxi	h,3000h
	lxi	d,loader
	lbcd	syssiz
	ldir
	jmp	cboot

; increment LBA in cmd17, and DMA
incr:
	lhld	dma
	inr	h	; +256
	inr	h	; +512
	shld	dma
	lxi	h,cmd17+4
	inr	m
	rnz
	dcx	h
	inr	m
	rnz
	dcx	h
	inr	m
	rnz
	dcx	h
	inr	m
	ret

; read LBA stored in cmd17...
; HL=buffer
; returns CY on error
read:
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
	ret	; CY=error
badblk:
	xra	a
	out	spi?ctl	; SCS off
	stc
	ret

dma:	dw	0
cnt:	db	0
scs:	db	SD0SCS
cmd17:	db	CMDST+17,0,0,0,0,0
	db	0

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$00B	;changes memory if "-FA" also
?CODE$LEN	EQU	$-?CODE

if $ > SYSADR
	.error	'Overflow SYSADR'
endif
	ORG	SYSADR
LBA:	DB	0,0,0,0	; synonymous with SYSADR
STAT:	DB	0
syssiz	dw	0

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
	ret	; NC

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
	xra	a	; NC
sdblk2:	push	psw
	xra	a
	out	spi?ctl	; SCS off
	pop	psw
	ret

	REPT	512-($-BOOT)-1
	DB	0
	ENDM
if $ > 2480h
	.error	'Overflow boot sector'
endif

?stack: equ	$+128

	END
