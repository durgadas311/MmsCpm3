; H8 Z80-CPU v3.2 Monitor (EEPROM 28C256)
VERN	equ	020h	; ROM version

false	equ	0
true	equ	not false

alpha	equ	true
beta	equ	false

	maclib	ram
	maclib	z80
	$*macro

CR	equ	13
LF	equ	10
BEL	equ	7
TAB	equ	9
ESC	equ	27
TRM	equ	0
DEL	equ	127

memtest	equ	03000h
ramboot	equ	0c000h
; fudge this... H17 junk
R$CONST	equ	01f5ah	; 037.132 R.CONST block...
CLOCK	equ	01c19h	; 034.031 CLOCK

btovl	equ	1000h		; boot module overlay area (RAM)
btinit	equ	btovl+4		; init entry point
btboot	equ	btovl+7		; boot entry point
btdisp	equ	btovl+12	; boot front panel mnemonic
btname	equ	btovl+15	; boot string

btmods	equ	2000h	; boot modules start in ROM
bterom	equ	8000h	; end/size of ROM

; Start of ROM code
	org	00000h

rombeg:
rst0:	jmp	init

bootms:	db	'oot ',TRM

rst1:	call	intsetup
	lhld	ticcnt
	jmp	int1$cont
if ((high int1$cont) <> 0)
	.error "Overlapped NOP error"
endif

rst2	equ	$-1	; must be a nop...
	call	intsetup
	ldax	d
	jmp	int2$cont

rst3:	jmp	vrst3

goms:	db	'o ',TRM
	db	0,0

rst4:	jmp	vrst4

	db	0,0,0	; overlayed by WizNet boot, others
	dw	conout	; pointer, not vector; A=char

rst5:	jmp	vrst5
delayx:
	jmp	delay

qmsg:	db	'?',TRM

rst6:	jmp	vrst6

	db	0,0,0,0,0	; overlayed by WizNet boot, others

rst7:	jmp	vrst7

	jmp	hwboot
	jmp	hxboot

subms:	db	'ubstitute ',TRM
pcms:	db	'rog Counter ',TRM
mtms:	db	'em test',TRM

intret:
	pop	psw
	pop	psw
	pop	b
	pop	d
	pop	h
nulint:
	ei
	ret

int1$cont:
	inx	h
	shld	ticcnt
	lda	ctl$F2
	out	0f2h
	jmp	int1$fp

intsetup:
	xthl
	push	d
	push	b
	push	psw
	xchg
	lxi	h,10
	dad	sp
	push	h
	push	d
	lxi	d,ctl$F0
	ldax	d
	cma
	ani	030h
	rz
	lxi	h,2
	dad	sp
	shld	monstk
	ret

re$entry:		; re-entry point for errors, etc.
	lxi	h,ctl$F0
	mvi	m,0f0h	; !beep, 2mS, MON, !SI
	lhld	monstk
	sphl
	call	belout
	;jmp	start
start:
	ei
	lxi	h,start
	push	h
	lxi	h,prompt
	call	msgout
	call	clrdisp	; temp
prloop:
	call	coninx
	ani	01011111b ; toupper
	lxi	h,cmdtab
	mvi	b,numcmd
cmloop:
	cmp	m
	inx	h
	jrz	docmd
	inx	h
	inx	h
	djnz	cmloop
	call	belout
	jr	prloop

docmd:
	call	conout
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
icall:	pchl

cmdtab:
	db	'G'
	dw	cmdgo
	db	'S'
	dw	cmdsub
	db	'P'
	dw	cmdpc
	db	'B'
	dw	cmdboot
	db	'M'
	dw	cmdmt
	db	'T'
	dw	termod
	db	'V'
	dw	prtver
	db	'L'	; list boot modules
	dw	cmdlb
	db	'H'	; long list (help) boot modules
	dw	cmdhb
	db	'A'	; add boot module
	dw	cmdab
	db	'U'	; update entire ROM
	dw	cmdur
numcmd	equ	($-cmdtab)/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PC command (set PC)
cmdpc:
	lxi	h,pcms
	call	msgout
	lxi	h,12
	dad	sp
	mov	e,m
	inx	h
	mov	d,m
	xchg
	call	inhexcr
	jrc	cmdpc0
	call	adrnl
	call	inhexcr
	rnc
