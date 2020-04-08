vers equ '2 ' ; April 7, 2020  17:46  drm  "LDRBZ17.ASM"
********** LOADER BOOT ROUTINE **********
********** FOR Z17 BOOT        **********

	maclib Z80
	$-MACRO

	extrn cboot,btend,loader

******** Select Boot mode from: ************
**  0 = 5.25" SD SS ST          Drive 0
**  1 = 5.25" SD DS ST          Drive 0
**  2 = 5.25" SD SS DT          Drive 0
**  3 = 5.25" SD DS DT          Drive 0
********************************************
ndrv	equ	3
drv0	equ	0

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****  0 = FIRST (BUILT-IN) MINI FLOPPY       *****
*****  1 = SECOND (ADD-ON) MINI FLOPPY	      *****
*****  2 = THIRD (LAST ADD-ON) MINI FLOPPY    *****
*****					      *****
***************************************************

***************************************************
**  PORTS AND CONSTANTS
***************************************************
?H8PT	EQU	0F0H
?PORT	EQU	0F2H
?PORT2	EQU	0F3H
ctl$F2	EQU	2036H		; last image of ?PORT

R@XOK	EQU	205EH	;TURN OFF Z17
R@READ	EQU	2067H	;ENTRY TO 444-19 ROM FOR READ DISK
R@SDT	EQU	2076H	;SEEK DESIRED TRACK (IN "R@TT")
R@MAI	EQU	2079H	;MOVE ARM IN (STEP IN)
R@MAO	EQU	207CH	;MOVE ARM OUT (STEP OUT)
R@RDB	EQU	2082H	;READ NEXT BYTE FROM DISK
R@SDP	EQU	2085H	;SELECT Z17 DRIVE (DELAY IF NEEDED)
R@STS	EQU	2088H	;SKIP-THIS-SECTOR (WAIT FOR SECTOR HOLE)
R@STZ	EQU	208BH	;SEEK TRACK ZERO
R@WSC	EQU	2091H	;WAIT FOR SYNC CHARACTER

D@TT	EQU	20A0H	;LOCATION FOR DESTINATION TRACK (SEEK)
D@TRKPT EQU	20A5H	;ADDRESS TO ACTUAL CURRENT TRACK
***************************************************

***************************************************
** START OF RELOCATABLE DISK BOOT MODULE
*************************************************** 
	aseg
	ORG	2280H
BOOT:	JMP	AROUND

sysend: dw	btend
systrt: dw	loader
drive:	db	drv0
btmode: db	1
	db	drv0
	db	ndrv

around: pop	h
	LXI	SP,?STACK
	shld	vrst0+1
***************************************************
*** START OF UNIQUE ROUTINE FOR BOOTING
***************************************************
	lxi	h,btend
	lxi	d,loader	;DE=load address
	ora	a
	dsbc	d
	shld	syssiz
	lxi	d,00ffh ;round up.
	dad	d	;
	lxi	d,3000h+256
	mov	b,h	;number of 256 byte sectors to load
	LXI	H,U@SDT
	SHLD	R@SDT+1 ;CHANGE ROM'S SEEK ROUTINE TO OURS
	LXI	H,0001H ;DISK ADDRESS OF FIRST SECTOR (0-399)
	MVI	C,9	;9 SECTORS LEFT IN THIS TRACK (TRACK 0)
DNTRK:	XRA	A
	STA	HT$FLAG
DOTRK:	PUSH	H
	PUSH	D
	PUSH	B
	LXI	B,0100H ;ONE SECTOR READ AT A TIME
	CALL	R@READ	;READ A SECTOR
	JC	ERR00
	POP	B
	POP	D
	POP	H
	INR	D	;STEP DMA ADDRESS 256 BYTES
	INX	H	;POINT TO NEXT SECTOR
	DCR	B	;NO MORE SECTORS TO READ??
	JZ	DONE
	DCR	C	;MORE SECTORS ON THIS TRACK??
	JNZ	DOTRK
	MVI	C,10
	LDA	TRK
	INR	A
	STA	TRK
	JMP	DNTRK

ERR00:	POP	B
	MOV	A,C
	CPI	10
	JNZ	VRST0	;THIS TEST ONLY VALID IF ERROR ON 1ST SECTOR OF TRACK
	LDA	HT$FLAG ;THIS CAN ANLY OCCURE ONCE PER REQUESTED TRACK
	ORA	A
	JNZ	VRST0
	CMA
	STA	HT$FLAG
	PUSH	B
	CALL	R@SDP	;SELECT DRIVE
	CALL	R@MAI	;STEP HEAD IN ONE TRACK
	LXI	H,TRK
	INR	M
	POP	B
	POP	D
	POP	H
	JMP	DOTRK

DONE:
	DI
	mvi	a,09fh	; 2ms off, blank fp on H8
	out	?H8PT	; H89 NMI should be innocuous
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
	JMP	CBOOT

?CODE	DB	0000$01$00B
	DB	0000$11$00B
	DB	0000$01$00B
	DB	0000$10$00B
	DB	0000$11$00B
	DB	0000$10$00B
	DB	0010$00$10B	;ALSO WORKS IN Z89-FA
?CODE$LEN	EQU	$-?CODE

; OUR OWN SEEK ROUTINE THAT USES OUR TRACK NUMBER (ALLOWS HALF-TRACK)
SDT3:	INR	M
	CALL	R@MAI
U@SDT:	LHLD	D@TRKPT
	LDA	TRK
	CMP	M
	JZ	R@STS
	JP	SDT3
SDT1:	DCR	M
	CALL	R@MAO
	JMP	U@SDT

TRK:	DB	0	;OUR CURRENT PHYSICAL TRACK NUMBER
HT$FLAG DB	0	;USED TO KEEP TRACK OF HALF-TRACK DETECTION
syssiz: dw	0

vrst0:	jmp	$-$

	rept	256-($-boot)
	db	0
	endm

?STACK	EQU	$+128

	END
