; Command Help - '?'
	maclib	ram
	maclib	core
	maclib	core80

CR	equ	13
LF	equ	10
BEL	equ	7
CTLC	equ	3
DEL	equ	127

btmods	equ	2000h	; start of add-ons
bterom	equ	8000h	; size/end of full ROM

	org	0E100h	; above full-ROM boundary
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

init:	xra	a	; NC
	ret

exec:	call	crlf
	call	rominit
	mvi	a,'A'
	sta	curcmd
loop:	call	builtin
	jnc	gotit
	call	xtra1
	jc	nomore
gotit:	call	crlf
	lda	lines
	inr	a
	sta	lines
	cpi	23
	jnz	nomore
	lxi	h,more
	call	msgout
	call	waitcr
	jc	exit
	xra	a
	sta	lines
	lxi	h,xmore
	call	msgout
nomore:
	lda	curcmd
	inr	a
	sta	curcmd
	cpi	'Z'+1
	jc	loop
	; now extended cmd set...
	mvi	a,'a'
	sta	curcmd
loop1:
	call	xtra1
	jc	nomore1
gotit1:
	call	crlf
	lda	lines
	inr	a
	sta	lines
	cpi	23
	jnz	nomore1
	lxi	h,more
	call	msgout
	call	waitcr
	jc	exit
	xra	a
	sta	lines
	lxi	h,xmore
	call	msgout
nomore1:
	lda	curcmd
	inr	a
	sta	curcmd
	cpi	'z'+1
	jc	loop1

exit:
	call	romdein
	ret

rominit:
	di
	lda	ctl$F2
	sta	sav$F2
	ori	00001000b	; MEM1 on
	ani	11011111b	; ORG0 off
	out	0f2h	; enable full ROM
	ret

romdein:
	lda	sav$F2
	out	0f2h
	ei
	ret

curcmd:	db	0
lines:	db	0
sav$F2:	db	0

; cmd letter in 'curcmd'
; Return CY if not built-in (NC=printed help)
builtin:
	lda	curcmd
	lxi	h,cmdtab
	mvi	b,numcmd
chk1:	cmp	m
	inx	h
	jz	got1
	inx	h
	inx	h
	dcr b ! jnz chk1
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
; should be OK to use HL
xtra1:
	lxi	h,btmods
xtra10:
	mvi	l,2
	mov	a,m
	cpi	200	; boot modules < 200
	jc	xtra12
	lda	curcmd
	mvi	l,10
	cmp	m
	jnz	xtra12
	; found match
	push	h
	lxi	h,gap
	cpi	'a'	; upper/lower case?
	jc	nox
	lxi	h,gap2
	mvi	a,'X'
	call	chrout
	lda	curcmd
	ani	01011111b	; toupper
nox:
	call	chrout
	call	msgout	; gap
	pop	h
	mvi	l,16
	call	msgout
	ora	a	; NC
	ret
xtra12:
	mvi	l,0
	mov	d,m	; num pages
	mvi	e,0
	dad	d
	mov	a,h
	cpi	HIGH bterom
	jnc	xtra11
	mov	a,m	; num pages
	ora	a
	jz	xtra11
	cpi	0ffh
	jnz	xtra10
xtra11:	; end of modules... not found
	stc
	ret

gap:	db	' '
gap2:	db	' - ',0

; must not trash HL
chrout:	push	h
	lhld	conout
	xthl
	ret

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
	jmp	waitcr

; must be kept in-sync with table in h8core.asm:
cmdtab:
	db	'G' ! dw cmdgo	; Go
	db	'P' ! dw cmdpc	; Set PC
	db	'B' ! dw cmdboot; Boot
	db	'V' ! dw prtver	; Version of ROM
	db	'L' ! dw cmdlb	; List boot modules
	db	'H' ! dw cmdhb	; long list (Help) boot modules
;	db	'X' ! dw cmdx	; extended command set X_
	db	'Z' ! dw cmdsst	; single-step
numcmd	equ	($-cmdtab)/3

cmdgo:	db	'Go [addr]',0
cmdpc:	db	'Prog Counter [addr]',0
cmdboot: db	'Boot [options]',0
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
