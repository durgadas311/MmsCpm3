********** BOOT MODULE LOADER ROUTINE **********
**********  FOR SDCard H8xSPI DRIVES  **********
************************************************
VERS	EQU	'1 '		; Mar 28, 2020 08:34 drm "BSDCBOT.ASM"
************************************************
********** MACRO ASSEMBLER DIRECTIVES **********
	MACLIB	z80
	$-MACRO
************************************************

************************************************
********** PORTS AND CONSTANTS *****************
************************************************
?PORT	EQU	0F2H
?STACK	EQU	2680H
AIO$UNI EQU	2131H		; Unit number
BASE$PORT EQU	2150H		; PORT ADDRESS SAVED BY BOOT PROM
SEGOFF	EQU	2156H		; setup by SDCard boot code in ROM
BTDRV	EQU	2034H		; BOOT DRIVE NUMBER SAVED BY PROM
BOOT	EQU	2280H		; ADDRESS TO LOAD BOOT MODULE INTO
SECTR0	EQU	2280H		; LOCATION OF 'MAGIC SECTOR'
DCTYPE	EQU	SECTR0+3	; DRIVE/CONTROLLER TYPE
ISTRING EQU	SECTR0+13	; CONTROLLER INITIALIZATION STRING
NPART	EQU	SECTR0+19	; NUMBER OF PARTITIONS ON THIS DRIVE
CONTROL EQU	SECTR0+4	; CONTROL BYTE
DRVDATA EQU	SECTR0+5	; DRIVE CHARACTERISTIC DATA
SECTBL	EQU	SECTR0+20	; START OF PARTITION DEFINITION TABLE
DPB	EQU	SECTR0+47	; START OF DPB TABLE
SYSADR	EQU	2377H		; LOCATION IN BOOT MODULE TO PLACE SECTOR
				;  ADDRESS OF OPERATING SYSTEM
DRIV0	EQU	80

spi	equ	40h	; same board as WizNet

spi?dat	equ	spi+0
spi?ctl	equ	spi+1
spi?sts	equ	spi+1

SD0SCS	equ	0100b	; SCS for SDCard 0
SD1SCS	equ	1000b	; SCS for SDCard 1

CMDST	equ	01000000b	; command start bits

;
; STACK OPERATIONS -- GET BOOT STRING
;
	ORG	2480H
	JMP	START
BLCODE: DB	0		; VALUES TO BE PASSED TO BOOT MODULE
LSP:	DB	0
START:
	POP	D		; BOOT ERROR ROUTINE ADDRESS IS LOCATED HERE
	; no need to parse string, ROM did that.
	LXI	SP,?STACK	; SET UP LOCAL STACK
	PUSH	D		;  AND PUSH ADDRESS OF BOOT ERROR ROUTINE

;
; INITIALIZE THE CONTROLLER -- ASSIGN DRIVE TYPE
;
	; nothing to do?

;
; NOW, LOOK AT THE PARAMS TO SEE WHAT PARTITION
; THE USER REQUESTED.
;
	lda	aio$uni
	inr	a	; 01b or 10b
	rlc
	rlc		; SD0SCS or SD1SCS
	sta	scs
	LDA	BTDRV		; BOOT DRIVE FROM PROM DETERMINES LOGICAL
	SUI	DRIV0		; PARTN NUMBER
	LXI	H,NPART
	CMP	M		; RETURN TO BOOT PROMPT IF PARTITION
	RNC			;  NUMBER IS OUT OF RANGE
	LXI	H,SECTBL
	MOV	C,A
	MVI	B,0
	DAD	B
	DAD	B
	DAD	B		; POINT TO SECTOR TABLE ENTRY
;
; GOT CORRECT PARTITION. PREPARE TO READ THE SECTOR
;
	MOV	A,M		; SET UP REGISTERS C,E,D TO CONTAIN SECTOR
	ANI	00011111B	; (EXCLUDE 3 MSB'S - LUN - FROM ROTATION)
	MOV	C,A		;  ADDRESS FOR ROTATION
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	SRLR	C		; ROTATE C:E:D >> 1
	RARR	E
	RARR	D		; 128/sec => 256/sec
	SRLR	C		; ROTATE C:E:D >> 1
	RARR	E
	RARR	D		; 256/sec => 512/sec
	lhld	SEGOFF+0	; fixed bits, L=SEG 31:24, H=SEG 23:16
	mov	a,h
	ORA	C		; OR IT INTO NEW SECTOR ADDRESS.
	mov	h,a
	shld	cmd17+1
	xchg			; E=LBA 15:8, D=LBA 7:0
	shld	cmd17+3		;
;
;  READ IN BOOT MODULE AND JUMP TO IT WHEN DONE
;
	lxi	h,BOOT
	call	read
	rc

	; now that module is loaded, we can overlay LBA to SYSADR
	lxi	h,cmd17+1
	lxi	d,SYSADR
	lxi	b,4
	ldir
	JMP	BOOT

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
	jrnz	badblk	; turn off SCS
	call	sdblk	; turns off SCS
	ret	; CY=error
badblk:
	xra	a
	out	spi?ctl	; SCS off
	stc
	ret

scs:	db	SD0SCS
cmd17:	db	CMDST+17,0,0,0,0,1
	db	0

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
; return CY on error (A=error), SCS always off
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

	END
