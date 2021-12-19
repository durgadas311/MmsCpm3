vers equ '0a' ; Nov 14, 2021  13:49  drm "MXIOS.ASM"
;****************************************************************
; MP/M main XIOS module for Z180 on the H8/H89			*
; Derived from the MMS 77500 server XIOS			*
; Copyright (c) 1983 Magnolia Microsystems			*
;****************************************************************
; All memory segments are ORGed at 0000.
; Uses CP/M Plus format DPBs.

	maclib	z180
	maclib	cfgmpm

	public	@adrv,@pdrv,@rdrv,@side,@trk,@sect
	public	@dma,@dbnk,@dirbf
	public	@dstat,@cmode,@dph,@rcnfg,@eops
	public	@cbnk,@scrcb,@vect,@secnd

	public	xdos,polltb,sysdat

	extrn	@lptbl
	extrn	?memsl,?bnksl,?bnkck,?xmove,?move	; MMU module
	extrn	@memstr,@mmerr,@nbnk
	extrn	?time,?itime,@rtcstr			; RTC module

 if z180
z180tick	equ	true
h89tick		equ	false
 else
  if h89
z180tick	equ	false
h89tick		equ	true
tick$tick	equ	10	; number of 2mS ticks per MP/M tick
  else
; TODO: what to use for tick?
z180tick	equ	false
h89tick		equ	false
  endif
 endif

only$prot$A	equ	true	; Only worry about R/O A:
secsize		equ	512	; largest sector size supported/used

cr	equ 13
lf	equ 10
bell	equ 7

cpm	equ	0
bdos	equ	5

poll	equ	131
flagset equ	133

;relative position of elements in buffer headers:
link	equ	0	;link to next headr, or 0
hstpda	equ	2	;Process Descriptor Adr of owner
hstmod	equ	4	;mode pointer (partition address)
pndwrt	equ	6	;pending write flag
hstdsk	equ	7	;host disk
hsttrk	equ	8	;host track
hstsec	equ	10	;host sector
hstbuf	equ	12	;host buffer address
hstbnk	equ	14	;host bank
hstmdl	equ	15	;host module entry
hstlen	equ	17	;length of header

 if z180
; Z180 registers
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
il	equ	33h
tmdr0l	equ	0ch
tmdr0h	equ	0dh
rldr0l	equ	0eh
rldr0h	equ	0fh
tcr	equ	10h
 endif

;-------- Start of Code-producing source -----------

	; Because LINK puts dseg after cseg, and 'combas' is
	; at the beginning of dseg, GENSYS will enforce that
	; all of dseg falls in common memory.
	cseg		; Banked memory
BIOS$0	equ	$
	jmp combas	; initial entry on cold start, common base
	jmp wboot	; reentry on program exit, warm start

	jmp const	; return console input status
	jmp conin	; return console input character
	jmp conout	; send console output character
	jmp list	; send list output character
	jmp auxout	; send auxilliary output character	-NULL
	jmp auxin	; return auxilliary input character	-NULL

	jmp home	; set disks to logical home
	jmp seldsk	; select disk drive, return disk parameter info
	jmp settrk	; set disk track
	jmp setsec	; set disk sector
	jmp setdma	; set disk I/O memory address
	jmp read	; read physical block(s)
	jmp write	; write physical block(s)

	jmp listst	; return list device status
	jmp sectrn	; translate logical to physical sector

	jmp	?memsl
	jmp	poll$dev
	jmp	strtclk
	jmp	stopclk
	jmp	exitreg
	jmp	maxcon
	jmp	boot	;   sysinit
;	jmp	idle	;
	nop ! nop ! nop	; no idle routine

	dw	polltb	;for RSP's (such as NETWRKIF)

	ds	13	;this puts setup/mode info where they expect it
	jmp	search
	jmp	setspd	; change CPU speed - platform dependent
	ds	3

; These are only static when accessed via XIOSJMP.TBL
@dstat: ds	1
speed:	ds	1	; formerly Port F2 image "@intby"

	dw	@lptbl	;logical/physical drive table
	dw	thread	;module thread
	dw	0	;?serdp	;test mode validity, HL=memory address of ?serdp

@adrv:	ds	1		; currently selected disk drive
@pdrv:	ds	1		; physical drive number (MMS)
@rdrv:	ds	1		; module relative disk drive number
curmdl: ds	2		; currently selected Disk I/O module address
@cmode: ds	2
@dph:	ds	2

icovec: dw	1000000000000000b
icivec: dw	1000000000000000b
iaovec: dw	0000000000000000b
iaivec: dw	0000000000000000b
ilovec: dw	0000000000000000b