cmdpc0:
	xchg
cmdpc1:
	mvi	d,CR
	jmp	adrin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go command
cmdgo:
	lxi	h,goms
	call	msgout
	lxi	h,13
	dad	sp
	call	inhexcr
	cc	cmdpc1	; read HEX until CR
	call	crlf
	mvi	a,0d0h	; no-beep, 2mS, !MON, !single-step
	jr	cmdgo0
	di
	lda	ctl$F0
	xri	010h	; toggle single-step
	out	0f0h
cmdgo0:
	sta	ctl$F0
	pop	h
	jmp	intret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	rept	0137h-$
	db	0ffh
	endm
if	($ <> 0137h)
	.error "HDOS entry overrun 0137h"
endif
	jmp	0	; initialized by H47 boot module


int2$cont:
	ori	010h	; disable single-step
	out	0f0h
	stax	d
	ani	020h	; MON active?
	jnz	start	; break to monitor code
	jmp	vrst2	; else chain to (possible) user code.

take$5:
	mvi	a,5	; 5 seconds
take$A:
	lxi	h,timeout
	shld	vrst1+1
	sta	SEC$CNT
	mvi	a,1
	sta	MFlag
	ei
	ret

timeout:
	lxi	h,ticcnt
	xra	a
	ora	m
	rnz
	inx	h
	mov	a,m
	rrc
	rc
	; every 512 ticks... 1024mS
	lxi	h,SEC$CNT
	dcr	m
	rnz
error:
	lhld	monstk
	sphl
	lxi	h,qmsg
	call	msgout
	lxi	h,nulint
	shld	vrst1+1
	sta	MFlag
	in	0f2h
	ani	00000011b
	jrnz	error0
	out	07fh
error0:
	jmp	re$entry

; determine device for port 078H
; return phy drv number in D.
gtdev1:
	mvi	d,0	; Z17
	in	0f2h
gtdev0:
	ani	00000011b	; port 078H device
	rz		; Z17 (or Z37)
	cpi	01b
	mvi	d,5
	rz		; Z47
	cpi	10b
	mvi	d,3
	rz		; Z67/MMS77320
	jmp	error	; fatal error... not defined

; determine device for port 078H
; return phy drv number in D.
gtdev2:
	mvi	d,46	; Z37
	in	0f2h
	rrc
	rrc
	jr	gtdev0	; rest are same

; determine default boot device.
gtdfbt:
	lxi	d,0
	in	0f2h
	ani	01110000b	; default boot selection
	cpi	00100000b	; device at 07CH
	jrz	gtdev1
	cpi	00110000b	; device at 078H
	jrz	gtdev2
	jmp	gtdvtb		; get MMS device

; Check SW501 for installed device.
; C = desired port pattern, 00=Z17/Z37, 01=Z47, 10=Z67, 11=undefined
; returns base I/O port adr in B.
getport:
	mvi	b,07ch
	in	0f2h
	ani	003h
	cmp	c
	rz
	mvi	b,078h
	in	0f2h
	rrc
	rrc
	ani	003h
	cmp	c
	rz
	pop	h	; discard return address
s501er:
	lxi	h,s501ms
	jmp	msgout

s501ms:	db	'SW1 wrong ',TRM

inport0:
	ora	a	; NC
; input from cport+CY
inportx:
	push	b
	lda	cport
	aci	0
	mov	c,a
	inp	a
	pop	b
	ret

delay:
	push	h
	lxi	h,ticcnt
	add	m
delay0:
	cmp	m
	jrnz	delay0
	pop	h
	ret

digerr:
	call	belout
	jr	btdig0
; Got a digit in boot command, parse it
btdig:	; boot by phys drive number, E=0
	call	conout	; echo digit
	ani	00fh	; convert to binary
	mov	d,a
btdig0:
	call	conin	; get another, until term char (C)
	cmp	c
	jrz	gotnum
	cpi	'0'
	jrc	digerr
	cpi	'9'+1
	jrnc	digerr
	call	conout
	ani	00fh
	mvi	b,10	; add 10 times, i.e. D = (D * 10) + A
