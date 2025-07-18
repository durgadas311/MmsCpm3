; H8 Z80-CPU v3.2 Monitor (EEPROM 28C256)
VERN	equ	021h	; ROM version

false	equ	0
true	equ	not false

alpha	equ	0
beta	equ	4

z180	equ	false
h8nofp	equ	false
h89	equ	false
nofp	set	false

	maclib	ram
	maclib	setup
 if z180
pcode	set	0f180h
	maclib	z180
use$dma	equ	true
 if h8nofp
pcode	set	0f18fh
 endif
 if h89
pcode	set	0f189h
 endif
 else	; Z80 based
pcode	set	0ff80h
	maclib	z80
 if h8nofp
pcode	set	0ff8fh
 endif
 if h89
pcode	set	0ff89h
 endif
 endif	; z180 else z80

 if h8nofp or h89
nofp	set	true
 endif
	$*macro

oled	set	false
 if h89
oled	set	true
 endif

CR	equ	13
LF	equ	10
BEL	equ	7
TAB	equ	9
BS	equ	8
ESC	equ	27
TRM	equ	0
DEL	equ	127

; ctrl port F2 bit definitions
ctl$SPD		equ	00010100b	; CPU speed control bits
ctl$CLK		equ	00000010b	; enable H89 2mS clock (not used here)
ctl$MEM1	equ	00001000b	; maps full ROM (if !ORG0)
ctl$ORG0	equ	00100000b	; maps full RAM
ctl$IO1		equ	10000000b	; enables EEPROM write

; MFlag bit definitions
mfl$HLT	equ	10000000b	; disable HLT processing (TODO)
mfl$NRF	equ	01000000b	; disable refresh of display
mfl$DDU	equ	00000010b	; disable disp update (debug info)
mfl$CLK	equ	00000001b	; allow 2mS clock hook (user hook)

 if z180
; Z180 internal registers (I/O ports)
ccr	equ	1fh
itc	equ	34h
rcr	equ	36h
mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah
sar0l	equ	20h
sar0h	equ	21h
sar0b	equ	22h
dar0l	equ	23h
dar0h	equ	24h
dar0b	equ	25h
bcr0l	equ	26h
bcr0h	equ	27h
dstat	equ	30h
dmode	equ	31h
dcntl	equ	32h

; DCNTL register definitions:
MW0	equ	00$000000b
MW1	equ	01$000000b
MW2	equ	10$000000b
MW3	equ	11$000000b
IOW0	equ	00$00$0000b
IOW1	equ	00$01$0000b
IOW2	equ	00$10$0000b
IOW3	equ	00$11$0000b
; CCR register definitions:
CLK2	equ	0$0000000b	; CLK/2
CLK1	equ	1$0000000b	; CLK/1
 else
; H8-512K MMU
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
 endif

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

 if z180
; Where ROM is mapped-in for searching...
btmap	equ	4000h
btmods	equ	btmap+2000h
bterom	equ	btmap+8000h
 else
btmods	equ	2000h	; boot modules start in ROM
bterom	equ	8000h	; end/size of ROM
 endif

rptcnt	equ	16
debounce equ	1

; Start of ROM code
	org	00000h

rombeg:
rst0:
 if nofp
	jmp	init	; must be JMP so Heath CP/M thinks we're an H89
	nop
 else
	di	; can't be JMP or Heath CP/M thinks we're an H89
	jmp	init
 endif

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
	pop	psw
	pop	psw
	pop	b
	pop	d
	pop	h
	popix
	popiy
	exx
	exaf
	pop	b	; I,R - R cannot be restored
	mov	a,b
	stai
	pop	psw
	pop	b
	pop	d
	pop	h
	exx
	exaf
nulint:
	ei
	ret

 if nofp
nReg	equ	13*2	; must match number of entries in intsetup/intret...

	rept	0066h-$
	db	0ffh
	endm
 if	($ <> 0066h)
	.error	'NMI overflow'
 endif
	jmp	nmi
 endif

int1$cont:
	inx	h
	shld	ticcnt
	lda	ctl$F2
	out	0f2h
 if nofp
	jmp	int1$xx
 else
	jmp	int1$fp
 endif

intsetup:
	exx
	exaf
	xthl	; HL=PC (ret adr)
	push	d
	push	b
	push	psw
	ldar
	mov	c,a
	ldai
	mov	b,a
	push	b
	pushiy
	pushix
	push	h	; save PC
	exx
	exaf
	xthl		; HL=PC
	push	d
	push	b
	push	psw
	xchg		; DE=PC
	lxi	h,nReg-2
	dad	sp
	push	h
	push	d	; save PC
	lxi	d,ctl$F0
	ldax	d
	cma
	ani	030h
	rz
	lxi	h,2
	dad	sp
	shld	monstk	; a.k.a. RegPtr
	ret