defsrc: db	0,0ffh,0ffh,0ffh
tmpdrv: db	0
srctyp: db	000$00$000b	;only bits 3,4 are used (others ignored)

	; for MODULES.COM... well, not quite since not in common memory...
	; This will be copied to BIOS JMP PAGE, in common memory,
	; but these strings must also reside in common memory.
	dw	@memstr
	dw	@rtcstr

@dma:	dw	0
wbtrap: dw	0

	dseg
;---------- COMMON MEMORY -----------
; WARNING: must be on page boundary ('vect' alignment).
; Use LINK 'B' option.
combas: jmp	colds
swtusr: jmp	$-$
swtsys: jmp	$-$
pdisp:	jmp	$-$
xdos:	jmp	$-$
sysdat: dw	$-$

; These locations are fixed, after combas block.
@vect:	dw	$-$
dbuga:	dw	$-$
dbugv:	dw	$-$
biosjmp:dw	$-$
@dbnk:	ds	1	; bank for user I/O (user DMA addr)
@eops:	ds	1
@intby: ds	1	; Port F2 image

@dirbf: ds	128

 if z180
	; Z180 internal devices interrupt vector table.
	; If external devices also generate interrupts,
	; this must be expanded/realigned to compensate.
	; need 32-byte aligned address:
	rept	(32 - (($-combas) AND 1fh)) AND 1fh
	db	0
	endm
vect:	dw	nulint	; 0 - /INT1
	dw	nulint	; 1 - /INT2
	dw	tick	; 2 - PRT0 (TMDR0 -> 0)
	dw	nulint	; 3 - PRT1 (TMDR1 -> 0)
	dw	nulint	; 4 - DMA0
	dw	nulint	; 5 - DMA1
	dw	nulint	; 6 - CSIO
	dw	nulint	; 7 - ASCI0
	dw	nulint	; 8 - ASCI1
	dw	nulint	; 9 - unused by Z180
	dw	nulint	; 10 - unused by Z180
	dw	nulint	; 11 - unused by Z180
	dw	nulint	; 12 - unused by Z180
	dw	nulint	; 13 - unused by Z180
	dw	nulint	; 14 - unused by Z180
	dw	nulint	; 15 - unused by Z180
 endif

wboot:
colds:
 if z180
	; possible TRAP
	in0	a,itc
	tsti	10000000b	; TRAP bit
	jrnz	trap
 endif
	mvi	c,0
	jmp	xdos

 if z180
; For now, any TRAP is fatal
trap:	lxi	h,trpmsg
	jmp	errx

trpmsg:	db	cr,lf,'*TRAP*',cr,lf,'$'
 endif

nulint:	ei
	reti

; C=device to poll, 0-N char I/O devices (input status)
poll$dev:
	mov	a,c
	cpi	8
	jrnc	pd0	; not char I/O...
	mov	d,c
	sui	4
	jc	const
	mov	d,a
	jmp	conost
pd0:	mvi	b,0
	lxi	h,polltb
	dad	b
	dad	b
	mov	e,m
	inx	h
	mov	d,m
	; TODO: check DE=NULL?
	xchg
	pchl

; Devices 8..15, starting at +0...
polltb:	dw	$-$,$-$,$-$,$-$,$-$,$-$,$-$,$-$ ; 8..15 unassigned (yet)

maxcon: mvi	a,0	;filled in at init from SYSDAT and config
	ret

exitreg:
	lda	preempt
	ora	a
	rnz
	ei
	ret

strtclk: mvi	a,true
	 jr	sc00
stopclk: mvi	a,false
sc00:	 sta	clock
	 ret

preempt: db	0
clock:	 db	0

@secnd: dw	$-$	;used to do timeouts

tps:	db	0	; from system data page on boot
pcnt:	db	0	; pre-scale for interrupts to MP/M ticks
tcnt:	db	0	; must immediately follow pcnt...

second:
	lhld	@secnd
	mov	a,h
	ora	l
	cnz	icall
	mvi	e,2
	mvi	c,flagset
	call	xdos
	jr	tk1

tick:	sspd	istk
	lxi	sp,intstk
	push	psw
	push	h
	push	d
	push	b
 if z180tick
	in0	a,tmdr0l	; reset INT
 endif
 if h89tick
	lda	@intby
	out	0f2h	; reset INT
	lxi	h,pcnt
	dcr	m
	jrnz	iexit
	mvi	m,tick$tick
 endif
	mvi	a,true
	sta	preempt
	lda	clock
	ora	a
	jrz	tk0
	mvi	e,1
	mvi	c,flagset
	call	xdos
tk0:
	lxi	h,tcnt
	dcr	m
	jrnz	tk1
	lda	tps
	mov	m,a
	jr	second
tk1:	mvi	a,false
	sta	preempt
 if z180tick
	lxi	d,nexti
	push	d
	reti	; required by Z180?
nexti:
 endif
	pop	b
	pop	d
	pop	h
	pop	psw
	lspd	istk
	jmp	pdisp

 if h89tick