btdig1:
	add	d
	jc	error
	djnz	btdig1
	mov	d,a
	cpi	200
	jnc	error
	jr	btdig0

gotnum:	; Boot N... "N" in D
	mov	a,d
	cpi	5
	jc	goboot
	cpi	9
	jnc	goboot
	adi	200	; modify 5..8 to not conflict
	mov	d,a
	jmp	goboot

cmdboot:
	lxi	h,bootms
	call	msgout	; complete (B)oot
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
	lxi	sp,bootbf
	call	gtdfbt
	mvi	c,CR	; end input on CR
	jr	boot0
bterr:
	call	belout
boot0:
	call	conin
	cmp	c
	jz	goboot
	mvi	e,0
	cpi	'0'
	jrc	nodig
	cpi	'9'+1
	jrc	btdig
nodig:	; boot by letter... Boot alpha-
	ani	05fh ; toupper
	cpi	'Z'+1
	jrnc	bterr
	cpi	'A'
	jrc	bterr
	call	conout
	call	conout
	cpi	'B'
	jrc	gotit	; 'A' is synonym for default
	push	b
	mov	c,a
	lxi	h,bfchr
	call	bfind
	pop	b
	jc	error
	call	setboot	; temp?
	lda	btovl+2	; base phy drv num
	mov	d,a
gotit:
	mvi	a,'-'	; next is optional unit number...
	call	conout
	jr	luboot0

lunerr:
	call	belout
luboot0:
	call	conin
	cmp	c
	jrz	goboot
	cpi	':'
	jrz	colon
	cpi	' '
	jrz	space
	cpi	'0'
	jrc	lunerr
	cpi	'9'+1
	jrnc	lunerr
	call	conout
	sui	'0'
	mov	e,a	; single digit (0..9)
luboot1:
	call	conin
	cmp	c
	jrz	goboot
	cpi	':'	; Boot alpha-dig:str
	jrz	colon
	cpi	' '	; cosmetic spaces?
	jrz	space
	mvi	a,BEL
space:
	call	conout
	jr	luboot1

colon:	; get arbitrary string as last boot param
	mvi	b,0
	lxi	h,bootbf
btstr0:
	call	conout
	call	conin
	inr	b
	inx	h
	mov	m,a
	cmp	c
	jrnz	btstr0
	mov	a,b
	sta	bootbf	; bootbf: <len> <string...> as in CP/M cmd buf
	xra	a	; TRM - string terminator
btstr1:	; use stack as char array...
	push	psw
	inx	sp	; undo half of push
	dcx	h
	mov	a,m
	djnz	btstr1
; D=Phys Drive base number, E=Unit number
; (or, D=Phys Drive unit, E=0)
goboot:
	call	crlf
	lxi	h,error
	push	h
	push	d	; save unit num (E)
	mov	c,d
	lxi	h,bfnum
	call	bfind	; might have already been loaded...
	pop	d
	rc
	call	h17init
	mov	a,e
	sta	AIO$UNI	; relative unit num
	add	d
	sta	l2034h	; boot phys drv unit num
	jmp	btboot

hwboot:	xra	a
	sta	MFlag
hxboot:	lxi	h,CLOCK
	shld	vrst1+1
	jmp	bootbf

msg$die:
	call	msgout
	di
	hlt

; ROM start point - initialize everything
; We know we have at least 64K RAM...
; But, right now, ROM is in 0000-7FFF so must copy
; core code and switch to RAM...
init:
	lxi	h,0
	lxi	d,0
	lxi	b,2000h	; copy everything?
	ldir
	lxi	h,0ffffh
	sphl
	push	h	; save top on stack
	lxi	h,re$entry
	push	h
	call	coninit
	xra	a
	sta	l2153h
	mvi	a,00100000b	; ORG0 on, 2mS off...
	sta	ctl$F2	; 2mS, Org0 OFF
	out	0f2h	; enable RAM now...
	mvi	a,0c9h	; RET
	sta	PrsRAM
	lxi	h,05000h	; 0, (beep, 2mS, !MON, !SI)
	shld	MFlag
	rst	1	; kick-start clock
	lxi	h,signon
	call	msgout
	; save registers on stack, for debugger access...
	xthl
	push	d
	push	b
	push	psw
	xchg
	lxi	h,10
	dad	sp
	push	h
	push	d
	lxi	d,ctl$F0
	ldax	d
	cma
	ani	030h
	rz
	lxi	h,2
	dad	sp
	shld	monstk
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Substitute command
cmdsub:
	lxi	h,subms
	call	msgout
	lxi	h,l2003h
	mvi	d,CR
	call	adrin
	xchg
