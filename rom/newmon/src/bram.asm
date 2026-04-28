; Boot Module for SDCard(s) on H8xSPI
	maclib	ram
	maclib	core
	maclib	z80

drv0	equ	80
ndrv	equ	8

	org	1000h
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	drv0,ndrv	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	boot	; +7: boot entry

	db	'R'	; +10: Boot command letter
	db	8	; +11: front panel key
	db	040h	; +12: port, 0 if variable
	db	11011110b,11000010b,11111111b	; +13: FP display ("rD")
	db	'Ramdisk',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

boot:
	CALL	PGINIT

;	BC = BYTE COUNT
;	DE = DEST ADDRESS
;	HL = BLOCK NUMBER

	lxi	d,bootbf	; Destination
	lxi	h,0		; Starting block number
	lxi	b,0A00H		; 10 sectors
	CALL	SMALLRD		; Call the Read Function
	jmp	hwboot

MMU     EQU     000H
RD00K   EQU     MMU+0
RD16K   EQU     MMU+1
RD32K	EQU	MMU+2
RD48K	EQU	MMU+3
WR00K	EQU	MMU+4
WR16K	EQU	MMU+5
WR32K	EQU	MMU+6
WR48K	EQU	MMU+7
RD00KH	EQU	MMU+8
RD16KH	EQU	MMU+9
RD32KH	EQU	MMU+10
RD48KH	EQU	MMU+11
WR00KH	EQU	MMU+12
WR16KH	EQU	MMU+13
WR32KH	EQU	MMU+14
WR48KH	EQU	MMU+15

PGINIT:
        DI
        MVI     A,0
        OUT     RD00KH
	OUT	RD00KH
	OUT	WR00KH
	OUT	RD16KH
	OUT	WR16KH
	OUT	RD32KH
	OUT	WR32KH
	OUT	RD48KH
	OUT	WR48KH
	OUT	RD00K
	OUT	WR00K
	INR	A
	OUT	RD16K
	OUT	WR16K
	INR	A
	OUT	RD32K
	OUT	WR32K
	INR	A
	OUT	RD48K
	OUT	WR48K
        EI
        RET

CALCPG:
	PUSH	B		; Pushes both B and C
	LDA	AIO$UNI
	ORA	A
	JNZ	CALCN0		; Not unit 0
	INR	H		; Skip the first 256 sectors == 4 pages
CALCN0: 
	MOV 	A,L
	ANI 	0C0H
	RRC
	RRC
	RRC
	RRC
	RRC
	RRC
	MOV 	B,A
	MOV	A,H
	ANI	01FH
	RLC
	RLC
	ORA 	B
	POP 	B		; Pops both B and C
	PUSH	PSW
	MOV     A,L
	ANI	03FH
	MOV	H,A
	MVI	L,000H
	POP	PSW
	RET

**	SMALLRD
*
*	PERFORM A READ OF 16640 BYTES OR LESS. 
*
*	BC = BYTE COUNT
*	DE = DEST ADDRESS
*	HL = BLOCK NUMBER

SMALLRD:
	MOV	A,B
	ORA	C
	RZ			; Asking to read 0 bytes so just return

	LDA	AIO$UNI		; Store a copy of AIO.UNI since we cannot access it inside critical section
	STA	RDUNIT

	CALL    CALCPG		; Calc page and offset

	PUSH	PSW
	MOV	A,H		; Add 16384 to src offset, because we'll map in at 16K instead of 00K
	ADI	040H
	MOV	H,A
	POP	PSW

	DI			; ** Start Critical section: All paging happens inside here **
	ORI	080H		; Turn on paging -- keep in mind the 512K board won't pay attention to RD00KH/RD16KH
	OUT	RD16K		; Map page0 to virt-page in ramdisk
	INR	A
	OUT	RD32K		; Always allocate two pages, so we can handle writes that are greater than 16K
	LDA	RDUNIT
	ORI	080H		; Select the proper bank, and turn on paging
	OUT     RD16KH
	OUT	RD32KH

RLOOP:  MOV     A,M             ; Load value in memory location HL into A
	STAX	D               ; Store value in A into memory location DE
	INX	D
	INX	H
        DCX     B
	MOV	A,B
	ORA	C
	JNZ	RLOOP

	MVI     A,081H		; do not disable paging until the last reg (8MHz Bug)
	OUT     RD16K		; ... and bank 0
	MVI	A,080H
	OUT	RD16KH          ; map page0 back to virt-page0
	OUT     RD32KH          ; ... and page 1 back to bank 0
	MVI	A,082H
	OUT	RD32K		; ... and page 1 back to virt-page1
	MVI	A,002H
	OUT	RD32K		; ... and disable paging
	EI			; ** End Critical section **
	RET

RDUNIT:	DB	0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm
if ($ > 1800h)
	.error	'Module overflow'
endif

last:	end