cold$entry:		; re-entry point for RESET
 if oled
	call	auto
 endif
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
	jz	nocmd0	; handled my add-on
	ani	11011111b ; toupper
	sta	lstcmd
 if not nofp
	jm	kpcmd	; from keypad... jumps back here...
 endif
cmchr:	lxi	h,cmdtab
	mvi	b,numcmd
cmloop:
	cmp	m
	inx	h
	jrz	docmd
	inx	h
	inx	h
	djnz	cmloop
	jmp	nocmd

cmdtab:
	; console commands
	db	'D' ! dw cmddmp	; Dump memory
	db	'G' ! dw cmdgo	; Go
	db	'S' ! dw cmdsub	; Substitute in memory
	db	'P' ! dw cmdpc	; Set PC
	db	'B' ! dw cmdboot; Boot
	db	'M' ! dw cmdmt	; Memory Test
	db	'V' ! dw prtver	; Version of ROM
	db	'L' ! dw cmdlb	; List boot modules
	db	'H' ! dw cmdhb	; long list (Help) boot modules
	db	'X' ! dw cmdx	; extended command set X_
; TODO: vflash.sys does 'U', 'A' may require more complexity.
;	db	'A' ! dw cmdab	; Add boot module
;	db	'U' ! dw cmdur	; Update entire ROM
	db	'Z' ! dw cmdsst	; Go Single-Step
 if not nofp
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
 endif
numcmd	equ	($-cmdtab)/3

 if nofp
nmi:	; only get here from I/O instructions on ports F0,F1,FA,FB
	xthl
	push	h
	push	psw
	; This assumes i8080 code... reasonable for HDOS
	dcx	h	; should be I/O port number...
	mov	a,m
	cpi	0f0h	; H8 FP ctrl
	jz	nmi$f0
	cpi	0f1h	; H8 FP disp
	jrz	nmi$ign
	cpi	0fah	; H8-5 console port
	jrz	nmi$ign
	cpi	0fbh	; H8-5 console port
	jrz	nmi$ign
nmi$xit2:
	pop	psw
nmi$xit:
	pop	h
	xthl
	retn
nmi$ign:	; ignore, but IN must get 00
	dcx	h
	mov	a,m
	cpi	0d3h	; OUT
	jrz	nmi$xit2
	cpi	0dbh	; IN
	jrnz	nmi$xit2
	pop	psw
	mvi	a,0	; don't change flags...
	jr	nmi$xit
 endif

	rept	0137h-$
	db	0ffh
	endm
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
	jrc	cmdpc0	; hex digit entered
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
 if not nofp
	ori	00010000b	; disable single-step
	out	0f0h
	stax	d
 else
	lda	ctl$F2
	ani	11111110b	; disable single-step
	out	0f2h
	sta	ctl$F2
	ldax	d		;  ctl$F0
 endif
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
	jrnz	error0
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
	jrnz	delay0
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
	ldx	d,mdbase
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
	jr	boot0

 if z180
trpms:	db	CR,LF,'*** TRAP ',TRM
 if not nofp	; need the space
; C *must* contain vd$sts port from getvdpt
flsvdip:
	; flush out VDIP1 while we wait...
	inp	a	; VDIP1/FT245R status
	ani	00001000b	; VDIP1 RxR
	rz
	dcr	c
	inp	a	; flush char, VDIP1 data reg
	inr	c
	ret
 endif
 endif

	rept	0260h-$
	db	0ffh
	endm
 if	($ <> 0260h)
	.error 'HDOS entry overrun 0260h'
 endif
; Legacy entry for "Horn" - beep for num 2mS ticks in A
hhorn:	push	h
	push	psw
 if nofp
	call	belout	; make some sort of noise
	lxi	h,ticcnt ; delay is not really relevant, but...
	add	m
 else
	call	set$horn
	lxi	h,horn
	xra	a
 endif
hhorn0:	cmp	m
	jrnz	hhorn0
	pop	psw
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
	jrc	bterr
	cpi	'Z'+1
	jrnc	bterr
	cpi	'A'
	jrc	bterr
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
	ldx	d,mdbase	; base phy drv num
gotit:
	mvi	e,0
	mvi	a,'-'	; next is optional unit number...
	call	conout
	jr	luboot0

; verify port is set
; IX=boot module (in memory)
vfport:	ldx	a,mdport
	ora	a
	jrnz	vfp0
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
	jrnc	luboot2	; valid HEX digit...
	cmp	c
	jrz	goboot
	cpi	':'
	jrz	colon
	cpi	' '
	jrz	space
	jr	lunerr
