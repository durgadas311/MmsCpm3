; Command Help - '?'
	maclib	ram
	maclib	core
	maclib	z180

CR	equ	13
LF	equ	10
BEL	equ	7
CTLC	equ	3
DEL	equ	127

btmods	equ	2000h	; start of add-ons
bterom	equ	8000h	; size/end of full ROM

; Z180 registers
mmu$cbr	equ	38h
mmu$bbr	equ	39h
mmu$cbar equ	3ah

	org	0E000h	; above full-ROM boundary
first:	db	HIGH (last-first)	; +0: num pages
	db	HIGH first		; +1: ORG page
	db	255,0	; +2,+3: phy drv base, num

	jmp	init	; +4: init entry
	jmp	exec	; +7: action entry

	db	'?'	; +10: Command letter
	db	-1	; +11: front panel key
	db	0	; +12: port, 0 if variable
	db	11111111b,11111111b,11111111b	; +13: FP display
	db	'Help',0	; +16: mnemonic string

init:
	xra	a	; NC
	ret

exec:
	call	crlf
	call	cpu$type
	sta	z180
	call	rominit
	mvi	a,'A'
	sta	curcmd
loop:
	call	builtin
	jrnc	gotit
	call	xtra1
	jrc	nomore
gotit:
	call	crlf
	lda	lines
	inr	a
	sta	lines
	cpi	23
	jrnz	nomore
	lxi	h,more
	call	msgout
	call	waitcr
	jrc	exit
	xra	a
	sta	lines
	lxi	h,xmore
	call	msgout
nomore:
	lda	curcmd
	inr	a
	sta	curcmd
	cpi	'Z'+1
	jrc	loop
	; now extended cmd set...
	mvi	a,'a'
	sta	curcmd
loop1:
	call	xtra1
	jrc	nomore1
gotit1:
	call	crlf
	lda	lines
	inr	a
	sta	lines
	cpi	23
	jrnz	nomore1
	lxi	h,more
	call	msgout
	call	waitcr
	jrc	exit
	xra	a
	sta	lines
	lxi	h,xmore
	call	msgout
nomore1:
	lda	curcmd
	inr	a
	sta	curcmd
	cpi	'z'+1
	jrc	loop1

exit:
	call	romdein
	ret

rominit:
	lda	z180
	ora	a
	jrz	romi0
	; map ROM F8000 into 4000
	lxi	h,btmods+4000h
	shld	mstart
	lxi	h,bterom+4000h
	shld	mend
	mvi	a,0f8h-04h
	out0	a,mmu$bbr
	ret
romi0:	di
	lxi	h,btmods
	shld	mstart
	lxi	h,bterom
	shld	mend
	lda	ctl$F2
	sta	sav$F2
	ori	00001000b	; MEM1 on
	ani	11011111b	; ORG0 off
	out	0f2h	; enable full ROM
	ret

romdein:
	lda	z180
	ora	a
	jrz	romd0
	xra	a
	out0	a,mmu$bbr
	ret
romd0:
	lda	sav$F2
	out	0f2h
	ei
	ret

curcmd:	db	0
lines:	db	0
sav$F2:	db	0
z180:	db	0
mstart:	dw	0	; mapped address of ROM image modules
mend:	dw	0	; mapped address of end of ROM

; cmd letter in 'curcmd'
; Return CY if not built-in (NC=printed help)
builtin:
	lda	curcmd
	lxi	h,cmdtab
	mvi	b,numcmd
chk1:	cmp	m
	inx	h
	jrz	got1
	inx	h
	inx	h
	djnz	chk1
	stc
	ret
got1:
	mov	e,m
	inx	h
	mov	d,m
	push	d	; help msg
	call	chrout
	lxi	h,gap
	call	msgout
	pop	h	; help msg
	call	msgout
	ora	a	; NC
	ret

; search for add-on command
xtra1:
	lixd	mstart
xtra10:
	ldx	a,+2
	cpi	200	; boot modules < 200
	jrc	xtra12
	lda	curcmd
	cmpx	+10
	jrnz	xtra12
	; found match
	lxi	h,gap
	cpi	'a'	; upper/lower case?
	jrc	nox
	lxi	h,gap2
	mvi	a,'X'
	call	chrout
	lda	curcmd
	ani	01011111b	; toupper
nox:
	call	chrout
	call	msgout	; gap
	pushix
	pop	h
	lxi	d,+16
	dad	d
	call	msgout
	ora	a	; NC
	ret
xtra12:
	ldx	d,+0	; num pages
	mvi	e,0
	dadx	d
	pushix
	pop	psw	; A=IXh
	lbcd	mend	; B=HIGH bterom
	cmp	b
	jrnc	xtra11
	ldx	a,+0	; num pages
	ora	a
	jrz	xtra11
	cpi	0ffh
	jrnz	xtra10
xtra11:	; end of modules... not found
	stc
	ret

gap:	db	' '
gap2:	db	' - ',0

chrout:	liyd	conout
	pciy

waitcr:
	call	conin
	cpi	CR
	rz
	cpi	DEL
	stc
	rz
	cpi	CTLC
	stc
	rz
	mvi	a,BEL
	call	chrout
	jr	waitcr

; returns FF if running on Z180, 00 if Z80
cpu$type:
	mvi	a,1
	mlt	b	; a.k.a. alt NEG on Z80
	sui	0ffh	; Z180: CY(02), Z80: NC(00)
	sbb	a	; Z180: FF, Z80: 00
	ret

; must be kept in-sync with table in h8core.asm:
cmdtab:
	db	'D' ! dw cmddmp	; Dump memory
	db	'G' ! dw cmdgo	; Go
	db	'S' ! dw cmdsub	; Substitute in memory
	db	'P' ! dw cmdpc	; Set PC
	db	'B' ! dw cmdboot; Boot
	db	'M' ! dw cmdmt	; Memory Test
	db	'V' ! dw prtver	; Version of ROM
	db	'L' ! dw cmdlb	; List boot modules
	db	'H' ! dw cmdhb	; long list (Help) boot modules
;	db	'X' ! dw cmdx	; extended command set X_
	db	'Z' ! dw cmdsst	; single-step
numcmd	equ	($-cmdtab)/3

cmddmp:	db	'Dump [addr]',0
cmdgo:	db	'Go [addr]',0
cmdsub:	db	'Substitute [addr]',0
cmdpc:	db	'Prog Counter [addr]',0
cmdboot: db	'Boot [options]',0
cmdmt:	db	'Mem test',0
prtver:	db	'Version',0
cmdlb:	db	'List boot modules',0
cmdhb:	db	'Help boot',0
cmdsst:	db	'Single-Step',0

more:	db	   'Press RETURN to continue: ',0
xmore:	db	CR,'                          ',CR,0

	rept	(($+0ffh) and 0ff00h)-$
	db	0ffh
	endm

last:	end
