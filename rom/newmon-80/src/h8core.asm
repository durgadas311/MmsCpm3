; H8 8080A-CPU v? Monitor (EEPROM 28C256)
VERN	equ	020h	; ROM version

false	equ	0
true	equ	not false

alpha	equ	6
beta	equ	31

	maclib	ram
	maclib	setup
pcode	set	08080h

	$*macro

CR	equ	13
LF	equ	10
BEL	equ	7
TAB	equ	9
BS	equ	8
ESC	equ	27
TRM	equ	0
DEL	equ	127

; ctrl port F2 bit definitions for 8080A...
;ctl$SPD		equ	00010100b	; CPU speed control bits
;ctl$CLK		equ	00000010b	; enable H89 2mS clock (not used here)
ctl$MEM1	equ	00001000b	; maps full ROM (if !ORG0)
ctl$ORG0	equ	00100000b	; maps full RAM
ctl$IO1		equ	10000000b	; enables EEPROM write

; MFlag bit definitions
mfl$HLT	equ	10000000b	; disable HLT processing (TODO)
mfl$NRF	equ	01000000b	; disable refresh of display
mfl$DDU	equ	00000010b	; disable disp update (debug info)
mfl$CLK	equ	00000001b	; allow 2mS clock hook (user hook)

; H8-512K MMU (not used?)
mmu	equ	0	; base port
rd	equ	0
wr	equ	4
pg0k	equ	0
pg16k	equ	1
pg32k	equ	2
pg48k	equ	3
ena	equ	80h
rd00k	equ	mmu+rd+pg0k
rd16k	equ	mmu+rd+pg16k
rd32k	equ	mmu+rd+pg32k
rd48k	equ	mmu+rd+pg48k
wr00k	equ	mmu+wr+pg0k
wr16k	equ	mmu+wr+pg16k
wr32k	equ	mmu+wr+pg32k
wr48k	equ	mmu+wr+pg48k

rtc	equ	0a0h	; standard port address of RTC 72421

memtest	equ	03000h
ramboot	equ	0c000h
; fudge this... H17 junk
R$CONST	equ	01f5ah	; 037.132 R.CONST block...
CLOCK	equ	01c19h	; 034.031 CLOCK

; offsets in a module
mdpgs	equ	0	; num pages
mdorg	equ	1	; ORG for module (run/load addr)
mdbase	equ	2	; base phy drv num
mdluns	equ	3	; num LUNs
mdinit	equ	4	; init entry point
mdboot	equ	7	; boot entry point
mdchr	equ	10	; device letter
mdkey	equ	11	; device key
mdport	equ	12	; device port, 0 if variable
mddisp	equ	13	; boot front panel mnemonic
mdname	equ	16	; boot string

btmods	equ	2000h	; boot modules start in ROM
bterom	equ	8000h	; end/size of ROM

rptcnt	equ	16
debounce equ	1

; Start of ROM code
	org	00000h

rombeg:
rst0:
	di	; can't be JMP or Heath CP/M thinks we're an H89
	jmp	init

	jmp	getport
	db	0

rst1:	call	intsetup
	lhld	ticcnt
	jmp	int1$cont
if ((high int1$cont) <> 0)
	.error 'Overlapped NOP error'
endif

rst2	equ	$-1	; must be a nop...
	call	intsetup
	ldax	d
	jmp	int2$cont

rst3:	jmp	vrst3	; 0018

	jmp	crlf	; 001b
	dw	retmon	; 001e

rst4:	jmp	vrst4

	db	0,0,0	; overlayed by WizNet boot, others
	dw	conout	; pointer, not vector; A=char

rst5:	jmp	vrst5

	jmp	delay
qmsg:	db	'?',TRM

rst6:	jmp	vrst6

	db	0,0,0,0,0	; overlayed by WizNet boot, others

rst7:	jmp	vrst7

; routines made public (to modules)
	jmp	hwboot	; 003b
	jmp	hxboot	; 003e
	jmp	take$A	; 0041
	jmp	msgout	; 0044
	jmp	linin	; 0047
	jmp	conin1	; 004a - without kaypad or DEL

intret:
	pop	psw	; discard SP?
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
	xthl	; HL=PC (ret adr) [HL]
	push	d		; [HL DE]
	push	b		; [HL DE BC]
	push	psw		; [HL DE BC AF]
	xchg		; DE=PC
	lxi	h,nReg-2
	dad	sp
	push	h		; [HL DE BC AF SP]
	push	d	; save PC (ret adr)
	lxi	d,ctl$F0
	ldax	d
	cma
	ani	030h	; org0 or mem1
	rz		; return to caller...
	lxi	h,2
	dad	sp
	shld	monstk	; a.k.a. RegPtr
	ret

re$entry:		; re-entry point for errors, etc.
	lxi	h,ctl$F0
	mvi	m,0f0h	; !beep, 2mS, MON, !SI
	lhld	monstk
	sphl
	call	belout	; TODO: beep front panel if appropriate
	;jmp	start
start:
	lxi	h,start
	push	h
	; reset FP display... this doesn't make a lot of sense...
	lda	DspMod
	ani	00000001b
	cma
	sta	DsProt
	ei
	; avoid prompt if last was keypad command...
	lxi	h,prompt
	lda	lstcmd
	ora	a
	cp	msgout
prloop:
	; could take one of two paths here,
	; console or kaypad...
	call	cmdin
	cpi	'?'	; HELP command?
	jz	nocmd0	; handled by add-on
	ani	11011111b ; toupper
	sta	lstcmd
	jm	kpcmd	; from keypad... jumps back here...
cmchr:	lxi	h,cmdtab
	mvi	b,numcmd
cmloop:
	cmp	m
	inx	h
	jz	docmd
	inx	h
	inx	h
	dcr b ! jnz	cmloop
	jmp	nocmd

cmdtab:
	; console commands
	db	'G' ! dw cmdgo	; Go
	db	'P' ! dw cmdpc	; Set PC
	db	'B' ! dw cmdboot; Boot
	db	'V' ! dw prtver	; Version of ROM
	db	'L' ! dw cmdlb	; List boot modules
	db	'H' ! dw cmdhb	; long list (Help) boot modules
	db	'X' ! dw cmdx	; extended command set X_