luboot2:
	call	E$x16$A
	jrc	lunerr
	call	conout
	jr	luboot0
space:
	call	conout
	jr	luboot0	; TODO: this gets dodgy if spaces between digits.

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
	lxiy	error
	call	crlf
; IY=error routine
; Move string to stack, if present.
; Stack space is 292 bytes, be certain not to overrun.
; Since len value is 127 max + TRM, should be OK.
; Can't use stack until copy is done... can't destroy DE...
gbooty:
	lxi	h,bootbf
	mov	a,m
	cpi	0c3h
	jrz	gboot0
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
	jrnz	btstr1
gboot0:
	pushiy	; error routine
; IX=boot module (in memory)
; D=phy drv base, E=unit
doboot:	; common boot path for console and keypad
	call	h17init	; leaves interrupts disabled
	mov	a,e
	sta	AIO$UNI	; relative unit num
	mov	a,d
	sta	l2034h	; boot phys drv base
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
 if z180
; Might arrive here from a TRAP...
	in0	a,itc
	bit	7,a
	jnz	trap
init0:	lxi	h,0ffffh
	sphl
	push	h	; save top on stack
	mvi	a,CLK1
	out0	a,ccr	; use full clock speed
	xra	a
	out0	a,rcr	; turn off refresh
	; configure WAIT states later...
	call	savram
	; map in 8K of ROM from 0xf8000 into 0x4000
	mvi	a,1100$0100b	; ca at 0xc000, ba at 0x4000
	out0	a,mmu$cbar
	; both CBR and BBR are "0" - if got here via RESET
 if use$dma
	; DMA F8000-FA000 into 00000-02000
	call	dmarom
 else
	mvi	a,0f8h-04h	; page offset by start
	out0	a,mmu$bbr
	lxi	h,04000h
	lxi	d,0
	lxi	b,2000h	; copy everything?
	ldir
	; restore default map...
	xra	a	; 00 - reset map to 0000
	out0	a,mmu$bbr
 endif
 else
	lxi	h,0ffffh
	sphl
	push	h	; save top on stack
 if h89	; must be NC-89
	mvi	a,00100100b	; WE off, SCL high
	out	080h		; safe for DS1302 and I2C
 endif
	mvi	a,ctl$MEM1	; MEM1 = full ROM
	out	0f2h	; enable full ROM
 if h89	; NC-89
	call	savram	; H89-512K built-in, save RAM
 else
	lda	suadr+m512k
	ora	a
	cz	savram	; H8-512K installed, save RAM
 endif
	lxi	h,0
	lxi	d,0
	lxi	b,2000h	; copy everything?
	ldir
 endif
	; save config data
	lxi	h,suadr
	lxi	d,susave
	lxi	b,sumax
	ldir
	lxi	h,cold$entry
	push	h
	call	hwinit
	call	coninit
	call	meminit
	rst	1	; kick-start clock and EI
	lxi	h,signon
	call	msgout
	; save registers on stack, for debugger access...
	jmp	intsetup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Substitute command
cmdsub:
	lxi	h,subms
	call	msgout
	lxi	h,ABUSS
	ora	a	; NC
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

 if not nofp
 if z180	; need the space...
getvdpt:
	lda	susave+vdipt
	cpi	0ffh
	jrnz	gvp0
	mvi	a,0d8h
gvp0:	adi	2	; status port
	mov	c,a
	ret
 endif
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
 endif

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
	mov	m,e
	inx	h
	mov	m,d
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Test command

cserr:
	lxi	h,cserms
	jmp	msgout

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
	jrnz	cserr
	di
	lda	ctl$F2
	ani	ctl$SPD	; all but speed bits OFF
	ori	ctl$ORG0	; set ORG0 only
	; pass ctl$F2 in A...
	jmp	memtest - (mtest1-mtest)

;------------------------------------------------
; Start of relocated code...
; Memory Test routine, position-independent
;
mtest0:
mtest:
	; A reg contains desired ctl$F2 image
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

 if not nofp
; must be called with interrupts off
; A = horn delay, in 2mS ticks
; A,HL used
set$horn:
	sta	horn
	lxi	h,ctl$F0
	res	7,m	; beep on
	mov	a,m
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
 endif

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
 if z180
	lda	susave+waits
	cpi	0ffh
	jrnz	cfgwt
	mvi	a,MW0+IOW3
cfgwt:	out0	a,dcntl	; set WAIT states for memory (and I/O)
 endif
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

 if nofp
nmi$f0:
	dcx	h
	mov	a,m
	cpi	0d3h	; OUT
	jrz	nmi$out
	cpi	0dbh	; IN
	jrz	nmi$in
	jmp	nmi$xit2