cmdsub0:
	call	adrnl
	mov	a,m
	call	hexout
	call	spout
cmdsub1:
	call	hexin
	jrnc	cmdsub4
	cpi	CR
	jrz	cmdsub2
	cpi	'-'
	jrz	cmdsub3
	cpi	'.'
	rz
	call	belout
	jr	cmdsub1
cmdsub2:
	inx	h
	jr	cmdsub0
cmdsub3:
	call	conout
	dcx	h
	jr	cmdsub0
cmdsub4:
	mvi	m,000h
cmdsub5:
	call	conout
	call	hexbin
	rld
	call	inhexcr
	jrnc	cmdsub2
	jr	cmdsub5

inhexcr:
	call	conin
	cpi	CR
	rz
	call	hexchk
	cmc
	rc
	call	belout
	jr	inhexcr

; This loop checks for auto boot while waiting for command input.
; Theoretically, one could flip the auto-boot dipsw at the MMS: prompt?
coninx0:
	call	nulfn	; some patched-out code?
coninx:
	in	0edh
	rrc
	jrnc	coninx0
conin:
	in	0edh
	rrc
	jrnc	conin
	in	0e8h
	ani	07fh
	cpi	DEL	; DEL key restarts from anywhere?
	jz	re$entry
	ret

belout:
	mvi	a,BEL
conout:
	push	psw
conot1:
	in	0edh
	ani	00100000b
	jrz	conot1
	pop	psw
	out	0e8h
	ret

; D=term char (e.g. '.' for Substitute)
; HL=location to store address
adrin:
	push	h
	lxi	h,0
adrin0:
	cnc	conin
	call	hexchk
	jrc	adrin1
	call	conout
	call	hexbin
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	mov	l,a
	jr	adrin0
adrin1:
	cmp	d
	jrz	adrin2
	call	belout
	ora	a
	jr	adrin0
adrin2:
	call	conout
	xchg
	pop	h
	mov	m,d
	dcx	h
	mov	m,e
	ret

hexbin:
	sui	'9'+1
	jrnc	hexbi0
	adi	7
hexbi0:
	adi	3
	ret

hexin:
	call	conin
hexchk:
	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	rnc
	ani	05fh	; toupper
	cpi	'A'
	rc
	cpi	'F'+1
	cmc
	ret

adrnl:
	call	crlf
adrout:
	mov	a,h
	call	hexout
	mov	a,l
	call	hexout
spout:
	mvi	a,' '
	jr	conout

hexout:
	push	psw
	rlc
	rlc
	rlc
	rlc
	call	hexdig
	pop	psw
hexdig:
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	jr	conout

coninit:
	mvi	c,12	; 9600 baud
	in	0f2h
	ani	10000000b	; 9600/19.2K?
	jrz	ci0
	mvi	c,6	; 19.2K baud
ci0:	mvi	a,083h
	out	0ebh
	xra	a
	out	0e9h
	mov	a,c
	out	0e8h
	mvi	a,003h
	out	0ebh
	xra	a
	out	0e9h
	mvi	a,00001111b	; OUT2=1 hides 16C2550 intr enable diff
	out	0ech
	ret

waitcr:
	call	conin
	cpi	CR
	jrnz	waitcr
crlf:
	mvi	a,CR
	call	conout
	mvi	a,LF
	jmp	conout

msgout:
	mov	a,m
	ora	a
	rz
	call	conout
	inx	h
	jr	msgout

cserr:
	lxi	h,cserms
	jr	msgout