; TODO: vflash.sys does 'U', 'A' may require more complexity.
;	db	'A' ! dw cmdab	; Add boot module
;	db	'U' ! dw cmdur	; Update entire ROM
	db	'Z' ! dw cmdsst	; Go Single-Step
	; front-panel commands    key(old)  command/action
	db	80h ! dw kpubt	; [0]     - Universal Boot
	db	81h ! dw kppbt	; [1]     - Pri Boot
	db	82h ! dw kpsbt	; [2]     - Sec Boot
	db	83h ! dw kprdx	; [3]     - Radix Mode
	db	84h ! dw kpgo	; [4]     - Go
	db	85h ! dw kpin	; [5]     - Input
	db	86h ! dw kpout	; [6]     - Output
	db	87h ! dw kpsst	; [7]     - Single Step
	db	88h ! dw kptap	; [8]     - Cass Load
	db	89h ! dw kptap	; [9]     - Cass Store
	db	8ah ! dw kpnxt	; [A] [+] - Next
	db	8bh ! dw kpprv	; [B] [-] - Prev
	db	8ch ! dw kpabt	; [C] [*] - CANCEL, usually
	db	8dh ! dw kprw	; [D] [/] - Display/Alter
	db	8eh ! dw kpmem	; [E] [#] - Memory Mode
	db	8fh ! dw kprgm	; [F] [.] - Register Mode
numcmd	equ	($-cmdtab)/3

	rept	0137h-$-21
	db	0ffh
	endm

	jmp	inhexcr
	jmp	hexbin
	jmp	hexin
	jmp	adrin
	jmp	adrnl
	jmp	hexout
	jmp	spout

if	($ <> 0137h)
	.error 'HDOS entry overrun 0137h'
endif
	jmp	0	; initialized by H47 boot module

docmd:
	ora	a
	cp	conout
	mov	c,m
	inx	h
	mov	h,m
	mov	l,c
icall:	pchl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PC command (set PC)
cmdpc:
	lxi	h,pcms
	call	msgout
	lhld	RegPtr
	lxi	d,24	; Reg[PC]
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	dcx	h
	xchg		; HL=PC, DE=adr to store
	call	inhexcr
	jc	cmdpc0	; hex digit entered
	call	adrnl	; show current PC (HL)
	call	inhexcr	; get another char
	rnc	; CR entered, don't update value
cmdpc0:
	xchg	; HL=adr to store
cmdpc1:
	mvi	d,CR
	jmp	adrin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int2$cont:
	ori	00010000b	; disable single-step
	out	0f0h
	stax	d
	ani	00100000b	; MON active?
	jnz	start		; break to monitor code
	jmp	vrst2		; else chain to (possible) user code.

take$5:
	mvi	a,5	; 5 seconds
take$A:	; set a timeout for A seconds
	lxi	h,timeout
	shld	vrst1+1
	sta	SEC$CNT
	mvi	a,mfl$HLT+mfl$CLK
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
	call	msgout	; A=0 on return
	lxi	h,nulint
	shld	vrst1+1
	mvi	a,mfl$HLT
	sta	MFlag
	in	0f2h
	ani	00000011b
	jnz	error0
	out	07fh	; clear H17 ctrl port (A=0)
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
	mvi	d,3	; Z67/MMS77320
	rz
	mvi	d,0ffh
	ret	; NZ

; determine device for port 078H
; return phy drv number in D.
gtdev2:
	mvi	d,46	; Z37
	in	0f2h
	rrc
	rrc
	jmp	gtdev0	; rest are same

; determine default boot device.
gtdfbt:
	lxi	d,0
	in	0f2h
	ani	01110000b	; default boot selection
	cpi	00100000b	; device at 07CH
	jz	gtdev1
	cpi	00110000b	; device at 078H
	jz	gtdev2
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
	ret	; let caller decide error handling (NZ)

s501er:	lxi	h,s501ms
	call	msgout
	jmp	re$entry

s501ms:	db	' SW1 wrong',TRM

delay:
	push	h
	lxi	h,ticcnt
	add	m
delay0:
	cmp	m
	jnz	delay0
	pop	h
	ret

gotnum:	; Boot N... "N" in D
	push	d	; save unit num (E)
	mov	c,d
	mvi	b,-1	; boot modules only
	lxi	h,bfnum
	call	bfind	; might have already been loaded...
	pop	d
	jc	error
	call	vfport
	jc	s501er
	; convert phy drv to phy base + unit
	mov	a,d
	lhld	bfmod	; module to HL
	mvi	l,mdbase
	mov	d,m
	sub	d
	mov	e,a	; always zero?
	jmp	goboot

cmdboot:
	lxi	h,bootms
	call	msgout	; complete (B)oot
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
	xra	a
	sta	cport
	lxi	sp,bootbf
	mvi	c,CR	; end input on CR
	jmp	boot0

	rept	0260h-$
	db	0ffh
	endm
if	($ <> 0260h)
	.error 'HDOS entry overrun 0260h'
endif
; Legacy entry for "Horn" - beep for num 2mS ticks in A
hhorn:	push	h
	call	set$horn
	lxi	h,horn
	xra	a
hhorn0:	cmp	m
	jnz	hhorn0
	pop	h
	ret
bterr:
	call	belout
boot0:
	call	conin
	cmp	c
	jz	dfboot	; default boot, by phy drv...
	mvi	e,0
	; boot by letter... Boot alpha-
	ani	05fh ; toupper
	cpi	'A'
	jc	bterr
	cpi	'Z'+1
	jnc	bterr
	cpi	'A'
	jc	bterr
	call	conout
	call	conout
	cpi	'B'
	jc	A$boot	; 'A' is synonym for default
gotit1:	push	b
	mov	c,a
	mvi	b,-1	; boot modules only
	lxi	h,bfchr
	call	bfind
	pop	b
	jc	error
	call	vfport
	jc	s501er
	lhld	bfmod
	mvi	l,mdbase	; base phy drv num
	mov	d,m
gotit:
	mvi	e,0
	mvi	a,'-'	; next is optional unit number...
	call	conout
	jmp	luboot0

; verify port is set
vfport:	push h
	lhld	bfmod
	mvi	l,mdport
	mov	a,m
	pop	h
	ora	a
	jnz	vfp0
	lda	cport	; if btinit did not set, we can't go on
	ora	a
	rnz
	stc
	ret
vfp0:	sta	cport
	xra	a
	ret

lunerr:
	call	belout
luboot0:
	call	hexin
	jnc	luboot2	; valid HEX digit...
	cmp	c
	jz	goboot
	cpi	':'
	jz	colon
	cpi	' '
	jz	space
	jmp	lunerr
luboot2:
	call	E$x16$A
	jc	lunerr
	call	conout
	jmp	luboot0
space:
	call	conout
	jmp	luboot0	; TODO: this gets dodgy if spaces between digits.

colon:	; get arbitrary string as last boot param
	call	conout	; echo ':'
	lxi	h,bootbf+1
	call	linin
	mov	a,b	; excludes TRM
	sta	bootbf	; bootbf: <len> <string...> as in CP/M cmd buf
; D=Phys Drive base number, E=Unit number
; (or, D=Phys Drive unit, E=0)
; module must have already been loaded
; NOTE: string might have been placed at bootbf...
; SP was set to 'bootbf'...
goboot:
	call	crlf
	lxi	h,error
; HL=error routine
; Move string to stack, if present.
; Stack space is 292 bytes, be certain not to overrun.
; Since len value is 127 max + TRM, should be OK.
; Can't use stack until copy is done... can't destroy DE...
gbooty:
	shld	bferr
	lxi	h,bootbf
	mov	a,m
	cpi	0c3h
	jz	gboot0
	mov	c,a	; length
	mvi	b,0
	inx	h	; first byte of string...
	dad	b	; point to end (TRM)
	inr	c	; +1 for TRM
btstr1:
	mov	a,m
	push	psw
	inx	sp	; undo half of push
	dcx	h
	dcr	c
	jnz	btstr1
gboot0:
	lhld	bferr
	push	h	; error routine on stack
; D=phy drv base, E=unit
doboot:	; common boot path for console and keypad
	call	h17init	; leaves interrupts disabled
	mov	a,e
	sta	AIO$UNI	; relative unit num
	mov	a,d
	sta	l2034h	; boot phys drv base
	lhld	bfmod
	jmp	btboot
	; btboot effectively returns here on success
	; (in most cases)
hwboot:	mvi	a,mfl$HLT
	sta	MFlag
hxboot:	lxi	h,CLOCK
	shld	vrst1+1
	jmp	bootbf

; ROM start point - initialize everything
; We know we have at least 64K RAM...
; But, right now, ROM is in 0000-7FFF so must copy
; core code and switch to RAM...
init:
	lxi	h,0ffffh
	sphl
	push	h	; save top on stack
	mvi	a,ctl$MEM1	; MEM1 = full ROM
	out	0f2h	; enable full ROM
	lda	suadr+m512k
	ora	a
	cz	savram	; H8-512K installed, save RAM
	lxi	h,0
	lxi	d,0
	lxi	b,2000h	; copy everything?
	call	ldir
	; save config data
	lxi	h,suadr
	lxi	d,susave
	lxi	b,sumax
	call	ldir
	lxi	h,re$entry
	push	h
	call	hwinit
	call	coninit
	call	meminit
	rst	1	; kick-start clock and EI
	lxi	h,signon
	call	msgout
	; save registers on stack, for debugger access...
	jmp	intsetup

inhexcr:
	call	conin
	cpi	CR
	rz
	call	hexchk
	cmc
	rc
	call	belout
	jmp	inhexcr

belout:
	mvi	a,BEL
conout:
	push	psw
conot1:
	in	0edh
	ani	00100000b
	jz	conot1
	pop	psw
	out	0e8h
	ret

	rept	03eeh-$
	db	0ffh
	endm
if	($ <> 03eeh)
	.error	'Digit table overrun 03eeh'
endif

; octal (base 8) 7-seg translation
doddig:	db	00000001b	; "0."
	db	01110011b	; "1."
	db	01001000b	; "2."
	db	01100000b	; "3."
	db	00110010b	; "4."
	db	00100100b	; "5."
	db	00000100b	; "6."
	db	01110001b	; "7."
	db	00000000b	; "8."
	db	00100000b	; "9."
	db	00010000b	; "A."
	db	00000110b	; "b."
	db	00001101b	; "C."
	db	01000010b	; "d."
	db	00001100b	; "E."
	db	00011100b	; "F."

; D=term char (e.g. '.' for Substitute)
; HL=location to store address
; CY=first digit in A
adrin:
	push	h	; adr to store value
	cnc	conin
	cmp	d	; no input?
	jz	adrin3
	lxi	h,0
	stc
adrin0:	cnc	conin
	call	hexchk
	jc	adrin1
	call	conout
	call	hexbin
	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	mov	l,a
	jmp	adrin0
adrin1:
	cmp	d
	jz	adrin2
	call	belout
	ora	a
	jmp	adrin0
adrin2:
	call	conout
	xchg
	pop	h
	mov	m,e
	inx	h
	mov	m,d
	ret

hexbin:
	sui	'9'+1
	jnc	hexbi0
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
	cpi	'A'
	rc
	ani	05fh	; toupper
	cpi	'A'
	rc
	cpi	'F'+1
	cmc
	ret

; HL = adr to print
adrnl:
	call	crlf
adrout:
	mov	a,h
	call	hexout
	mov	a,l
	call	hexout
spout:
	mvi	a,' '
	jmp	conout

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
	jmp	conout

coninit:
	mvi	c,12	; 9600 baud
	in	0f2h
	ani	10000000b	; 9600/19.2K?
	jz	ci0
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

;------------------------------------------------

; must be called with interrupts off
; A = horn delay, in 2mS ticks
; A,HL used
set$horn:
	sta	horn
	lxi	h,ctl$F0
	mvi	a,01111111b	; beep on
	ana	m
	mov	m,a
	out	0f0h
	ret

; must be called with interrupts enabled
; A = horn delay, in 2mS ticks
; A,HL used
set$horn0:
	di
	call	set$horn
	ei
	ret

; If this gets much bigger, needs to move
hwinit:
	; The RTC 72421 will be in an unknown state.
	; If STD.P has been connected to /INTx,
	; we must ensure interrupts are off.
	mvi	a,00000001b ; mask pulse/intr, reset rest
	out	rtc+14
	xra	a
	out	rtc+13	; clear pending intr, HOLD
	; TODO: any other hardware needs init?
	ret

; Special entry points expected by HDOS, or maybe Heath CP/M boot.
	rept	0613h-$
	db	0ffh
	endm
if	($ <> 0613h)
	.error 'HDOS entry overrun 0613h'
endif
	jmp	0	; initialized by H47 boot module
	db	0
	jmp	0	; initialized by H47 boot module

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go command
cmdgo:
	lxi	h,goms
	call	getpc
	; Both H89 and H8-FP maintain MON flag internally
kpgo:	; entry point for keypad GO command...
	mvi	a,11010000b	; no-beep, 2mS, !MON, !single-step
	sta	ctl$F0
cmdgo1:
	pop	h
	jmp	intret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go Single-Step command
cmdsst:
	lxi	h,sstms
	call	msgout
kpsst:	; entry point for keypad SI command
	di
	lda	ctl$F0
	xri	00010000b	; toggle single-step = enable
	out	0f0h
	sta	ctl$F0
	jmp	cmdgo1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; HL=prompt message, ends with CRLF
getpc:
	call	msgout
	lhld	RegPtr
	lxi	d,24	; Reg[PC]
	dad	d	; HL=adr to store
	call	inhexcr
	cc	cmdpc1	; read HEX until CR, store in HL
	jmp	crlf

adrin3:	pop	h
	mov	e,m
	inx	h
	mov	d,m
	ret

; ABUSS L=port, H=value
kpin:	lhld	ABUSS
	mov	a,l	; port
	sta	kpin0+1
kpin0:	in	0
	mov	h,a	; get value
	shld	ABUSS
	ret

; ABUSS L=port, H=value
kpout:	lhld	ABUSS
	mov	a,l	; port
	sta	kpout0+1
	mov	a,h
kpout0:	out	0
kpabt:	ret

kprw:	; switch between display/modify
	lda	DspMod
	xri	1
	sta	DspMod
	ret

; initialize monitor memory at 2000h
meminit:
	xra	a
	sta	l2153h
	sta	lstcmd
	sta	RegI
	sta	DsProt
	sta	DspMod
	sta	Radix
	sta	kpchar
	sta	horn
	inr	a	; 1
	sta	Refind
	mvi	a,ctl$ORG0	; ORG0 on, 2mS off...
	sta	ctl$F2	; 2mS off, ORG0 on
	out	0f2h	; enable RAM now...
	mvi	a,0c9h	; RET
	sta	PrsRAM
	lxi	h,(50h SHL 8)+(mfl$HLT) ; 50h = (beep, 2mS, !MON, !SI)
	shld	MFlag	; MFlag, CtlFlg
	lxi	h,0ffffh	; top of memory
	shld	ABUSS
	mvi	a,debounce
	sta	kpcnt
	ret

prompt:	db	CR,LF,'H8'
	db	': ',TRM
bootms:	db	'oot ',TRM
goms:	db	'o ',TRM
sstms:	db	'-Step',TRM
pcms:	db	'rog Counter ',TRM

; command not built-in, check modules.
; should only be called for console commands.
; A=cmd key/chr (also in 'lstcmd')
nocmd0:
	sta	lstcmd
nocmd:
	mov	c,a
	mvi	b,0	; no boot modules
	lxi	h,bfchr
	call	bfind
	jc	cmerr
	lda	lstcmd
	call	conout
	jmp	cmexec

cmerr:	call	belout
	jmp	prloop

; get "alternate" (secondary) boot device...
galtbt:
	lxi	d,0
	in	0f2h
	ani	01110000b	; default boot selection
	cpi	00100000b	; if default at 07CH,
	jz	gtdev2		; get 078H device...
; if device was not 07CH, then use 07CH... ???
;;	cpi	00110000b	; if device at 078H
;;	jz	gtdev1		; get 07CH device...
	jmp	gtdev1		; get 07CH device...

kpubt:
	lda	MFlag
	ori	mfl$DDU	; disable disp updates
	sta	MFlag
	call	clrdisp	; clean slate
	lxi	b,dDev
	lxi	d,Aleds
	call	mov3dsp
	call	keyin	; get device
	ani	01111111b
	cpi	0ch	; cancel
	jz	kperr
	sta	BDF
	mov	c,a
	mvi	b,-1	; boot modules only
	lxi	h,bfkey
	call	bfind
	jc	deverr
	lda	bfmod+1	; page adr of mod
	mov	b,a
	mvi	c,mddisp
	lxi	d,Aleds
	call	mov3dsp
	push	d	; save LEDs pointer
	; determine if fixed port...
	lhld	bfmod
	mvi	l,mdport
	mov	a,m
	ora	a
	jnz	gotprt
	lxi	b,dPor
	call	mov3dsp
	call	keyin	; get port
	ani	01111111b
	cpi	04h	; 0..3 allowed
	jnc	deverr
	mov	e,a
	mvi	d,0
	lxi	h,ports
	dad	d
	mov	a,m
gotprt:	pop	h	; LEDs pointer
	sta	cport
	call	dod	; decode number to HL
	mov	d,h
	mov	e,l
	lxi	b,dUni
	call	mov3dsp
	call	keyin	; get unit
	ani	01111111b
	mov	e,a
	lhld	bfmod
	mvi	l,mdbase
	mov	d,m
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
	lxi	sp,bootbf
	call	doboot	; only returns if error...
kperr:
deverr:
	ei	; TODO: more required before this?
	lxi	h,MFlag
	mov	a,m
	ani	not mfl$CLK	; disable "private" clock intr
	ori	mfl$DDU		; disable disp updates
	mov	m,a
	lxi	b,dErr
	lxi	d,Aleds
	mvi	l,6
	call	movLdsp
	mvi	c,10000000b	; beep on/off bit
	lxi	h,ticcnt
	lxi	d,ctl$F0
bterr0:
	ldax	d
	xra	c	; beep on
	stax	d
	mov	a,m
	adi	25	; 50mS
bterr2:
	cmp	m
	jnz	bterr2
	ldax	d
	xra	c	; beep off
	stax	d
	mov	a,m
	adi	-1
bterr1:	cmp	m
	jz	bterr0
	lda	kpchar
	cpi	01101111b	; raw pattern for '*' or CANCEL
	jnz	bterr1
	xra	a
	sta	kpchar
	lxi	h,MFlag
	mov	a,m
	ani	not (mfl$NRF+mfl$DDU)	; MFlag normal mode...
	mov	m,a
	; should return to 'start' but avoid extra prompts...
	jmp	re$entry

; port options for keys 0-3
ports:	db	078h,07ch,0b8h,0bch

kppbt:	; primary boot (default boot)
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
	lxi	b,dPri
	call	btdsp
	call	gtdfbt
	mov	a,d
	cpi	0ffh
	jz	kperr
	cpi	0feh
	jz	kppbt0
kpbt0:
	xra	a
	sta	cport
	push	d	; phy drv, unit
	mov	c,d
	mvi	b,-1	; boot modules only
	lxi	h,bfnum
	call	bfind	; might have already been loaded...
	jc	kperr
	call	vfport
	jc	kperr	; TODO: specific error? SW1 Error?
	call	btdsp2	; show device name
	pop	d	; phy drv, unit
	lxi	sp,bootbf
	lxi	h,kperr
	push	h
	jmp	doboot

kpsbt:	; secondary boot
	mvi	a,0c3h
	sta	bootbf	; mark "no string"
	lxi	b,dSec
	call	btdsp
	lxi	h,susave+dsdev
	call	dfboot0
	jc	kperr
	ora	a
	jz	kpbt1
	call	galtbt
	jmp	kpbt0

kppbt0:	lxi	h,susave+dpdev
	call	dfboot0
	jc	kperr
	ora	a
	jnz	kperr
kpbt1:
	call	btdsp2	; show device name
	lxi	h,kperr
	lxi	sp,bootbf
	jmp	gbooty

btdsp:
	lda	MFlag
	ori	mfl$DDU	; disable disp updates
	sta	MFlag
	push	d
	push	b
	call	clrdisp
	pop	b	; display string
	lxi	d,Aleds
	call	mov3dsp
	pop	d
	ret
; show device name in FP display
btdsp2:
	push	d	; device/unit
	lda	bfmod+1	; page adr of mod
	mov	b,a
	mvi	c,mddisp	; FP display name
	lxi	d,Dleds
	call	mov3dsp
	; TODO: fix this - is there a better way?
	mvi	a,250	;; make it briefly visible
	call	delay	;;
	pop	d	; device/unit
	ret

kptap:	; cassette load (read) or store (write, save)
	mvi	b,0	; command only
	mvi	c,88h	; cassette module key
	lxi	h,bfkey
	call	bfind
	jc	kperr
	call	cmexec
	ret

kprdx:	; choose radix for display
	lda	MFlag
	ori	mfl$DDU	; disable disp updates
	sta	MFlag
	call	clrdisp
	lxi	b,dRad
	lxi	d,Aleds
	call	mov3dsp
	lda	Radix
	ora	a
	cma		; 00->ff
	jz	rdx0
	xra	a	; else 00
rdx0:	sta	Radix		; 00       ff
	ani	00010011b	; 00->00,  ff->13
	xri	10000001b	; 00->81,  ff->92
	sta	Aleds+5		; 00->'O', ff->'H'
	; wait 1S to allow user to see...
	mvi	a,250		; 500mS
	call	delay
	mvi	a,250		; 500mS
	call	delay
	lda	MFlag
	ani	not mfl$DDU	; enable disp updates
	sta	MFlag
	; TODO: beep?
	ret

kpnxt:	; next register/memory addr
	lda	DspMod
	ani	00000010b	; Z if memory mode
	lhld	ABUSS
	lxi	d,RegI
	inx	h
	jz	sae
	ldax	d
	adi	2
	stax	d
	cpi	nReg
	rc
	xra	a
	stax	d
	ret

kpprv:	; previous register/memory addr
	lda	DspMod
	ani	00000010b	; Z if memory mode
	lhld	ABUSS
	lxi	d,RegI
	dcx	h
	jz	sae
	ldax	d
	sui	2
	stax	d
	rnc
	mvi	a,nReg-2
	stax	d
	ret

sae:	shld	ABUSS
	ret

kpmem:	; switch to memory mode - enter address
	xra	a	; also NC
	sta	DspMod	; display memory...
	sta	DsProt	; periods all on...
	lxi	h,ABUSS+1	; little-endian, enter hi byte first
	call	iob
	dcx	h	; HL=low byte of address
	mvi	b,0
	ora	a	; CY=0
	call	iob
	ret		; back to start... TODO: prevent re-prompt

kprgm:	; switch to register mode
	mvi	a,2
	sta	DspMod	; display registers...
	xra	a
	sta	DsProt	; periods all on...
	call	keyin
	ani	01111111b
	cpi	(nReg-1)/2	; PC requires spcl
	jc	reg0
	sub	3		; gap in codes?
	cpi	12		; was 15...
	jnz	kperr	; TODO: proper handling
reg0:	rlc	; times 2
	sta	RegI
	ret		; back to start... TODO: prevent re-prompt

kpcmd:	; A=keypad command, +80h
	; keypad pressed...
	cpi	8ah	; non-digit (hex req first be '0')
	jnc	cmchr
	mov	b,a
	lda	DspMod
	rrc	; CY=alter mode
	jc	kpalter	; alter mode - numeric values only
	mov	a,b
	jmp	cmchr
; A=DspMod >> 1, B=key
kpalter:
	lhld	ABUSS
	rrc	; register (else memory)
	jc	kpreg
	stc
	call	iob
	inx	h
	shld	ABUSS
	ret

; B=key
kpreg:
	lda	RegI
	ora	a
	jz	kperr	; RegI == 0 (SP) not allowed
	mov	e,a
	mvi	d,0
	lhld	RegPtr
	dad	d
	inx	h	; HL=high byte of address
	stc
	call	iob
	dcx	h	; HL=low byte of address
	call	iob
	ret

; Input Octal(or Hex) byte
; B=key, CY=first digit
iob:	rar		; save CY => C bit 7
	mov	c,a	;
	lda	Radix
	ora	a
	mov	a,b
	jz	ioboct
; iobhex - to avoid conflict with cmd keys A-F, first input must be [0]
; So, hex input requires 3 or 5 + 1 keys.
	mov	a,c	;
	ral		; restore CY
	mov	a,b
	cnc	keyin
	ani	01111111b
	jnz	kperr
	mvi	d,2
iobh0:	call	keyin
	ani	01111111b
	mov	e,a
	mov	a,m
	rlc
	rlc
	rlc
	rlc
	ani	11110000b
	ora	e	; also ensure NC for loop
	mov	m,a
	dcr	d
	jnz	iobh0
	jmp	iob0
ioboct:
	mov	a,c	;
	ral		; restore CY
	mov	a,b
	mvi	d,3
iobo0:	cnc	keyin
	ani	01111111b
	cpi	8
	jnc	kperr
	mov	e,a
	mov	a,m
	rlc
	rlc
	rlc
	ani	11111000b
	ora	e	; also ensure NC for loop
	mov	m,a
	dcr	d
	jnz	iobo0
iob0:
	; TODO: blip to ack entry?
	ret

; returns with interrupts disabled
; preserves DE
h17init:
	di
	in	0f2h
	ani	00000011b	; port 7C - only one for H17
	jnz	h17in0
	xra	a
	out	07fh	; avoid this if H17 not configured
h17in0:	push	d
	lxi	h,ctl$F0
	mvi	m,11010000b	; !beep, 2mS, !mon, !SI
	lxi	h,R$CONST
	lxi	d,D$CONST
	lxi	b,88
	call	ldir
	mov	l,e
	mov	h,d
	inx	d
	mvi	c,30
	mov	m,a
	call	ldir	; fill l20a0h...
	mvi	a,7
	lxi	h,intvec	; vector area
h17ini0:
	mvi	m,0c3h
	inx	h
	mvi	m,LOW (nulint-rst0)
	inx	h
	mvi	m,HIGH (nulint-rst0)
	inx	h
	dcr	a
	jnz	h17ini0
	pop	d
	ret

waitcr:
	call	conin
	cpi	CR
	jnz	waitcr
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
	jmp	msgout

; called in the context of a command on console
conin:	in	0edh
	rrc
	jc	conin0
	; flush out VDIP1 while we wait...
	in	0dah	; VDIP1/FT245R status
	ani	00001000b	; VDIP1 RxR
	jz	novdip2
	in	0d9h	; flush char
novdip2:
	lda	kpchar
	ora	a
	jz	conin
	; cancel console cmd, leave keypad char for cmdin
	jmp	start

conin0:	in	0e8h
	ani	07fh
	cpi	DEL	; DEL key restarts from anywhere?
	jz	re$entry
	ret

; Pure console input, no tricks
conin1:	in	0edh
	rrc
	jnc	conin1
	in	0e8h
	ani	07fh
	ret

; called in the context of command on front-panel
keyin:	lda	kpchar
	ora	a
	jnz	getkey
	in	0edh
	rrc
	jnc	keyin
	; cancel kaypad cmd, leave console char for cmdin
	; TODO: what modes need reset?
	jmp	start

; wait for command - console or keypad
cmdin:
	in	0edh
	rrc
	jc	conin0
	; flush out VDIP1 while we wait...
	in	0dah	; VDIP1/FT245R status
	ani	00001000b	; VDIP1 RxR
	; INS8250 IIR always 0
	; 16550 IIR is RxD timeout (?)
	; 16C2550 ISR is RxD timeout (?)
	jz	novdip1
	in	0d9h	; flush char
novdip1:
	lda	kpchar
	ora	a
	jz	cmdin
getkey:	push	psw	; A=scan code
	xra	a
	sta	kpchar
	pop	psw
	xri	11111110b
	rrc
	jnc	gotkey
	rrc
	rrc
	rrc
	rrc
gotkey:	ani	00001111b
	ori	10000000b	; distinguish from console input
	; TODO: check for CANCEL key?
	ret

; keypad check at 32mS
kpchk:	lxi	h,RckA
	in	0f0h
	cmp	m	; RckA
	jnz	kpchk0
	ani	00010001b
	cpi	00010001b
	rz	; nothing pressed
	mov	a,m
	; need to count auto-repeat/debounce
	inx	h	; kpcnt
	dcr	m
	rnz
	; got a key press...
	sta	kpchar
	mvi	m,rptcnt
	mvi	a,4/2	; 4mS click
	call	set$horn
	ret
kpchk0:	mov	m,a	; RckA
	inx	h	; kpcnt
	mvi	m,debounce
	ret

; Update Front-panel Display
; B=MFlag, destroyed
ufd:	mvi	a,mfl$DDU
	ana	b
	rnz		; updates disabled
	lxi	h,DsProt
	mov	a,m
	rlc
	mov	m,a
	mov	b,a
	inx	h	; DspMod
	mov	a,m
	ani	00000010b
	lhld	ABUSS
	jz	ufd1	; displaying memory
	; displaying registers
	call	lra	; locate register address offset (DE)
	push	h
	lxi	h,LedRegTbl
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	xthl
	ora	h
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
ufd1:	push	psw
	xchg
	lxi	h,Aleds
	mov	a,d
	call	dod
	mov	a,e
	call	dod
	pop	psw
	ldax	d
	jz	dod	; if displaying memory
	; displaying register name
	pop	b
	lxi	d,Dleds
mv3byt:	mvi	l,3
mvb:	ldax	b
	stax	d
	inx	b
	inx	d
	dcr	l
	jnz	mvb
	ret

; B=dot flag
dod:	mov	c,a	; value to display
	lda	Radix
	ora	a	; Z if octal (also CY=0)
	mov	a,c
	jnz	dodhex
	push	d
	mvi	c,3
dodr5:	ral
	ral
	ral
	push	psw
	ani	07h
	adi	LOW doddig
	mov	e,a
	mvi	a,HIGH doddig
	aci	0
	mov	d,a
	ldax	d
	xra	b	; DP on/off
	and	01111111b	; why???
	xra	b
	mov	m,a
	inx	h
	mov	a,b	; rlcr b
	rlc
	mov	b,a
	pop	psw
	dcr	c
	jnz	dodr5
	pop	d
	ret

dodhex:	push	d
	mvi	c,2
deh55:	rlc
	rlc
	rlc
	rlc
	push	psw
	ani	0fh
	adi	LOW doddig
	mov	e,a
	mvi	a,HIGH doddig
	aci	0
	mov	d,a
	ldax	d
	xra	b		; DP on/off
	ani	01111111b	; why???
	xra	b		; ???
	mov	m,a
	inx	h
	mov	a,b	; rlcr b
	rlc
	mov	b,a
	pop	psw
	dcr	c
	jnz	deh55
	pop	d
	mvi	a,01101111b	; "_"
	xra	b		; DP on/off
	ani	01111111b	; why???
	xra	b		; ???
	mov	m,a
	inx	h
	mov	a,b	; rlcr b
	rlc
	mov	b,a
	ret

dSP:	db	11111111b,10100100b,10011000b	; " SP"
dPSW:	db	11111111b,10010000b,10011100b	; " AF"
dBC:	db	11111111b,10000110b,10001101b	; " BC"
dDE:	db	11111111b,11000010b,10001100b	; " DE"
dHL:	db	11111111b,10010010b,10001111b	; " HL"
dPC:	db	11111111b,10011000b,11001110b	; " PC"

dDev:	db	11000010b,10001100b,10000011b	; "dEU" (dev)
dPor:	db	10011000b,11000110b,11011110b	; "Por"
dUni:	db	10000011b,11010110b,11110111b	; "Uni"
dErr:	db	10001100b,11011110b,11011110b	; "Error "
	db	11000110b,11011110b,11111111b
dRad:	db	11011110b,10010000b,11000010b	; "rAd"
dPri:	db	10011000b,11011110b,11011111b	; "Pri"
dSec:	db	10100100b,10001100b,10001101b	; "SEC"

LedRegTbl:
	dw	dSP	; 0
	dw	dPSW	; 1
	dw	dBC	; 2
	dw	dDE	; 3
	dw	dHL	; 4
	dw	dPC	; 5
nReg	equ	$-LedRegTbl	; 2x num registers...

lra:	lda	RegI
lrax:	mov	e,a
	mvi	d,0
	lhld	RegPtr
	dad	d
	ret

mov3dsp:
	mvi	l,3
movLdsp:
md0:	ldax	b
	stax	d
	inx	b
	inx	d
	dcr	l
	jnz	md0
	ret

clrdisp:
	lxi	h,fpLeds
	mov	e,l
	mov	d,h
	lxi	b,9-1
	mvi	m,11111111b
	inx	d
	call	ldir
	ret

; Front panel display refresh and keypad check
int1$fp:
	; if /INT1 caused by keypad (RTM), skip the rest (?)
	; Should probably loop here until key released?
	; De-bounce?
	in	0f0h
	cpi	2eh		; RTM: [0]+[#] a.k.a. [0]+[E]
	jz	re$entry	; Return To Monitor...
	;
	mvi	c,0
	lxi	h,horn
	mov	a,m
	ora	a
	jz	fp1
	dcr	m
	jnz	fp1
	mvi	c,10000000b	; beep off
fp1:
	lxi	h,MFlag
	mov	b,m
	inx	h	; ctl$F0
	mov	a,m
	ora	c	; beep off bit
	mov	m,a
	mov	a,b
	ani	01000000b	; refresh display?
	mov	a,m
	jnz	fp3
	inx	h	; Refind
	dcr	m
	jnz	fp2
	mvi	m,9
fp2:	mov	e,m	; 1-9
	mvi	d,0
	dad	d	; HL = &fpLeds[E-1]
	ora	e	; merge digit select
fp3:
	out	0f0h
	mov	a,m	; FP segments (fpLeds[E-1])
	out	0f1h
	; See if time to update display values or check keypad
	mvi	l,LOW ticcnt
	mov	a,m
	push	psw
	ani	31	; 64mS
	cz	ufd	; B=MFlag, destroyed
	pop	psw
	ani	15	; 32mS
	cz	kpchk

int1$xx:
	; not really FP related, but no space in low ROM...
	lda	ctl$F0
	ani	00100000b	; MON mode?
	jnz	intret	; skip if running monitor...
	lda	MFlag
	ani	10000000b	; HLT processing enabled
	cz	chkhlt
	rrc		; mfl$CLK private int1?
	cc	vrst1
	jmp	intret

; NOTE: HLT processing is inherently unreliable.
; It presumes that the current instruction was single-byte,
; however it will mis-fire on things like JMP 76xxH
; (any instr with a last byte of 76H)
chkhlt:
	push	psw
	lhld	RegPtr
	lxi	d,24	; Reg[PC]
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	dcx	d	; current instr, not next
	ldax	d
	cpi	76h	; HLT
	jz	re$entry
	pop	psw
	ret

; match module by character (letter)
; C=letter, B=00:cmd,ff:boot
bfchr:
	mvi	e,mdbase	; phy drv or type
	ldax	d		; phy drv or type
	sui	200	; boot modules < 200
	sbb	a	; ff=boot, 00=cmd
	cmp	b	; ZR=match
	jnz	bfn0
	mvi	e,mdchr
	ldax	d	; mdchr
	cmp	c
	ret

; match module by FP key
; C=FP key, B=00:cmd,ff:boot
bfkey:
	mvi	e,mdbase	; phy drv or type
	ldax	d		; phy drv or type
	sui	200	; boot modules < 200
	sbb	a	; ff=boot, 00=cmd
	cmp	b	; ZR=match
	jnz	bfn0
	mvi	e,mdkey
	ldax	d	; mdkey
	cmp	c
	ret

; match boot module by phy drv number
; C=phy drv (base), B=type
; DE=module
; Only for boot modules
bfnum:	mvi	e,mdbase	; phy drv or type
	ldax	d		; phy drv or type
	cpi	200	; boot modules < 200
	jnc	bfn0	; skip if >= 200
	sub	c
	rz	; A is zero - match
bfn0:	xra	a
	inr	a
	ret

; List only boot modules
; On first module, C=0
bflst:
	mvi	e,mdbase	; phy drv or type
	ldax	d		; phy drv or type
	cpi	200	; boot modules < 200
	jnc	bfn0
	mov	a,c
	ora	a
	mvi	a,','
	cnz	conout
	inr	c
	ldax	d	; mdbase - phy drv or type
	sub	b
	mvi	a,'*'
	cz	conout
	mov	h,d
	mvi	l,mdname
	call	msgout
	lxi	h,bflst
	jmp	bfn0	; NZ - keep going

; List only boot modules
bfllst:
	mvi	e,mdbase	; phy drv or type
	ldax	d		; phy drv or type
	cpi	200	; boot modules < 200
	jnc	bfn0
	sub	b
	mvi	a,' '
	jnz	bfll2
	mvi	a,'*'
bfll2:	call	conout
	mov	h,d
	mvi	l,mdname
	call	msgout
	mvi	a,TAB
	call	conout
	mvi	e,mdchr
	ldax	d
	call	conout
	mvi	a,' '
	call	conout
	mvi	e,mdkey
	ldax	d
	adi	'0'
	jnc	bfll0
	mvi	a,'-'
bfll0:	call	conout
	mvi	a,' '
	call	conout
	mvi	e,mdbase
	ldax	d
	call	decout
	call	crlf
	lxi	h,bfllst
	xra	a	; NZ - keep going
	inr	a	;
	ret

; Find boot module and load into 1000h if necessary.
; Entry: BC=target, HL=match function
; match function: returns Z if found (BC=target, DE=module)
; Return CY at end of modules (not found)
; Else return 'bfmod'=loaded module (run location)
; Must preserve BC during search loop.
; Uses memory near E000H (stack below; storage above)
; Modules MUST be on page boundaries.
bfstk	equ	0e000h
bfssp	equ	bfstk	; saved SP of caller
bffnc	equ	bfssp+2	; saved match func
bfmod	equ	bffnc+2	; current module being checked
bferr	equ	bfmod+2	; error message for booting
bfind:
	; can't check if it's loaded until we know where it's loaded...
	; first, check if already loaded
	;lxix	btovl
	;call	icall
	;rz
bfind0:
	; must map ROM back in, so prevent interruptions...
	; also, we loose memory at SP...
	di
	shld	bffnc
	lxi	h,0
	dad	sp
	shld	bfssp
	lxi	sp,bfstk	; a safe SP?
	lda	ctl$F2
	push	psw
	ani	not ctl$ORG0	; ORG0 off
	ori	ctl$MEM1	; MEM1 on
	out	0f2h	; low 32K RAM disappears...
	lxi	h,btmods	; start of modules...
	shld	bfmod
bf0:	; HL=curr mod
	xchg		; DE=module
	lhld	bffnc
	call	icall
	lhld	bfmod
	jz	bf9
	;mvi	l,mdpgs	; 'mdpgs' must be zero
	mov	d,m	; mod.mdpgs
	mvi	e,0
	dad	d
	shld	bfmod
	mov	a,h
	cpi	HIGH bterom	; end of ROM
	jnc	bf1
	mov	a,m	; mod.mdpgs is +0
	ora	a
	jz	bf1
	cpi	0ffh
	jnz	bf0	; keep searching, HL=next mod
bf1:	; error exit - not found.
	pop	psw
	out	0f2h
	lhld	bfssp
	sphl
	ei
	stc	; CY = end of list (not found)
	ret

bf9:	; match found, now load into place and init
	; HL=curr mod
	mov	b,m	; mdpgs, must be +0
	inx	h	; mdorg, must be +1
	mov	d,m
	dcx	h	; restore module+0
	mvi	e,0
	mvi	c,0
	push	d
	; TODO: avoid redundant load... and init?
	call	ldir	; copy module into place, DE
	pop	h	; module load addr
	shld	bfmod	;
	; now call init routine... but must restore RAM...
	pop	psw
	out	0f2h
	lhld	bfssp
	sphl
	ei
	call	btinit	; CY indicates error, pass along...
	ret

; DE=module in real memory
btinit:	lhld	bfmod
	mvi	l,mdinit
	pchl

cmexec:
btboot:
	lhld	bfmod
	mvi	l,mdboot
	pchl

; assume < 100
decout:
	mvi	d,'0'
decot0:
	sui	10
	jc	decot1
	inr	d
	jmp	decot0
decot1:
	adi	10
	adi	'0'
	push	psw
	mov	a,d
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
	mov	d,m	; might be FF or FE
	ret

A$boot:
	call	gtdfbt	; DE=phy drv/unit
	mov	a,d
	cpi	0ffh
	jz	s501er
	cpi	0feh
	jnz	findit
	lxi	h,susave+dpdev
	mov	a,m
	inx	h
	cpi	0ffh
	jz	s501er	; not setup
	jmp	gotit1
findit:
	push	d
	push	b
	mov	c,d
	mvi	b,-1	; boot modules only
	lxi	h,bfnum
	call	bfind
	pop	b
	pop	d
	jc	s501er
	call	vfport
	jc	s501er
	jmp	gotit

; default boot selected from console
dfboot:
	call	gtdfbt	; DE=phy drv/unit
	mov	a,d
	cpi	0ffh
	jz	error
	cpi	0feh
	jnz	gotnum
	lxi	h,susave+dpdev
	call	dfboot0
	jc	error
	ora	a
	jnz	error
	jmp	goboot

dfboot0:	; HL=setup data for pri or sec
	mov	a,m
	inx	h
	cpi	0ffh
	rz		; A <> 0: not setup
	push	h
	mov	c,a
	mvi	b,-1	; boot modules only
	lxi	h,bfchr
	call	bfind
	pop	h
	rc		; CY: no module - error
	call	vfport
	rc		; CY: SW501 error
	push	h
	lhld	bfmod
	mvi	l,mdbase
	mov	d,m
	mvi	l,mdluns
	mov	e,m	; DE = mdbase:mdluns
	pop	h
	mov	a,m
	inx	h
	cpi	0ffh
	jnz	dfbt0
	xra	a
dfbt0:	cmp	e	; mdluns
	cmc
	rc
	mov	e,a	; DE=phy drv base,unit
	mov	a,m
	cpi	0ffh	; no string?
	jz	dfbt2
	push	d
	lxi	d,bootbf+1	; len in +0...
	mvi	c,0
dfbt1:	mov	a,m
	stax	d
	inx	h
	inx	d
	inr	c
	ora	a
	jnz	dfbt1
	mov	a,c
	dcr	a
	sta	bootbf
	pop	d
dfbt2:	xra	a	; A=0: ready to boot
	ret

defbt:	; default boot table... port F2 bits 01110000b
	db	33	; -000---- MMS 5" floppy 0
	db	29	; -001---- MMS 8" floppy 0
	db	0ffh	; -010---- n/a  (port 7CH)
	db	0ffh	; -011---- n/a  (port 78H)
	db	41	; -100---- VDIP1
	db	70	; -101---- GIDE disk part 0
	db	60	; -110---- Network
	db	0feh	; -111---- use setup primary

savram:	; interrupts are disabled
	; init H8-512K mmu.
	; WARNING: The H8-512K MAP FF has a R-C delay on its CLR
	; pin, triggered by RESET. This means the MAP enable bit is held
	; off for a period of time after RESET is released. Currently,
	; components are expected to cause a 5mS delay. This places
	; an upper limit of 10mS on the CLR release, with lots of margin
	; for component variation. That equates to 853 iterations of this
	; delay loop at 2.048MHz.
	; This also requires a change to older H8-512K boards to reduce
	; the delay time, which was previously 220mS.
	lxi	b,853
savram0:		; total: 24 cy
	dcx	b	;  6 cy
	mov	a,b	;  4 cy
	ora	c	;  4 cy
	jnz	savram0	; 10 cy
	; H8-512K MMU (MAP) should be usable now.
	mvi	a,0	; page 0
	out	rd00k
	out	wr00k
	inr	a
	out	rd16k
	out	wr16k
	inr	a
	out	rd32k
	out	wr32k
	inr	a
	ori	ena
	out	rd48k
	out	wr48k
	; setup pages (RD)8000->00000, (WR)8000->30000
	mvi	a,00h+ena
	out	rd32k
	mvi	a,0ch+ena
	out	wr32k
	lxi	h,08000h
	lxi	d,08000h
	lxi	b,16*1024
	call	ldir
	; de-init mmu
	mvi	a,0
	out	rd00k	; turn off MAP bit, back to normal
	ret

ldir:	mov	a,m
	stax	d
	inx	h
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	ldir
	ret

linix:	mvi	m,0	; terminate buffer
	ret

; input a line from console, allow backspace
; HL=buffer (size 128)
; returns B=num chars, 128 max (never is 0c3h)
linin:
	mvi	b,0	; count chars
lini0	call	conin	; handles DEL (cancel)
	cpi	CR
	jz	linix
	cpi	BS
	jz	backup
	cpi	' '
	jc	chrnak
	cpi	'~'+1
	jnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	b
	jm	chrovf	; 128 chars max
	call	conout
	jmp	lini0
chrovf:	dcx	h
	dcr	b
chrnak:	mvi	a,BEL
	call	conout
	jmp	lini0
backup:
	mov	a,b
	ora	a
	jz	lini0
	dcr	b
	dcx	h
	mvi	a,BS
	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jmp	lini0

; Used during entry of LUN in boot command.
; multiply E by 16, check for >= (bfmod.mdluns) (or overflow)
; add in A (converted to binary).
; IX=active boot module
; Returns CY on overflow, else E updated to new LUN value
E$x16$A:
	push	psw
	sui	'0'
	cpi	9+1
	jc	ex16a0
	sui	'A'-'0'-10
ex16a0:
	mov	b,a
	mov	a,e
	add	a
	jc	ex16a2
	add	a
	jc	ex16a2
	add	a
	jc	ex16a2
	add	a
	jc	ex16a2
	add	b	; never CY
	push	h
	lhld	bfmod
	mvi	l,mdluns
	cmp	m	; might be 0ffh
	pop	h
	jc	ex16a1
ex16a2:	pop	psw
	stc
	ret	; overflow
ex16a1:	mov	e,a
	pop	psw
	ora	a	; NC
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; List available boot modules
cmdlb:	lxi	h,lbmsg
	call	msgout
	call	gtdfbt
	mov	b,d
	lxi	h,bflst
	mvi	c,0
	call	bfind0
	ret

lbmsg:	db	'ist boot modules',CR,LF,0
hbmsg:	db	'elp boot',CR,LF,0
hbmsg2:	db	'Pri: ',0
hbmsg3:	db	'Sec: ',0

; Help boot command
cmdhb:	lxi	h,hbmsg
	call	msgout
	call	gtdfbt
	mov	b,d
	lxi	h,bfllst
	call	bfind0
	; Now display primary/secondary configs
	lxi	h,hbmsg2
	lxi	d,susave+dpdev
	in	0f2h
	ani	01110000b	; default boot device
	cpi	01110000b	; use setup cfg?
	mvi	a,'*'
	jz	cmdhb6
	mvi	a,' '
cmdhb6:	call	cmdhbx
	lxi	h,hbmsg3
	lxi	d,susave+dsdev
	mvi	a,' '	; never the default
	call	cmdhbx
	ret

cmdhbx:	call	conout
	call	msgout
	ldax	d
	inx	d
	cpi	0ffh
	jnz	cmdhb0
	mvi	a,'-'
cmdhb0:	call	conout
	mvi	a,' '
	call	conout
	ldax	d
	inx	d
	adi	'0'	; FF=2F,CY
	jnc	cmdhb1
	mvi	a,'-'
cmdhb1:	call	conout
	mvi	a,' '
	call	conout
	ldax	d
	cpi	0ffh
	jnz	cmdhb2
	mvi	a,'-'
	call	conout
	jmp	cmdhb3
cmdhb2:	xchg
	call	msgout
cmdhb3:	call	crlf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; eXtended command set
cmdx:
	call	conin	; get actual command character
	ori	00100000b	; lower case
	cpi	'a'
	jc	cmxerr
	cpi	'z'+1
	jnc	cmxerr
	sta	lstcmd
	; would like to re-use nocmd, but error path is wrong...
	mov	c,a
	mvi	b,0	; no boot modules
	lxi	h,bfchr
	call	bfind
	jc	cmxerr
	lda	lstcmd
	ani	01011111b	; upper case echo
	call	conout
	jmp	cmexec

cmxerr:	call	belout
	jmp	cmdx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print ROM version command
prtver:
	lxi	h,versms
	call	msgout
	lxi	h,vernum
	call	msgout
	ret

versms:	db	'ersion ',TRM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; code required to return to monitor from stand-alone programs.
retmon:
	di
	xra	a	; reset state of ctl port
	out	0f2h
	mvi	a,0dfh	; reset state of FP port 0
	out	0f0h
	jmp	0

signon:	db	CR,LF,'H8 8080A '
	db	'Monitor v'
vernum:	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
if alpha
	db	'(alpha',alpha+'0',')'
else
if beta
	db	'(beta'
if beta > 9
	db	(beta/10)+'0'
endif
	db	(beta MOD 10)+'0',')'
endif
endif
	db	CR,LF,TRM

	rept	1000h-$-2
	db	0ffh
	endm
	dw	pcode	; product code for system
if	($ <> 1000h)
	.error 'core ROM overrun'
endif

; module overlay area starts here...
; ensure this does not match any...
	dw	-1
	db	0,0

	rept	1800h-$
	db	0ffh
	endm
if	($ <> 1800h)
	.error 'overlay ROM overrun'
endif
	end