nmi$in:	; simulate IN returning FF
	pop	psw
	mvi	a,0ffh
	jmp	nmi$xit

nmi$out:	; convert relevant F0 bits to F2 bits
	lxi	h,ctl$F2
	mov	a,m
	ani	11111100b	; ensure bits are "0"
	mov	m,a
	pop	psw
	push	psw	; _  7 6 5 4 3 2 1 0
	ral		; 7  6 5 4 3 2 1 0 _
	ral		; 6  5 4 3 2 1 0 _ 7
	cma		; 6  5'4'3'2'1'0'_ 7'
	ral		; 5' 4'3'2'1'0'_ 7'6
	rlc		; 4' 3'2'1'0'_ 7'6 4'
	ani	03h	; _  _ _ _ _ _ _ 6 4'
	ora	m	; this assumes ctl$F2 bits 0,1 are "0"
	mov	m,a
	out	0f2h
	jmp	nmi$xit2
 endif

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
 if not nofp
	lda	ctl$F0
	xri	00010000b	; toggle single-step = enable
	out	0f0h
	sta	ctl$F0
 else
	lda	ctl$F2
	ori	00000001b	; enable single-step
	out	0f2h
	sta	ctl$F2
 endif
	jr	cmdgo1
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

 if z180
 if use$dma
; DMA F8000-FA000 into 00000-02000
; copy core ROM (8K) into 0000 using DMAC
dmarom:
	lxi	h,0f80h	; page addr (256B)
	lxi	d,0000h	; page addr (256B)
	lxi	b,2000h	; bytes
; Generic memcpy using DMAC.
; HL=src, DE=dst, all units 256B "pages".
; BC=count, units are bytes
dmacpy:
	xra	a
	out0	a,dar0l	; (256B page boundary)
	out0	e,dar0h ;
	out0	d,dar0b	; dest addr
	out0	a,sar0l	; (256B page boundary)
	out0	l,sar0h ;
	out0	h,sar0b	; source addr
	out0	c,bcr0l	;
	out0	b,bcr0h	; byte count
	mvi	a,00000010b	; mem2mem, burst mode
	out0	a,dmode
	mvi	a,01100000b	; DE0,/DWE0(!/DWE1) - start ch 0
	out0	a,dstat
	mvi	c,dstat
init1:	tstio	01000000b	; wait for DMAC to idle
	jrnz	init1
	ret
 endif
 endif

adrin3:	pop	h
	mov	e,m
	inx	h
	mov	d,m
	ret

 if not nofp
; ABUSS L=port, H=value
kpin:	lhld	ABUSS
	mov	c,l	; port
	inp	h	; get value
	shld	ABUSS
	ret

; ABUSS L=port, H=value
kpout:	lhld	ABUSS
	mov	c,l	; port
	outp	h	; output value
kpabt:	ret

kprw:	; switch between display/modify
	lda	DspMod
	xri	1
	sta	DspMod
	ret
 endif

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
 if nofp
	mvi	a,ctl$ORG0+ctl$CLK	; ORG0 on, 2mS on...
 else
	mvi	a,ctl$ORG0	; ORG0 on, 2mS off...
 endif
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

; for cmdmt...
cserms:	db	BEL,'Cksum error',TRM
topms:	db	'Top of Mem: ',TRM

prompt:	db	CR,LF,'H8'
 if h8nofp
	db	'N'
 endif
 if h89
	db	'9'
 endif
	db	': ',TRM
bootms:	db	'oot ',TRM
goms:	db	'o ',TRM
sstms:	db	'-Step',TRM
subms:	db	'ubstitute ',TRM
pcms:	db	'rog Counter ',TRM
mtms:	db	'em test',TRM
dmpms:	db	'ump ',TRM

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
	jrc	cmerr
	lda	lstcmd
	call	conout
	jmp	cmexec

cmerr:	call	belout
	jmp	prloop

 if oled	; for now, only this
auto:
	in	0efh	; INS8250 scratch reg - power-on FF (!= 0)
	ora	a
	rz
	xra	a
	out	0efh	; should persist through RESET
	mvi	c,'@'
	mvi	b,0	; no boot modules
	lxi	h,bfchr
	call	bfind
	rc
	call	cmexec
	ret
 endif

 if not nofp
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
	jrc	deverr
	pushix
	pop	b	; b = IXh
	mvi	c,mddisp
	lxi	d,Aleds
	call	mov3dsp
	push	d	; save LEDs pointer
	; determine if fixed port...
	ldx	a,mdport
	ora	a
	jrnz	gotprt
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
	ldx	d,mdbase
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
	jrnz	bterr2
	ldax	d
	xra	c	; beep off
	stax	d
	mov	a,m
	adi	-1