cserms:	db	BEL,'Cksum error',TRM
topms:	db	'Top of Mem: ',TRM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Test command
cmdmt:
	lxi	h,mtms
	call	msgout
	call	waitcr
	lxi	h,topms
	call	msgout
	lxi	h,0
	dad	sp
	mov	a,h
	inr	a
	jrz	cmdmt0
	sui	020h
cmdmt0:
	mov	h,a
	mvi	l,0
	dcx	h
	sui	'0'
	mov	e,a
	call	adrout
	call	crlf
	mvi	d,000h
	mvi	c,030h
	mvi	b,000h
	exx
	lxi	h,mtest0
	lxi	d,memtest - (mtest1-mtest0)
	lxi	b,mtestZ-mtest0
	ldir
	lxi	d,memtest
	lxi	h,mtest1
	mvi	c,mtestZ-mtest1
	xra	a
	exaf
	xra	a
cmdmt1:
	add	m
	exaf
	xchg
	add	m
	exaf
	xchg
	inx	h
	inx	d
	dcr	c
	jrnz	cmdmt1
	mov	c,a
	exaf
	cmp	c
	jnz	cserr
	di
	jmp	memtest - (mtest1-mtest)

;------------------------------------------------
; Start of relocated code...
; Memory Test routine, position-independent
;
mtest0:
mtest:
	mvi	a,20h	; ORG0 on (ROM off)
	out	0f2h
mtest1:		; lands at 03000h - retained relocated code
	exx
	mov	h,d
	mvi	l,0
	mov	a,b
	exx
	mov	c,a
	mvi	b,2
mtest2:
	mov	a,c
	rlc
	rlc
	rlc
	rlc
	mov	c,a
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
mtest3:
	in	0edh
	ani	020h
	jrz	mtest3
	dcr	b
	jrnz	mtest2
	mvi	a,CR
	out	0e8h
	exx
	mov	a,b
mtest4:
	mov	m,a
	adi	1
	daa
	inr	l
	jrnz	mtest4
	inr	h
	dcr	c
	jrnz	mtest4
	mov	a,h
	sub	d
	mov	c,a
	mov	h,d
	mvi	l,0
	mov	a,b
mtest5:
	cmp	m
	jrnz	mtest9
	adi	1
	daa
	inr	l
	jrnz	mtest5
	inr	h
	dcr	c
	jrnz	mtest5
	exx
	lxi	h,memtest
	lxi	d,0
	lxi	b,mtestZ-mtest1
	exx
	mov	a,d
	xri	030h
	mov	d,a
	jrz	mtest6
	mov	c,e
	jr	mtest7
mtest6:
	mvi	c,030h
	mvi	a,001h
	add	b
	daa
	mov	b,a
	exx
	xchg
	exx
mtest7:
	exx
	ldir
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	mvi	c,mtestZ-mtest1
	xra	a
mtest8:
	add	m
	inx	h
	dcr	c
	jrnz	mtest8
	mov	c,a
	exaf
	cmp	c
	jrnz	mtestE
	exaf
	mov	a,d
	ani	0f0h
	mov	h,a
	mvi	l,0
	pchl
mtest9:
	xra	m
	mov	d,a
	mvi	a,LF
	out	0e8h
mtestA:
	in	0edh
	ani	020h
	jrz	mtestA
	mvi	c,2
	mvi	b,4
mtestB:
	mov	a,h
	rlc
	rlc
	rlc
	rlc
	ani	00fh
	adi	090h
	daa
	aci	040h
	daa
	out	0e8h
mtestC:
	in	0edh
	ani	020h
	jrz	mtestC
	dad	h
	dad	h
	dad	h
	dad	h
	djnz	mtestB
	mvi	a,' '
	out	0e8h
mtestD:
	in	0edh
	ani	020h
	jrz	mtestD
	dcr	c
	xchg
	mvi	b,002h
	jrnz	mtestB
	mvi	a,'*'
	out	0e8h
	jr	mtestG
mtestE:
	in	0edh
	ani	020h
	jrz	mtestE
	mvi	a,LF
	out	0e8h
mtestF:
	in	0edh
	ani	020h
	jrz	mtestF
	mvi	a,'!'
	out	0e8h
mtestG:
	in	0edh
	ani	020h
	jrz	mtestG
	xra	a
	mvi	b,0fah