iexit:
	pop	b
	pop	d
	pop	h
	pop	psw
	lspd	istk
	ei
	ret
 endif

	ds	64	;32 levels of stack
intstk: ds	0
istk:	dw	0

; SEARCH for a module by device #.
;   entry:	C = device # (0-249)
;   exit:	[CY] = not found
;	   else HL=module address ("init" entry)
;		A=device number (relative to module's #0)
;
search: lxi	d,thread	;C=device number
snext:	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	mov	a,d
	ora	e
	sui	1	;produce [CY] if DE=0000
	rc		;return if device not found, DE=0000
	mov	a,c
	sub	m
	jrc	snext
	inx	h
	cmp	m
	jrnc	snext
	inx	h	;point to "init" vector
	ora	a	;set [NC] condition
	ret

ciomdl:	dw	0	;character device driver, filled at cold-start.
cionum:	db	0	;max num cio devices (numcon+numlst)

cinit:	;C=device number (0-11)
	lhld	ciomdl	; init routine
	mov	b,c
	pchl		;jump to modules "init" with B=device #

auxin:	mvi	a,1ah	; EOF
	ora	a
auxout:	ret

nodev:	pop	psw
nost:	xra	a	; never ready
	ret

; D=device number
listst:
	lda	maxcon+1
	add	d
	mov	d,a	; LST: #0 = con#N+1
conost:
	mvi	a,9
	jr	devio

; D=device number, C=char
list:
	lda	maxcon+1
	add	d
	mov	d,a	; LST: #0 = con#N+1
conout:
	push	b
	push	d
	call	conost	; is ready now?
	ora	a
	jnz	co0
	pop	d
	push	d
	mov	a,d
	adi	4
	mov	e,a
	mvi	c,poll
	call	xdos	; sleep until ready
co0:	pop	d
	pop	b
coo:	mvi	a,12
	jr	devio

; D=device number
const:	mvi	a,3
	;jr	devio

; A=JMP tbl off, D=devnum [C=char]
devio:	push	psw
	lda	cionum	;see if device exists
	dcr	a
	cmp	d
	jrc	nodev
	pop	psw	; driver JMP offset
	mov	b,d	;device number in B for modules
	jr	indjmp0

; D=device number
conin:	push	d
	call	const	; is ready now?
	ora	a
	jnz	ci0
	pop	d
	push	d
	mov	e,d
	mvi	c,poll
	call	xdos	; sleep until ready
ci0:	pop	d
	mvi	a,6
	jr	devio

; char I/O driver function calls
; A=offset (0,3,6,9,...), B=device number (0..N)
indjmp0:
	lhld	ciomdl
	add	l	;a=0,3,6,9,12,...
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
icall:	pchl		;indirect call


@cbnk:	db	0	; bank for processor operations
bnkflg: ds	1	;flag for enough memory installed.

getusrbnk:	;finds the bank number for calling process
	call	swtusr		; would like better way...
	lda	@cbnk
	sta	@dbnk
	jmp	swtsys

 if h89
; CPU clock rate selected, ORG0+2mS handled by user
cpuspd:	db	00h,10h,04h,14h
 endif

; A=0,1,2,3[...] speed index, FF=get current speed
; Returns A: FF=error, FE=not supported, 0,1,2,3...=success
; Called from user bank, must be in common mem.
setspd:
 if h89
	cpi	0ffh
	jrz	ssx
	sta	speed
	mov	e,a
	cpi	4
	mvi	a,0ffh
	rnc
	lxi	h,cpuspd
	mvi	d,0
	dad	d
	mov	d,m
	di
	lda	@intby
	ani	11101011b
	ora	d
	sta	@intby
	out	0f2h	; speed changes now
  if z180tick
	; there will be a small error until next tick
	lxi	h,maxclk
	mov	a,e
	cpi	3
	jrz	ss0
	lxi	h,minclk
	ora	a
	jrz	ss0
ss1:	dad	h
	dcr	a
	jrnz	ss1
ss0:	; HL=timer value for 50Hz tick
	out0	l,rldr0l	; update timer reload count
	out0	h,rldr0h	;
  endif
ssx:	lda	speed	; always return current speed
 else
	mvi	a,0feh	; not supported
 endif
	ret

thread: equ	$	;must be last in dseg (common mem)

	cseg	; rest is in banked memory...

signon: db	cr,lf,bell
 if h89
	db	'H8-'
 endif
; TODO: other platforms...
 if z180
	db	'Z180'
 else
	db	'Z80'
 endif
	db	' MP/M-II v3.00'
	dw	vers
	db	'  (c) 1984 DRI and MMS',cr,lf,'$'

bnkerr:	db	cr,lf,bell,'Not enough memory banks$'

; Interrupts are disabled
; HL = BIOS JMP table
; DE = debug entry
; C = debug RST num
boot:
 if h89
	; This is H89-specific...
	mvi	a,defspd
	sta	speed
	lda	cpuspd+defspd
	ori	00100000b	; ORG0 only, right now
	sta	@intby
	out	0f2h	; prevent undesirable intrs
			; Console 8250 should already be off
 endif
 if z180
	; speed things up...
	mvi	a,z$dcntl
	out0	a,dcntl	; set WAIT states
	mvi	a,z$rcr
	out0	a,rcr	; set RESFRESH cycles
 endif
	;
	sded	dbuga
	shld	biosjmp
	mov	a,c
	add	a
	add	a
	add	a
	mov	l,a
	mvi	h,0
	shld	dbugv
 if z180tick
	lxi	h,vect
	shld	@vect
	mov	a,h
	stai
	out0	l,il
 endif
 if h89tick
	mvi	a,JMP
	sta	0008h
	lxi	h,tick
	shld	0008h+1
	lda	@intby
	ori	02h
	sta	@intby
	out	0f2h
 endif

	lhld	sysdat
	mvi	l,122	;ticks/sec
	mov	a,m
	sta	tps
	sta	tcnt
	mvi	l,252	;XDOS internal data page
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,5
	dad	d	; skip past TOD
	shld	rlr
	lxi	h,0096h	; osmsegtbl
	dad	d
	shld	msegtbl
; get common size from SYSDAT
	lhld	sysdat
	mvi	l,124		;common memory base page
	mov	a,m
; Verify that we have banked RAM... A=compag from MP/M
	call	?bnkck
	sta	bnkflg
 if z180tick
; initialize timer interrupts
	lxi	h,tickrate	; phi/20/tickrate = ticks per sec
	out0	l,tmdr0l
	out0	h,tmdr0h
	out0	l,rldr0l
	out0	h,rldr0h
	in0	a,tcr
	ori	00010001b	; TIE0, TDE0
	out0	a,tcr		; start the timer
 endif
; Initialize all modules and build tables.
	lxi	h,thread	;thread our way through the modules,
iin0:	mov	e,m		;initializing as we go.
	inx	h
	mov	d,m	;next module, or "0000" if we're past the end.
	inx	h
	mov	a,d
	ora	e
	jz	init$done
	mov	a,m	;device base number
	inx	h
	inx	h	;thread+4 = init entry (JMP)
	sui	200	;if Char I/O module, build entry(s) in tables.
	jc	notchr
	; should only be one...
	shld	ciomdl
	push	d	;save NEXT module address
	dcx	h	;number of devices
	push	h
	lhld	sysdat
	inx	h	;nmb$cns
	mov	d,m	;E=nmb$cns
	mvi	l,197
	mov	e,m	;D=nmb$lst
	pop	h	;HL=ciomdl.ndev
	mov	a,e
	add	d	;total ndev needed (never 0)
	dcr	a
	sub	m	; (nmb$cns+nmb$lst-1) - ciomdl.ndev
	jrc	iin50	; OK, we have enough
	inr	a	; num devs to drop
	sub	e	; drop printers first
	jrz	iin3
	jrnc	iin1
iin3:	neg
	mov	e,a	; num$lst remaining
	jr	iin50
iin1:	mvi	e,0	; no printers left, must reduce nmb$cns
	sub	d	; must be neg
	neg
	mov	d,a
iin50:	mov	a,d	; adjusted nmb$cns
	sta	maxcon+1
	add	e	; adjusted nmb$lst
	sta	cionum	; initialize only what is needed
	pop	h	; next module
	jmp	iin0

notchr: 		;HL point to init entry
	push	d
	call	icall	;"call" (HL)
	pop	h
	jmp	iin0

init$done:	;all Disk I/O modules are initialized.
		; now initialize the chrio devices
	lda	cionum
	mov	c,a	; last dev + 1
iin5:	dcr	c
	jm	iin2	; include dev 0
	push	b
	call	cinit
	pop	b
	jr	iin5
iin2:
	lxi	h,signon
	call	msgout
	lda	bnkflg
	ora	a	;is enough memory installed?
	jz	ramerr
	call	segchk	; check memsegtbl (if banked RAM good)
	ora	a
	jz	segerr
	call	set$jumps  ;setup system jumps and put in all banks
	call	?itime	; get (starting) TOD from RTC

 if z180tick
	im2
 endif
	xra	a
	ret

; Verify that memsegtbl has no bank >= @nbnk
segchk:
	lhld	sysdat
	mvi	l,15	; max$mem$seg
	mov	b,m
	lda	@nbnk	; num banks
	dcr	a	; largest bank num allowed
sgck0:
	inx	h
	inx	h
	inx	h
	inx	h	; memsegtbl[x].bank
	cmp	m
	jrc	sgck1
	djnz	sgck0
	ori	true
	ret
sgck1:	xra	a	; error - not enough banks
	ret

; Interrupts disabled, must not enable
set$jumps:
	liyd	dbugv
	mvi	a,(JMP)
	sta	cpm
	sty	a,+0      ; set up jumps in page zero
	lhld	biosjmp ! shld cpm+1	; BIOS warm start entry
	lhld	dbuga
	sty	l,+1
	sty	h,+2	; DEBUGGER entry point
	lda	@nbnk
	mov	b,a	;number of banks (also, -1 is dest bank)
	mvi	c,0	;source bank
sj0:
	dcr	b
	rz
	push	b
	; must setup DE,HL before ?xmove
	lxi	h,0	; page 0 in all banks
	mov	d,h
	mov	e,l
	call	?xmove
	lxi	b,64
	xra	a	; interrupts are disabled
	call	?move
	pop	b
	jr	sj0		;
	ret

segerr: lxi	h,bnkerr
	jr	errx
ramerr: lxi	h,@mmerr
errx:	call	msgout
	di ! hlt

msgout:
	mov	a,m
	cpi	'$'
	rz
	push	h
	mov	c,m
	mvi	d,0
	call	coo
	pop	h
	inx	h
	jr	msgout

@dtbl:	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

seldsk:
	mov a,c ! sta @adrv			; save drive select code
	lxi	h,@lptbl
	mvi b,0 ! dad b 	      ; create index from drive code
	mov	a,m
	cpi	255
	jz	selerr
	sta	@pdrv
	mov	c,a
	mov	b,e	;save login flag thru "search" routine
	call	search
	jc	selerr
	sta	@rdrv
	shld	curmdl
	push	b	;save login bit
	lxi	d,14
	dad	d	;point to dphtbl
	mov	e,m	;DE=dphtbl
	inx	h
	mov	d,m
	inx	h
	mov	c,m	;BC=modtbl
	inx	h
	mov	b,m
	lda	@rdrv
	add	a
	add	a
	add	a	;*8
	mov	l,a
	mvi	h,0
	dad	b	;select mode bytes
	shld	@cmode	;set current mode pointer
	pop	b	;get login bit back.
	bit	0,b	;test for initial select.
	jrnz	notlgi
	xchg		;DE=modes
	mov	c,a
	mvi	b,0
	dad	b	;+*8
	dad	b	;+*16
	shld	@dph
	xchg
	lda	@adrv
	mov	c,a
	add	a	;*2
	add	a	;*4
	add	a	;*8
	add	a	;*16
	add	c	;*17
	mov	c,a	;B still = 0
	call	setup$dph
	jrc	selerr
	xra	a
	sta	@rcnfg
	lhld	curmdl
	lxiy	@scrcb
	lda	@pdrv
	sty	a,hstdsk
	mvi	a,3
	call	calmod	;call module's "login" routine.
	ora	a	;see if an error occured.
	jrnz	selerr
	lda	@rcnfg
	ora	a
	cnz	setup$dph
	jrc	selerr
	lda	@adrv
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,@dtbl
	dad	b
	lded	@dph
	mov	m,e	;set current DPH in @dtbl
	inx	h
	mov	m,d
	jr	selcom	;DE=dph

selerr: lxi	h,0
	ret

notlgi: lda	@adrv
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,@dtbl
	dad	b
	mov	e,m	;get current DPH from @dtbl
	inx	h
	mov	d,m	;DE=dph
	sded	@dph
selcom:
	lxi	h,+10
	dad	d	;point to DPB entry
	mov	c,m
	inx	h
	mov	b,m
	ldax	b	;SPT (logical)
	sta	@spt
	lxi	h,+3
	dad	b
	mov	a,m	;BSM
	sta	blkmsk
	lxi	h,+13	;point to track offset
	dad	b
	mov	c,m
	inx	h
	mov	b,m
	inx	h
	sbcd	offset
	mov	a,m	;psh
	sta	blcode
	xchg		;put DPH in (HL) for BDOS
	ret

setup$dph:
	ora	a	;reset [CY]
	lhld	@cmode	;HL=modes
	bit	7,m	;check for hard-disk drive (modes not standard)
	rnz
	stc
	ret

home:	lxi b,0 	; same as set track zero
settrk: sbcd @trk
	ret

setsec: sbcd @sect
	ret

setdma:
	mov	a,b
	ana	c
	cpi	true
	jz	flushall
	sbcd	@dma
	ret

sectrn: mov l,c ! mov h,b
	mov a,d ! ora e ! rz
	xchg ! dad b ! mov l,m ! mvi h,0
	dcx	h	;sectors numbered 0 - (n-1)
	ret


read:
	mvi	a,true		; FLAG A READ OPERATION
	sta	preread 	; forces FLUSH and Physical READ
	sta	rdflg
	sta	defer		; never flush if reading (pointless)
	cma	; false
	sta	unalloc ;terminate any active unallocated-writing
	LHLD	REQTRK
	lda	OFFSET
	sub	l	; DIR track must be < 256
	ora	h	; 00=on DIR track
	lhld	@sect
	ora	h	;
	ora	l	; 00=first sector of directory
	sui	1	; CY = 1st sec of dir
	sbb	a	; FF = 1st sec of dir, else 00
	sta	dir0
	jr	rwoper

write:
	; For CP/NET servers, check if drive R/O.
	; must preserve DE, BC.
 if only$prot$A
	lda	@adrv
	ora	a
	jrnz	wr2
	lhld	rlr
	mov	a,m
	adi	29	; process compat attrs (and R/O vec)
	inx	h
	mov	h,m
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m	; get R/O vec
	ani	0001b
	mvi	a,2	; error: disk read/only
	rnz
 else
	lhld	rlr
	mov	a,m
	adi	29	; process compat attrs (and R/O vec)
	inx	h
	mov	h,m
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	mov	a,m	; get R/O vec
	ani	00001111b
	jrz	wr2
	mov	l,a
	lda	@adrv	; CP/M drive
	cpi	4
	jrnc	wr2
	inr	a
	mov	h,a
	mvi	a,0001b
wr0:	dcr	h
	jrz	wr1
	rlc
	jr	wr0
wr1:	ana	l	; test if selected drive is R/O
	mvi	a,2	; error: disk read/only
	rnz
 endif
wr2:
	xra	a
	sta	dir0
	sta	rdflg
	mvi	a,true
	STA	preread 	; assume a PRE-READ
	mov	a,c
	ani	1		; 00 = defered write, else 01
	dcr	a		; FF = defer, else 00
	sta	defer
	bit	1,c		; write to 1st sector of unallocated block ?
	jrz	CHKUNA
	SDED	URECORD 	; SET UNALLOCATED RECORD #
	mov	a,b
	sta	urecord+2
	mvi	a,true
	STA	UNALLOC 	; FLAG WRITING OF AN UNALLOCATED BLOCK
CHKUNA: LDA	UNALLOC 	; ARE WE WRITING AN UNALLOCATED BLOCK ?
	ORA	A
	JRZ	rwoper
	LHLD	URECORD 	; IS REQUESTED RECORD SAME AS EXPECTED
	DSBC	D		;  SAME AS EXPECTED UNALLOCATED RECORD ?
	JRNZ	ALLOC		; IF NOT, THEN DONE WITH UNALLOCATED BLOCK
	lda	urecord+2
	sub	b
	jrnz	alloc
	XRA	A		; CLEAR PRE-READ FLAG
	STA	preread
	lxi	h,1		; INCREMENT TO NEXT EXPECTED UNALLOCATED RECORD
	dad	d
	shld	urecord
	mvi	a,0
	adc	b
	sta	urecord+2
	LDA	BLKMSK
	ana	l		; IS IT THE START OF A NEW BLOCK ?
	JRNZ	rwoper
ALLOC:	XRA	A		; NO LONGER WRITING AN UNALLOCATED BLOCK
	STA	UNALLOC
rwoper:
	; RLR - Ready List Root - points to the current process
	lhld	rlr
	mov	c,m
	inx	h
	mov	b,m	;BC=PDAdr, must be preserved throughout.
; get a buffer for this disk access...
 if lrubuf
	lixd	hsttop
	lxi	h,0
	shld	previous
	lhld	hsttop
	mov	a,h
	ora	l
	jnz	sd0
	lhld	fretop
	jmp	sd1
sd0:	ldx	e,link
	ldx	d,link+1
	ldx	l,hstpda
	ldx	h,hstpda+1
	ora	a
	dsbc	b	;compare P.D.Adr
	jz	sd2
	mov	a,d
	ora	e
	jz	sd3
	sixd	previous
	push	d
	popix
	jmp	sd0
sd3:	sixd	last
	lhld	fretop
	mov	a,h
	ora	l
	jz	sd4
sd1:	mov	e,m
	inx	h
	mov	d,m
	dcx	h
	sded	fretop
	jmp	setbuf
; found our buffer, may not be at top of list.
sd2:	lhld	previous	;patch previous bufr to skip this one,
	mov	a,h		;unless this is already first.
	ora	l
	jz	sd5
	mov	m,e
	inx	h
	mov	m,d
	pushix
	pop	h	; move this bufr to top of list (most recently used)
	jmp	setbuf1
; No existing buffer, no free buffers, must take last on list.
sd4:	lixd	previous	;no existing in-use bufr, no free bufr.
	mvix	0,link		;remove last buffer in list,
	mvix	0,link+1	;patching previous to be new end.
	liyd	last	;must flush this buffer, if write pending.
	call	flush	; ERROR will return directly to BDOS (pop h, ret)
	lhld	last	;
;	jmp	setbuf
setbuf: xchg
	lxi	h,hstdsk
	dad	d
	mvi	m,-1	;invalidate buffer.
	xchg
setbuf1:lded	hsttop	;used to be top of list, now make it 2nd.
	shld	hsttop	;put selected bufr at top of list.
	mov	m,e	;set link
	inx	h
	mov	m,d
	inx	h
	mov	m,c	;BC must still = P.D.Adr
	inx	h
	mov	m,b
sd5:
 else
	lxi	h,xxhdr
	shld	hsttop
 endif
	; BC is still PDAdr
	liyd	hsttop
	lda	@pdrv		; Calculate physical sector, etc
	sta	reqdsk
	call	getusrbnk
	lhld	@trk
	shld	reqtrk
	MVI	C,0		; CALCULATE PHYSICAL SECTOR
	LDA	blcode		; PHYSICAL SECTOR SIZE CODE
	ORA	A		; TEST FOR ZERO
	MOV	B,A
	lded	@sect
	JRZ	DBLOK3		; 128 BYTE SECTORS ?
DBLOK1: srlr	d		; DIVIDE BY 2
	rarr	e
	RARR	C		; SAVE OVERFLOW BITS
	DJNZ	DBLOK1		; AND CONTINUE IF BLOCKING STILL <> 0
	mov	b,a
DBLOK2: RLCR	C		; NOW RESTORE THE OVERFLOW BY
	DJNZ	DBLOK2		; ROTATING IT RIGHT
DBLOK3: MOV	A,C
	sta	blksec		; STORE IT
	sded	reqsec

chk1:	ldy	e,link		; next buffer, or 0000
	ldy	d,link+1	;
	mov	a,d
	ora	e
	jrz	chk2
	push	d
	popiy
	lxi	h,hstdsk
	dad	d
	lxi	d,reqdsk
	mvi	b,5
chk0:	ldax	d
	cmp	m
	jrnz	chk1
	inx	h
	inx	d
	djnz	chk0
	call	flush	;an error bumps us out here.
	siyd	previous	;save pointer
	lda	rdflg
	ora	a
	jrnz	chk3
	mviy	-1,hstdsk	;invalidate their buffer if we are writing.
chk3:	liyd	hsttop	;restore IY
	lda	dir0
	ora	a
	jrnz	readit	;don't bother to move data if a read is forced...
chk4:	call	flush		; must flush our buffer BEFORE changing data.
	ldy	l,hstbuf	; destination - our buffer
	ldy	h,hstbuf+1	;
	ldy	b,hstbnk	;
	lixd	previous
	ldx	e,hstbuf	; source
	ldx	d,hstbuf+1	;
	ldx	c,hstbnk	;
	mvi	a,1	; interrupts are enabled
	call	?xmove		;
	lxi	b,secsize	; put requested sector data in our buffer
	call	?move		;
	xra	a
	sta	preread
	jr	readit0
chk2:	liyd	hsttop	;restore IY
	lda	dir0
	ora	a
	jrnz	readit
chkbuf: lhld	hsttop
	lxi	d,hstdsk
	dad	d
	xchg
	lxi	h,reqdsk
	mvi	b,5
chkbuf1:ldax	d
	cmp	m
	jrnz	readit
	inx	h
	inx	d
	djnz	chkbuf1
	jr	noread		;  THEN NO NEED TO PRE-READ
readit: call	flush
readit0:lhld	hsttop		; SET UP NEW BUFFER PARAMETERS
	lxi	d,hstdsk
	dad	d
	xchg
	lxi	h,reqdsk	; set HSTDSK,HSTTRK,HSTSEC
	lxi	b,5		;
	ldir			;
	lhld	curmdl
	sty	l,hstmdl
	sty	h,hstmdl+1
	lhld	@cmode
	sty	l,hstmod
	sty	h,hstmod+1
	lda	preread
	ora	a
	cnz	pread		; READ THE SECTOR
	rnz		;stop here if error
noread: ldy	l,hstbuf	; POINT TO START OF SECTOR BUFFER
	ldy	h,hstbuf+1
	lxi	b,128
	lda	blksec		; POINT TO LOCATION OF CORRECT LOGICAL SECTOR
movit1: dcr	a
	jm	movit2
	dad	b
	jr	movit1
movit2:
	; TODO: need to handle possible common memory DMA
	lded	@dma		; POINT TO DMA
	lda	@dbnk
	xchg		;DE is source, HL is dest.
	mov	b,a		;B=dest. bank
	ldy	c,hstbnk	;C=source bank
	lda	rdflg		; IS IT A WRITE ?
	ora	a
	jrnz	movit3
	mov	a,c
	mov	c,b
	mov	b,a
	xchg			; SWITCH DIRECTION OF MOVE FOR WRITE
	mviy	true,pndwrt	; FLAG A PENDING WRITE
movit3: call	?xmove
	lxi	b,128
	mvi	a,1	; interrupts are enabled
	call	?move		; MOVE IT
	lda	defer		; CHECK FOR non-defered write
	ora	a
	cz	flush		; WRITE THE SECTOR IF IT IS
	xra	a		; FLAG NO ERROR
	ret			; RETURN TO BDOS

flushall:
 if lrubuf
	lded	hsttop
	mov	a,d
	ora	e
	rz		;no buffers in use.
	lxi	h,hsttop
	shld	previous
	lhld	rlr
	mov	c,m
	inx	h
	mov	b,m	;BC = PDAdr, must be preserved
fls0:	lxi	h,hstpda
	dad	d
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	ora	a
	dsbc	b	;compare P.D. adr
	jz	flush1
	xchg
	shld	previous
	mov	e,m
	inx	h
	mov	d,m
	mov	a,d
	ora	e
	jnz	fls0
	ret

; TODO: could there be more than one?
; might need to resume flushall...
flush1: push	d
	popiy
	lhld	previous
	ldy	a,link
	mov	m,a
	inx	h
	ldy	a,link+1
	mov	m,a
	lhld	fretop
	sty	l,link
	sty	h,link+1
	siyd	fretop
 else
	lxiy	xxhdr
 endif
	call	flush	; must handle stupid stack tricks
	ret

; Requires 2 ret adrs on stack, returns to imm caller on success,
; returns to caller's caller on error.
flush:	ldy	a,pndwrt
	ora	a
	rz
	mviy	false,pndwrt
	call	pwrite
	rz
	pop	h
	ret

; IY=buffer header
pread:	mvi	e,6	;read entry is +6
	jmp rw$common			; use common code

pwrite: mvi	e,9	;write entry is +9

rw$common:	;do any track/sector/side conversion...
;	xra	a
;	sta	@side
;	; Only "hard disk" supported...
;	ldy	l,hstmod
;	ldy	h,hstmod+1
;	bit	7,m	;floppy or hard-disk?
;	jrnz	rw0
rw0:
	mov	a,e	; read(6) or write(9)
	ldy	l,hstmdl
	ldy	h,hstmdl+1
calmod:
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	pchl		; leap to driver

@side:	ds	1		; current side of media (floppy only)
@trk:	ds	2		; current track number
@sect:	ds	2		; current sector number
@cnt:	db	0		; record count for multisector transfer
@spt:	ds	1
@rcnfg: ds	1

blcode: ds	1	;blocking code, PSH
offset: ds	2
blksec: ds	1
dir0:	ds	1
preread:ds	1
defer:	ds	1
unalloc:ds	1
urecord:ds	3
blkmsk: ds	1
rdflg:	ds	1

reqdsk: ds	1
reqtrk: ds	2
reqsec: ds	2

rlr:	dw	0
msegtbl: dw	0

hsttop:   dw	0
 if lrubuf
fretop:   dw	hsthdr
previous: dw	0
last:	  dw	0

numbuf	equ	16
@@bnk	equ	0
@@ set 0100h	;start of buffers in bank
		; (numbuf + 2) * secsize, buffers used,
		; must not overrun system. At 512b and 16 bufs,
		; this consumes 0100-2500, MP/M starts about A900.
hsthdr: rept	numbuf
	dw	$+hstlen ;Link
	dw	0	;hstpda - Process Descriptor Address
	dw	0	;hstmod
	db	false	;pndwrt
	db	-1	;hstdsk
	dw	0	;hsttrk
	dw	0	;hstsec
	dw	@@	;hstbuf
	db	@@bnk	;hstbnk
	dw	0	;hstmdl
@@ set @@+secsize
	endm
 endif
xxhdr:	dw	0	;Link - initially last in list.
	dw	0	;hstpda
	dw	0	;hstmod
	db	false	;pndwrt
	db	-1	;hstdsk
	dw	0	;hsttrk
	dw	0	;hstsec
	dw	@@	;hstbuf
	db	@@bnk	;hstbnk
	dw	0	;hstmdl
@@ set @@+secsize

; NOTE: this buffer can be used for reading only. (it is never flushed)
@scrcb: dw	0	;link - not used
	dw	0	;hstpda - not used
	dw	0	;hstmod
	db	false	;pndwrt - assumed always false
	db	-1	;hstdsk
	dw	0	;hsttrk
	dw	0	;hstsec
	dw	@@	;hstbuf
	db	@@bnk	;hstbnk
	dw	0	;hstmdl

	end