bterr1:	cmp	m
	jrz	bterr0
	lda	kpchar
	cpi	01101111b	; raw pattern for '*' or CANCEL
	jrnz	bterr1
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
	jrz	kppbt0
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
	jrz	kpbt1
	call	galtbt
	jr	kpbt0

kppbt0:	lxi	h,susave+dpdev
	call	dfboot0
	jc	kperr
	ora	a
	jnz	kperr
kpbt1:
	call	btdsp2	; show device name
	lxiy	kperr
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
; IX=boot module
; show device name in FP display
btdsp2:
	push	d	; device/unit
	pushix
	pop	h
	lxi	d,13	; FP display name
	dad	d
	mov	c,l
	mov	b,h
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
	jrz	rdx0
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
	jrz	sae
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
	jrz	sae
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
	jrc	reg0
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
	jrc	kpalter	; alter mode - numeric values only
	mov	a,b
	jmp	cmchr
; A=DspMod >> 1, B=key
kpalter:
	lhld	ABUSS
	rrc	; register (else memory)
	jrc	kpreg
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
iob:	rarr	c	; save CY => C bit 7
	lda	Radix
	ora	a
	mov	a,b
	jrz	ioboct
; iobhex - to avoid conflict with cmd keys A-F, first input must be [0]
; So, hex input requires 3 or 5 + 1 keys.
	ralr	c	; restore CY
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
	jrnz	iobh0
	jr	iob0
ioboct:
	ralr	c	; restore CY
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
	jrnz	iobo0
iob0:
	; TODO: blip to ack entry?
	ret
 endif

; returns with interrupts disabled
; preserves DE
h17init:
	di
	in	0f2h
	ani	00000011b	; port 7C - only one for H17
	jrnz	h17in0
	xra	a
	out	07fh	; avoid this if H17 not configured
h17in0:	push	d
	lxi	h,ctl$F0
	mvi	m,11010000b	; !beep, 2mS, !mon, !SI
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
	jrnz	h17ini0
	pop	d
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

; called in the context of a command on console
conin:	push	b
	call	getvdpt	; vd$sts in C
conin2:	in	0edh
	rrc
	jrc	conin0
	call	flsvdip	; flush out VDIP1 while we wait...
 if nofp
	jr	conin2
 else
	lda	kpchar
	ora	a
	jrz	conin2
	; cancel console cmd, leave keypad char for cmdin
	pop	b
	jmp	start
 endif

conin0:	pop	b
conin3:	in	0e8h
	ani	07fh
	cpi	DEL	; DEL key restarts from anywhere?
	jz	re$entry	; resets SP
	ret

; Pure console input, no tricks
conin1:	in	0edh
	rrc
	jrnc	conin1
	in	0e8h
	ani	07fh
	ret

 if not nofp
; called in the context of command on front-panel
keyin:	lda	kpchar
	ora	a
	jrnz	getkey
	in	0edh
	rrc
	jrnc	keyin
	; cancel kaypad cmd, leave console char for cmdin
	; TODO: what modes need reset?
	jmp	start
 endif

; wait for command - console or keypad
cmdin:	call	getvdpt	; gets vd$sts in C
cmdin0:
	in	0edh
	rrc
	jrc	conin3
	call	flsvdip ; flush out VDIP1 while we wait...
	; INS8250 IIR always 0
	; 16550 IIR is RxD timeout (?)
	; 16C2550 ISR is RxD timeout (?)
 if nofp
	jr	cmdin0
 else
	lda	kpchar
	ora	a
	jrz	cmdin0
getkey:	push	psw	; A=scan code
	xra	a
	sta	kpchar
	pop	psw
	xri	11111110b
	rrc
	jrnc	gotkey
	rrc
	rrc
	rrc
	rrc
gotkey:	ani	00001111b
	ori	10000000b	; distinguish from console input
	; TODO: check for CANCEL key?
	ret
 endif

 if not nofp
; keypad check at 32mS
kpchk:	lxi	h,RckA
	in	0f0h
	cmp	m	; RckA
	jrnz	kpchk0
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
	rlcr	m
	mov	b,m
	inx	h	; DspMod
	mov	a,m
	ani	00000010b
	lhld	ABUSS
	jrz	ufd1	; displaying memory
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
	jrz	dod	; if displaying memory
	; displaying register name
	pop	b
	lxi	d,Dleds
mv3byt:	mvi	l,3
mvb:	ldax	b
	stax	d
	inx	b
	inx	d
	dcr	l
	jrnz	mvb
	ret