mtestH:
	dcr	a
	jrnz	mtestH
	djnz	mtestH
	mvi	a,BEL
	out	0e8h
	jr	mtestG
; End of relocated code
mtestZ	equ	$
;------------------------------------------------

; returns with interrupts disabled
h17init:
	di
	xra	a
	out	07fh
	push	d
	lxi	h,ctl$F0
	mvi	m,0d0h	; !beep, 2mS, !mon, !SI
	lxi	h,R$CONST
	lxi	d,D$CONST
	lxi	b,88
	ldir
	mov	l,e
	mov	h,d
	inx	d
	mvi	c,30
	mov	m,a
	ldir	; fill l20a0h...
	inr	a	; A=1
	lxi	h,intvec	; vector area
h17ini0:
	mvi	m,0c3h
	inx	h
	mvi	m,LOW (nulint-rst0)
	inx	h
	mvi	m,HIGH (nulint-rst0)
	inx	h
	add	a	; shift left, count 7
	jp	h17ini0
	pop	d
	ret

prompt:	db	CR,LF,'H8: ',TRM

nulfn:
	ret

; Special entry points expected by HDOS, or maybe Heath CP/M boot.
	rept	0613h-$
	db	0ffh
	endm
if	($ <> 0613h)
	.error "HDOS entry overrun 0613h"
endif
	jmp	0	; initialized by H47 boot module
	db	0
	jmp	0	; initialized by H47 boot module

; temp: do this the hard way...
setboot:
	lhld	btdisp
	shld	Aleds
	lda	btdisp+2
	sta	Aleds+2
	ret

clrdisp:
	lxi	h,fpLeds
	mov	e,l
	mov	d,h
	lxi	b,9-1
	mvi	m,11111111b
	inx	d
	ldir
	ret

; Front panel display refresh...
int1$fp:
	lxi	h,MFlag
	mov	a,m
	mov	b,a
	ani	01000000b	; refresh display?
	inx	h	; ctl$F0
	mov	a,m
	mvi	c,0
	jrnz	fp3
	inx	h	; Refind
	dcr	m
	jrnz	fp2
	mvi	m,9
fp2:	mov	e,m	; 1-9
	mvi	d,0
	dad	d	; fpLeds[E-1]
	mov	c,e
fp3:	ora	c
	out	0f0h
	mov	a,m
	out	0f1h
	; See if time to update display values
;	mvi	l,LOW ticcnt
;	mov	a,m
;	ani	1fh
;	cz	ufd
	jmp	intret

; match boot module by character (letter)
bfchr:	ldx	a,+10
	cmp	c
	ret

; match boot module by FP key
bfkey:	ldx	a,+11
	cmp	c
	ret

; match boot module by phy drv number
bfnum:	mov	a,c
	subx	+2
	cmpx	+3
	rnc	; also NZ
	xra	a
	ret

bflst:	mov	a,c
	ora	a
	mvi	a,','
	cnz	conout
	inr	c
	pushix
	pop	h
	lxi	d,15
	dad	d
	call	msgout
	lxi	h,bflst
	xra	a
	inr	a	; NZ
	ret

bfllst:	pushix
	pop	h
	lxi	d,15
	dad	d
	call	msgout
	mvi	a,TAB
	call	conout
	ldx	a,+10
	call	conout
	mvi	a,' '
	call	conout
	ldx	a,+11
	adi	'0'
	jrnc	bfll0
	mvi	a,'-'
bfll0:	call	conout
	mvi	a,' '
	call	conout
	ldx	a,+2
	call	decout
	ldx	a,+3
	dcr	a
	jrz	bfll1
	mvi	a,'-'
	call	conout
	ldx	a,+2
	addx	+3
	dcr	a
	call	decout
bfll1:	call	crlf
	lxi	h,bfllst
	xra	a
	inr	a	; NZ
	ret

; Find boot module and load into 1000h if necessary.
; HL=match function, returns Z if found, BC=target, IX=module
; Return CY at end of modules (not found)
bfind:
	; first, check if already loaded
	lxix	btovl
	call	icall
	rz
