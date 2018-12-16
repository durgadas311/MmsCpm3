VERS equ '0b' ; November 1, 1982  13:45  drm  "RELOC.ASM"

	maclib	Z80

;*****************************************************
;**** Relocator for OSZ89, OS422, and CCP422	 *****
;**** (Equivilent to a Cold Boot for the 77422)  *****
;****  Copyright (C) 1982 Magnolia microsystems  *****
;*****************************************************

false	equ	0
true	equ	not false

CPM	equ	0	;warmboot entry for users
BDOS	equ	5	;BDOS entry for users
RST5	equ	(5)*8
FCB	equ	5CH
DMA	equ	80H
TPA	equ	0100H

msgout	equ	9
retver	equ	12

;********************************************************
;*  I/O port base addresses
;********************************************************
;m422	 equ	 078h	 ;77422 board
port	equ	0f2h	;gpio

;********************************************************
;*   77422 board ports
;********************************************************
;dat422  equ	 m422	 ;input/output
;intoff  equ	 m422+1  ;output only
;nmi	 equ	 m422+2  ;output only
;last	 equ	 m422+3  ;output only
;sta422  equ	 m422+1  ;input only

bel	equ	7
lf	equ	10
cr	equ	13

	org	TPA
begin:	jmp	start

signon: db	cr,lf,'RELOC v2.29'
	dw	VERS
	db	'$'

	ds	64
stack:	ds	0

swerr:	db	cr,lf,bel,'SW501 is set wrong!$'
vererr: db	cr,lf,bel,'Environmental error!$'

start:	lxi	sp,stack
	lxi	d,signon
	mvi	c,msgout
	call	bdos
	mvi	c,retver
	call	bdos
	cpi	22H
	lxi	d,vererr
	jnz	errxit
	mov	a,h
	ora	a
	jnz	errxit
	lhld	bdos+1
	mov	a,l
	ora	a
	jz	errxit
	push	h
	inx	h
	mov	a,m	;get entry routine address lo-byte
	cpi	11H	;if dri's BDOS is running, it will be "11"
	jnz	errxit
	pop	h
	mvi	l,0
	dcx	h	;point to last byte of CCP (system drive designator)
	mov	a,m
	cpi	16+1
	jnc	errxit
	sta	sysdrv	;save current system-drive designator
	mvi	a,(JMP)
	sta	RST5
	lxi	h,INT5
	shld	RST5+1
	in	port
	mvi	c,07cH
	ani	11b
	cpi	11b
	jrz	re0
	mvi	c,078h
	in	port
	ani	1100b
	cpi	1100b
	jrz	re0
	lxi	d,swerr
errxit: mvi	c,msgout
	call	bdos
	jmp	cpm
re0:	mov	a,c
	sta	porta
	inr	c
	inr	c
	outp	a	;cause NMI (soft RESET) in 77422
	inr	c
	outp	a	;cause pending INT in 77422
	dcr	c
	dcr	c