; B=dot flag
dod:	mov	c,a	; value to display
	lda	Radix
	ora	a	; Z if octal (also CY=0)
	mov	a,c
	jrnz	dodhex
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
	jrnz	dodr5
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
	rlcr	b
	pop	psw
	dcr	c
	jrnz	deh55
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
dIX:	db	11111111b,11110011b,10110110b	; " IX"
dIY:	db	11111111b,11110011b,11011110b	; " IY"
dIR:	db	11111111b,11110011b,11010011b	; " IR"
dPSWp:	db	10010000b,10011100b,10111111b	; "AF'"
dBCp:	db	10000110b,10001101b,10111111b	; "BC'"
dDEp:	db	11000010b,10001100b,10111111b	; "DE'"
dHLp:	db	10010010b,10001111b,10111111b	; "HL'"
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
	dw	dIX	; 5	- TODO
	dw	dIY	; 6	- TODO
	dw	dIR	; 7	- TODO
	dw	dPSWp	; 8	- TODO
	dw	dBCp	; 9	- TODO
	dw	dDEp	; 10	- TODO
	dw	dHLp	; 11	- TODO
	dw	dPC	; 12	- 5
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
	jrnz	md0
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
	jrz	fp1
	dcr	m
	jrnz	fp1
	mvi	c,10000000b	; beep off
fp1:
	lxi	h,MFlag
	mov	b,m
	inx	h	; ctl$F0
	mov	a,m
	ora	c	; beep off bit
	mov	m,a
	bit	6,b	; refresh display?
	jrnz	fp3
	inx	h	; Refind
	dcr	m
	jrnz	fp2
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
 endif
int1$xx:
	; not really FP related, but no space in low ROM...
	lda	ctl$F0
	bit	5,a	; MON mode?
	jnz	intret	; skip if running monitor...
	lda	MFlag
	bit	7,a	; HLT processing enabled
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
bfchr:	ldx	a,+2	; phy drv or type
	sui	200	; boot modules < 200
	sbb	a	; ff=boot, 00=cmd
	cmp	b	; ZR=match
	jrnz	bfn0
	ldx	a,mdchr
	cmp	c
	ret

; match module by FP key
; C=FP key, B=00:cmd,ff:boot
bfkey:	ldx	a,+2	; phy drv or type
	sui	200	; boot modules < 200
	sbb	a	; ff=boot, 00=cmd
	cmp	b	; ZR=match
	jrnz	bfn0
	ldx	a,mdkey
	cmp	c
	ret

; match boot module by phy drv number
; C=phy drv (base), B=type
; Only for boot modules
bfnum:	ldx	a,mdbase	; phy drv or type
	cpi	200	; boot modules < 200
	jrnc	bfn0	; skip if >= 200
	mov	a,c
	subx	mdbase
	ora	a
	jrnz	bfn0
	xra	a
	ret
bfn0:	xra	a
	inr	a
	ret

; List only boot modules
; On first module, C=0
bflst:	ldx	a,mdbase	; phy drv or type
	cpi	200	; boot modules < 200
	jrnc	bfn0
	mov	a,c
	ora	a
	mvi	a,','
	cnz	conout
	inr	c
	mov	a,b
	subx	mdbase
	ora	a
	mvi	a,'*'
	cz	conout
	pushix
	pop	h
	lxi	d,mdname
	dad	d
	call	msgout
	lxi	h,bflst
	jr	bfn0	; NZ - keep going

; List only boot modules
bfllst:	ldx	a,mdbase	; phy drv or type
	cpi	200	; boot modules < 200
	jrnc	bfn0
	mov	a,b
	subx	mdbase
	ora	a
	mvi	a,' '
	jrnz	bfll2
	mvi	a,'*'
bfll2:	call	conout
	pushix
	pop	h
	lxi	d,mdname
	dad	d
	call	msgout
	mvi	a,TAB
	call	conout
	ldx	a,mdchr
	call	conout
	mvi	a,' '
	call	conout
	ldx	a,mdkey
	adi	'0'
	jrnc	bfll0
	mvi	a,'-'
bfll0:	call	conout
	mvi	a,' '
	call	conout
	ldx	a,mdbase
	call	decout
	call	crlf
	lxi	h,bfllst
	xra	a	; NZ - keep going
	inr	a	;
	ret

; Find boot module and load into 1000h if necessary.
; HL=match function: returns Z if found, BC=target, IX=module
; Return CY at end of modules (not found)
; Return IX=loaded module (run location)
; Must preserve BC during search loop.
bfind:
	; can't check if it's loaded until we know where it's loaded...
	; first, check if already loaded
	;lxix	btovl
	;call	icall
	;rz