bfind0:
	; must map ROM back in, so prevent interruptions...
	; also, loose memory at SP...
	di
	lxiy	0
	dady	sp
	lxi	sp,0ffffh
	lda	ctl$F2
	ani	11011111b	; ORG0 off
	out	0f2h
	lxix	btmods	; start of modules...
bf0:	call	icall
	jrz	bf9
	ldx	e,+0
	ldx	d,+1
	dadx	d
	db 0ddh ! mov	a,h	; mov a,IX(h)
	cpi	HIGH bterom	; end of ROM
	jrnc	bf1
	ldx	a,+0
	orax	+1
	jrz	bf1
	ldx	a,+0
	anax	+1
	cpi	0ffh
	jrnz	bf0
bf1:	stc	; CY = end of list (not found)
	lda	ctl$F2
	out	0f2h
	spiy
	ei
	ret

bf9:	; match found, now load into place and init
	ldx	c,+0
	ldx	b,+1
	pushix
	pop	h
	lxi	d,btovl
	ldir
	; now call init routine... but must restore RAM...
	lda	ctl$F2
	out	0f2h
	call	btinit
	xra	a	; NC
	spiy
	ei
	ret

; assume < 100
decout:
	mvi	b,'0'
decot0:
	sui	10
	jc	decot1
	inr	b
	jmp	decot0
decot1:
	adi	10
	adi	'0'
	push	psw
	mov	a,b
	call	conout
	pop	psw
	jmp	conout

; Returns NZ if found, D=phy drv
gtdvtb:
	in	0f2h
	ani	01110000b	; default boot device
	rlc
	rlc
	rlc
	rlc
	lxi	h,defbt
gtdvtb0:
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m
	cpi	0ffh
	rz	; no device
	mov	d,a
	ret	; NZ

defbt:	; default boot table... port F2 bits 01110000b
	db	33	; -000---- MMS 5" floppy 0
	db	29	; -001---- MMS 8" floppy 0
	db	0ffh	; -010---- n/a  (port 7CH)
	db	0ffh	; -011---- n/a  (port 78H)
	db	41	; -100---- VDIP1
	db	70	; -101---- GIDE disk part 0
	db	60	; -110---- Network
	db	0ffh	; -111---- none

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; List available boot modules
cmdlb:	lxi	h,lbmsg
	call	msgout
	lxi	h,bflst
	mvi	c,0
	call	bfind0
	ret

lbmsg:	db	'ist boot modules',CR,LF,0
hbmsg:	db	'elp boot modules',CR,LF,0

cmdhb:	lxi	h,hbmsg
	call	msgout
	lxi	h,bfllst
	call	bfind0
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add new boot module
cmdab:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update ROM
cmdur:	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Terminal mode - shuttle I/O between H19 and serial port
; since both ports operate at the same speed, don't need
; to check ready as often.
termod:
	lxi	h,terms
	call	msgout
	call	waitcr
termfl:
	in	0edh
	ani	01100000b
	cpi	01100000b
	jrnz	termfl	; wait for output to flush
	in	0ebh
	ori	10000000b
	out	0ebh
	out	0dbh
	in	0e8h
	out	0d8h
	in	0e9h
	out	0d9h
	in	0ebh
	ani	01111111b
	out	0ebh
	out	0dbh
	xra	a
	out	0d9h
	in	0d8h
	mvi	a,00fh
	out	0dch
termlp:
	in	0ddh
	ani	00000001b
	jrz	terml0
	in	0d8h
	out	0e8h
terml0:
	in	0edh
	ani	00000001b
	jrz	termlp
	in	0e8h
	out	0d8h
	jr	termlp

terms:	db	'erminal Mode',TRM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print ROM version command
prtver:
	lxi	h,versms
	call	msgout
	ret

versms:	db	'ersion '
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0',0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
signon:	db	'H8 Monitor v'
	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
if alpha
	db	'(alpha)'
endif
if beta
	db	'(beta)'
endif
	db	CR,LF,0

	rept	1000h-$
	db	0ffh
	endm
if	($ <> 1000h)
	.error "core ROM overrun"
endif

; module overlay area starts here...
	rept	1800h-$
	db	0ffh
	endm
if	($ <> 1800h)
	.error "overlay ROM overrun"
endif
	end
