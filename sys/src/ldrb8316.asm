vers equ '1 ' ; July 14, 1983  16:30 mjm "LDRB316.ASM"

false	equ	0
true	equ	not false

	MACLIB Z80
	$*MACRO
	extrn cboot,btend,loader

**************	Boot mode codes **************
**	 0 = 8"    SD SS                    **
**	 1 = 8"    DD SS                    **
**	 2 = 8"    DD DS                    **
**	 3 = 5.25" DD SS ST                 **
**	 4 = 5.25" DD DS ST                 **
**	 5 = 5.25" DD SS DT                 **
**	 6 = 5.25" DD DS DT                 **
********** 77316 xxxxxxxx BOOT ROUTINE *******
disksiz equ	8		; 8 = 8 inch disk or 5 = 5.25 inch disk

ctl$bytsd equ	 01101000b	;single density
ctl$bytdd equ	 00101000b	;double density

SPT8SD	  EQU	 26		;SECTORS PER TRACK  8" sd
SPT8DD	  EQU	 16		;   "     "    "    8" dd
SPT5	  EQU	 9		;   "     "    "    5" dd

secmsksd  equ	  007fh 	 
secmskdd  equ	  01ffh

secshfsd  equ	  7
secshfdd  equ	  9

ndrv	equ	8
drv0	equ	29

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****  29 = FIRST 8" DRIVE                    *****
*****  30 = SECOND 8" DRIVE                   *****
*****  31 = THIRD 8" DRIVE                    *****
*****  32 = FOURTH 8" DRIVE                   *****
*****  33 = FIRST 5.25" DRIVE                 *****
*****  34 = SECOND 5.25" DRIVE                *****
*****  35 = THIRD 5.25" DRIVE                 *****
*****  36 = FOURTH 5.25" DRIVE                *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************
CTRL	EQU	38H
WD1797	EQU	3CH
STAT	EQU	WD1797+0
TRACK	EQU	WD1797+1
SECTOR	EQU	WD1797+2
DATA	EQU	WD1797+3

?PORT	EQU	0F2H
***************************************************

***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	org	2280h
BOOT:	jmp	around

sysend: dw	btend
systrt: dw	loader
 if disksiz eq 8
drive:	db	29		; boot drive
btmode: db	2		; boot mode default DD DS
	db	29		; first drive
 else
drive:	db	33
btmode: db	4
	db	33
 endif
	db	4		; number of valid drives

around: POP	H	;ADDRESS OF ERROR ROUTINE
	LXI	SP,?STACK
	PUSH	H

***************************************************
*** START OF UNIQUE ROUTINE FOR BOOTING
***************************************************
	lxi	h,btend
	lxi	d,loader
	ora	a
	dsbc	d	;length of system, in bytes
	shld	syssiz
 if disksiz eq 8
	lda	btmode
	ora	a
	jrnz	yes$dd	
	lxi	d,secmsksd+100h   ;add in boot size, round up.
	dad	d
	mvi	a,secshfsd
	jr	div0
yes$dd:
 endif
	lxi	d,secmskdd+100h   ; add in boot size, round up
	dad	d
	mvi	a,secshfdd
div0:	srlr	h
	rarr	l
	dcr	a
	jrnz	div0
	mov	e,l	;number of sectors to load
	LXI	H,3000h
	lda	drive
	SUI	drv0
	CPI	ndrv	;don't allow invalid drives
	RNC
 if disksiz eq 8
	mov	b,a
	lda	btmode
	ora	a
	mov	a,b
	jrz	not$dd
	ORI	ctl$bytdd
	jr	a1
not$dd	ORI	ctl$bytsd
 else
	ORI	ctl$bytdd
 endif
a1:	STA	ctrlpt
	OUT	CTRL
	MVI	A,00001011B	;RESTORE COMMAND
LOOP0	CALL	COMMAND
	IN	STAT
	ANI	10011001B
	RNZ
 if disksiz eq 8	;8" drives
	MVI	A,10	;NUMBER OF RETRYS
	STA	RETRY
	lda	btmode 
	ora	a
	jrz	no$burst0
	mvi	a,(NOP) 	;nop out halts in read sector 
	sta	RD0
	sta	RD1
no$burst0:
 endif
	MVI	D,1
	LXI	B,(0)*256+(DATA)
SECL0	PUSH	H	;SAVE DMA ADDRESS IN CASE OF RETRY
 if disksiz eq 8	;8" drives
	lda	btmode	
	ora	a
	jrz	no$burst1
	LDA	ctrlpt
	ANI	11011111B	;BURST ON
	OUT	CTRL
no$burst1:
 endif
	MOV	A,D
	OUT	SECTOR
	MVI	A,10001000B	;READ SINGLE SECTOR
	CALL	READ$REC
	ANI	10111111B
 if disksiz eq 8	;8" drives
	LDA	ctrlpt		  
	OUT	CTRL
 endif
	JRZ	OK
	POP	H
 if disksiz eq 5	 ;5" drives
	lda	errf
	ora	a
	rnz
	cma
	sta	errf
	mvi	a,01001011b	;step-in, w/o update, for HT
	jr	loop0
 else			;8" drives
	LDA	RETRY
	DCR	A
	STA	RETRY
	JRNZ	SECL0
	RET
 endif
OK:	XTHL
	POP	H
 if disksiz eq 5	 ;5" drives
	cma
	sta	errf
 endif
	DCR	E
	JRZ	DONE
	INR	D
 if disksiz eq 8
	lda	btmode
	ora	a
	MOV	A,D
	jrz	not$dd2
	CPI	SPT8DD+1
	JRC	SECL0
not$dd2 CPI	SPT8SD+1
 else
	MOV	A,D
	CPI	SPT5+1
 endif
	JRC	SECL0
 if disksiz eq 5	 ;5" drives
	xra	a
	sta	errf
	mvi	a,01011011b	;step in, with update
	jr	loop0
 else			;8" drives
	IN	TRACK
	INR	A
	OUT	DATA
	MVI	A,00011011B	;SEEK
	JR	LOOP0
 endif
DONE:
	DI
	LXI	H,?CODE ;SEQUENCE TO MOVE MEMORY-MAP
	MVI	B,?CODE$LEN	;NUMBER OF BYTES IN SEQUENCE
	MVI	C,?PORT ;I/O PORT TO SEND SEQUENCE
	OUTIR
	lxi	h,3000h+256
	lxi	d,loader
	lbcd	syssiz
	ldir
	JMP	CBOOT

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$10B	;FOR "-FA" MACHINES
?CODE$LEN	EQU	$-?CODE

COMMAND:
	OUT	STAT
	EI
	JR $-1

READ$REC:
	OUT	STAT
	EI
	HLT
	INI
RD0	HLT		; changed to a NOP on 8" dd
	INI
	JNZ	RD0
RD1	HLT		; changed to a NOP on 8" dd
	INI
	JNZ	RD1
	JR $-1

errf:	db	0
retry:	db	0
syssiz: dw	0
ctrlpt	db	0	

	REPT	256-($-BOOT)
	DB	0
	ENDM

?STACK: EQU	$+128

	END
R $-1

errf:	db	0
retry:	db	0
syssiz: dw	0
ctrlpt	db	0	

	REPT	256-($-BOO