bfind0:
 if z180
	; map ROM F8000 into 4000
	mvi	a,0f8h-04h
	out0	a,mmu$bbr
 else
	; must map ROM back in, so prevent interruptions...
	; also, we loose memory at SP...
	di
	lxiy	0
	dady	sp
	lxi	sp,0e000h	; a safe SP?
	lda	ctl$F2
	push	psw
	ani	not ctl$ORG0	; ORG0 off
	ori	ctl$MEM1	; MEM1 on
	out	0f2h
 endif
	lxix	btmods	; start of modules...
bf0:	call	icall
	jrz	bf9
	ldx	d,mdpgs
	mvi	e,0
	dadx	d
	pushix
	pop	psw	; A=IXh
	cpi	HIGH bterom	; end of ROM
	jrnc	bf1
	ldx	a,mdpgs
	ora	a
	jrz	bf1
	cpi	0ffh
	jrnz	bf0
bf1:
 if z180
	xra	a
	out0	a,mmu$bbr
 else
	pop	psw
	out	0f2h
	spiy
	ei
 endif
	stc	; CY = end of list (not found)
	ret

bf9:	; match found, now load into place and init
	ldx	b,mdpgs
	ldx	d,mdorg
	pushix		;
	pop	h	; HL=IX (module in logical addr)
	mvi	e,0
	mvi	c,0
	push	d
 if z180
 if use$dma
	mov	a,h	; L should (must) be 00... also E...
	sui	40h	; remove offset of mapping @ 4000h
	adi	80h	; low byte of 0f80h ROM page addr
	mov	l,a
	mvi	a,0fh	; hi byte of 0f80h ROM page addr
	aci	0
	mov	h,a	; HL=ROM phy addr
	mov	e,d	; shift dest addr into page addr
	mvi	d,0	; always in low memory?
	call	dmacpy
 else
	; TODO: avoid redundant load... and init?
	ldir
 endif
 else
	; TODO: avoid redundant load... and init?
	ldir
 endif
	popix	; module load addr
	; now call init routine... but must restore RAM...
 if z180
	xra	a
	out0	a,mmu$bbr
 else
	pop	psw
	out	0f2h
	spiy
	ei
 endif
	call	btinit	; CY indicates error, pass along...
	ret

; IX=module in real memory
btinit:	pushix
	pop	h
	mvi	l,mdinit
	pchl

; IX=module in real memory
cmexec:
btboot:	pushix
	pop	h
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
	jrnz	findit
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
	ldx	d,mdbase
	mov	a,m
	inx	h
	cpi	0ffh
	jrnz	dfbt0
	xra	a
dfbt0:	cmpx	mdluns
	cmc
	rc
	mov	e,a	; DE=phy drv base,unit
	mov	a,m
	cpi	0ffh	; no string?
	jrz	dfbt2
	push	d
	lxi	d,bootbf+1	; len in +0...
	mvi	c,0
dfbt1:	mov	a,m
	stax	d
	inx	h
	inx	d
	inr	c
	ora	a
	jrnz	dfbt1
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

 if z180
; TODO: preserve CPU regs for debug/front-panel
; (by the time we reach intsetup, everything is trashed)
trap:
	pop	h
	dcx	h
	bit	6,a
	jrz	trap0
	dcx	h
trap0:
	mov	b,a
	mvi	a,1111$1111b
	out0	a,mmu$cbar
	xra	a
	out0	a,mmu$cbr
	out0	a,mmu$bbr
	lxi	sp,0ffffh
	push	h
	mov	a,b
	ani	01111111b	; reset TRAP
	out0	a,itc
	lxi	h,trpms
	call	msgout
	pop	h
	call	adrout
	call	crlf
	jmp	init0
 endif

 if z180
savram:	; TODO: implement this w/o DMAC?
	lxi	h,000h	; save from 00000h
	lxi	d,300h	; save into 30000h
	lxi	b,16*1024	; save all 16K
	call	dmacpy
	ret
 else
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
	ldir
	; de-init mmu
	mvi	a,0
	out	rd00k	; turn off MAP bit, back to normal
	ret
 endif

linix:	mvi	m,0	; terminate buffer
	ret

; input a line from console, allow backspace
; HL=buffer (size 128)
; returns B=num chars, 128 max (never is 0c3h)
linin:
	mvi	b,0	; count chars
lini0	call	conin	; handles DEL (cancel)
	cpi	CR
	jrz	linix
	cpi	BS
	jrz	backup
	cpi	' '
	jrc	chrnak
	cpi	'~'+1
	jrnc	chrnak
chrok:	mov	m,a
	inx	h
	inr	b
	jm	chrovf	; 128 chars max
	call	conout
	jr	lini0
chrovf:	dcx	h
	dcr	b