re1:	inp	a	;wait for INT to be acknowledged
	ani	0001b
	jnz	re1
	call	clear422	;run-out all characters waiting to be taken.
	lxix	modules ;(IX) = SPR module address (first module is OS422)
	call	getlen	;(BC) = Length of module
			;(IX) = Address of module (code)
	sbcd	rBC
	lxi	h,0	;"top of memory" in a 64K system (77422's system)
	ora	a
	dsbc	b	;(HL) = Execution address of OS422
	shld	rHL
	xchg		;(DE) =  ''
	call	relocate	;relocate module.
			;(IX) = next SPR module
	mvi	a,0e1h	;function code for "execute module"
	sta	func
	lxi	h,func
	lxi	b,7
	call	put422	;send command
	pushiy
	pop	h	;(HL) = current address of OS422
	lbcd	rBC	;(BC) = Length of OS422
	call	put422	;send module
; done with OS422, now do CCP422
	call	getlen	;get length of CCP422
	xchg		;(HL) = execution address of OS422
	ora	a
	dsbc	b	;(HL) = execution address of CCP422
	xchg
	call	relocate	;relocate CCP422
	lhld	BDOS+1
	mvi	l,0
	ora	a
	dsbc	b	;find address to store CCP422
	push	h	;save CCP422 storage address
	push	d	;save CCP422 execution address
	push	b	;save CCP422 size
	xchg		;(DE) = CCP422 storage address
	pushiy
	pop	h	;(HL) = CCP422 current address
	ldir		;(BC) = CCP422 size - put CCP422 into storage
	dcx	d	;point to last byte of CCP (system drive designator)
	lda	sysdrv
	stax	d	;put system drive designator in CCP422
; done with CCP422, do OSZ89
	call	getlen	;(BC) = length of OSZ89, (IX) = start of OSZ89
	pop	h
	stx	l,+0	;
	stx	h,+1	;save CCP422 size in OSZ89+0,1
	pop	h
	stx	l,+2	;
	stx	h,+3	;save CCP422 exec addr in OSZ89+2,3
	pop	h	;restore CCP422 storage address
	ora	a
	dsbc	b	;(HL) = OSZ89 execution address
	xchg		;(DE) =  ''
	call	relocate	;relocate OSZ89
	ldy	l,+4	;(IY) = Address of module
	ldy	h,+5	;(HL) = "cstart" address from OSZ89+4,5
	shld	cstart	;save properly relocated start-up address
	pushiy
	pop	h	;(HL) = OSZ89 current address
	ldir		;(BC) = OSZ89 length - put OSZ89 in executable location
;
	lda	porta	;give system port address of 77422 board
	mov	c,a
	lhld	cstart	;
	pchl		;startup CP/M-422


*********************************************************************

clear422:		;this must be a subroutine (CALL-RET).
	lxi	h,junk	 ;in case an EOP interupt occurs, register must be
	lda	porta
	mov	c,a	 ;validly initialized
cl0:	inp	a	;clear 9517 in case it has an extranious character.
	inr	c
	inp	a	;if the DMA is setup, we must clean it out.
	dcr	c
	ani	1000b
	jnz	cl0
	ret

junk:	db	0,0,0	;should only require 1 byte, but to be sure...

getlen: 		;get module length (bytes)
			;(IX) = SPR module address
	ldx	c,+1
	ldx	b,+2	;(BC) = module length (bytes)
	db 0ddh ;
	inr h	;;;;;;;;;inr IXH      ;module starts at +100H
	ret		;(IX) = Address of module

relocate:		;(IX) = Address of module
			;(DE) = Destination address (relocation base)
			;(BC) = Module size (bytes)
	pushix		;save Address of module for return from routine
	pushix
	popiy		;(IY) = Address of module
	dadx	b	;(IX) = Address of bit map
	push	b	;save module size for retrun from routine
	DCXIX
	LDX	A,+0	;"prime" A' register
	EXAF
RELOC:	MOV	A,C
	ORA	B	;check if there are no more byte to relocate
	JZ	DONE
	MOV	A,C	;
	DCX	B	;count one byte
	ANI	00000111B	;check if on 8th byte
	JNZ	NOSTEP	;if at 8th byte, step to next bitmap byte
	EXAF		;THIS SEQUENCE MAINTAINS INTEGRITY OF BITMAP
	STX	A,+0
	INXIX		;WHILE SELECTING NEXT ELEMENT
	LDX	A,+0
	EXAF
NOSTEP: RALX	+0	;TEST CURRENT BIT IN MAP
	JNC	NOREL	;DON'T RELOCATE IF ZERO
	LDY	A,+0	;GET HI-BYTE OF ADDRESS TO RELOCATE
	ADD	D	;PAGE-RELOCATE ADDRESS
	STY	A,+0	;STORE BACK IN MODULE
NOREL:	INXIY
	JMP	RELOC	;CONTINUE UNTILL FINISHED...
DONE:	EXAF
	STX	A,+0	;RESTORE LAST ELEMENT OF BITMAP
	inxix		;(IX) = Last byte of bit map +1
	db 0ddh ;
	mov a,l ;;;;;;;;;mov a,IXL
	adi	01111111b
	push	psw	;save carry
	ani	10000000b	;round up to next 128-byte boundary
	db 0ddh ;
	mov l,a ;;;;;;;;;mov IXL,a
	pop	psw	;restore carry
	mvi	a,0
	db 0ddh ;
	adc h	;;;;;;;;;adc IXH
	db 0ddh ;
	mov h,a ;;;;;;;;;mov IXH,a
			;(IX) = Start of next SPR module
			;(DE) = Relocation base (unchanged since entry)
	pop	b	;(BC) = Length of module
	popiy		;(IY) = Address of module
	ret

; Byte count (BC) must be greater than 1.
put422: mov	a,c	;must handle blocks larger than 256 bytes
	ora	a	;(Z80 OUTIR/INIR cannot)
	mov	e,b
	jz	pu3
	inr	e
pu3:	mov	b,c
	lda	porta
	mov	c,a
	inr	c
pu0:	inp	a
	ani	0100b	;check channel 2 for idle
	jz	pu0
	dcr	c
	mov	a,m	;send first byte
	inx	h
	outp	a
	inr	c
pu1:	inp	a
	ani	0100b
	jz	pu1
	dcr	c
	dcr	b
	jz	pu4
pu2:	outir
pu4:	dcr	e
	jnz	pu2
	ret

INT5:	inr	c
	outp	a	;this routine will usually terminate "get422".
	dcr	c
	ini		;get last byte of transfer.
	pop	b	;discard interupt return address.
	ei
	ret		;and return to caller.

porta:	db	0
sysdrv: db	0
cstart: dw	0

func:	db	0	;function code "E1"
rBC:	dw	0	;module size (bytes)
rDE:	dw	0	;
rHL:	dw	0	;module load/execution address

	ds	0	;prints address on listing (only function)

@@ set (($-begin) and 0ffh)
 if @@ ne 0
 rept 100h-@@
 db 0
 endm
 endif

modules: end