chrnak:	mvi	a,BEL
	call	conout
	jr	lini0
backup:
	mov	a,b
	ora	a
	jrz	lini0
	dcr	b
	dcx	h
	mvi	a,BS
	call	conout
	mvi	a,' '
	call	conout
	mvi	a,BS
	call	conout
	jr	lini0

; Used during entry of LUN in boot command.
; multiply E by 16, check for >= (IX+mdnum) (or overflow)
; add in A (converted to binary).
; IX=active boot module
; Returns CY on overflow, else E updated to new LUN value
E$x16$A:
	mov	b,e
	ralr	b
	rc
	ralr	b
	rc
	ralr	b
	rc
	ralr	b
	rc
	push	psw
	sui	'0'
	cpi	9+1
	jrc	ex16a0
	sui	'A'-'0'-10
ex16a0:	add	b	; never CY
	cmpx	mdluns	; might be 0ffh
	jrc	ex16a1	; value OK
	pop	psw
	stc
	ret
ex16a1:	mov	e,a
	pop	psw
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dump command
cmddmp:
	lxi	h,dmpms
	call	msgout
	lxi	h,ABUSS
	ora	a	; NC
	mvi	d,CR
	call	adrin
	xchg	; HL=adr
	mvi	b,8	; 8 lines (one half page, 128 bytes)
dmp0:	push	b
	call	adrnl	; CR,LF,"AAAA " (HL=AAAA)
	push	h
	mvi	b,16
dmp1:	mov	a,m
	call	hexout
	call	spout
	inx	h
	djnz	dmp1
	pop	h
	mvi	b,16
dmp2:	mov	a,m
	cpi	' '
	jrc	dmp3
	cpi	'~'+1
	jrc	dmp4
dmp3:	mvi	a,'.'
dmp4:	call	conout
	inx	h
	djnz	dmp2
	pop	b
	djnz	dmp0
	shld	ABUSS
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
 if not nofp
hbmsg3:	db	'Sec: ',0
 endif

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
	jrz	cmdhb6
	mvi	a,' '
cmdhb6:	call	cmdhbx
 if not nofp
	lxi	h,hbmsg3
	lxi	d,susave+dsdev
	mvi	a,' '	; never the default
	call	cmdhbx
 endif
	ret

cmdhbx:	call	conout
	call	msgout
	ldax	d
	inx	d
	cpi	0ffh
	jrnz	cmdhb0
	mvi	a,'-'
cmdhb0:	call	conout
	mvi	a,' '
	call	conout
	ldax	d
	inx	d
	adi	'0'	; FF=2F,CY
	jrnc	cmdhb1
	mvi	a,'-'
cmdhb1:	call	conout
	mvi	a,' '
	call	conout
	ldax	d
	cpi	0ffh
	jrnz	cmdhb2
	mvi	a,'-'
	call	conout
	jr	cmdhb3
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
	jrc	cmxerr
	cpi	'z'+1
	jrnc	cmxerr
	sta	lstcmd
	; would like to re-use nocmd, but error path is wrong...
	mov	c,a
	mvi	b,0	; no boot modules
	lxi	h,bfchr
	call	bfind
	jrc	cmxerr
	lda	lstcmd
	ani	01011111b	; upper case echo
	call	conout
	jmp	cmexec

cmxerr:	call	belout
	jr	cmdx

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

if not z180 or nofp
getvdpt:
	lda	susave+vdipt
	cpi	0ffh
	jrnz	gvp0
	mvi	a,0d8h
gvp0:	adi	2	; status port
	mov	c,a
	ret

; C *must* contain vd$sts port from getvdpt
flsvdip:
	; flush out VDIP1 while we wait...
	inp	a	; VDIP1/FT245R status
	ani	00001000b	; VDIP1 RxR
	rz
	dcr	c
	inp	a	; flush char, VDIP1 data reg
	inr	c
	ret
 endif

; code required to return to monitor from stand-alone programs.
retmon:
	di
	xra	a	; reset state of ctl port
	out	0f2h
 if not nofp
	mvi	a,0dfh	; reset state of FP port 0
	out	0f0h
 endif
	jmp	0

signon:	db	CR,LF,'H8'
 if h8nofp
	db	'N'
 endif
 if h89
	db	'9'
 endif
	db	' '
 if z180
	db	'Z180 '
 endif
	db	'Monitor v'
vernum:	db	(VERN SHR 4)+'0','.',(VERN AND 0fh)+'0'
 if alpha
	db	'(alpha',alpha+'0',')'
 endif
 if beta
	db	'(beta'
 if beta > 9
	db	(beta/10)+'0'
 endif
	db	(beta MOD 10)+'0',')'
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
